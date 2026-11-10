#!/usr/bin/env python3
"""Run the three original RTL benches; gate timing is a separate, historical flow."""
import csv
import hashlib
import json
import re
import shutil
import subprocess
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / '.build' / datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')


def execute(command, cwd, logfile):
    with logfile.open('w') as output:
        status = subprocess.run(command, cwd=cwd, stdout=output,
                                stderr=subprocess.STDOUT, timeout=180).returncode
    result = logfile.read_text(errors='replace')
    if status or re.search(r'Error-|Fatal:|\bFAIL:|\bHW3_FAIL\b|Error!', result):
        raise RuntimeError(f'Command failed (status={status}); inspect {logfile}')
    return result


def main():
    if not shutil.which('vcs'):
        raise SystemExit('VCS is required. Load your licensed EDA environment (for example, module load vcs/2025.06).')
    BUILD.mkdir(parents=True)
    print(f'Build and logs: {BUILD}', flush=True)
    benches = [('adder6', 'tb_adder6.v', 'tb_adder6_only', None),
               ('bist6', 'tb_bist_adder6.v', 'tb_bist_adder6', 0x4d),
               ('bist12', 'tb_bist_adder12.v', 'tb_bist_adder12', 0x458)]
    rows = []
    for name, filename, top, signature in benches:
        work = BUILD / name
        (work / 'waves').mkdir(parents=True)
        command = ['vcs', '-full64', '+v2k', '-sverilog', '-top', top,
                   str(ROOT / 'src/bist_adder.v'), str(ROOT / 'tests/original' / filename),
                   '-o', str(work / 'simv'), '-Mdir=' + str(work / 'csrc')]
        execute(command, work, BUILD / (name + '_compile.log'))
        result = execute([str(work / 'simv'), '-no_save', '+PERIOD_PS=10000'],
                         work, BUILD / (name + '.log'))
        if signature is None:
            comparisons = len(re.findall(r'^PASS: a=', result, re.MULTILINE))
            if comparisons != 7:
                raise RuntimeError(f'{name}: expected 7 directed comparisons, got {comparisons}')
            detail = '7 directed arithmetic comparisons'
        else:
            match = re.search(r'HW3_RESULT N=(\d+) PERIOD_PS=(\d+) signature=0x([0-9a-f]+) expected=0x([0-9a-f]+) done=(\d+) cycles=(\d+)', result)
            width = 6 if name == 'bist6' else 12
            if (not match or 'HW3_PASS' not in result or int(match[1]) != width
                    or int(match[2]) != 10000 or int(match[3], 16) != signature
                    or int(match[4], 16) != signature or match[5] != '1'):
                raise RuntimeError(f'{name}: missing valid completion/golden-signature result')
            detail = f'signature=0x{signature:x}; PERIOD_PS=10000; bench_cycles={match[6]}'
        rows.append([name, 'PASS', detail])
        print(f'{name}: PASS ({detail})', flush=True)
    with (BUILD / 'results.tsv').open('w', newline='') as output:
        writer = csv.writer(output, delimiter='\t', lineterminator='\n')
        writer.writerow(['test', 'result', 'detail'])
        writer.writerows(rows)
    sources = ['src/bist_adder.v'] + ['tests/original/' + b[1] for b in benches]
    metadata = {
        'date': datetime.now(timezone(timedelta(hours=8))).strftime('%Y-%m-%d'),
        'date_timezone': 'Asia/Taipei',
        'scope': 'RTL simulation only; no SDF annotation or timing checks on a mapped netlist',
        'command': 'python3 scripts/run_tests.py',
        'sources': {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in sources},
    }
    (BUILD / 'run.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print('PASS: pure-adder directed checks and both BIST golden signatures (RTL).')


if __name__ == '__main__':
    main()
