# Recaf Multi-Client Skills

Shared Recaf headless automation skills for Codex, Gemini, and OpenCode.

This repository focuses on validated headless workflows:

- install or build Recaf nightly
- set up a compatible JDK 22 toolchain
- load a target JAR into a Recaf workspace
- run Java snippet scripts inside Recaf
- inspect services and decompile classes
- compile replacement classes, update the workspace, and export a patched JAR

It does not try to be a general Recaf plugin distribution. The goal is a small, reusable skill set that is easy to install on multiple clients without duplicating content.

## What Is Included

- [`skills/recaf-cli/SKILL.md`](skills/recaf-cli/SKILL.md)
- [`skills/recaf-script-authoring/SKILL.md`](skills/recaf-script-authoring/SKILL.md)
- [`skills/recaf-patching/SKILL.md`](skills/recaf-patching/SKILL.md)
- [`examples/`](examples)
- install helpers for Codex, Gemini, and OpenCode

## Validated Behavior

These behaviors were exercised locally against a current Recaf 4.x nightly build:

- `recaf-nightly -v`
- `recaf-nightly -p`
- `recaf-nightly -l`
- `recaf-nightly -h -i /path/to/app.jar`
- `recaf-nightly -h -i /path/to/app.jar -s /path/to/script.java`
- `workspace` and `log` are available inside scripts
- `Bootstrap.get()` returns the active Recaf container
- `DecompilerManager` can decompile classes
- `JavacCompiler` can compile replacement class bytes
- `JvmClassBundle.put(...)` updates the workspace
- `WorkspaceExportOptions` can export a patched JAR

## Requirements

- macOS or another platform supported by Recaf
- Java 22 for Recaf's Gradle toolchain and runtime
- Git
- GitHub CLI if you want to publish or install from a remote repository

## Install Recaf Nightly

Recaf 4.x current nightlies are built from the `master` branch and distributed through the Recaf launcher / CI path.

### Option A: Use The Official Launcher

Follow the launcher instructions in the Recaf launcher repository, then point it at the current 4.x nightly.

### Option B: Build From Source

```bash
git clone https://github.com/Col-E/Recaf.git
cd Recaf
JAVA_HOME=/path/to/jdk-22 ./gradlew :recaf-ui:shadowJar -x test
```

The build output is the `recaf-ui-*-all.jar` artifact under `recaf-ui/build/libs/`.

### Recommended Local Launcher

Create a small wrapper that pins the JDK 22 runtime:

```bash
#!/bin/zsh
JAVA_HOME=/path/to/jdk-22
exec "$JAVA_HOME/bin/java" -jar /path/to/recaf-ui-4.0.0-SNAPSHOT-all.jar "$@"
```

This repository assumes a launcher named `recaf-nightly` is available on your `PATH`.

## Install JDK 22

Recaf nightly currently expects Java 22 for a clean build and run experience.

Homebrew example:

```bash
brew install --cask temurin@22
```

Then point Recaf to that JDK:

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 22)"
export PATH="$JAVA_HOME/bin:$PATH"
java -version
```

## Verify Recaf

The current nightly validates these commands:

```bash
recaf-nightly -v
recaf-nightly -p
recaf-nightly -l
```

Important caveat: `recaf-nightly --help` does not short-circuit correctly on the validated nightly build, so do not depend on it as the primary help path.

## Install The Skills

The repository keeps one shared skill source tree and installs it into each client separately.

### Codex

```bash
./scripts/install-codex.sh
```

Expected destination:

```text
~/.codex/skills/
```

### Gemini

```bash
./scripts/install-gemini.sh
```

Expected destination:

```text
~/.gemini/skills/
```

### OpenCode

```bash
./scripts/install-opencode.sh
```

OpenCode may use a config-based skills path or symlinks depending on local setup. The repository documents both paths.

## Verify The Skills

Run the verification helper after installing Recaf and the skills:

```bash
./scripts/verify-recaf.sh
```

The script creates a tiny test JAR, loads it into Recaf, and checks the headless analysis path.

## Example Workflows

### Workspace Smoke

Open a JAR and confirm the workspace sees the expected class:

```bash
recaf-nightly -h -i /path/to/app.jar -s examples/smoke/workspace-smoke.java
```

### Decompile Smoke

```bash
recaf-nightly -h -i /path/to/app.jar -s examples/smoke/decompile-smoke.java
```

### Patch And Export

```bash
recaf-nightly -h -i /path/to/app.jar -s examples/patching/patch-export.java
java -cp /tmp/hello-recaf-patched.jar HelloRecaf
```

## Caveats

- Recaf scripts are Java snippets, not Groovy.
- Scripts that contain the literal text `public class Foo` inside source strings can be misclassified by the script engine. Break the literal apart or load source from a file.
- Checked exceptions such as `future.get()` must be handled inside the script.
- This repository documents validated headless workflows. It does not promise that every UI-first Recaf feature will work in headless mode.

## Troubleshooting

See [`docs/troubleshooting.md`](docs/troubleshooting.md) for the common failure cases and the exact symptoms we validated.

## CLI Reference

See [`docs/recaf-cli-usage.md`](docs/recaf-cli-usage.md) for the validated command set and usage notes.

## License

MIT
