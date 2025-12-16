# ============================================
# Multi-stage Dockerfile for SQL Agent Portal
# ============================================
 
# Stage 1: Builder
FROM python:3.11-slim AS builder
 
WORKDIR /app
 
# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy and install requirements
COPY requirements.txt . 
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Production
FROM python:3.11-slim AS production
 
# Security:  Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app
 
# Copy dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local
 
# Copy application code
COPY --chown=appuser:appgroup src/ ./src/

# Set environment variables
ENV PATH=/home/appuser/.local/bin: $PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Security: Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Run application
CMD ["python", "src/main.py"]
