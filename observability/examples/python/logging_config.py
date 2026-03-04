"""
Configuração de Logs Estruturados para Python
Usa structlog + python-json-logger para logs em JSON

Instalação:
    pip install structlog python-json-logger

Uso:
    from logging_config import setup_logging, get_logger

    setup_logging()
    logger = get_logger(__name__)

    logger.info("user_logged_in", user_id="u_123", ip="192.168.1.1")
"""

import logging
import os
import sys
import time
import uuid
from typing import Any, Dict

import structlog
from pythonjsonlogger import jsonlogger


def setup_logging(
    service_name: str = None,
    environment: str = None,
    version: str = None,
    log_level: str = None,
) -> None:
    """
    Configura logging estruturado para a aplicação.

    Args:
        service_name: Nome do serviço (default: SERVICE_NAME env var)
        environment: Ambiente (default: ENVIRONMENT env var)
        version: Versão do serviço (default: APP_VERSION env var)
        log_level: Nível de log (default: LOG_LEVEL env var ou INFO)
    """
    service_name = service_name or os.getenv("SERVICE_NAME", "unknown-service")
    environment = environment or os.getenv("ENVIRONMENT", "development")
    version = version or os.getenv("APP_VERSION", "unknown")
    log_level = log_level or os.getenv("LOG_LEVEL", "INFO")

    # Configurar handler JSON
    log_handler = logging.StreamHandler(sys.stdout)

    # Formato JSON
    formatter = jsonlogger.JsonFormatter(
        "%(timestamp)s %(level)s %(message)s %(service)s %(environment)s %(version)s",
        timestamp=True,
    )
    log_handler.setFormatter(formatter)

    # Configurar root logger
    root_logger = logging.getLogger()
    root_logger.addHandler(log_handler)
    root_logger.setLevel(log_level.upper())

    # Configurar structlog
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso", utc=True),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )


def get_logger(name: str = None, **initial_context: Any) -> structlog.BoundLogger:
    """
    Obtém logger estruturado com contexto inicial.

    Args:
        name: Nome do logger (geralmente __name__)
        **initial_context: Contexto adicional para todos os logs

    Returns:
        Logger estruturado

    Example:
        logger = get_logger(__name__, service="order-service")
        logger.info("order_created", order_id="ord_123")
    """
    logger = structlog.get_logger(name)

    # Adicionar contexto base
    context = {
        "service": os.getenv("SERVICE_NAME", "unknown-service"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "version": os.getenv("APP_VERSION", "unknown"),
        **initial_context,
    }

    return logger.bind(**context)


def sanitize_pii(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Sanitiza PII de dados antes de logar.

    Args:
        data: Dicionário com dados potencialmente sensíveis

    Returns:
        Dicionário com dados mascarados
    """
    sensitive_keys = [
        "password",
        "secret",
        "token",
        "apikey",
        "api_key",
        "authorization",
        "auth",
        "credential",
        "private_key",
    ]

    sanitized = {}
    for key, value in data.items():
        key_lower = key.lower()

        if any(sensitive in key_lower for sensitive in sensitive_keys):
            sanitized[key] = "***REDACTED***"
        elif isinstance(value, dict):
            sanitized[key] = sanitize_pii(value)
        elif key_lower in ["cpf", "ssn", "tax_id"]:
            # Mascarar parcialmente
            sanitized[key] = f"***{str(value)[-4:]}" if value else None
        elif key_lower == "email":
            # Mascarar email
            if value and "@" in str(value):
                parts = str(value).split("@")
                sanitized[key] = f"{parts[0][:2]}***@{parts[1]}"
            else:
                sanitized[key] = value
        else:
            sanitized[key] = value

    return sanitized


# FastAPI Middleware
def create_fastapi_logging_middleware():
    """
    Cria middleware de logging para FastAPI.

    Usage:
        from fastapi import FastAPI
        from logging_config import create_fastapi_logging_middleware

        app = FastAPI()
        app.middleware("http")(create_fastapi_logging_middleware())
    """
    from fastapi import Request

    logger = get_logger("http")

    async def logging_middleware(request: Request, call_next):
        # Gerar IDs de correlação
        trace_id = request.headers.get("traceparent", str(uuid.uuid4()))
        request_id = str(uuid.uuid4())

        # Logger com contexto
        log = logger.bind(
            trace_id=trace_id,
            request_id=request_id,
            method=request.method,
            path=request.url.path,
            client_ip=request.client.host if request.client else None,
        )

        log.info("request_started")

        start_time = time.time()
        try:
            response = await call_next(request)
            duration_ms = (time.time() - start_time) * 1000

            log.info(
                "request_completed",
                status_code=response.status_code,
                duration_ms=round(duration_ms, 2),
            )

            return response

        except Exception as e:
            duration_ms = (time.time() - start_time) * 1000

            log.error(
                "request_failed",
                error=str(e),
                error_type=type(e).__name__,
                duration_ms=round(duration_ms, 2),
                exc_info=True,
            )
            raise

    return logging_middleware


# Flask Logging
def setup_flask_logging(app):
    """
    Configura logging para Flask.

    Usage:
        from flask import Flask
        from logging_config import setup_flask_logging

        app = Flask(__name__)
        setup_flask_logging(app)
    """
    from flask import g, request

    logger = get_logger("http")

    @app.before_request
    def before_request():
        g.start_time = time.time()
        g.request_id = str(uuid.uuid4())
        g.trace_id = request.headers.get("traceparent", str(uuid.uuid4()))

        log = logger.bind(
            trace_id=g.trace_id,
            request_id=g.request_id,
            method=request.method,
            path=request.path,
            client_ip=request.remote_addr,
        )

        log.info("request_started")

    @app.after_request
    def after_request(response):
        duration_ms = (time.time() - g.start_time) * 1000

        log = logger.bind(
            trace_id=g.trace_id,
            request_id=g.request_id,
            method=request.method,
            path=request.path,
        )

        log.info(
            "request_completed",
            status_code=response.status_code,
            duration_ms=round(duration_ms, 2),
        )

        return response


# Exemplo de uso
if __name__ == "__main__":
    # Setup logging
    setup_logging(
        service_name="example-service",
        environment="development",
        version="1.0.0",
        log_level="INFO",
    )

    # Obter logger
    logger = get_logger(__name__)

    # Logs simples
    logger.info("application_started")

    # Logs com contexto
    logger.info(
        "user_logged_in", user_id="u_789", session_id="sess_456", ip="192.168.1.1"
    )

    # Log de erro
    try:
        raise ValueError("Something went wrong")
    except Exception as e:
        logger.error("operation_failed", error=str(e), exc_info=True)

    # Sanitizar PII
    sensitive_data = {
        "user_id": "u_123",
        "email": "john@example.com",
        "password": "secret123",
        "cpf": "12345678900",
        "api_key": "sk_test_123456",
    }

    sanitized = sanitize_pii(sensitive_data)
    logger.info("data_processed", data=sanitized)
