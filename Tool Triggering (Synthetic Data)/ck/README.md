# CK — Chidamber & Kemerer metrics

The sheet's **primary** tool for all six Cyclomatic Complexity metrics. A standalone jar,
not a Maven or Gradle plugin, which is why it is invoked from here rather than the build file.

    java -jar "Tool Triggering (Synthetic Data)/ck/ck.jar" <src-dir> true 0 false out/

Produces `class.csv`, `method.csv`, `field.csv`, `variable.csv`. `method.csv` carries the
`wmc` column — the McCabe-based figure the Cyclomatic Complexity block derives from.

Pinned: CK 0.7.0. Parser: Eclipse JDT Core 3.26.0.

**Known ceiling:** JDT 3.26.0 parses up to Java 16. On the java17 family and above this
tool must be rebuilt against a newer JDT. Recorded as a roster defect, not a repo defect.
