using System;
using System.Diagnostics;
using System.Linq;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Prometheus;

namespace Qbem.Observability.Metrics
{
    /// <summary>
    /// Configuração de Métricas para .NET Core com prometheus-net
    ///
    /// Instalação:
    ///     dotnet add package prometheus-net
    ///     dotnet add package prometheus-net.AspNetCore
    ///
    /// Uso no Program.cs:
    ///     var builder = WebApplication.CreateBuilder(args);
    ///     builder.Services.AddMetrics();
    ///
    ///     var app = builder.Build();
    ///     app.UseHttpMetrics();
    ///     app.MapMetrics();
    /// </summary>
    public static class MetricsConfiguration
    {
        private static string ServiceName => Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";

        /// <summary>
        /// Adiciona métricas customizadas ao container de DI.
        /// </summary>
        public static IServiceCollection AddMetrics(this IServiceCollection services)
        {
            services.AddSingleton<MetricsCollector>();
            return services;
        }

        /// <summary>
        /// Habilita métricas HTTP automáticas.
        /// </summary>
        public static IApplicationBuilder UseHttpMetrics(this IApplicationBuilder app)
        {
            app.UseMiddleware<MetricsMiddleware>();
            return app;
        }
    }

    /// <summary>
    /// Coletor centralizado de métricas.
    /// </summary>
    public class MetricsCollector
    {
        private readonly string _serviceName;

        // HTTP Metrics (RED)
        public Counter HttpRequestsTotal { get; }
        public Histogram HttpRequestDurationSeconds { get; }
        public Gauge HttpRequestsInProgress { get; }

        // Business Metrics
        public Counter OrdersCreatedTotal { get; }
        public Counter PaymentAmountTotal { get; }

        // Database Metrics
        public Histogram DbQueryDurationSeconds { get; }
        public Gauge DbConnectionsActive { get; }

        // Cache Metrics
        public Counter CacheHitsTotal { get; }
        public Counter CacheMissesTotal { get; }

        // Job Metrics
        public Histogram JobProcessingDurationSeconds { get; }
        public Counter JobProcessedTotal { get; }

        public MetricsCollector()
        {
            _serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";

            // HTTP Metrics
            HttpRequestsTotal = Prometheus.Metrics.CreateCounter(
                "http_requests_total",
                "Total HTTP requests",
                new CounterConfiguration
                {
                    LabelNames = new[] { "service", "method", "path", "status_code" }
                }
            );

            HttpRequestDurationSeconds = Prometheus.Metrics.CreateHistogram(
                "http_request_duration_seconds",
                "HTTP request duration in seconds",
                new HistogramConfiguration
                {
                    LabelNames = new[] { "service", "method", "path" },
                    Buckets = new[] { 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10 }
                }
            );

            HttpRequestsInProgress = Prometheus.Metrics.CreateGauge(
                "http_requests_in_progress",
                "HTTP requests currently being processed",
                new GaugeConfiguration
                {
                    LabelNames = new[] { "service", "method", "path" }
                }
            );

            // Business Metrics
            OrdersCreatedTotal = Prometheus.Metrics.CreateCounter(
                "orders_created_total",
                "Total orders created",
                new CounterConfiguration
                {
                    LabelNames = new[] { "service", "payment_method", "status" }
                }
            );

            PaymentAmountTotal = Prometheus.Metrics.CreateCounter(
                "payment_amount_total",
                "Total payment amount in cents",
                new CounterConfiguration
                {
                    LabelNames = new[] { "service", "currency" }
                }
            );

            // Database Metrics
            DbQueryDurationSeconds = Prometheus.Metrics.CreateHistogram(
                "db_query_duration_seconds",
                "Database query duration in seconds",
                new HistogramConfiguration
                {
                    LabelNames = new[] { "service", "database", "operation" },
                    Buckets = new[] { 0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1 }
                }
            );

            DbConnectionsActive = Prometheus.Metrics.CreateGauge(
                "db_connections_active",
                "Number of active database connections",
                new GaugeConfiguration
                {
                    LabelNames = new[] { "service", "database" }
                }
            );

            // Cache Metrics
            CacheHitsTotal = Prometheus.Metrics.CreateCounter(
                "cache_hits_total",
                "Total cache hits",
                new CounterConfiguration
                {
                    LabelNames = new[] { "service", "cache_name" }
                }
            );

            CacheMissesTotal = Prometheus.Metrics.CreateCounter(
                "cache_misses_total",
                "Total cache misses",
                new CounterConfiguration
                {
                    LabelNames = new[] { "service", "cache_name" }
                }
            );

            // Job Metrics
            JobProcessingDurationSeconds = Prometheus.Metrics.CreateHistogram(
                "job_processing_duration_seconds",
                "Job processing duration in seconds",
                new HistogramConfiguration
                {
                    LabelNames = new[] { "service", "job_type" },
                    Buckets = new[] { 0.1, 0.5, 1, 5, 10, 30, 60, 120, 300 }
                }
            );

            JobProcessedTotal = Prometheus.Metrics.CreateCounter(
                "job_processed_total",
                "Total jobs processed",
                new CounterConfiguration
                {
                    LabelNames = new[] { "service", "job_type", "status" }
                }
            );
        }
    }

