# X-AnyLabeling-Server Docker Image (CPU Version)
# Auto-built from https://github.com/CVHub520/X-AnyLabeling-Server

ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim

LABEL org.opencontainers.image.source="https://github.com/CVHub520/X-AnyLabeling-Server"
LABEL org.opencontainers.image.description="X-AnyLabeling-Server - AI Model Inference Service (CPU)"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Clone the repository
ARG VERSION=main
RUN git clone --depth 1 --branch ${VERSION} \
    https://github.com/CVHub520/X-AnyLabeling-Server.git . || \
    git clone --depth 1 https://github.com/CVHub520/X-AnyLabeling-Server.git .

# Install PyTorch CPU version first
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install uv for faster dependency installation
RUN pip install --upgrade uv

# Install the package with all dependencies
RUN uv pip install --system -e ".[all]"

# Create directories for configs and weights
RUN mkdir -p /app/weights /app/logs

# Expose the default port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Default command
CMD ["x-anylabeling-server", "--host", "0.0.0.0", "--port", "8000"]
