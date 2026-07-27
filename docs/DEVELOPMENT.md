# SaveRoom Scanner App Development Workflow

Tags: #type/reference

## Overview

This is the normal SaveRoom Scanner App development loop for Hermes + Matthew on the Windows PC emulator.

Default rule: Matthew should not need manual terminal commands for normal pull/test work. Use GitHub Desktop and VS Code UI first.

## Body

### Normal Matthew UAT flow

1. Hermes makes the requested change in the repo it is operating in.
2. Hermes states where it worked: machine/location, repo path, branch, and files touched.
3. Hermes validates the change and pushes a testable commit or branch to GitHub.
4. Matthew uses GitHub Desktop: `Fetch origin` then `Pull origin`.
5. Matthew opens the project in VS Code.
6. Matthew selects the Android emulator target.
7. Matthew uses VS Code Run/Play.
8. Matthew tests on the emulator.
9. Matthew reports pass/fail, screenshots, or notes.
10. Matthew says `save all` when the change is accepted.
11. Hermes finalizes: status/diff check, tests, commit/push, repo docs, SaveRoom Brain notes, and next-iteration recommendation.

### VS Code run

Matthew normally tests with the Zima API running, so use the regular VS Code Play button with the Android emulator selected. Keep this boring unless there is a real reason to add custom run profiles.

### Hot reload / hot restart

Flutter hot reload works while a VS Code/Flutter debug session is already running.

Use hot reload for local Dart UI edits. Use hot restart or press Play again after pulling larger changes from GitHub.

The Android emulator does not need to be recreated for normal changes. Keep one stable API 36 emulator and reuse it.

### When terminal commands are allowed

Manual commands are exception-only. If Hermes asks Matthew to run one, Hermes must state:

- Needed because: why UI flow is not enough.
- Run in: VS Code terminal, standalone PowerShell, CMD, or another exact shell.
- From folder: exact folder path.
- Expected result: what success looks like, including if silent success is normal.

### GitHub Desktop role

GitHub Desktop is Matthew's preferred pull UI. It does the same job as terminal `git pull`, but with buttons.

Use it for:

- Fetch origin
- Pull origin
- Seeing whether local files changed

Hermes owns commit/push/final docs during the `save all` step unless Matthew explicitly wants to do it locally.

### CI role

GitHub Actions runs format/analyze/tests after pushes and pull requests. It is not a replacement for Matthew's emulator UAT.

CI catches code-level breakage. Matthew catches real app feel, visual issues, emulator/API behaviour, and business acceptance.

## Links

- Related: [PC_EMULATOR_WORKFLOW.md](PC_EMULATOR_WORKFLOW.md)
- Related: [REAL_API_EMULATOR_TESTING.md](REAL_API_EMULATOR_TESTING.md)
- Related: [ROADMAP.md](ROADMAP.md)
