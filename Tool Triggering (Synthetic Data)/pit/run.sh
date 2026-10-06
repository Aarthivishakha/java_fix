#!/usr/bin/env bash
# Runner for pit on the MVN build. Exit contract: 0 ran / 1 failed / 3 skipped-cannot-run / 4 not-installed.
set -u
cd "$(dirname "$0")/../.." || exit 1
command -v mvn >/dev/null 2>&1 || exit 4
mvn -B -q org.pitest:pitest-maven:mutationCoverage
rc=$?
[ $rc -eq 0 ] && exit 0
exit 1
