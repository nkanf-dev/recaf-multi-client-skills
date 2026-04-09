#!/bin/zsh
set -euo pipefail

RECAF_BIN="${RECAF_BIN:-$HOME/bin/recaf-nightly}"
JAVA_HOME="${JAVA_HOME:-$HOME/.jdks/jdk-22.0.2+9/Contents/Home}"
JAVAC_BIN="$JAVA_HOME/bin/javac"
JAVA_BIN="$JAVA_HOME/bin/java"
JAR_BIN="${JAR_BIN:-/usr/bin/jar}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [ ! -x "$RECAF_BIN" ]; then
  echo "recaf binary not found: $RECAF_BIN" >&2
  exit 1
fi

mkdir -p "$TMP_DIR/classes"
cat > "$TMP_DIR/HelloRecaf.java" <<'EOF'
public class HelloRecaf {
  public static void main(String[] args) {
    System.out.println(secret());
  }
  public static String secret() {
    return "recaf-smoke";
  }
}
EOF

"$JAVAC_BIN" -d "$TMP_DIR/classes" "$TMP_DIR/HelloRecaf.java"
(cd "$TMP_DIR/classes" && "$JAR_BIN" --create --file "$TMP_DIR/hello-recaf.jar" HelloRecaf.class)

"$RECAF_BIN" -v >/dev/null
"$RECAF_BIN" -l >/dev/null
"$RECAF_BIN" -h -i "$TMP_DIR/hello-recaf.jar" -s "$ROOT/examples/smoke/workspace-smoke.java" >/dev/null
"$RECAF_BIN" -h -i "$TMP_DIR/hello-recaf.jar" -s "$ROOT/examples/smoke/decompile-smoke.java" >/dev/null
"$RECAF_BIN" -h -i "$TMP_DIR/hello-recaf.jar" -s "$ROOT/examples/patching/patch-export.java" >/dev/null

if [ ! -f /tmp/hello-recaf-patched.jar ]; then
  echo "patched jar was not produced" >&2
  exit 1
fi

ORIGINAL_OUT="$("$JAVA_BIN" -cp "$TMP_DIR/hello-recaf.jar" HelloRecaf)"
PATCHED_OUT="$("$JAVA_BIN" -cp /tmp/hello-recaf-patched.jar HelloRecaf)"

if [ "$ORIGINAL_OUT" != "recaf-smoke" ]; then
  echo "unexpected original output: $ORIGINAL_OUT" >&2
  exit 1
fi

if [ "$PATCHED_OUT" != "patched-by-recaf" ]; then
  echo "unexpected patched output: $PATCHED_OUT" >&2
  exit 1
fi

echo "Recaf verification passed"
