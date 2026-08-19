#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

make_command() {
  local name=$1
  local output=$2
  cat > "$TMP/$name" <<SH
#!/usr/bin/env bash
printf '%s\n' '$output'
SH
  chmod +x "$TMP/$name"
}

make_command cargo "cargo 1.95.0"
make_command rustc "rustc 1.95.0 (test)"
make_command node "v24.15.0"
make_command pnpm "11.4.0"

output=$(PATH="$TMP:/usr/bin:/bin" "$ROOT/scripts/check-windows-build-prereqs.sh")
grep -q 'Windows build prerequisites: PASS' <<<"$output"

rm "$TMP/rustc"
if PATH="$TMP:/usr/bin:/bin" "$ROOT/scripts/check-windows-build-prereqs.sh" >/dev/null 2>&1; then
  printf 'Prerequisite check unexpectedly passed without rustc.\n' >&2
  exit 1
fi

printf 'Windows prerequisite checker: PASS\n'
