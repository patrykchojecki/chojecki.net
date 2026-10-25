# Cloudflare crawler review

Reviewed 2026-10-25 (Asia/Taipei), starting at `dd3be91`.

## Findings

- Published robots.txt explicitly allows search and AI crawlers and advertises
  the canonical sitemap. Cloudflare Bot Preference Sync is off, so it does not
  prepend competing directives.
- Global Search, Agent, and Training policies are **Allow (do not block)**.
  Individual blocks for Googlebot, BingBot, OAI-SearchBot, Claude-SearchBot,
  PerplexityBot, and the corresponding assistant fetchers are off.
- AI Crawl Control's last-24-hours view showed successful traffic attributed to
  major search and AI operators. Errors were concentrated on obsolete/malformed
  paths and Bytespider traffic. User-agent classification alone is not proof of
  crawler identity; no security bypass is justified by this evidence.
- Bot Fight Mode and Browser Integrity Check are on; AI Labyrinth and Under
  Attack Mode are off. These settings were preserved.
- Markdown for Agents requires Pro in this dashboard. The existing static HTML
  and `/llms.txt` remain accessible without JavaScript. No paid upgrade or runtime
  conversion was introduced to improve a beta readiness score.
- Pages already caches static content at the edge. Preserve its HTML
  revalidation and deployment invalidation, hashed immutable assets, native
  deferred scripts, and stylesheet preload hints. Do not add Cache Everything.

## Applied change

Enabled **Caching → Configuration → Crawler Hints** on 2026-10-25 after the
owner explicitly approved enabling it and accepting its terms. It was off at
inspection; the dashboard confirmed **On**, including after a page reload.
Cloudflare uses cache signals to notify participating search engines through
IndexNow when content may have changed. This improves discovery signals; it
does not guarantee indexing, rankings, AI citations, or lower request latency.

The service shares website information needed for its functionality under
Cloudflare's Supplemental Terms. This was the only production setting changed.

Rollback: switch Crawler Hints off in the same panel. This change
requires no site deployment, DNS change, cache purge, or security exception.

## Verification

- After enabling Crawler Hints, the live discovery check passed again for all
  9 resources, and the same production hosting comparison passed again for
  60 pages/assets and 22 redirect/404 cases. No delivery regression was detected.
- `check-live-site.py` passed all 9 discovery resources: robots.txt, sitemap.xml,
  and its 7 canonical entries, including the PDF. Canonicals, structured data,
  indexing permissions, and revision-date consistency passed.
- The prepared local output passed `check-site.py`: 24 HTML files, internal
  links, fragments, assets, landmarks, JSON-LD, and 7 sitemap entries.
- Production hosting checks passed for 60 pages/assets and 22 redirect/404
  cases, including HTTPS, canonical www redirects, legacy routes, and true 404s.
  This was not an exact CI-artifact comparison: a temporary copy excluded
  build-time-dependent `feed.xml` and `sitemap.xml`, plus the untracked local
  `skills-lock.json` which is not deployed. The live discovery check separately
  validated the sitemap. No source or production files were removed.
- Detailed traffic counts and local evidence belong in ignored `.geo/`, not in
  this public repository. These checks establish delivery health, not indexing
  or verified access from every crawler network.
- The live RSS feed parsed as XML and `/llms.txt` returned the expected plain
  text through curl. A separate default Python urllib request received 403;
  this demonstrates that arbitrary automation can still be rejected. It does
  not identify the responsible rule or prove a verified search crawler fails.

## References

- [Crawler Hints](https://developers.cloudflare.com/cache/advanced-configuration/crawler-hints/)
- [Pages caching behavior](https://developers.cloudflare.com/pages/configuration/serving-pages/)
- [AI crawler controls and unsuccessful requests](https://developers.cloudflare.com/ai-crawl-control/features/manage-ai-crawlers/)
- [Existing delivery optimizations](PERFORMANCE.md)
