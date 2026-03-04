using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OpenTelemetry;
using OpenTelemetry.Context.Propagation;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

namespace Qbem.Observability.Tracing
{
    /// <summary>
    /// Configuração de Distributed Tracing para .NET Core com OpenTelemetry
    ///
    /// Instalação:
    ///     dotnet add package OpenTelemetry
    ///     dotnet add package OpenTelemetry.Extensions.Hosting
    ///     dotnet add package OpenTelemetry.Instrumentation.AspNetCore
    ///     dotnet add package OpenTelemetry.Instrumentation.Http
    ///     dotnet add package OpenTelemetry.Instrumentation.SqlClient
    ///     dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
    ///
    /// Uso no Program.cs:
    ///     var builder = WebApplication.CreateBuilder(args);
    ///     builder.Services.AddDistributedTracing();
    /// </summary>
    public static class TracingConfiguration
    {
        /// <summary>
        /// Configura distributed tracing com OpenTelemetry.
        /// </summary>
        public static IServiceCollection AddDistributedTracing(
            this IServiceCollection services,
            string serviceName = null,
            string environment = null,
            string version = null)
        {
            serviceName ??= Environment.GetEnvironmentVariable("SERVICE_NAME") ?? "unknown-service";
            environment ??= Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "development";
            version ??= Environment.GetEnvironmentVariable("APP_VERSION") ?? "unknown";

            var samplingRate = double.Parse(Environment.GetEnvironmentVariable("OTEL_SAMPLING_RATE") ?? "0.1");
            var otlpEndpoint = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT") ?? "http://localhost:4317";

            services.AddOpenTelemetry()
                .ConfigureResource(resource => resource
                    .AddService(serviceName: serviceName, serviceVersion: version)
                    .AddAttributes(new[]
                    {
                        new KeyValuePair<string, object>("deployment.environment", environment)
                    }))
                .WithTracing(tracing => tracing
                    // Instrumentação automática
                    .AddAspNetCoreInstrumentation(options =>
                    {
                        options.RecordException = true;
                        options.EnrichWithHttpRequest = (activity, httpRequest) =>
                        {
                            activity.SetTag("http.client_ip", httpRequest.HttpContext.Connection.RemoteIpAddress?.ToString());
                            activity.SetTag("http.user_agent", httpRequest.Headers["User-Agent"].ToString());
                        };
                        options.EnrichWithHttpResponse = (activity, httpResponse) =>
                        {
                            activity.SetTag("http.response_content_length", httpResponse.ContentLength);
                        };
                    })
                    .AddHttpClientInstrumentation(options =>
                    {
                        options.RecordException = true;
                    })
                    .AddSqlClientInstrumentation(options =>
                    {
                        options.SetDbStatementForText = true;
                        options.RecordException = true;
                        options.EnableConnectionLevelAttributes = true;
                    })
                    // Sources customizados
                    .AddSource("OrderService")
                    .AddSource("PaymentService")
                    // Sampling (parent-based com probabilistic)
                    .SetSampler(new ParentBasedSampler(new TraceIdRatioBasedSampler(samplingRate)))
                    // Exporter OTLP
                    .AddOtlpExporter(options =>
                    {
                        options.Endpoint = new Uri(otlpEndpoint);
                    })
                );

            return services;
        }
    }

    /// <summary>
    /// Helpers para instrumentação manual.
    /// </summary>
    public static class TracingHelpers
    {
        private static readonly TextMapPropagator Propagator = Propagators.DefaultTextMapPropagator;

        /// <summary>
        /// Injeta contexto de trace em headers HTTP.
        /// </summary>
        public static void InjectTraceContext(HttpRequestMessage request)
        {
            var activity = Activity.Current;
            if (activity == null) return;

            Propagator.Inject(
                new PropagationContext(activity.Context, Baggage.Current),
                request,
                (r, key, value) => r.Headers.Add(key, value)
            );
        }

        /// <summary>
        /// Extrai contexto de trace de headers HTTP.
        /// </summary>
        public static PropagationContext ExtractTraceContext(HttpRequest request)
        {
            return Propagator.Extract(
                default,
                request.Headers,
                (headers, key) =>
                {
                    if (headers.TryGetValue(key, out var value))
                    {
                        return new[] { value.ToString() };
                    }
                    return Array.Empty<string>();
                }
            );
        }
    }

    /// <summary>
    /// Exemplo de uso em um service.
    /// </summary>
    public class OrderService
    {
        private static readonly ActivitySource ActivitySource = new("OrderService");
        private readonly HttpClient _httpClient;

        public OrderService(IHttpClientFactory httpClientFactory)
        {
            _httpClient = httpClientFactory.CreateClient();
        }

        /// <summary>
        /// Exemplo de instrumentação manual com span customizado.
        /// </summary>
        public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
        {
            // Criar span manual
            using var activity = ActivitySource.StartActivity("create_order", ActivityKind.Internal);

            // Adicionar atributos
            activity?.SetTag("order.user_id", request.UserId);
            activity?.SetTag("order.amount", request.Amount);
            activity?.SetTag("order.payment_method", request.PaymentMethod);

            try
            {
                // Validar pedido
                await ValidateOrderAsync(request);

                // Processar pagamento (span aninhado)
                var payment = await ProcessPaymentAsync(request);

                // Adicionar evento
                activity?.AddEvent(new ActivityEvent("order_validated",
                    tags: new ActivityTagsCollection
                    {
                        { "validation.status", "success" }
                    }));

                // Salvar pedido
                var order = await SaveOrderAsync(request, payment);

                // Marcar como sucesso
                activity?.SetStatus(ActivityStatusCode.Ok);

                return order;
            }
            catch (Exception ex)
            {
                // Registrar exception
                activity?.RecordException(ex);
                activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
                throw;
            }
        }

