"""
Configuração de Métricas para Python (Prometheus)
Usa prometheus-client para exportar métricas no formato Prometheus

Instalação:
    pip install prometheus-client

Uso:
    from metrics_config import setup_metrics, get_metrics

    setup_metrics()
    metrics = get_metrics()

    metrics.http_requests_total.labels(method="GET", status=200).inc()
"""

import os
import time
from typing import Optional

from prometheus_client import (
    REGISTRY,
    CollectorRegistry,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)


class MetricsCollector:
    """Coletor centralizado de métricas."""

    def __init__(self, registry: Optional[CollectorRegistry] = None):
        self.registry = registry or REGISTRY
        self.service_name = os.getenv("SERVICE_NAME", "unknown-service")

        # HTTP Metrics (RED)
        self.http_requests_total = Counter(
            "http_requests_total",
            "Total HTTP requests",
            ["service", "method", "path", "status_code"],
            registry=self.registry,
        )

        self.http_request_duration_seconds = Histogram(
            "http_request_duration_seconds",
            "HTTP request duration in seconds",
            ["service", "method", "path"],
            buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
            registry=self.registry,
        )

        self.http_requests_in_progress = Gauge(
            "http_requests_in_progress",
            "HTTP requests currently being processed",
            ["service", "method", "path"],
            registry=self.registry,
        )

        # Business Metrics
        self.orders_created_total = Counter(
            "orders_created_total",
            "Total orders created",
            ["service", "payment_method", "status"],
            registry=self.registry,
        )

        self.payment_amount_total = Counter(
            "payment_amount_total",
            "Total payment amount in cents",
            ["service", "currency"],
            registry=self.registry,
        )

        # Database Metrics
        self.db_query_duration_seconds = Histogram(
            "db_query_duration_seconds",
            "Database query duration in seconds",
            ["service", "database", "operation"],
            buckets=[0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1],
            registry=self.registry,
        )

        self.db_connections_active = Gauge(
            "db_connections_active",
            "Number of active database connections",
            ["service", "database"],
            registry=self.registry,
        )

        # Cache Metrics
        self.cache_hits_total = Counter(
            "cache_hits_total",
            "Total cache hits",
            ["service", "cache_name"],
            registry=self.registry,
        )

        self.cache_misses_total = Counter(
            "cache_misses_total",
            "Total cache misses",
            ["service", "cache_name"],
            registry=self.registry,
        )

        # Job Metrics
        self.job_processing_duration_seconds = Histogram(
            "job_processing_duration_seconds",
            "Job processing duration in seconds",
            ["service", "job_type"],
            buckets=[0.1, 0.5, 1, 5, 10, 30, 60, 120, 300],
            registry=self.registry,
        )

        self.job_processed_total = Counter(
            "job_processed_total",
            "Total jobs processed",
            ["service", "job_type", "status"],
            registry=self.registry,
        )


# Instância global
_metrics: Optional[MetricsCollector] = None


def setup_metrics(service_name: str = None) -> MetricsCollector:
    """
    Configura métricas para a aplicação.

    Args:
        service_name: Nome do serviço (default: SERVICE_NAME env var)

    Returns:
        Coletor de métricas
    """
    global _metrics

    _metrics = MetricsCollector()
    return _metrics


def get_metrics() -> MetricsCollector:
    """
    Obtém instância do coletor de métricas.

    Returns:
        Coletor de métricas

    Raises:
        RuntimeError: Se setup_metrics() não foi chamado
    """
    if _metrics is None:
        raise RuntimeError("Metrics not initialized. Call setup_metrics() first.")
    return _metrics


# FastAPI Integration
def create_fastapi_metrics_middleware(service_name: str = None):
    """
    Cria middleware de métricas para FastAPI.

    Usage:
        from fastapi import FastAPI
        from metrics_config import setup_metrics, create_fastapi_metrics_middleware

        app = FastAPI()
        setup_metrics()
        app.middleware("http")(create_fastapi_metrics_middleware())
    """
    from fastapi import Request

    service_name = service_name or os.getenv("SERVICE_NAME", "unknown-service")
    metrics = get_metrics()

    async def metrics_middleware(request: Request, call_next):
        method = request.method
        path = request.url.path

        # Normalizar path (remover IDs)
        path_template = normalize_path(path)

        # Incrementar gauge de requisições em andamento
        metrics.http_requests_in_progress.labels(
            service=service_name, method=method, path=path_template
        ).inc()

        start_time = time.time()

        try:
            response = await call_next(request)
            duration = time.time() - start_time

            # Métricas de sucesso
            metrics.http_requests_total.labels(
                service=service_name,
                method=method,
                path=path_template,
                status_code=response.status_code,
            ).inc()

            metrics.http_request_duration_seconds.labels(
                service=service_name, method=method, path=path_template
            ).observe(duration)

            return response

        except Exception:
            duration = time.time() - start_time

            # Métricas de erro
            metrics.http_requests_total.labels(
                service=service_name,
                method=method,
                path=path_template,
                status_code=500,
            ).inc()

            metrics.http_request_duration_seconds.labels(
                service=service_name, method=method, path=path_template
            ).observe(duration)

            raise

        finally:
            # Decrementar gauge
            metrics.http_requests_in_progress.labels(
                service=service_name, method=method, path=path_template
            ).dec()

    return metrics_middleware


