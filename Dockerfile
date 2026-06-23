# ============================================================
# apuestas-service — imagen multi-stage, liviana y con usuario no-root
# Base: python:3.12-slim  ·  Arranque: uvicorn  ·  Puerto: 8005
# ============================================================

# ---------- Stage 1: builder (instala dependencias) ----------
FROM python:3.12-slim AS builder

# Evita .pyc y fuerza salida sin buffer (logs en vivo)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias en un prefijo aislado para copiarlas luego
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---------- Stage 2: runtime (imagen final mínima) ----------
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Crear usuario sin privilegios (no-root)
RUN useradd --create-home --uid 10001 appuser

WORKDIR /app

# Traer solo las dependencias ya instaladas desde el builder
COPY --from=builder /install /usr/local

# Copiar el código de la aplicación
COPY app ./app

# Ejecutar como usuario no-root
USER appuser

EXPOSE 8005

# Arranque del servidor ASGI. host 0.0.0.0 para ser accesible dentro del pod.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8005"]