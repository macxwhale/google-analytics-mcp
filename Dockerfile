# ---- Build stage ----
FROM python:3.12-slim AS builder

WORKDIR /app

# Copy only what's needed for installation
COPY pyproject.toml .
COPY analytics_mcp/ analytics_mcp/

# Install the package and all dependencies
RUN pip install --no-cache-dir .

# ---- Runtime stage ----
FROM python:3.12-slim

WORKDIR /app

# Copy installed packages and the entry-point script from the builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/analytics-mcp /usr/local/bin/analytics-mcp
COPY --from=builder /usr/local/bin/google-analytics-mcp /usr/local/bin/google-analytics-mcp

# Copy the application source
COPY analytics_mcp/ analytics_mcp/

# MCP servers communicate over stdio — no ports needed
ENTRYPOINT ["analytics-mcp"]
