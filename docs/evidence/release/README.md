# Fresh portfolio verification

Date: 2026-11-11 (Asia/Taipei). Tool: VCS X-2025.06.

After loading the licensed VCS environment, from repository root:

```bash
python3 scripts/run_tests.py
```

[Results](results.tsv) show seven directed pure-adder checks and successful
golden-signature completion for both BIST widths at a 10,000 ps testbench
period. [Run metadata](run.json) records tested source identities.

This is RTL simulation without mapped delays, SDF annotation or gate timing
checks. It does not re-establish the report's fastest passing periods.
Both original benches print `cycles=16` because their active-region loop reads
`done` before the DUT nonblocking update; the RTL performs 15 response captures.
The final comparison occurs on a falling edge after the registers have settled.

Logs include compile and simulation output, with the local project prefix
replaced by `<project>/`. Full build trees and generated VCD files are excluded.
