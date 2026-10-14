#!/bin/bash
# LIGHT app launcher - macOS. Decides and runs how the app is opened; saves the choice in lab-mode.txt.
# Built-in macOS tools only. Never installs anything.
#
#   bash tools/launch.sh auto [--open]            first run (/kickoff): reuse lab-mode.txt, or try the
#                                                 servers (perl, node, python; ~4 s each), else file mode
#   bash tools/launch.sh restart [--open]         make sure the saved mode is running (same address)
#   bash tools/launch.sh file [--open]            force file mode (trainer: /force-filebased)
#   bash tools/launch.sh server [perl|node|python] [--open]
#                                                 force localhost mode (trainer: /force-serverbased)
#   bash tools/launch.sh status | stop
#
# The last line printed always starts with RESULT.

cd "$(dirname "$0")/.." || exit 1
ROOT="$(pwd)"
MODE_FILE="$ROOT/lab-mode.txt"
LOG="${TMPDIR:-/tmp}/lab-app-server.log"
ORDER="${LAB_SERVERS:-perl node python}"   # LAB_SERVERS only for testing
SIZE=$(wc -c < "$ROOT/vendor/sql-asm.js" | tr -d ' ')
OPEN=0
ARGS=()
for a in "$@"; do if [ "$a" = "--open" ]; then OPEN=1; else ARGS+=("$a"); fi; done
CMD="${ARGS[0]:-auto}"
ONLY="${ARGS[1]:-}"

get() { [ -f "$MODE_FILE" ] && sed -n "s/^$1=//p" "$MODE_FILE" | head -1; }
saved_port() { get url | sed -n 's#^http://localhost:\([0-9]*\)/.*#\1#p'; }
file_url() { printf 'file://%s/index.html' "$ROOT" | sed 's/ /%20/g'; }

# Does THIS app answer on the port? (checks the size of the database engine file)
answers() {
  [ "$(curl -s --noproxy '*' --max-time 2 -o /dev/null -w '%{size_download}' "http://localhost:$1/vendor/sql-asm.js")" = "$SIZE" ]
}
# Does anything at all answer on the port?
taken() { curl -s --noproxy '*' --max-time 1 -o /dev/null "http://localhost:$1/"; }

cmd_for() {
  case "$1" in
    perl) command -v perl >/dev/null 2>&1 && echo "perl" ;;
    node) command -v node >/dev/null 2>&1 && echo "node" ;;
    python)
      local p; p="$(command -v python3 2>/dev/null)"
      [ -z "$p" ] && return
      # /usr/bin/python3 is only a placeholder that pops up an install prompt without the developer tools
      if [ "$p" = "/usr/bin/python3" ] && ! xcode-select -p >/dev/null 2>&1; then return; fi
      echo "$p" ;;
  esac
}
script_for() { case "$1" in perl) echo serve.pl ;; node) echo serve.js ;; python) echo serve.py ;; esac; }

write_localhost() {
  printf 'mode=localhost\nserver=%s\nurl=http://localhost:%s/\npid=%s\n' "$1" "$2" "$3" > "$MODE_FILE"
}
write_file() { printf 'mode=file\nurl=%s\n' "$(file_url)" > "$MODE_FILE"; }

stop_servers() {
  local pid; pid="$(get pid)"
  [ -n "$pid" ] && kill "$pid" 2>/dev/null
  pkill -f "$ROOT/tools/serve\." 2>/dev/null
  sleep 0.3
}

# Start one server in the background and wait up to ~4 s for it to answer. Prints the pid on success.
start_one() {
  local exe pid; exe="$(cmd_for "$1")"
  if [ -z "$exe" ]; then echo "TRIED $1: not available" >&2; return 1; fi
  nohup "$exe" "$ROOT/tools/$(script_for "$1")" "$2" >>"$LOG" 2>&1 &
  pid=$!
  disown "$pid" 2>/dev/null
  for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
    if answers "$2"; then echo "$pid"; return 0; fi
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.25
  done
  kill "$pid" 2>/dev/null
  echo "TRIED $1: no answer on port $2" >&2
  return 1
}

pick_port() {
  local p; for p in 8080 8081 8082; do
    if answers "$p" || ! taken "$p"; then echo "$p"; return 0; fi
  done
  return 1
}

# Try the servers in order on one port. Writes lab-mode.txt on success.
try_servers() {
  local list="$1" port="$2" s pid
  if answers "$port"; then
    write_localhost "${3:-unknown}" "$port" ""
    return 0
  fi
  for s in $list; do
    if pid="$(start_one "$s" "$port")"; then write_localhost "$s" "$port" "$pid"; return 0; fi
  done
  return 1
}

result() {
  if [ "$(get mode)" = "localhost" ]; then
    echo "RESULT mode=localhost server=$(get server) url=$(get url)"
  else
    echo "RESULT mode=file url=$(get url)"
  fi
  if [ "$OPEN" = 1 ]; then open "$(get url)"; fi
}

ensure_running() {
  # Saved localhost mode: keep the SAME port (the browser keeps the app's data per address).
  local port first list; port="$(saved_port)"
  answers "$port" && return 0
  first="$(get server)"
  list="$first $(echo "$ORDER" | tr ' ' '\n' | grep -vx "$first" | tr '\n' ' ')"
  try_servers "$list" "$port"
}

case "$CMD" in
  auto)
    if [ -f "$MODE_FILE" ]; then
      if [ "$(get mode)" = "localhost" ] && ! ensure_running; then
        echo "RESULT error=server-down url=$(get url) (no server could start on the saved port; a trainer can run /force-filebased)"
        exit 1
      fi
      result; exit 0
    fi
    if port="$(pick_port)" && try_servers "$ORDER" "$port"; then result; exit 0; fi
    write_file
    result ;;
  restart)
    if [ ! -f "$MODE_FILE" ]; then exec bash "$0" auto "$([ $OPEN = 1 ] && echo --open)"; fi
    if [ "$(get mode)" = "localhost" ] && ! ensure_running; then
      echo "RESULT error=server-down url=$(get url) (no server could start on the saved port; a trainer can run /force-filebased)"
      exit 1
    fi
    result ;;
  file)
    stop_servers
    write_file
    result ;;
  server)
    backup="$(cat "$MODE_FILE" 2>/dev/null)"
    list="${ONLY:-$ORDER}"
    port="$(saved_port)"
    stop_servers
    if [ -z "$port" ]; then port="$(pick_port)"; fi
    if [ -n "$port" ] && try_servers "$list" "$port"; then result; exit 0; fi
    if [ -n "$backup" ]; then printf '%s\n' "$backup" > "$MODE_FILE"; else rm -f "$MODE_FILE"; fi
    [ "$(get mode)" = "localhost" ] && ensure_running >/dev/null 2>&1
    echo "RESULT error=no-server tried=\"$list\" (previous mode kept; see the TRIED lines above)"
    exit 1 ;;
  status)
    if [ ! -f "$MODE_FILE" ]; then echo "RESULT mode=none (run /kickoff)"; exit 0; fi
    if [ "$(get mode)" = "localhost" ]; then
      if answers "$(saved_port)"; then echo "RESULT mode=localhost server=$(get server) url=$(get url) running=yes"
      else echo "RESULT mode=localhost server=$(get server) url=$(get url) running=no"; fi
    else echo "RESULT mode=file url=$(get url)"; fi ;;
  stop)
    stop_servers
    echo "RESULT stopped" ;;
  *)
    echo "RESULT error=unknown-command ($CMD)"; exit 1 ;;
esac
