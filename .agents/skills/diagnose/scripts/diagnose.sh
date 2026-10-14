#!/bin/bash
# LIGHT lab readiness check — macOS. Needs nothing installed (built-in bash + macOS tools).
# Usage, from the project folder:
#   bash .agents/skills/diagnose/scripts/diagnose.sh
# Optional: --open edge|chrome   opens index.html in that browser at the end.

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EXPECTED_SIZE=1355169
EXPECTED_HASH="82344159a161e30e1c012587a59567adc02f537cd5f376270eff88c564eed0fd"
FAILS=0
WARNS=0
OPEN=""
[ "$1" = "--open" ] && OPEN="$2"

report() {
  [ "$1" = "FAIL" ] && FAILS=$((FAILS + 1))
  [ "$1" = "WARN" ] && WARNS=$((WARNS + 1))
  printf "%-5s %-28s %s\n" "$1" "$2" "$3"
}

echo "LIGHT LAB DIAGNOSTIC - MAC"
echo "Date/time : $(date '+%Y-%m-%d %H:%M')"
echo "Computer  : $(scutil --get ComputerName 2>/dev/null) / $(whoami)"
echo "macOS     : $(sw_vers -productVersion 2>/dev/null)"
echo "Folder    : $ROOT"
echo

# 1. Browsers
EDGE_APP="/Applications/Microsoft Edge.app"
CHROME_APP="/Applications/Google Chrome.app"
[ -d "$HOME$EDGE_APP" ] && EDGE_APP="$HOME$EDGE_APP"
[ -d "$HOME$CHROME_APP" ] && CHROME_APP="$HOME$CHROME_APP"
HAVE=""
for pair in "edge|$EDGE_APP" "chrome|$CHROME_APP"; do
  name="${pair%%|*}"; app="${pair#*|}"
  if [ -d "$app" ]; then
    v=$(defaults read "$app/Contents/Info" CFBundleShortVersionString 2>/dev/null)
    report PASS "Browser: $name" "$v  ($app)"
    HAVE="$HAVE $name"
  fi
done
[ -z "$HAVE" ] && report FAIL "Browser (Edge or Chrome)" "neither Microsoft Edge nor Google Chrome found in /Applications"

# 2. Where the folder lives
case "$ROOT" in
  */AppTranslocation/*|*/private/var/folders/*)
    report FAIL "Unzipped on local disk" "running from a temporary/quarantine location - move the folder to Documents or Desktop" ;;
  /Volumes/*)
    report WARN "Unzipped on local disk" "folder is on an external or network volume - prefer a folder on this Mac" ;;
  *OneDrive*|*/Library/CloudStorage/*|*"/Mobile Documents/"*)
    report WARN "Unzipped on local disk" "folder is in OneDrive/iCloud - works, but syncing can lock files; prefer a non-synced folder" ;;
  *)
    report PASS "Unzipped on local disk" "local folder" ;;
esac

# 3. Boilerplate files
MISSING=""
for f in index.html styles.css js/config.js js/schema.js js/db.js js/router.js js/app.js vendor/sql-asm.js AGENTS.md GUARDRAILS.md; do
  [ -f "$ROOT/$f" ] || MISSING="$MISSING $f"
done
if [ -n "$MISSING" ]; then report FAIL "Boilerplate files" "missing:$MISSING"
else report PASS "Boilerplate files" "all 10 present"; fi

# 4. vendor/sql-asm.js intact
SQLF="$ROOT/vendor/sql-asm.js"
if [ -f "$SQLF" ]; then
  size=$(wc -c < "$SQLF" | tr -d ' ')
  hash=$(shasum -a 256 "$SQLF" | cut -d' ' -f1)
  if [ "$hash" = "$EXPECTED_HASH" ]; then
    report PASS "vendor/sql-asm.js intact" "$size bytes, checksum OK"
  elif [ "$size" -gt 1300000 ] && [ "$size" -lt 1400000 ]; then
    report WARN "vendor/sql-asm.js intact" "$size bytes (~1.35 MB) but checksum differs - re-extract the zip if the app stays on Loading"
  else
    report FAIL "vendor/sql-asm.js intact" "$size bytes, expected ~$EXPECTED_SIZE - file truncated or replaced, re-extract the zip"
  fi
else
  report FAIL "vendor/sql-asm.js intact" "file missing"
fi

# 5. Browser policies that would break the app (managed preferences)
for pair in "edge|com.microsoft.Edge" "chrome|com.google.Chrome"; do
  name="${pair%%|*}"; domain="${pair#*|}"
  case "$HAVE" in *"$name"*) ;; *) continue ;; esac
  problems=""
  for plist in "/Library/Managed Preferences/$domain.plist" "/Library/Managed Preferences/$(whoami)/$domain.plist"; do
    [ -f "$plist" ] || continue
    dump=$(plutil -p "$plist" 2>/dev/null)
    echo "$dump" | grep -q '"DefaultCookiesSetting" => 2' && problems="$problems DefaultCookiesSetting=2 (site storage blocked);"
    echo "$dump" | grep -q '"DefaultJavaScriptSetting" => 2' && problems="$problems DefaultJavaScriptSetting=2 (JavaScript blocked);"
    echo "$dump" | grep -q '"DownloadRestrictions" => 3' && problems="$problems DownloadRestrictions=3 (Export cannot download);"
    echo "$dump" | grep -q '"AllowFileSelectionDialogs" => 0' && problems="$problems AllowFileSelectionDialogs=0 (Import cannot pick a file);"
    echo "$dump" | grep -q '"file:' && problems="$problems a block list contains file:// URLs;"
  done
  if [ -n "$problems" ]; then report WARN "Policies: $name" "$problems"
  else report PASS "Policies: $name" "no policy blocking storage, JavaScript, downloads or file:// found"; fi
done

# 6. Optionally open the app
URL="file://$ROOT/index.html"
if [ "$OPEN" = "edge" ] && [ -d "$EDGE_APP" ]; then open -a "$EDGE_APP" "$ROOT/index.html" && echo "INFO  Opened in edge"; fi
if [ "$OPEN" = "chrome" ] && [ -d "$CHROME_APP" ]; then open -a "$CHROME_APP" "$ROOT/index.html" && echo "INFO  Opened in chrome"; fi

echo
echo "SUMMARY: $FAILS FAIL, $WARNS WARN"
echo "App link: $URL"
echo "DIAGNOSE SCRIPT DONE"
