# Stage - Build Dependencies

FROM python:3.11-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Stage - Runtime Image
FROM python:3.11-slim

RUN useradd -m appuser

WORKDIR /app

#copying installed dependencies from the builder stage
COPY --from=builder /install /usr/local

COPY app/ /app/

USER appuser

EXPOSE 443

# Adding healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f https://localhost/health || exit 1

# Run Gunicorn with SSL certs (mounted via docker-compose)  
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:443", "--certfile=certs/cert.pem", "--keyfile=certs/key.pem", "wsgi:app"]
