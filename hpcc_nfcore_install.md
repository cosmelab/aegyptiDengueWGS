# Nextflow + nf‑core/rnaseq Installation on UCR HPCC

This guide documents the steps to install Nextflow and run the nf‑core/rnaseq pipeline on UCR’s HPCC without using containers.

## 1. Load Java

```bash
module load java/21.0.7
```

## 2. Install Nextflow

1. Create a personal `bin` directory:
   ```bash
   mkdir -p /bigdata/cosmelab/lcosme/docker/bin
   ```
2. Download the Nextflow launcher:
   ```bash
   curl -fsSL https://get.nextflow.io -o /bigdata/cosmelab/lcosme/docker/bin/nextflow
   ```
3. Make it executable:
   ```bash
   chmod +x /bigdata/cosmelab/lcosme/docker/bin/nextflow
   ```
4. Add it to your `PATH` (e.g. in `~/.zshrc`):
   ```bash
   export PATH=/bigdata/cosmelab/lcosme/docker/bin:$PATH
   ```

## 3. Redirect Conda Storage to Bigdata

```bash
export CONDA_ENVS_PATH=/bigdata/cosmelab/lcosme/docker/conda/envs
export CONDA_PKGS_DIRS=/bigdata/cosmelab/lcosme/docker/conda/pkgs
mkdir -p "$CONDA_ENVS_PATH" "$CONDA_PKGS_DIRS"
```

## 4. Create & Activate Nextflow Conda Environment

```bash
conda create -y -n nfnextflow -c bioconda -c conda-forge nextflow
conda activate nfnextflow
```

## 5. Run nf‑core/rnaseq

```bash
nextflow run nf-core/rnaseq \
  -profile conda \
  --reads '/bigdata/cosmelab/lcosme/docker/data/*_R{1,2}.fastq.gz' \
  --genome GRCh38 \
  --outdir /bigdata/cosmelab/lcosme/docker/results
```

## 6. Verify Installation

- Check Nextflow version:
  ```bash
  nextflow -v
  ```
- Confirm pipeline launch:
  ```bash
  nextflow run nf-core/rnaseq -resume
  ```

