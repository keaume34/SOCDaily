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
