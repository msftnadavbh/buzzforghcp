#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin" "$TMP/fake-path"
cp "$ROOT/bin/activate-hermit" "$TMP/bin/activate-hermit"

cat > "$TMP/fake-path/uname" <<'SH'
#!/usr/bin/env bash
printf '%s\n' MINGW64_NT-10.0-26100
SH

cat > "$TMP/bin/hermit" <<'SH'
#!/usr/bin/env bash
case "$1" in
  noop) exit 0 ;;
  activate) printf 'export HERMIT_ENV=%q\n' "$(cd "$(dirname "$0")/.." && pwd)" ;;
  env) printf '%s\n' "$HERMIT_ENV" ;;
esac
SH

chmod +x "$TMP/fake-path/uname" "$TMP/bin/hermit"

output=$(
  unset HERMIT_STATE_DIR
  export HOME="$TMP/home"
  export PATH="$TMP/fake-path:$PATH"
  # shellcheck disable=SC1091
  source "$TMP/bin/activate-hermit"
  printf 'state=%s\n' "$HERMIT_STATE_DIR"
)

expected="state=$TMP/home/.cache/hermit"
if [[ "$output" != *"$expected"* ]]; then
  printf 'Git Bash activation did not set the expected state directory.\n%s\n' "$output" >&2
  exit 1
fi

printf 'Git Bash Hermit activation: PASS\n'

cat > "$TMP/bin/hermit" <<'SH'
#!/usr/bin/env bash
exit 23
SH
chmod +x "$TMP/bin/hermit"

if (
  unset HERMIT_STATE_DIR
  export HOME="$TMP/home"
  export PATH="$TMP/fake-path:$PATH"
  # shellcheck disable=SC1091
  source "$TMP/bin/activate-hermit"
); then
  printf 'Hermit activation unexpectedly succeeded when bootstrap failed.\n' >&2
  exit 1
fi

printf 'Hermit activation failure propagation: PASS\n'
