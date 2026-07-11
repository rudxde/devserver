- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Git
- Never commit, stage, or unstage in git unless explicitly told to.

## Additional instructions
Check the following path for additional instructions files. Only read its content if the file name is relevant to the current task.
.github/instructions

## Plans
- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.


## Nx Monorepo Guidelines
when running commands from nx, use nx alias, not npx

when running tests over jest limit the max workers to 50% with --max-workers=50%

when running in parallel (nx affected or run-many), do --parallel=3 and --max-workers=25% to limit the total system load
nx alias sets env: NX_ISOLATE_PLUGINS=false NX_DAEMON=false
