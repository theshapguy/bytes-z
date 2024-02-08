+++

title = "Cloudflare Pages Build Bash Script for Zola"
date = "2024-02-04"
draft = false

[taxonomies]
tags = ["zola", "cloudflare", "static-page"]
categories = ["Today I Learned", "Zola"]


[extra]
lang = "en"
toc = false

+++

Rather than using the predefied build commands of Cloudflare Pages, it is extremley handly to create a build script and call the script with `bash build.sh` from the build command. It gives you control over how pages are build in different branches.

`$CF_PAGES_BRANCH` & `$CF_PAGES_URL` are enviornment variables provided by Cloudflare at build time.

```bash
#!/bin/bash
echo "Building Site Now"
if [ "$CF_PAGES_BRANCH" == "main" ]; then
  # Run the "production" build
  zola build --force
else
  # Run the build  with drafts
  zola build --drafts --force --base-url $CF_PAGES_URL
fi
```

#### Sources

1. <https://developers.cloudflare.com/pages/how-to/build-commands-branches/>