# SOCDaily — VPS PDF Host (Phase 12)

Source-page PDFs that the Flutter app links back to are **not** stored in
this repo (they're copyrighted study material — see `raw/pdf/MANIFEST.md`).
Instead they're served by `nginx` on the user's VPS, reachable only over a
Tailscale tailnet.

## Topology

```
[ Flutter app on phone ]
        │
        │ https? no — http on the tailnet (private network)
        ▼
[ nginx on neam-vps  100.110.125.8 : 8080 ]
        │
        └──> /var/www/socdaily-pdfs/<subject>/<topic>/<file>.pdf
```

- Tailscale provides the encrypted transport, so the inner traffic can be
  plain HTTP.
- The nginx server block (see `vps/nginx/socdaily-pdfs.conf` next to this
  file) only listens on the tailnet IP — it is *not* reachable from the
  public internet.

## URL contract

Files live under `/var/www/socdaily-pdfs/`. The app builds URLs of the form

```
http://100.110.125.8:8080/<subject_code>/<topic_code>/<filename>.pdf#page=N
```

Adding `#page=N` is a hint to PDF viewers; the byte-range fetch is
independent of the page anchor.

## Provisioning a fresh VPS

```bash
# From inside the tailnet (Tailscale already up):
ssh ubuntu@100.110.125.8

# On the VPS:
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
sudo mkdir -p /var/www/socdaily-pdfs
sudo chown -R ubuntu:ubuntu /var/www/socdaily-pdfs
sudo cp vps/nginx/socdaily-pdfs.conf /etc/nginx/sites-available/socdaily-pdfs
sudo ln -sf /etc/nginx/sites-available/socdaily-pdfs \
            /etc/nginx/sites-enabled/socdaily-pdfs
sudo nginx -t
sudo systemctl reload nginx
```

## Uploading PDFs

From a machine on the tailnet (the Devin VM works fine):

```bash
tar -C raw/pdf -czf /tmp/pdfs.tar.gz .
scp /tmp/pdfs.tar.gz ubuntu@100.110.125.8:/tmp/
ssh ubuntu@100.110.125.8 "tar xzf /tmp/pdfs.tar.gz -C /var/www/socdaily-pdfs"
```

The structure under `raw/pdf/` should already match the
`<subject>/<topic>/<file>.pdf` convention used in the seed JSON's
`source_pdf` field.

## Verifying

```bash
curl -sI http://100.110.125.8:8080/healthz       # → 200 ok
curl -sI http://100.110.125.8:8080/<path>.pdf    # → 200 + Accept-Ranges
```

## Exposing publicly later (optional)

If you ever want PDFs reachable outside the tailnet:

1. Point a domain at the VPS public IP.
2. Add a second `server { listen 443 ssl http2; … }` block in nginx with
   `certbot --nginx -d pdf.example.com` for TLS.
3. Set `PDF_BASE_URL=https://pdf.example.com` in the app's
   `--dart-define`.

The current tailnet-only setup is **deliberately** preferred for MVP:
no public exposure, no DMCA surface, no SSL cert renewal.

---

# SOCDaily — Public Generator API (Phase 14.A)

The same VPS also runs a **public** FastAPI service that wraps the
Python pipeline so the Flutter app can request newly-generated TopicSeed
JSON on demand. Unlike the PDF host, this one is exposed on the public
internet — bearer-token auth + nginx rate limiting do the heavy lifting.

## Topology

```
[ Flutter app anywhere on the internet ]
        │  HTTPS + Authorization: Bearer <token>
        ▼
[ nginx on socdaily.example.com : 443 ]   (Let's Encrypt cert)
        │  reverse proxies → 127.0.0.1:8000
        ▼
[ uvicorn / socdaily.api.app:app ]         (systemd: socdaily-api.service)
        │
        ├── GET  /healthz             — public, returns "ok"
        ├── GET  /pdfs                — list .pdf under SOCDAILY_PDF_DIR
        ├── POST /pdfs                — multipart upload (50 MB cap)
        └── POST /generate            — runs pipeline.generate.generate_topic_seed
                                         and returns the TopicSeed JSON
```

The PDF directory is shared between the two services — uploads via
`POST /pdfs` land in `/var/www/socdaily-pdfs/`, so the same file is then
servable by the tailnet nginx (Phase 12) for in-app viewing. One source
of truth.

## Provisioning

```bash
# 1. Pick a hostname pointing at the VPS public IP and edit:
#       vps/nginx/socdaily-api.conf  →  server_name socdaily.example.com
#
# 2. On the VPS:
sudo apt-get install -y python3-venv certbot python3-certbot-nginx
sudo certbot --nginx -d socdaily.example.com   # provisions TLS + reload

git clone https://github.com/<you>/SOCDaily.git ~/SOCDaily
cd ~/SOCDaily
python3 -m venv .venv
.venv/bin/pip install -e .

# 3. Secrets — pick a long random token (or several, comma-separated).
sudo install -d -m 0700 -o ubuntu -g ubuntu /etc/socdaily
sudo tee /etc/socdaily/api.env >/dev/null <<EOF
SOCDAILY_API_TOKENS=$(openssl rand -hex 24),$(openssl rand -hex 24)
SOCDAILY_PDF_DIR=/var/www/socdaily-pdfs
SOCDAILY_LLM_PROVIDER=openai
SOCDAILY_LLM_BASE_URL=https://api.openai.com/v1
SOCDAILY_LLM_API_KEY=sk-...
SOCDAILY_LLM_MODEL=gpt-4o-mini
SOCDAILY_CONTENT_LANG=vi
EOF
sudo chmod 0600 /etc/socdaily/api.env
sudo chown ubuntu:ubuntu /etc/socdaily/api.env

# 4. Install the systemd unit + nginx site.
sudo cp vps/socdaily-api.service /etc/systemd/system/
sudo cp vps/nginx/socdaily-api.conf /etc/nginx/sites-available/socdaily-api
sudo ln -sf /etc/nginx/sites-available/socdaily-api \
            /etc/nginx/sites-enabled/socdaily-api
sudo systemctl daemon-reload
sudo systemctl enable --now socdaily-api
sudo nginx -t && sudo systemctl reload nginx
```

## Verifying

```bash
# Public health (no auth):
curl https://socdaily.example.com/healthz                # → {"status":"ok"}

# Listing PDFs (auth required):
curl -H "Authorization: Bearer <token>" \
     https://socdaily.example.com/pdfs

# Generate flashcards + MCQs from a PDF page range:
curl -X POST https://socdaily.example.com/generate \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{
       "subject_code":"soc-fundamentals",
       "subject_title":"SOC Fundamentals",
       "chapter_code":"siem",
       "chapter_title":"SIEM",
       "topic_code":"siem-core-concepts",
       "topic_title":"SIEM Core Concepts",
       "pdf_filename":"SOC Analyst Guide.pdf",
       "page_start":12,
       "page_end":15,
       "n_flashcards":6,
       "n_questions":4,
       "content_lang":"vi"
     }'
```

## Rotating tokens

Edit `/etc/socdaily/api.env`, restart the service:

```bash
sudo nano /etc/socdaily/api.env
sudo systemctl restart socdaily-api
```

Old tokens become invalid immediately. The app's settings screen
(P14.B) lets each user paste their own token, so rotating only requires
re-pasting on the device(s) that need access.
