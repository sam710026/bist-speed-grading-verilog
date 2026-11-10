# Provenance and source preservation

This project presents the design by [sam710026](https://github.com/sam710026)
(蕭以勝) for National Tsing Hua University, EE-6250 VLSI Testing,
Homework 3 Option 2. The supplied snapshot was the local `BISG` directory.

## Original assets

All 11 supplied files are preserved byte-for-byte. The original directory was
not modified. [ORIGINAL_SOURCES.json](ORIGINAL_SOURCES.json) maps each original
filename to its portfolio location and SHA-256 checksum.

| Original material | Portfolio location |
| --- | --- |
| `bist_adder.v` | `src/bist_adder.v` |
| Three Verilog testbenches | `tests/original/` |
| Five Bash scripts | `scripts/original/` |
| `homework.3.Option2.2026.pdf` | `docs/spec/homework.3.Option2.2026.pdf` |
| `110070016_蕭以勝_HW3_Option2_BISG_Adder_Report.pdf` | `docs/report/BISG_Adder_Report.pdf` |

The RTL SHA-256 is:

```text
0615279eb741b1a5f26f7233800fe0a69ae490539c4f002424b076dd8ff298a1
```

The assignment PDF is course material; the design, testbenches, scripts and
report are the supplied project work. Existing attribution is retained. No
repository-wide license is assigned to course material or external EDA tools.

## Portfolio additions

README, architecture/performance documentation, `Makefile`, packaging checks,
and the isolated RTL regression runner were added to make the design reviewable
and executable. These additions do not change the hardware or original tests.
[SOURCES.sha256](SOURCES.sha256) covers packaged inputs and execution scripts;
`make check` also independently checks preservation against the original manifest.

The original gate-level scripts are retained under `scripts/original/` because
their synthesis configuration and generated implementation files are absent.
They are not presented as a complete portable gate-level reproduction flow.
Synopsys binaries, licensed model sources, library files and license configuration
are not included.

## Evidence scope

Historical timing figures are attributed to sections 5–7 of the original
[report](report/BISG_Adder_Report.pdf). The supplied snapshot has waveform
screenshots in that PDF, but no raw synthesis reports, gate simulation logs,
netlists or SDF to independently validate the numerical speed boundaries.
There is no historical source-hash manifest tying a specific generated netlist
to the supplied RTL; the new source manifest establishes this portfolio's identity.

Fresh results in [evidence/release](evidence/release/) come from the packaged
RTL and original testbenches on 2026-11-11 (Asia/Taipei), using VCS X-2025.06.
The run metadata includes source hashes and explicitly identifies RTL-only
scope. Published log copies replace the local project prefix with `<project>/`;
functional results and numerical values are retained. Full builds and waveforms
are excluded from Git.
