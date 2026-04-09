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

## When Not to Use

- If you need a UI interaction or a plugin, do not force it into a snippet.
- If the task is only export or patch orchestration, use `recaf-patching`.
