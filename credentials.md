Viewed .env:1-2

### Getting the Google Cloud credentials the MCP server needs  

The server reads the two environment variables **`GOOGLE_APPLICATION_CREDENTIALS`** and **`GOOGLE_CLOUD_PROJECT`** (see `analytics_mcp/tools/client.py`).  
You have two common ways to provide them:

| Method | When to use it | How to obtain |
|--------|----------------|---------------|
| **Service‑account key JSON** (recommended for production or CI) | You want a dedicated, least‑privilege account that the container can use automatically. | 1. Open the Google Cloud Console → **IAM & Admin → Service Accounts**. <br>2. Click **Create Service Account** → give it a name (e.g. `analytics-mcp`). <br>3. Grant the role **Analytics Viewer** (or a more restrictive custom role that includes `analyticsadmin.readonly` and `analyticsdata.readonly`). <br>4. After creating, click **Keys → Add Key → Create new key** → **JSON**. <br>5. Save the file (e.g. `service-account-key.json`). |
| **Application Default Credentials (ADC)** (good for local development) | You already run `gcloud auth application-default login` and want to reuse that token. | 1. Run `gcloud auth application-default login --scopes https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform` <br>2. The command writes a JSON file to `~/.config/gcloud/application_default_credentials.json` (Windows: `C:\Users\<you>\AppData\Roaming\gcloud\application_default_credentials.json`). |

---

## 1. Fill the **.env** file  

The repository already contains an empty `.env`. Add the values that match the method you choose.

### Example for a service‑account key (mounted into the container)

```text
# .env
GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json   # path inside the container
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
```

*When you run the container, mount the key file at the same location:*

```bash
docker run -i --rm \
  -v /path/to/service-account-key.json:/app/credentials.json:ro \
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json \
  -e GOOGLE_CLOUD_PROJECT=your-gcp-project-id \
  analytics-mcp
```

### Example for ADC (host‑mounted)

```text
# .env
GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
```

And run:

```bash
docker run -i --rm \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  -e GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json \
  -e GOOGLE_CLOUD_PROJECT=your-gcp-project-id \
  analytics-mcp
```

*(On Windows PowerShell replace `$HOME` with `$env:USERPROFILE`.)*

---

## 2. Verify the credentials work  

Inside the container you can run a quick Python snippet to confirm the client can load the credentials:

```bash
docker run -i --rm \
  -v /path/to/service-account-key.json:/app/credentials.json:ro \
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json \
  -e GOOGLE_CLOUD_PROJECT=your-gcp-project-id \
  analytics-mcp \
  python - <<'PY'
import google.auth
creds, project = google.auth.default(scopes=["https://www.googleapis.com/auth/analytics.readonly"])
print("Loaded credentials for project:", project)
PY
```

You should see `Loaded credentials for project: your-gcp-project-id`. If you get an error, double‑check that the JSON file is reachable at the path you set in `GOOGLE_APPLICATION_CREDENTIALS`.

---

## 3. Keep the `.env` out of version control  

Your `.gitignore` already excludes `.env`. **Do not commit** the filled‑in file or the JSON key. This prevents accidental secret leakage.

---

### TL;DR steps for you right now  

1. **Create a service‑account key** in the Cloud Console (or run `gcloud auth application-default login`).  
2. **Put the key file somewhere safe** on your host, e.g. `C:\keys\analytics-mcp-key.json`.  
3. **Edit `.env`** (in the repo root) as shown above, pointing to the path you’ll mount (`/app/credentials.json`).  
4. **Build**: `docker build -t analytics-mcp .`  
5. **Run** (replace paths/project‑id):  

```powershell
docker run -i --rm `
  -v "C:\keys\analytics-mcp-key.json:/app/credentials.json:ro" `
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json `
  -e GOOGLE_CLOUD_PROJECT=your-project-id `
  analytics-mcp
```

That’s all you need to get the MCP server talking to Google Analytics inside Docker. Let me know if you need any tweaks or a sample `docker-compose.yml` with the env variables filled in