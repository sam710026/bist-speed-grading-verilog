# Project rules

- The main agent supervises changes, verification and publication; delegate independent tasks when useful.
- Preserve submitted RTL, original testbenches, scripts and PDFs unless a change is explicitly requested.
- Keep new verification/packaging helpers separate from the original materials.
- Distinguish the report's historical speed results from fresh RTL simulation.
- A 15-pattern BIST pass does not establish exhaustive fault or timing coverage.
- Use `make check` for documentation/packaging changes and `make test` for relevant RTL/runner changes.
- Never commit EDA libraries, license configuration, generated executables or waveforms.
- The original synthesis/gate sweep is incomplete in the provided snapshot; do not invent missing netlists, SDF, reports or synthesis constraints.
