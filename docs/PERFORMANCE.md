# Performance and validation

The timing figures below are historical results reported in the [original coursework report](report/BISG_Adder_Report.pdf), sections 5–7. The release's fresh RTL simulations verify functional signatures; they do not reproduce those gate-level timing measurements.

## Historically reported timing

| Configuration | Reported smallest passing period | Equivalent frequency | Next faster tested period, reported failing | Golden signature |
| --- | --- | --- | --- | --- |
| 6-bit adder, 7-bit MISR | 800 ps | 1250 MHz | 700 ps | `0x4d` |
| 12-bit adder, 13-bit MISR | 1000 ps | 1000 MHz | 900 ps | `0x458` |

Frequency is calculated as `1,000,000 / period_ps` in MHz. The clock-period search uses 100 ps steps and stops at the first failure after a passing candidate.

The historical procedure resynthesizes the design for **each candidate clock period**, then uses the same period for gate-level SDF simulation. These numbers describe the best reported passing candidates across separately synthesized implementations. They are not a fixed-netlist Fmax measurement or silicon results. The 15-pattern signature test also does not prove worst-case timing over all possible input transitions.

The report additionally records 6-bit RTL and gate-level success at 100 MHz. Its waveform illustrations support the reported final signatures and show unknown signature values in failing examples, but the cropped screenshots are insufficient to independently validate the stated clock periods. No area, power, cell-count, timing-slack, or fault-coverage result is claimed here.

## Fresh functional validation

A fresh run with licensed Synopsys VCS 2025.06 passed:

| Test | Result |
| --- | --- |
| Pure 6-bit adder | All seven original directed checks passed |
| 6-bit BIST at `PERIOD_PS=10000` | Signature `0x4d`, `done=1`, `HW3_PASS` |
| 12-bit BIST at `PERIOD_PS=10000` | Signature `0x458`, `done=1`, `HW3_PASS` |

Both BIST testbenches print 16 loop iterations; the RTL performs 15 response captures, as explained in [Architecture](ARCHITECTURE.md#response-compaction-and-completion).

Evidence is recorded in [results.tsv](evidence/release/results.tsv), [run.json](evidence/release/run.json), and the individual [adder](evidence/release/adder6.log), [6-bit BIST](evidence/release/bist6.log), and [12-bit BIST](evidence/release/bist12.log) logs. `make test` runs the functional checks using Python 3.6+ and licensed VCS; it does not require DesignWare. `make check` verifies the preserved-source manifest. RTL simulation at a specified period does not model standard-cell delays or establish that period as an implementation timing limit.

## Limits of historical timing reproduction

The [preserved scripts](../scripts/original) document the original flow, but the snapshot lacks `syn/bist_syn.tcl`, generated netlists/SDF, raw synthesis and gate-simulation logs, timing reports, and required technology-library files. The reported boundaries therefore remain attributed historical results. See [Provenance](PROVENANCE.md) for artifact origins.

Two implementation details also limit reliance on the historical automation:

- The sweep allows a nonzero synthesis status when netlist and SDF files exist, without first deleting those outputs. A failed candidate can therefore reuse stale synthesis artifacts. Candidate simulation logs are also not cleared before retrying the same period.
- The original gate testbenches parse and print `+SDF`, but `$sdf_annotate` uses a literal default filename. Changing that plusarg does not change the annotated file.

The sweep's acceptance rule checks simulator status, an `HW3_PASS` marker, and selected timing-violation strings. It does not independently establish fresh synthesis outputs, full SDF annotation, or static timing closure. The original flow is retained as historical material rather than presented as a complete timing-signoff environment.