    /// <summary>
    /// Middleware para coletar métricas HTTP.
    /// </summary>
    public class MetricsMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly MetricsCollector _metrics;
        private readonly string _serviceName;

        public MetricsMiddleware(RequestDelegate next, MetricsCollector metrics)
        {
            _next = next;
            _metrics = metrics;
            _serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var method = context.Request.Method;
            var path = NormalizePath(context.Request.Path);

            // Incrementar gauge
            _metrics.HttpRequestsInProgress
                .WithLabels(_serviceName, method, path)
                .Inc();

            var sw = Stopwatch.StartNew();

            try
            {
                await _next(context);

                sw.Stop();

                // Métricas de sucesso
                _metrics.HttpRequestsTotal
                    .WithLabels(_serviceName, method, path, context.Response.StatusCode.ToString())
                    .Inc();

                _metrics.HttpRequestDurationSeconds
                    .WithLabels(_serviceName, method, path)
                    .Observe(sw.Elapsed.TotalSeconds);
            }
            catch
            {
                sw.Stop();

                // Métricas de erro
                _metrics.HttpRequestsTotal
                    .WithLabels(_serviceName, method, path, "500")
                    .Inc();

                _metrics.HttpRequestDurationSeconds
                    .WithLabels(_serviceName, method, path)
                    .Observe(sw.Elapsed.TotalSeconds);

                throw;
            }
            finally
            {
                // Decrementar gauge
                _metrics.HttpRequestsInProgress
                    .WithLabels(_serviceName, method, path)
                    .Dec();
            }
        }

        private static string NormalizePath(string path)
        {
            if (string.IsNullOrEmpty(path))
                return "/";

            // Substituir UUIDs
            path = System.Text.RegularExpressions.Regex.Replace(
                path,
                @"/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
                "/:id",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase
            );

            // Substituir números
            path = System.Text.RegularExpressions.Regex.Replace(path, @"/\d+", "/:id");

            // Substituir IDs longos
            path = System.Text.RegularExpressions.Regex.Replace(path, @"/[a-zA-Z0-9_-]{8,}", "/:id");

            return path;
        }
    }

    /// <summary>
    /// Exemplo de uso em um service.
    /// </summary>
    public class OrderService
    {
        private readonly MetricsCollector _metrics;
        private readonly string _serviceName;

        public OrderService(MetricsCollector metrics)
        {
            _metrics = metrics;
            _serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";
        }

        public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
        {
            using (_metrics.DbQueryDurationSeconds
                .WithLabels(_serviceName, "postgres", "INSERT")
                .NewTimer())
            {
                // Simular insert no banco
                await Task.Delay(50);
            }

            // Registrar métricas de negócio
            _metrics.OrdersCreatedTotal
                .WithLabels(_serviceName, request.PaymentMethod, "success")
                .Inc();

            _metrics.PaymentAmountTotal
                .WithLabels(_serviceName, request.Currency)
                .Inc(request.Amount);

            return new Order { Id = Guid.NewGuid().ToString() };
        }

        public async Task<User> GetUserFromCacheAsync(string userId)
        {
            // Simular cache lookup
            var inCache = new Random().Next(0, 2) == 1;

            if (inCache)
            {
                _metrics.CacheHitsTotal
                    .WithLabels(_serviceName, "redis")
                    .Inc();

                return new User { Id = userId };
            }

            _metrics.CacheMissesTotal
                .WithLabels(_serviceName, "redis")
                .Inc();

            // Buscar do banco
            using (_metrics.DbQueryDurationSeconds
                .WithLabels(_serviceName, "postgres", "SELECT")
                .NewTimer())
            {
                await Task.Delay(100);
            }

            return new User { Id = userId };
        }
    }

    /// <summary>
    /// Exemplo de uso em background job.
    /// </summary>
    public class EmailJob
    {
        private readonly MetricsCollector _metrics;
        private readonly string _serviceName;

        public EmailJob(MetricsCollector metrics)
        {
            _metrics = metrics;
            _serviceName = Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";
        }

        public async Task ProcessAsync()
        {
            using (_metrics.JobProcessingDurationSeconds
                .WithLabels(_serviceName, "send-email")
                .NewTimer())
            {
                try
                {
                    // Processar job
                    await Task.Delay(100);

                    _metrics.JobProcessedTotal
                        .WithLabels(_serviceName, "send-email", "success")
                        .Inc();
                }
                catch
                {
                    _metrics.JobProcessedTotal
                        .WithLabels(_serviceName, "send-email", "failed")
                        .Inc();

                    throw;
                }
            }
        }
    }

    // Classes auxiliares
    public class Order
    {
        public string Id { get; set; }
    }

    public class User
    {
        public string Id { get; set; }
    }

    public class CreateOrderRequest
    {
        public string PaymentMethod { get; set; }
        public string Currency { get; set; }
        public long Amount { get; set; }
    }
}
