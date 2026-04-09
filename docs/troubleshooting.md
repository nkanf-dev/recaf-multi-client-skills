# Troubleshooting

## `--help` Starts The App Instead Of Printing Usage

This is a current nightly behavior. The launch path uses Picocli argument parsing, but the help flag does not short-circuit before the app initializes.

Use:

```bash
recaf-nightly -v
recaf-nightly -l
recaf-nightly -p
```

and this repository's CLI usage doc as the reference instead of depending on `--help`.

## Script Compilation Fails With A Syntax Error

Most often this means the snippet is malformed Java.

Example failure:

```java
log.info("broken"
```

Expected symptom:

- Recaf prints a compiler diagnostic
- The diagnostic includes a line number
- The script does not run

## Script Runs But Throws At Runtime

Expected symptom:

- Recaf prints `Failed to execute script`
- The stack trace points into the generated script class

Example:

```java
throw new RuntimeException("boom-from-script");
```

## `future.get()` Or Similar Calls Do Not Compile

The Recaf script wrapper does not magically handle checked exceptions. Catch them inside the snippet:

```java
try {
  DecompileResult result = dm.decompile(workspace, cls).get();
} catch (Exception e) {
  throw new RuntimeException(e);
}
```

## A Script String Contains `public class` And Recaf Misclassifies It

Recaf's script engine uses a heuristic to decide whether a snippet is a full class or a function-style script. If your snippet contains source text for another class inside a string, that heuristic can misfire.

Safer patterns:

```java
String source = "public " + "class" + " HelloRecaf { ... }";
```

or load the source from a file.

## Recaf Cannot Find A JDK 22 Toolchain

Use a Java 22 installation for this repo's validated build and runtime path.

Example:

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 22)"
java -version
```

If you're building from source and Gradle complains about toolchains, point it at JDK 22 explicitly.

## Patch Export Produced A JAR But It Still Looks Unchanged

Verify the patch in two ways:

1. Run the exported JAR with `java -cp /tmp/hello-recaf-patched.jar HelloRecaf`
2. Re-open the exported JAR in Recaf and check the decompiled body

If the runtime output is unchanged, the patch did not actually replace the class bytes.

## Verification Script Fails

The verification script assumes:

- `recaf-nightly` is on `PATH`
- JDK 22 exists at the expected path or is exposed through `JAVA_HOME`

If you use a different launcher path, set:

```bash
RECAF_BIN=/your/path/to/recaf-nightly ./scripts/verify-recaf.sh
```
