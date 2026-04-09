# Recaf CLI Usage

This repository documents the Recaf nightly entry points that were validated locally for headless automation.

## Known-Good Commands

```bash
recaf-nightly -v
recaf-nightly -p
recaf-nightly -l
recaf-nightly -h -i /path/to/app.jar
recaf-nightly -h -i /path/to/app.jar -s /path/to/script.java
```

## What These Flags Do

- `-v`, `--version` prints the Recaf build version, git hash, and git time.
- `-p`, `--listprops` prints system properties.
- `-l`, `--listservices` prints the active CDI services.
- `-h`, `--headless` skips the UI and runs input handling in the background.
- `-i`, `--input` loads an input file or archive into a workspace.
- `-s`, `--script` runs a startup script inside the loaded workspace.
- `-q`, `--silent` disables logging to stdout.
- `-d`, `--datadir` overrides Recaf's data directory.
- `-r`, `--extraplugins` adds an additional plugin directory.

## Help Caveat

Do not rely on `recaf-nightly --help` on the validated nightly build. The current launch path parses arguments but does not short-circuit on help flags, so the application continues booting instead of printing usage.

Use this file as the canonical short reference instead.

## Headless Workflow

The validated workflow is:

1. Verify the runtime with `recaf-nightly -v`
2. Check available services with `recaf-nightly -l`
3. Load a JAR with `recaf-nightly -h -i /path/to/app.jar`
4. Attach a Java snippet with `-s`
5. Use `workspace`, `log`, and CDI services inside the snippet

## Script Shape

Recaf startup scripts are Java snippets. They are wrapped into a generated `Runnable` and executed inside Recaf's CDI container.

Minimal example:

```java
log.info("primary jvm classes = {}", workspace.getPrimaryResource().getJvmClassBundle().size());
```

Service access example:

```java
Recaf recaf = Bootstrap.get();
DecompilerManager dm = recaf.get(DecompilerManager.class);
```

## Common Failure Modes

- Compile failure: Recaf prints diagnostics with line numbers and a compiler message.
- Runtime failure: Recaf prints the stack trace from the script execution thread.
- Checked exception in a script: the script must catch it explicitly.
- String-literal class detection: avoid placing the literal `public class Foo` directly inside a script string.
