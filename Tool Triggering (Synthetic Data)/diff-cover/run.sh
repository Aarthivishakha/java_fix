#!/usr/bin/env bash
# Runner for diff-cover. Standalone tool - identical invocation on every build system.
# Exit contract: 0 ran / 1 failed / 3 skipped-cannot-run / 4 not-installed.
set -u
cd "$(dirname "$0")/../.." || exit 1
T="Tool Triggering (Synthetic Data)"
command -v diff-cover >/dev/null 2>&1 || exit 4
mkdir -p "$T/diff-cover/out"

# source root differs between the monolith and multi-module layouts
SRC=$(ls -d */src/main/java 2>/dev/null | head -1)
[ -n "${SRC:-}" ] || SRC="src/main/java"
[ -d "$SRC" ] || exit 3

# tools that read a coverage report need the jacoco runner to have gone first
JACOCO_XML=$(find . \( -name 'jacoco.xml' -o -name 'jacocoTestReport.xml' \) 2>/dev/null | head -1)
CK_JAR="${CK_JAR:-$T/ck/ck.jar}"

# a tool whose artefact is absent is not-installed (4); a missing input is skipped (3)
case "diff-cover" in
  ck)         [ -f "$CK_JAR" ] || exit 4 ;;
  spoon)      [ -f "$T/spoon/spoon.jar" ] || exit 4 ;;
  asm-defuse) [ -f "$T/asm-defuse/asm-defuse.jar" ] || exit 4 ;;
  ba-dua)     [ -f "$T/ba-dua/ba-dua-cli.jar" ] || exit 4 ;;
  diff-cover) [ -n "${JACOCO_XML:-}" ] || exit 3 ;;
esac

BASE="${BASE_BRANCH:-main}"
git rev-parse --verify -q "$BASE" >/dev/null || BASE="origin/main"
diff-cover "$JACOCO_XML" --compare-branch="$BASE" --html-report "$T/diff-cover/out/report.html"
rc=$?
# propagate the tool's own skipped/not-installed codes instead of flattening them to 1
case $rc in
  0) exit 0 ;;
  3|4) exit $rc ;;
  *) exit 1 ;;
esac
