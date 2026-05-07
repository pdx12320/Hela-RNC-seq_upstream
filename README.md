# ONT cDNA isoform upstream pipeline (Nextflow DSL2)

本流程用于 **ONT cDNA long-read RNA-seq** 上游分析，从 FASTQ 到高可信 isoform 定量矩阵，**不包含下游翻译调控解释**。

## 功能范围

- 输入检查（samplesheet / FASTQ / reference / GTF）
- 原始 reads 质控（NanoPlot + MultiQC）
- reads 过滤（chopper）
- minimap2 比对 + samtools 统计
- IsoQuant isoform 发现（主分支）
- FLAIR 交叉验证（可选）
- SQANTI3 去假阳性与置信度分级（可选）
- 生成最终矩阵：
  - isoform counts
  - isoform TPM
  - gene TPM
  - isoform fraction (isoform_TPM / gene_TPM)

> 不包含：AD 候选事件筛选、ORF/UTR/uORF/Kozak/NMD/miRNA/RNAfold/蛋白结构域等下游分析。

---

## 目录结构

```text
.
├── main.nf
├── nextflow.config
├── modules/
│   ├── input_check.nf
│   ├── qc_nanoplot.nf
│   ├── filter_chopper.nf
│   ├── align_minimap2.nf
│   ├── bam_stats.nf
│   ├── isoquant.nf
│   ├── flair.nf
│   ├── sqanti3_classify.nf
│   ├── sqanti3_filter.nf
│   ├── isoform_quant.nf
│   └── report.nf
├── bin/
│   ├── check_samplesheet.py
│   ├── filter_sqanti3_isoforms.py
│   ├── calc_isoform_fraction.py
│   ├── summarize_qc.py
│   ├── summarize_mapping.py
│   └── summarize_quantification.py
├── envs/
│   ├── base.yml
│   ├── isoform.yml
│   └── sqanti3.yml
└── assets/
    └── example_samplesheet.csv
```

---

## 输入说明

`samplesheet.csv` 需要以下列：

```csv
sample_id,condition,replicate,fastq
AD_01,AD,1,data/AD_01.fastq.gz
AD_02,AD,2,data/AD_02.fastq.gz
CTRL_01,control,1,data/CTRL_01.fastq.gz
CTRL_02,control,2,data/CTRL_02.fastq.gz
```

---

## 运行方式

### 1) 简化版（推荐先跑通）
仅运行：输入检查 → QC → 过滤 → 比对 → IsoQuant → 定量。

```bash
nextflow run main.nf \
  -profile conda \
  --samplesheet samplesheet.csv \
  --reference mm10.fa \
  --annotation gencode.gtf \
  --run_flair false \
  --run_sqanti3 false \
  -resume
```

### 2) 完整版（含 FLAIR + SQANTI3）
运行：QC → 过滤 → 比对 → IsoQuant + FLAIR → SQANTI3 → high-confidence 定量。

```bash
nextflow run main.nf \
  -profile conda \
  --samplesheet samplesheet.csv \
  --reference mm10.fa \
  --annotation gencode.gtf \
  --run_flair true \
  --run_sqanti3 true \
  --min_read_support 3 \
  --min_novel_support 5 \
  --min_multi_sample 2 \
  -resume
```

### 测试模式

```bash
nextflow run main.nf -profile test,conda -resume
```

---

## 关键参数（`nextflow.config`）

- `params.chopper_min_length`：默认 200
- `params.chopper_min_quality`：默认 8
- `params.minimap2_preset`：默认 `-ax splice -uf -k14`
- `params.run_flair`：是否开启 FLAIR
- `params.run_sqanti3`：是否开启 SQANTI3 分支
- `params.min_read_support`：SQANTI3 过滤最小 read support

---

## 主要输出

- `results/logs/input_check.log`
- `results/tables/samplesheet.validated.csv`
- `results/qc/raw_nanoplot/{sample}/`
- `results/multiqc/raw_multiqc_report.html`
- `results/filtered_fastq/*.filtered.fastq.gz`
- `results/bam/*.sorted.bam(.bai)`
- `results/isoquant/*`
- `results/flair/*`（可选）
- `results/sqanti3/*`（可选）
- `results/high_confidence_isoforms/*`（可选）
- `results/quantification/isoform_counts.tsv`
- `results/quantification/isoform_tpm.tsv`
- `results/quantification/gene_tpm.tsv`
- `results/quantification/isoform_fraction.tsv`
- `results/report/final_report.html`

