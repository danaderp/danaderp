#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"
fixture_suffix="${BASHPID}"
giscus_fixture="_posts/2000-01-01-comments-giscus-fixture-${fixture_suffix}.md"
disqus_fixture="_posts/2000-01-02-comments-disqus-fixture-${fixture_suffix}.md"

cleanup() {
  rm -f "${giscus_fixture}" "${disqus_fixture}"
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cat >"${giscus_fixture}" <<'MARKDOWN'
---
layout: post
title: Comments Giscus Fixture
date: 2000-01-01
giscus_comments: true
---
MARKDOWN

cat >"${disqus_fixture}" <<'MARKDOWN'
---
layout: post
title: Comments Disqus Fixture
date: 2000-01-02
disqus_comments: true
---
MARKDOWN

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
YAML

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

giscus_page="${tmp_site}/blog/2000/comments-giscus-fixture-${fixture_suffix}/index.html"
disqus_page="${tmp_site}/blog/2000/comments-disqus-fixture-${fixture_suffix}/index.html"

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"
