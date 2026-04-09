# Reverse Engineering Large JVM Targets With Recaf

This note captures high-signal lessons from using Recaf nightly on a large real-world JVM target.

## What Worked

- Verify the exact artifact first.
  Reverse engineering gets noisy fast if the version is wrong. Confirm the metadata, the jar path, and any local-cache mismatch before opening Recaf.

- Inventory classes before decompiling.
  For large targets, start with `jar tf` or `zipinfo` to find packages and likely entry points. This narrows the first Recaf pass to a small, intentional class list.

- Use Recaf to bulk-dump selected classes to files.
  Headless Recaf is strongest as a controlled extraction tool. A small script that decompiles 5-15 targeted classes into `/tmp/.../decompiled` is more effective than trying to read giant blobs from stdout.

- Switch to shell tools after extraction.
  Once decompiled sources are on disk, `rg` is the fastest way to follow call chains, backend selection, option flow, and repeated symbols across classes.

- Reconstruct architecture after the call graph is visible.
  First collect evidence. Then write the higher-level explanation, diagrams, and pseudocode. Doing this in the opposite order creates guesswork.

## Recaf-Specific Friction Points

- `recaf-nightly --help` is not a reliable entry point on the validated nightly.
- Recaf scripts are Java snippets, not Groovy.
- Checked exceptions must be handled inside the snippet, including file I/O.
- A script that literally contains `public class Foo` inside a string can be misclassified as a full-class script.

## Recommended Workflow

1. Verify artifact identity and version.
2. Inventory classes and packages outside Recaf.
3. Write a small Recaf script that decompiles a targeted class set to files.
4. Grep those outputs to trace the real control flow.
5. Expand the class set only when the current evidence stops explaining the system.

## Why This Pattern Scales

Recaf gives backend-aware decompilation and controlled access to the workspace model. Shell tools give speed for broad source navigation. Combining the two is more reliable than trying to do the entire investigation inside either tool alone.
