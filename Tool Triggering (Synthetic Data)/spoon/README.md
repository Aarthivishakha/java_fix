# Spoon — AST and def-use analysis

Named in the sheet's prose alongside ba-dua and ASM-DefUse for the 16 Data Flow metrics.
INRIA/spoon, actively maintained, gives a real AST with resolved references — the
recommended replacement now that ba-dua is ruled out by its Java 10 ceiling.

    java -cp tools/spoon/spoon.jar:<classpath> com.pramora.testable.tools.SpoonDefUse <src-dir>

Requires a small driver class against the Spoon API; the analyser itself is not a CLI.
Bundled: Spoon 11.5.0 (`spoon.jar`; 11.5.1 is not released). Requires JDK 17+, so it is unavailable on the java8 and java11
families — the runner exits 3 there.
