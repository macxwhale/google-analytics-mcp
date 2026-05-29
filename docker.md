docker build -t analytics-mcp

docker run -i --rm \
    -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
    -e GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json \
    analytics-mcp \
    python -c "import google.auth; print(google.auth.default())"
