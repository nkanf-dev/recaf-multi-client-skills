---
name: recaf-patching
description: Use when replacing JVM class bytes inside a Recaf workspace, recompiling patched classes, exporting a modified JAR, and verifying runtime behavior in headless workflows.
---

# Recaf Patching

Use this skill for the validated patch loop:

1. compile replacement bytes
2. write them back into the workspace bundle
3. export a new JAR
4. verify the output with a plain JVM run

## Validated APIs

- `JavacCompiler`
- `CompilerResult`
- `JvmClassBundle.put(...)`
- `WorkspaceExportOptions`
- `PathWorkspaceExportConsumer`
- `WorkspaceExporter`

## Patch Loop

```java
Recaf recaf = Bootstrap.get();
JavacCompiler javac = recaf.get(JavacCompiler.class);
CompilerResult result = javac.compile(args, workspace, null);
if (!result.wasSuccess()) throw new RuntimeException("compile failed");
byte[] bytes = result.getCompilations().get("HelloRecaf");
JvmClassInfo updated = new JvmClassInfoBuilder(bytes).build();
workspace.getPrimaryResource().getJvmClassBundle().put(updated);
WorkspaceExporter exporter = new WorkspaceExportOptions(
    WorkspaceCompressType.MATCH_ORIGINAL,
    WorkspaceOutputType.FILE,
    new PathWorkspaceExportConsumer(Paths.get("/tmp/hello-recaf-patched.jar"))
).create();
exporter.export(workspace);
```

## Caveats

- Recaf script snippets are Java snippets, so keep the patch script as a snippet, not as an embedded full class definition.
- Do not embed the exact literal sequence `public class Foo` inside a script string. Recaf's script engine can mis-detect that as a full class script.
- If you call APIs such as `future.get()`, catch checked exceptions and rethrow as runtime errors if you want the script to fail cleanly.

## Verification

Always verify the patched JAR outside Recaf:

```bash
java -cp /tmp/hello-recaf.jar HelloRecaf
java -cp /tmp/hello-recaf-patched.jar HelloRecaf
```

If the patched output does not change, do not assume export worked. Re-run the headless patch script and inspect diagnostics first.
