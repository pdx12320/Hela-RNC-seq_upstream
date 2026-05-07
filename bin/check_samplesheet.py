#!/usr/bin/env python3
import argparse, csv, os, sys

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--samplesheet', required=True)
    p.add_argument('--reference', required=True)
    p.add_argument('--annotation', required=True)
    p.add_argument('--out_csv', required=True)
    p.add_argument('--log', required=True)
    args = p.parse_args()

    errors = []
    if not os.path.exists(args.samplesheet): errors.append(f"Missing samplesheet: {args.samplesheet}")
    if not os.path.exists(args.reference): errors.append(f"Missing reference: {args.reference}")
    if not os.path.exists(args.annotation): errors.append(f"Missing annotation: {args.annotation}")
    rows = []
    if not errors:
        with open(args.samplesheet) as f:
            reader = csv.DictReader(f)
            required = ['sample_id','condition','replicate','fastq']
            if reader.fieldnames != required:
                errors.append(f"Header must be exactly: {','.join(required)}")
            for i, r in enumerate(reader, start=2):
                sid = (r.get('sample_id') or '').strip()
                cond = (r.get('condition') or '').strip()
                rep = (r.get('replicate') or '').strip()
                fq = (r.get('fastq') or '').strip()
                if not sid: errors.append(f"Line {i}: empty sample_id")
                if not cond: errors.append(f"Line {i}: empty condition")
                if not rep: errors.append(f"Line {i}: empty replicate")
                if not fq: errors.append(f"Line {i}: empty fastq")
                elif not os.path.exists(fq): errors.append(f"Line {i}: fastq not found: {fq}")
                rows.append({'sample_id': sid, 'condition': cond, 'replicate': rep, 'fastq': fq})
    sids = [r['sample_id'] for r in rows]
    dups = sorted({x for x in sids if sids.count(x) > 1})
    if dups:
        errors.append(f"Duplicated sample_id: {','.join(dups)}")

    with open(args.log, 'w') as log:
        if errors:
            log.write("INPUT_CHECK: FAILED\n")
            log.write("\n".join(errors) + "\n")
        else:
            log.write(f"INPUT_CHECK: PASSED\nSamples: {len(rows)}\n")

    if errors:
        print("\n".join(errors), file=sys.stderr)
        sys.exit(1)

    with open(args.out_csv, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=['sample_id','condition','replicate','fastq'])
        w.writeheader()
        w.writerows(rows)

if __name__ == '__main__':
    main()
