#!/usr/bin/env bash
# Checks that the live site serves the SEO changes and that every profile link still resolves.
# Usage: bash .seo/check.sh
# (Folders starting with "." are not published by GitHub Pages, so this file is not part of the site.)

SITE="https://fmorenopino.github.io/"
page=$(curl -sL "$SITE")

check() { if printf '%s' "$page" | grep -q "$2"; then echo "  OK    $1"; else echo "  MISSING  $1"; fi; }

echo "Live page: $SITE"
check "Title"                 "<title>Fernando Moreno-Pino | Machine Learning"
check "Meta description"      'name="description"'
check "Canonical link"        'rel="canonical"'
check "Structured data"       'application/ld+json'
check "Alternate name"        '"Fernando Moreno"'

echo
echo "Profile links (HTTP status):"
printf '%s' "$page" | python3 -c '
import sys, re, json
m = re.search(r"ld\+json\">(.*?)</script>", sys.stdin.read(), re.S)
if not m: sys.exit("  no structured data found")
for u in json.loads(m.group(1)).get("sameAs", []): print(u)
' | while read -r u; do
  echo "  $(curl -s -o /dev/null -L -A 'Mozilla/5.0' -w '%{http_code}' "$u")  $u"
done

echo
echo "Next: check Search Console > Performance > Search results, filtered by query 'Fernando Moreno'."