        /// <summary>
        /// Span aninhado para processamento de pagamento.
        /// </summary>
        private async Task<Payment> ProcessPaymentAsync(CreateOrderRequest request)
        {
            using var activity = ActivitySource.StartActivity("process_payment", ActivityKind.Internal);

            activity?.SetTag("payment.method", request.PaymentMethod);
            activity?.SetTag("payment.amount", request.Amount);

            // Simular chamada para gateway de pagamento
            var paymentRequest = new HttpRequestMessage(HttpMethod.Post, "https://payment.qbem.net.br/charge");

            // Injetar contexto de trace
            TracingHelpers.InjectTraceContext(paymentRequest);

            paymentRequest.Content = JsonContent.Create(new
            {
                order_id = Guid.NewGuid().ToString(),
                amount = request.Amount,
                payment_method = request.PaymentMethod
            });

            var response = await _httpClient.SendAsync(paymentRequest);
            response.EnsureSuccessStatusCode();

            activity?.SetTag("payment.status", "success");

            return new Payment { Id = Guid.NewGuid().ToString() };
        }

        private async Task ValidateOrderAsync(CreateOrderRequest request)
        {
            using var activity = ActivitySource.StartActivity("validate_order", ActivityKind.Internal);

            // Simular validação
            await Task.Delay(10);

            if (request.Amount <= 0)
            {
                var ex = new ArgumentException("Amount must be greater than zero");
                activity?.RecordException(ex);
                activity?.SetStatus(ActivityStatusCode.Error, "Invalid amount");
                throw ex;
            }
        }

        private async Task<Order> SaveOrderAsync(CreateOrderRequest request, Payment payment)
        {
            using var activity = ActivitySource.StartActivity("save_order", ActivityKind.Internal);

            // Simular save no banco (o SqlClient já é instrumentado automaticamente)
            await Task.Delay(50);

            return new Order
            {
                Id = Guid.NewGuid().ToString(),
                UserId = request.UserId,
                Amount = request.Amount,
                PaymentId = payment.Id
            };
        }
    }

    /// <summary>
    /// Exemplo de uso com Kafka (mensageria).
    /// </summary>
    public class EventPublisher
    {
        private static readonly ActivitySource ActivitySource = new("EventPublisher");
        private static readonly TextMapPropagator Propagator = Propagators.DefaultTextMapPropagator;

        /// <summary>
        /// Publica evento no Kafka com propagação de contexto.
        /// </summary>
        public async Task PublishOrderCreatedAsync(string orderId)
        {
            using var activity = ActivitySource.StartActivity("kafka_publish", ActivityKind.Producer);

            activity?.SetTag("messaging.system", "kafka");
            activity?.SetTag("messaging.destination", "orders-events");
            activity?.SetTag("messaging.operation", "publish");
            activity?.SetTag("messaging.message_id", orderId);

            // Headers para propagação (simulado)
            var headers = new Dictionary<string, string>();

            Propagator.Inject(
                new PropagationContext(activity?.Context ?? default, Baggage.Current),
                headers,
                (dict, key, value) => dict[key] = value
            );

            // Publicar mensagem (aqui você usaria seu cliente Kafka real)
            await Task.Delay(10); // Simular publish

            activity?.SetStatus(ActivityStatusCode.Ok);
        }

        /// <summary>
        /// Consome evento do Kafka com extração de contexto.
        /// </summary>
        public async Task ProcessOrderEventAsync(Dictionary<string, string> headers, string payload)
        {
            // Extrair contexto do trace
            var parentContext = Propagator.Extract(
                default,
                headers,
                (dict, key) =>
                {
                    if (dict.TryGetValue(key, out var value))
                    {
                        return new[] { value };
                    }
                    return Array.Empty<string>();
                }
            );

            // Criar span como filho do trace original
            using var activity = ActivitySource.StartActivity(
                "kafka_consume",
                ActivityKind.Consumer,
                parentContext.ActivityContext
            );

            activity?.SetTag("messaging.system", "kafka");
            activity?.SetTag("messaging.operation", "consume");

            // Processar mensagem
            await Task.Delay(100);

            activity?.SetStatus(ActivityStatusCode.Ok);
        }
    }

    /// <summary>
    /// Exemplo de background job com tracing.
    /// </summary>
    public class EmailBackgroundJob
    {
        private static readonly ActivitySource ActivitySource = new("EmailBackgroundJob");

        public async Task ProcessAsync(string jobId, string userId)
        {
            // Criar novo trace (root span)
            using var activity = ActivitySource.StartActivity("process_email_job", ActivityKind.Internal);

            activity?.SetTag("job.id", jobId);
            activity?.SetTag("job.type", "send_email");
            activity?.SetTag("user.id", userId);

            try
            {
                // Processar job
                await Task.Delay(200);

                activity?.AddEvent(new ActivityEvent("email_sent"));
                activity?.SetStatus(ActivityStatusCode.Ok);
            }
            catch (Exception ex)
            {
                activity?.RecordException(ex);
                activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
                throw;
            }
        }
    }

    // Classes auxiliares
    public class Order
    {
        public string Id { get; set; }
        public string UserId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentId { get; set; }
    }

    public class Payment
    {
        public string Id { get; set; }
    }

    public class CreateOrderRequest
    {
        public string UserId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; }
    }
}
