---
name: recaf-cli
description: Use when reverse engineering JVM artifacts with Recaf nightly in headless mode, especially for workspace loading, service discovery, decompilation, and scripted analysis across Codex, Gemini, or OpenCode.
---

# Recaf CLI

Use Recaf nightly as a headless workspace-plus-script engine.

## When to Use

- Load a JAR into a workspace and inspect it without opening the UI.
- Enumerate Recaf services before deciding which API to call in a script.
- Decompile classes, inspect workspace state, or prepare a patch/export flow.
- Start from `-h -i` and a small smoke script instead of guessing at UI behavior.

## Known Good Commands

```bash
recaf-nightly -v
recaf-nightly -p
recaf-nightly -l
recaf-nightly -h -i /path/to/app.jar -s /path/to/script.java
```

`recaf-nightly --help` is not a reliable entry point on the validated nightly. The current launch path parses args but does not short-circuit on help flags.

If `recaf-nightly` is not found, verify that your launcher directory is on `PATH` or call the launcher via its absolute path.

## Workflow

1. Verify the runtime with `-v`.
2. List services with `-l` if you need to know what Recaf can do in this build.
3. Load the target with `-h -i`.
4. Run a minimal script that proves `workspace` is available.
5. Escalate to decompile, patch, or export only after the smoke passes.

For large JVM targets:

1. Confirm the exact artifact and version before loading it into Recaf.
2. Inventory class names first with `jar tf` or `zipinfo`, then pick a focused class set.
3. Use a Recaf script to dump selected decompilations to files instead of streaming large output to the terminal.
4. Grep the dumped sources locally to trace backend selection, pipeline flow, and cross-class references.
5. Treat Recaf as one stage in the workflow, not the whole workflow.

## Proven Pattern For Large RE Targets

- Start with metadata and packaging evidence before decompiling.
- Narrow from package inventory to a small set of key classes.
- Bulk-decompile those classes to `/tmp/.../decompiled`.
- Use `rg` over the dumped sources to follow call chains and option flow.
- Only then write the architectural summary or pseudocode reconstruction.

## Common Mistakes

- Treating Recaf like a normal CLI app with a stable `--help` flow.
- Assuming UI-only features are available headless.
- Writing scripts in Groovy. Recaf scripts are Java snippets.
- Forgetting that scripts can fail on checked exceptions such as `future.get()`.
- Trying to decompile an entire large application mentally from one class at a time in the terminal.
- Skipping artifact verification and reverse engineering the wrong version.

## Hand Off

Use `recaf-script-authoring` when you need to write a script.
Use `recaf-patching` when you need to replace class bytes and export a modified JAR.
