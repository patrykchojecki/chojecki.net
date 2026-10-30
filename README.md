# chojecki.net

Source for [Patryk Chojecki’s personal website](https://chojecki.net): biography, CV, projects, and current interests. Built with Jekyll, checked by GitHub Actions, and published to Cloudflare Pages from `master`.

## Run locally

Use **Ruby 3.4.11**, **Bundler 4.0.9**, **Node.js 26**, **npm 10+**, and **Python 3.9+**. Ruby and Node versions are recorded in [.ruby-version](.ruby-version) and [.node-version](.node-version); Bundler is locked in [Gemfile.lock](Gemfile.lock). Python checks use only the standard library.

Activate the required Ruby and Node versions with your version manager, then:

```sh
git clone https://github.com/patrykchojecki/chojecki.net.git
cd chojecki.net
gem install bundler -v 4.0.9
bundle install
npm ci
npm run serve
```

Open **[http://127.0.0.1:4001](http://127.0.0.1:4001)**. No secrets or environment variables are needed. Development uses expanded CSS, source maps, and preview Xbox activity when live data is absent.

Restart Jekyll after editing `_config.yml` or `_config.dev.yml`. When editing `assets/js/_main.js`, run `npm run watch:js` in a second terminal and commit the resulting `assets/js/main.min.js` alongside its source. Other JavaScript files are served directly.

## Validate changes

```sh
npm run check
```

This runs the JavaScript and Python regression tests, rebuilds JavaScript, builds the production site into `_site/`, and checks internal links, fragments, assets, landmarks, structured data, sitemap entries, and publication exclusions.

| Command | Purpose |
| --- | --- |
| `npm run serve` | Serve the development site on port 4001 |
| `npm run watch:js` | Rebuild the main JavaScript bundle on source changes |
| `npm test` | Run the OpenXBL regression tests |
| `npm run test:seo` | Run all Python checks’ regression tests, including hosting and assets |
| `npm run build` | Build JavaScript and the production site, then validate the output |
| `npm run check:site` | Validate an existing `_site/` build |
| `npm run check:live` | Check the published site’s discovery resources |

Pull requests run [Check site](.github/workflows/check.yml), including Cloudflare packaging and a check that generated JavaScript is committed. This workflow needs no deployment secrets and does not publish the site.

## Where to edit

| Location | Contents |
| --- | --- |
| [_pages/](./_pages/) | Home/about, CV, Now, projects listing, and other pages |
| [_portfolio/](./_portfolio/) | Project entries rendered on the projects listing |
| [_data/](./_data/) | Navigation, profile links, UI labels, and Xbox preview data |
| [_config.yml](_config.yml) | Site identity, metadata, collections, and publication settings |
| [_includes/](./_includes/), [_layouts/](./_layouts/) | Shared components and page templates |
| [_sass/](./_sass/), [assets/](./assets/), [images/](./images/) | Styles, JavaScript, fonts, PDFs, and images |
| [_posts/](./_posts/), [_drafts/](./_drafts/) | Existing writing and unpublished drafts |
| [scripts/](./scripts/) | Build validation, deployment preparation, and maintenance tools |

Read [PRODUCT.md](PRODUCT.md) for content constraints and [DESIGN.md](DESIGN.md) for visual conventions. Existing blog posts and publication pages intentionally stay out of search discovery. The CV PDF is a historical snapshot; update `_pages/cv.md` for current career information.

`_site/`, dependency directories, local caches, `.geo/` reports, and live `_data/xbox.json` are generated or local files. Keep them out of commits. The inherited [markdown generators](markdown_generator/readme.md) are optional legacy tools, excluded from the site and unnecessary for normal development.

## Deployment and maintenance

Pushing to `master` runs the [Cloudflare deployment workflow](.github/workflows/cloudflare.yml). It also runs every six hours (`17 */6 * * *`, UTC) and on manual dispatch. It tests and builds the site, optionally fetches Xbox activity, prepares redirects and cached assets, verifies a preview, and publishes the same build to production. It then verifies the Pages origin and, when enabled, the custom domain.

See [scripts/README.md](scripts/README.md) for required deployment settings, Xbox data, and validation commands. The [Cloudflare runbook](scripts/cloudflare/README.md) records hosting configuration, migration history, and rollback instructions. [Search visibility operations](scripts/geo/README.md) covers indexing and private measurement reports.

[GitHub Pages](.github/workflows/static.yml) is retained for manual rollback only. The repository is `patrykchojecki/chojecki.net`; old repository links redirect, but the former `patrykchojecki.github.io` website address is retired.

## Troubleshooting

- **Ruby or Bundler errors:** check `ruby --version`, `bundle --version`, and `which ruby`. On macOS, ensure your version manager selects the required Ruby instead of `/usr/bin/ruby`, then rerun the dependency installation above.
- **Port 4001 is busy:** stop the existing server or run `bundle exec jekyll serve --config _config.yml,_config.dev.yml --host 127.0.0.1 --port 4002`.
- **JavaScript changes do not appear:** run `npm run build:js`, or keep the watcher running while editing `_main.js`.
- **Xbox activity is missing:** preview data is only used in development. Production omits the card when no live snapshot is available; see the [Xbox maintenance notes](scripts/README.md#xbox-activity).

## Credits and license

Originally forked from [Academic Pages](https://github.com/academicpages/academicpages.github.io), based on [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/). Available under the [MIT License](LICENSE). The live site uses Cloudflare’s basic analytics; see the [privacy page](https://chojecki.net/terms/).