def create_fastapi_metrics_endpoint():
    """
    Cria endpoint /metrics para FastAPI.

    Usage:
        from fastapi import FastAPI, Response
        from metrics_config import create_fastapi_metrics_endpoint

        app = FastAPI()
        app.get("/metrics")(create_fastapi_metrics_endpoint())
    """
    from fastapi import Response

    def metrics_endpoint():
        return Response(content=generate_latest(REGISTRY), media_type="text/plain")

    return metrics_endpoint


# Flask Integration
def setup_flask_metrics(app, service_name: str = None):
    """
    Configura métricas para Flask.

    Usage:
        from flask import Flask
        from metrics_config import setup_metrics, setup_flask_metrics

        app = Flask(__name__)
        setup_metrics()
        setup_flask_metrics(app)
    """
    from flask import g, request

    service_name = service_name or os.getenv("SERVICE_NAME", "unknown-service")
    metrics = get_metrics()

    @app.before_request
    def before_request():
        g.start_time = time.time()

        method = request.method
        path = normalize_path(request.path)

        metrics.http_requests_in_progress.labels(
            service=service_name, method=method, path=path
        ).inc()

    @app.after_request
    def after_request(response):
        duration = time.time() - g.start_time
        method = request.method
        path = normalize_path(request.path)

        metrics.http_requests_total.labels(
            service=service_name,
            method=method,
            path=path,
            status_code=response.status_code,
        ).inc()

        metrics.http_request_duration_seconds.labels(
            service=service_name, method=method, path=path
        ).observe(duration)

        metrics.http_requests_in_progress.labels(
            service=service_name, method=method, path=path
        ).dec()

        return response

    @app.route("/metrics")
    def metrics_route():
        from flask import Response

        return Response(generate_latest(REGISTRY), mimetype="text/plain")


# Utilities
def normalize_path(path: str) -> str:
    """
    Normaliza path para evitar alta cardinalidade.

    Args:
        path: Path da URL

    Returns:
        Path normalizado

    Example:
        /users/123 -> /users/:id
        /orders/abc-def-123 -> /orders/:id
    """
    import re

    # Substituir UUIDs
    path = re.sub(
        r"/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
        "/:id",
        path,
        flags=re.IGNORECASE,
    )

    # Substituir números
    path = re.sub(r"/\d+", "/:id", path)

    # Substituir alfanuméricos longos (prováveis IDs)
    path = re.sub(r"/[a-zA-Z0-9_-]{8,}", "/:id", path)

    return path


# Context Manager para medir duração
class timer:
    """
    Context manager para medir duração de operações.

    Usage:
        metrics = get_metrics()
        with timer(metrics.db_query_duration_seconds.labels(
            service="order-service",
            database="postgres",
            operation="SELECT"
        )):
            # Execute query
            result = db.execute("SELECT * FROM orders")
    """

    def __init__(self, histogram):
        self.histogram = histogram
        self.start_time = None

    def __enter__(self):
        self.start_time = time.time()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        duration = time.time() - self.start_time
        self.histogram.observe(duration)


# Exemplo de uso
if __name__ == "__main__":
    # Setup
    setup_metrics(service_name="example-service")
    metrics = get_metrics()

    # HTTP Metrics
    metrics.http_requests_total.labels(
        service="example-service", method="GET", path="/users/:id", status_code=200
    ).inc()

    metrics.http_request_duration_seconds.labels(
        service="example-service", method="GET", path="/users/:id"
    ).observe(0.123)

    # Business Metrics
    metrics.orders_created_total.labels(
        service="example-service", payment_method="credit_card", status="success"
    ).inc()

    metrics.payment_amount_total.labels(service="example-service", currency="BRL").inc(
        12990
    )

    # Database Metrics (com timer)
    with timer(
        metrics.db_query_duration_seconds.labels(
            service="example-service", database="postgres", operation="SELECT"
        )
    ):
        # Simular query
        time.sleep(0.05)

    # Cache Metrics
    metrics.cache_hits_total.labels(service="example-service", cache_name="redis").inc()

    # Job Metrics
    with timer(
        metrics.job_processing_duration_seconds.labels(
            service="example-service", job_type="send-email"
        )
    ):
        # Simular job
        time.sleep(0.1)

    metrics.job_processed_total.labels(
        service="example-service", job_type="send-email", status="success"
    ).inc()

    # Imprimir métricas
    print(generate_latest(REGISTRY).decode("utf-8"))
