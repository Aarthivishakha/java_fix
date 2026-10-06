# Testable Java corpus — JV_V16_MAVEN_THINJAR_MONO

Grid cell `MVN-THIN-M` of the 24-cell Java grid.

## Project type

Order pricing and risk domain. The domain layer is byte-identical across all 24 branches
in this family, so any difference in tool output is attributable to the branch variables
below and not to the code the tool was pointed at.

## Branches

Branch `java_all_tool` of `java-fix` was built from `testable-platform/java-corpus`
branch `JV_V16_MAVEN_THINJAR_MONO`, with its full git history kept. Java 16 is the only
version where all 13 tools below run: CK stops at Java 16 and Spoon starts at Java 12.
See `dataset.json` for the machine-readable description of this branch.

## Branch variables

| Variable | Value |
|---|---|
| Java version | 16 |
| Host JDK | 17 |
| Build system | Maven |
| Packaging | Thin jar |
| Architecture | Monolith |

## Supported tools

13 tools are wired on this branch (one `Tool Triggering (Synthetic Data)/<dir>/` folder
each), and **all 13 run on JDK 16 (host JDK 17)**. The corpus tools that cannot run
here (`asm-defuse`, `ba-dua`, `custom-def-use`, `nullaway`, `sonar`) and `grype` were removed.

| Tool | Role | Block |
|---|---|---|
| `checkstyle` | primary | Lint / Rule Violations |
| `ck` | primary | Cyclomatic Complexity |
| `cpd` | primary | Code Duplication |
| `diff-cover` | primary | Coverage Delta |
| `git-churn` | primary | Code Churn |
| `jacoco` | primary | Statement / Branch / Path Coverage |
| `lizard` | alternative | Cyclomatic Complexity |
| `owasp-dependency-check` | primary | Dependency Risk (SCA) |
| `pit` | primary | Mutation Score |
| `pmd` | primary | Cognitive Complexity |
| `pydriller` | alternative | Code Churn |
| `spoon` | primary | Data Flow Testing (Def-Use) |
| `spotbugs` | primary | Static Vulnerabilities (SAST) |

## Build

```
mvn -B clean package
```

Main and test sources both compile at Java 16 (bytecode major version 60), built by
`javac 17` with `--release 16`.

**Two more preview arcs land here.** Records (JEP 395) and pattern matching for
{@code instanceof} (JEP 394) both became final in Java 16 after preview in 14 and a second
preview in 15 - the third and fourth three-release arcs in this corpus, after switch
expressions (12, 13, final 14) and text blocks (13, 14, final 15). Four headline features,
four families that could not use them, and the reason java12 and java13 have API-only locks.

The Java 16 lock is deliberately split across three files, one lock kind per file:

| File | Lock | Kind |
|---|---|---|
| `model/ShipmentLeg.java` | record declaration + compact canonical constructor | parse-time |
| `analysis/RouteDescriber.java` | pattern matching for `instanceof` | parse-time |
| `analysis/RoutePlanner.java` | `Stream.toList`, `Stream.mapMulti` | attribution-time |

### Why the split, and why the lock count depends on how you compile

`javac` halts at the first syntax error **in a file**, so an API lock that shares a file with
a syntax lock can never be reported. Compiling the whole family at `--release 15` gives
**2 errors**. Compiling each file separately, with the family's own compiled classes on the
classpath, gives **5**:

```
ShipmentLeg.java     records are not supported in -source 15
RouteDescriber.java  pattern matching in instanceof is not supported in -source 15
RoutePlanner.java    cannot find symbol: method mapMulti(...)
RoutePlanner.java    cannot find symbol: method toList()
RoutePlanner.java    cannot find symbol: method toList()
```

Same source, same release, two and a half times the locks. The whole-family number is not
wrong, it just answers a different question - *does this branch build?* rather than *how many
independent things pin it to this version?* Earlier families measured the second number by
neutralising the syntax lock in a scratch copy, which needs a hand-written stand-in per
family and silently under-reports if the stand-in drifts. Per-file compilation needs nothing
hand-written and cannot drift, so it replaces that step from this family on.

