using System;
using System.Diagnostics;
using System.Linq;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Serilog;
using Serilog.Context;
using Serilog.Core;
using Serilog.Events;
using Serilog.Formatting.Compact;

namespace Qbem.Observability.Logging
{
    /// <summary>
    /// Configuração de logs estruturados para .NET Core com Serilog
    ///
    /// Instalação:
    ///     dotnet add package Serilog.AspNetCore
    ///     dotnet add package Serilog.Sinks.Console
    ///     dotnet add package Serilog.Formatting.Compact
    ///     dotnet add package Serilog.Enrichers.Environment
    ///
    /// Uso no Program.cs:
    ///     var builder = WebApplication.CreateBuilder(args);
    ///     builder.Host.ConfigureStructuredLogging();
    ///
    ///     var app = builder.Build();
    ///     app.UseRequestLogging();
    /// </summary>
    public static class LoggingConfiguration
    {
        /// <summary>
        /// Configura Serilog com formato JSON estruturado.
        /// </summary>
        public static IHostBuilder ConfigureStructuredLogging(
            this IHostBuilder builder,
            string serviceName = null,
            string environment = null,
            string version = null)
        {
            serviceName ??= Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";
            environment ??= Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "development";
            version ??= Environment.GetEnvironmentVariable("APP_VERSION") ?? "unknown";

            return builder.UseSerilog((context, services, configuration) =>
            {
                configuration
                    .MinimumLevel.Information()
                    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
                    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
                    .MinimumLevel.Override("System", LogEventLevel.Warning)
                    .Enrich.FromLogContext()
                    .Enrich.WithProperty("service", serviceName)
                    .Enrich.WithProperty("environment", environment)
                    .Enrich.WithProperty("version", version)
                    .Enrich.WithMachineName()
                    .Enrich.WithThreadId()
                    .Enrich.With<PiiSanitizingEnricher>()
                    .WriteTo.Console(new CompactJsonFormatter());
            });
        }

        /// <summary>
        /// Adiciona middleware de logging de requisições HTTP.
        /// </summary>
        public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder app)
        {
            app.UseMiddleware<RequestLoggingMiddleware>();
            return app;
        }
    }

    /// <summary>
    /// Middleware para logging de requisições HTTP com contexto completo.
    /// </summary>
    public class RequestLoggingMiddleware
    {
        private readonly RequestDelegate _next;

        public RequestLoggingMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Gerar IDs de correlação
            var traceId = context.Request.Headers["traceparent"].FirstOrDefault()
                ?? Guid.NewGuid().ToString();
            var requestId = Guid.NewGuid().ToString();

            // Adicionar ao contexto de log
            using (LogContext.PushProperty("trace_id", traceId))
            using (LogContext.PushProperty("request_id", requestId))
            using (LogContext.PushProperty("method", context.Request.Method))
            using (LogContext.PushProperty("path", context.Request.Path))
            using (LogContext.PushProperty("client_ip", context.Connection.RemoteIpAddress?.ToString()))
            {
                Log.Information("Request started");

                var sw = Stopwatch.StartNew();

                try
                {
                    await _next(context);

                    sw.Stop();

                    Log.Information(
                        "Request completed with {StatusCode} in {DurationMs}ms",
                        context.Response.StatusCode,
                        sw.ElapsedMilliseconds
                    );
                }
                catch (Exception ex)
                {
                    sw.Stop();

                    Log.Error(
                        ex,
                        "Request failed with {StatusCode} in {DurationMs}ms",
                        context.Response.StatusCode,
                        sw.ElapsedMilliseconds
                    );

                    throw;
                }
            }
        }
    }

    /// <summary>
    /// Enricher para sanitizar PII de logs.
    /// </summary>
    public class PiiSanitizingEnricher : ILogEventEnricher
    {
        private static readonly string[] SensitiveKeys =
        {
            "password", "secret", "token", "apikey", "api_key",
            "authorization", "auth", "credential", "private_key"
        };

        public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
        {
            var propertiesToSanitize = logEvent.Properties
                .Where(p => ShouldSanitize(p.Key))
                .ToList();

            foreach (var property in propertiesToSanitize)
            {
                var sanitized = propertyFactory.CreateProperty(
                    property.Key,
                    "***REDACTED***"
                );
                logEvent.AddOrUpdateProperty(sanitized);
            }
        }

        private static bool ShouldSanitize(string propertyName)
        {
            return SensitiveKeys.Any(key =>
                propertyName.Contains(key, StringComparison.OrdinalIgnoreCase));
        }
    }

    /// <summary>
    /// Exemplo de uso em um controller.
    /// </summary>
    public class ExampleUsage
    {
        private readonly ILogger<ExampleUsage> _logger;

        public ExampleUsage(ILogger<ExampleUsage> logger)
        {
            _logger = logger;
        }

        public async Task ProcessOrderAsync(string orderId)
        {
            // Log simples
            _logger.LogInformation("Processing order {OrderId}", orderId);

            try
            {
                // Processar...
                await Task.Delay(100);

                // Log com contexto
                _logger.LogInformation(
                    "Order {OrderId} processed successfully",
                    orderId
                );
            }
            catch (Exception ex)
            {
                // Log de erro com exception
                _logger.LogError(
                    ex,
                    "Failed to process order {OrderId}",
                    orderId
                );
                throw;
            }
        }
    }
}
