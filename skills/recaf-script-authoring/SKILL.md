---
name: recaf-script-authoring
description: Use when writing or debugging Recaf headless Java snippet scripts, especially when accessing workspace objects, CDI services, decompilers, or checked-exception APIs.
---

# Recaf Script Authoring

Recaf headless scripts are Java snippets wrapped into a generated `Runnable` and executed inside Recaf's CDI container.

## What Is Available

- `workspace`
- `log`
- `Bootstrap.get()`
- `Recaf.get(...)`

## Minimal Pattern

```java
Recaf recaf = Bootstrap.get();
DecompilerManager dm = recaf.get(DecompilerManager.class);
log.info("primary classes = {}", workspace.getPrimaryResource().getJvmClassBundle().size());
```

## Writing Rules

- Write Java snippet code, not Groovy.
- Catch checked exceptions explicitly.
- Prefer small scripts with one responsibility.
- Keep imports minimal and only add what the script actually uses.
- When a script writes files or creates directories, wrap that file I/O in `try/catch` too.
- For large reverse-engineering tasks, prefer scripts that dump artifacts to files over scripts that only log to stdout.

## Good Example

```java
Recaf recaf = Bootstrap.get();
DecompilerManager dm = recaf.get(DecompilerManager.class);
var cp = workspace.findJvmClass("HelloRecaf");
if (cp == null) throw new RuntimeException("class not found");
JvmClassInfo cls = (JvmClassInfo) cp.getValue();
try {
  DecompileResult result = dm.decompile(workspace, cls).get();
  log.info("decompile ok = {}", result.getText() != null);
} catch (Exception e) {
  throw new RuntimeException(e);
}
```

## Failure Modes

- Compile errors should be handled by reading Recaf diagnostics, not by guessing.
- Runtime errors surface as stack traces from the generated script class.
- A script string that literally contains `public class Foo` can be misclassified as a full class script. If you need to embed source text, split the literal or read it from a file.
- File helpers such as `Files.createDirectories(...)` and `Files.writeString(...)` still need checked-exception handling inside snippet scripts.
- Long decompilation output is easier to work with when written to `/tmp/...` and grepped afterward than when logged directly.

## Reverse-Engineering Notes

- For large artifacts, build a script that decompiles a targeted class list to files.
- Keep the class list explicit and small enough to reason about.
- After dumping, use external tools such as `rg` to trace references and option flow across the decompiled sources.
- Use Recaf for controlled extraction and backend-aware decompilation, not for every downstream analysis step.

## When Not to Use

- If you need a UI interaction or a plugin, do not force it into a snippet.
- If the task is only export or patch orchestration, use `recaf-patching`.
