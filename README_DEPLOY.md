# Deploy Instructions - Cloudflare

## Quick Start (1 command)

### Option A: GitHub Connected (Recommended - auto deploy on push)

1. Create GitHub repo: https://github.com/new -> name: hacyberglobal-dpdns-portal
2. Run:

```bash
cd cloudflare-deploy-ready
git init
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/hacyberglobal-dpdns-portal.git
git add .
git commit -m "Initial deploy HACYBERGLOBALTECH v3"
git push -u origin main
```

3. Cloudflare Dashboard -> Pages -> Create Project -> Connect to Git -> Select repo -> Framework: None -> Deploy
4. Add custom domain: hacyberglobal.dpdns.org

### Option B: Direct Deploy via Wrangler (instant, no GitHub)

```bash
cd cloudflare-deploy-ready
npm install
npx wrangler login
npx wrangler pages deploy . --project-name=hacyberglobal-dpdns-portal
```

### Option C: One-click script

```bash
chmod +x deploy.sh
./deploy.sh
```

## Files
- index.html = Public portal (https://hacyberglobal.dpdns.org)
- admin.html = Admin CRM (https://hacyberglobal.dpdns.org/admin.html) password: hgt217
- logo.png = Transparent logo
- _headers, _redirects = Cloudflare config
- wrangler.toml = Cloudflare config

## DNS (already set in your Cloudflare)
A hacyberglobal.dpdns.org 37.140.223.216 Proxied
CNAME www -> hacyberglobal.dpdns.org Proxied

Pages will auto-add CNAME for custom domain.

## After Deploy
Your site live at:
- https://hacyberglobal-dpdns-portal.pages.dev
- https://hacyberglobal.dpdns.org (after custom domain added)