**Sealed types are deliberately absent.** They were in their second preview in Java 16 and
became final in Java 17, so they belong to that family - and they are what java17's
`model/PricingEvent.java` already uses.

Forward-checked at `--release 17, 21` and `25`: clean.

Java 16 is **not an LTS release**. It shipped March 2021 and reached end of life in
September 2021, six months later. It is in this corpus to complete the version axis, not as
a recommendation.

Produces: `dist/jv-265.jar or target/jv-265-1.0.0.jar`

## Run

```
java -jar <artifact> O-1234
```

## Test

```
mvn -B test
```

## Workspace projects

- `src/main/java/` (single module)


## Tool test-data folders

Three sibling folders sit at the repo root, alongside this branch's own
`Tool Triggering (Synthetic Data)/` (above).

### `Tool Triggering (Tool Github Test data)/`
12 of the 13 tools carry their own real upstream test suite or source, pulled
as-is from that tool's GitHub project: `CK/`, `Spoon/`, `JaCoCo/`, `PMD/`,
`SpotBugs/` (with `FindSecBugs/`), `Checkstyle/`, `CPD/`, `PIT/`,
`OWASP Dependency-Check/`, `Lizard/`, `diff-cover/` and `pydriller/`.
`git-churn` has no folder because it is git's own log, not a packaged tool.

### `Tool Clean (Synthetic Data)/`
Most tools here carry 5 generated fixture packages, one per representative
JDK family (8, 9, 16, 24, 25), engineered to be clean so the tool should
report zero findings: the **Tool Clean (100% pass)** condition.

### `Tool Invalid (Synthetic Data)/`
Same shape as Clean -- the same 5-JDK-family fixtures -- but engineered so
every fixture makes the tool flag or fail rather than pass: the
**Tool Invalid** condition. `diff-cover` and `pydriller` each carry one real
git repository's worth of history in both Clean and Invalid rather than 5
per-version copies, restored from `_git-bundles/` via `restore-git.ps1`
rather than kept as a live `.git` folder, so a plain file copy never
silently drops their content.

## Tool entry points

Each tool has `Tool Triggering (Synthetic Data)/<tool>/trigger.yaml` and `Tool Triggering (Synthetic Data)/<tool>/run.sh`. Runners follow the
exit-code contract: 0 ran, 1 failed, 3 skipped-cannot-run, 4 not-installed.
Run them from anywhere, e.g. `"./Tool Triggering (Synthetic Data)/ck/run.sh"`; output
goes to `Tool Triggering (Synthetic Data)/<tool>/out/` (git-ignored).

What each runner needs on the machine:

| Tools | Needs |
|---|---|
| `checkstyle`, `cpd`, `pmd`, `spotbugs`, `jacoco`, `pit`, `owasp-dependency-check` | Maven + JDK 17 or newer (OWASP also downloads the NVD database) |
| `ck`, `spoon` | JDK 17 or newer; the jars are bundled (`ck/ck.jar` = CK 0.7.0, `spoon/spoon.jar` = Spoon 11.5.0) |
| `git-churn` | git |
| `lizard` | `pip install lizard` |
| `pydriller` | `python3` + `pip install pydriller` |
| `diff-cover` | `pip install diff-cover`; run `jacoco` first. Compares against `main` (or `origin/main`, or `$BASE_BRANCH`) |

## Planted CVE pins

| Dependency | Version |
|---|---|
| `commons-collections:commons-collections` | 3.2.1 |
| `org.apache.commons:commons-text` | 1.9 |
| `com.fasterxml.jackson.core:jackson-databind` | 2.9.10.1 |
| `log4j:log4j` | 1.2.17 |
| `org.yaml:snakeyaml` | 1.30 |

Deliberately vulnerable versions, so the SCA metrics have known true positives. Do not
upgrade them.
