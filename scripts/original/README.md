# Original synthesis and gate-level scripts

The five shell files in this directory are unchanged historical project assets.
The runnable portfolio flow is `make test` from the repository root; it runs RTL
simulation independently of these scripts.

| Script | Original role |
| --- | --- |
| `syn6.sh`, `syn12.sh` | Invoke Design Compiler with a candidate clock constraint |
| `sim_gate6.sh`, `sim_gate12.sh` | Compile mapped netlists and run SDF simulation |
| `sweep_syn_sim.sh` | Sweep candidate periods and save passing/failing waveforms |

The supplied snapshot does not include the referenced `syn/bist_syn.tcl`,
generated netlists, SDF files, standard-cell simulation model, synthesis
library setup, or raw timing logs. Paths also assume the original `scripts/`
and `tb/` hierarchy and a course-machine waveform archive location. A full
gate-level reproduction requires restoring that environment and validating
the flow before using its output as a timing measurement.

Two implementation details matter when restoring it:

- Both testbenches parse `+SDF` but pass a literal default path to
  `$sdf_annotate`; the plusarg does not actually change the annotated file.
- The sweep may continue after a failed synthesis if old netlist/SDF files
  still exist. Candidate outputs and logs must be verified fresh before a
  pass is assigned to that candidate.

The archived scripts are not run or repaired by the portfolio helpers.
See [performance evidence](../../docs/PERFORMANCE.md) for the historical result scope.
