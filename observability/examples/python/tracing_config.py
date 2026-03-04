"""
Configuração de Distributed Tracing para Python (OpenTelemetry)
Instrumentação automática e manual para rastreamento de requisições

Instalação:
    # Core
    pip install opentelemetry-api opentelemetry-sdk

    # Instrumentação automática
    pip install opentelemetry-instrumentation-fastapi
    pip install opentelemetry-instrumentation-requests
    pip install opentelemetry-instrumentation-sqlalchemy

    # Exporters
    pip install opentelemetry-exporter-otlp

Uso:
    from tracing_config import setup_tracing, get_tracer

    setup_tracing()
    tracer = get_tracer(__name__)
"""

import os
from typing import Optional

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace.sampling import (
    ParentBasedSampler,
    TraceIdRatioBased,
)
from opentelemetry.trace import Status, StatusCode


def setup_tracing(
    service_name: str = None,
    environment: str = None,
    version: str = None,
    otlp_endpoint: str = None,
    sampling_rate: float = None,
) -> TracerProvider:
    """
    Configura distributed tracing para a aplicação.

    Args:
        service_name: Nome do serviço (default: SERVICE_NAME env var)
        environment: Ambiente (default: ENVIRONMENT env var)
        version: Versão do serviço (default: APP_VERSION env var)
        otlp_endpoint: Endpoint do OTEL Collector (default: localhost:4317)
        sampling_rate: Taxa de sampling 0-1 (default: 0.1 = 10%)

    Returns:
        TracerProvider configurado
    """
    service_name = service_name or os.getenv("SERVICE_NAME", "unknown-service")
    environment = environment or os.getenv("ENVIRONMENT", "development")
    version = version or os.getenv("APP_VERSION", "unknown")
    otlp_endpoint = otlp_endpoint or os.getenv(
        "OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317"
    )
    sampling_rate = sampling_rate or float(os.getenv("OTEL_SAMPLING_RATE", "0.1"))

    # Configurar resource (identifica o serviço)
    resource = Resource.create(
        {
            "service.name": service_name,
            "service.version": version,
            "deployment.environment": environment,
        }
    )

    # Configurar sampler (parent-based com probabilistic)
    sampler = ParentBasedSampler(root=TraceIdRatioBased(sampling_rate))

    # Configurar provider
    provider = TracerProvider(resource=resource, sampler=sampler)
    trace.set_tracer_provider(provider)

    # Configurar exporter OTLP
    otlp_exporter = OTLPSpanExporter(endpoint=otlp_endpoint, insecure=True)

    # Adicionar span processor (batch para performance)
    provider.add_span_processor(BatchSpanProcessor(otlp_exporter))

    return provider


def get_tracer(name: str = __name__) -> trace.Tracer:
    """
    Obtém tracer para instrumentação manual.

    Args:
        name: Nome do tracer (geralmente __name__)

    Returns:
        Tracer configurado

    Example:
        tracer = get_tracer(__name__)
        with tracer.start_as_current_span("process_order"):
            # Processar pedido
            pass
    """
    return trace.get_tracer(name)


# FastAPI Auto-Instrumentation
def setup_fastapi_tracing(app):
    """
    Configura instrumentação automática para FastAPI.

    Usage:
        from fastapi import FastAPI
        from tracing_config import setup_tracing, setup_fastapi_tracing

        app = FastAPI()
        setup_tracing()
        setup_fastapi_tracing(app)
    """
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

    FastAPIInstrumentor.instrument_app(app)


# Requests Auto-Instrumentation
def setup_requests_tracing():
    """
    Configura instrumentação automática para requests HTTP.

    Usage:
        from tracing_config import setup_requests_tracing

        setup_requests_tracing()
        # Agora todas chamadas com requests() são instrumentadas
        import requests
        response = requests.get("https://api.example.com")
    """
    from opentelemetry.instrumentation.requests import RequestsInstrumentor

    RequestsInstrumentor().instrument()


# SQLAlchemy Auto-Instrumentation
def setup_sqlalchemy_tracing(engine):
    """
    Configura instrumentação automática para SQLAlchemy.

    Usage:
        from sqlalchemy import create_engine
        from tracing_config import setup_sqlalchemy_tracing

        engine = create_engine("postgresql://...")
        setup_sqlalchemy_tracing(engine)
    """
    from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

    SQLAlchemyInstrumentor().instrument(
        engine=engine,
        enable_commenter=True,  # Adiciona trace_id em comentários SQL
    )


# Manual Instrumentation
def trace_function(span_name: str = None):
    """
    Decorator para instrumentar funções automaticamente.

    Args:
        span_name: Nome do span (default: nome da função)

    Usage:
        @trace_function("process_payment")
        def process_payment(order_id: str):
            # Função é automaticamente instrumentada
            pass
    """

    def decorator(func):
        import functools

        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            tracer = get_tracer(func.__module__)
            name = span_name or func.__name__

            with tracer.start_as_current_span(name) as span:
                try:
                    result = func(*args, **kwargs)
                    span.set_status(Status(StatusCode.OK))
                    return result
                except Exception as e:
                    span.record_exception(e)
                    span.set_status(Status(StatusCode.ERROR, str(e)))
                    raise

        return wrapper

    return decorator


# Context Propagation Utilities
def inject_trace_context(headers: dict) -> dict:
    """
    Injeta contexto de trace em headers HTTP.

    Args:
        headers: Dicionário de headers

    Returns:
        Headers com traceparent e tracestate

    Usage:
        import requests
        from tracing_config import inject_trace_context

        headers = {"Authorization": "Bearer token"}
        headers = inject_trace_context(headers)
        response = requests.get("https://api.example.com", headers=headers)
    """
    from opentelemetry.propagate import inject

    inject(headers)
    return headers


def extract_trace_context(headers: dict):
    """
    Extrai contexto de trace de headers HTTP.

    Args:
        headers: Dicionário de headers

    Usage:
        from tracing_config import extract_trace_context

        # Em um consumer Kafka, por exemplo
        headers = message.headers()
        extract_trace_context(headers)
    """
    from opentelemetry.propagate import extract

    return extract(headers)


# Exemplo de uso completo
if __name__ == "__main__":
    import time

    # Setup tracing
    setup_tracing(
        service_name="example-service",
        environment="development",
        version="1.0.0",
        sampling_rate=1.0,  # 100% para exemplo
    )

    # Obter tracer
    tracer = get_tracer(__name__)

    # Span manual básico
    with tracer.start_as_current_span("example_operation") as span:
        span.set_attribute("user_id", "u_123")
        span.set_attribute("operation", "create_order")

        time.sleep(0.1)

        span.add_event("order_validated", {"order_id": "ord_456"})

        time.sleep(0.05)

    # Span aninhado
    with tracer.start_as_current_span("parent_operation") as parent:
        parent.set_attribute("parent_attr", "value")

        with tracer.start_as_current_span("child_operation") as child:
            child.set_attribute("child_attr", "value")
            time.sleep(0.02)

    # Span com erro
    with tracer.start_as_current_span("operation_with_error") as span:
        try:
            raise ValueError("Something went wrong")
        except Exception as e:
            span.record_exception(e)
            span.set_status(Status(StatusCode.ERROR, str(e)))

    # Usando decorator
    @trace_function("decorated_function")
    def my_function(param: str):
        time.sleep(0.01)
        return f"Processed: {param}"

    result = my_function("test")

    print("Tracing example completed!")
    print("Spans foram enviados para o OTEL Collector")
