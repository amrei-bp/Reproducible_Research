# RNA-seq teaching pipeline (Nextflow)

[![Pipeline test](https://github.com/amrei-bp/Reproducible_Research/actions/workflows/pipeline-test.yml/badge.svg)](https://github.com/amrei-bp/Reproducible_Research/actions/workflows/pipeline-test.yml)

A small RNA-seq workflow used in the Nextflow session of the course
*Reproducible Research in Bioinformatics and Computational Biology*.
The step-by-step exercise is on the course page:
[Nextflow RNAseq pipeline](https://amrei-bp.github.io/Reproducible_Research/course_nextflow_rnaseq.html).

It is a proof of concept for teaching, not a production pipeline.
For real RNA-seq analysis, use [nf-core/rnaseq](https://nf-co.re/rnaseq).

## The pipeline

```
transcriptome.fa --> INDEX (salmon index) --+
                                            v
read pairs ---------+---------------> QUANTIFICATION (salmon quant) --+
                    |                                                 +--> MULTIQC --> multiqc_report.html
                    +---------------> FASTQC -------------------------+
```

1. `INDEX` builds a Salmon index from the reference transcriptome, once.
2. `QUANTIFICATION` runs `salmon quant` for each sample.
3. `FASTQC` checks read quality for each sample, in parallel with quantification.
4. `MULTIQC` waits for all samples and combines the Salmon and FastQC output into one report.

Outputs go to `results/` (change with `--outdir`):

```
results/
├── salmon/<sample>/        quantification per sample
├── fastqc/fastqc_<sample>_logs/
└── multiqc/multiqc_report.html
```

## Contents

| Path | What it is |
|---|---|
| `main.nf` | The finished pipeline |
| `nextflow.config` | Profiles `slurm` (course HPC) and `test` (small local run) |
| `steps/script1.nf` – `steps/script7.nf` | The scripts students will build up during the session, one step at a time |
| `steps/solutions/` | Worked solutions to the exercises (`script1.2.nf`, `script2.1.nf`, `script4.1.nf`, `script5.1.nf`) |
| `data/ggal/` | Test data: paired-end reads for three samples (gut, liver, lung) and a transcriptome |
| `pixi.toml`, `pixi.lock` | Pixi environment that pins Nextflow |

## How to run

You need [Pixi](https://pixi.sh) and Apptainer (or Singularity). Each process
runs in its own container from [Seqera Containers](https://seqera.io/containers/),
pulled as a Singularity image (`oras://`). Docker is not used, because it is
not available on the HPC.

On the HPC, with Slurm (replace the account with your compute allocation):

```bash
pixi run nextflow run main.nf -profile slurm --account hpc2nXXXX-YYY
```

Quick test on any Linux machine with Apptainer, using the local executor and
low resources:

```bash
pixi run nextflow run main.nf -profile test
```

Run on other data:

```bash
pixi run nextflow run main.nf -profile slurm --account hpc2nXXXX-YYY \
    --reads 'my_reads/*_{1,2}.fq.gz' --transcriptome_file my_ref.fa
```

To follow the teaching steps, run the scripts in `steps/` from this folder,
for example `pixi run nextflow run steps/script6.nf -profile test`.

The step scripts are starting points for the exercises, so some of them do not
run until the student completes them. The worked solutions are
in `steps/solutions/`, named after the script they complete (`script2.1.nf`
completes `script2.nf`). `main.nf` is the completed pipeline. CI lints all
step scripts but runs only `main.nf`.

## Testing

GitHub Actions runs the pipeline on every push and pull request that changes
`pipeline/` (see [`.github/workflows/pipeline-test.yml`](../.github/workflows/pipeline-test.yml)).
The job installs Apptainer and Nextflow (from `pixi.lock`), runs `nextflow lint`,
then runs `main.nf -profile test` with the same `oras://` containers students
use on the HPC, and checks that the MultiQC report was produced.

## Credits and changes

The workflow is adapted from the simple RNA-seq example (`script1.nf` –
`script7.nf` and the `data/ggal` test data) in Seqera's Nextflow training
material, [nextflow-io/training](https://github.com/nextflow-io/training).
Those files were removed from the training repository in January 2026; the
last version that contains them is
[commit e943963](https://github.com/nextflow-io/training/tree/e9439633455959297125a827316084188ff21c5d/nf-training).

What I changed or added for the course:

- **Slurm executor** in a `slurm` profile, with the project account as a
  parameter (`--account`) and `resume` switched on.
- **Per-process containers**: each process names its own image from Seqera
  Containers (Salmon 2.7.0, FastQC 0.12.1, MultiQC 1.35), run with
  Singularity/Apptainer. The original used one Docker image
  (`nextflow/rnaseq-nf`) for all tools.
- **Per-process resources** with `withName` selectors (time and CPUs).
- **Pixi environment** that pins Nextflow, so students and CI use the same
  version (26.04.6).
- **Current Nextflow syntax** (strict syntax, checked with `nextflow lint`):
  lowercase `channel` factories, the run summary and `onComplete` handler inside
  the `workflow` block, `checkIfExists` on the inputs.
- **Outputs** published per tool (`salmon/`, `fastqc/`, `multiqc/`) and copied
  rather than linked, so they survive cleaning `work/`.
- A `test` profile and a GitHub Actions job that runs the pipeline.
- Teaching notes on the course page, explaining why each step is used and how
  the channels fit together.

The scripts in `steps/` and `steps/solutions/` are as used in the course,
except that the data path points to the shared `data/` folder.

An earlier teaching pipeline I wrote is [SLUBioinformaticsInfrastructure/Nextflow_training_qc_pipeline](https://github.com/SLUBioinformaticsInfrastructure/Nextflow_training_qc_pipeline). Its extended_pipeline branch holds the version completed during this earlier rendition of the course: reads fetched from SRA, quality control (FastQC), read merging (FLASH2), mapping (Bowtie2), taxonomic classification (Kraken2, Bracken) with Krona plots, and a MultiQC summary.

## Licence

The original training material is licensed under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/), and so
is everything in this `pipeline/` folder (ShareAlike). See [`LICENSE`](LICENSE).
The rest of this repository is under the MIT licence.
