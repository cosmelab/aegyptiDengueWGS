# WORKFLOW.md - Step-by-Step WGS Analysis Pipeline

## 🎯 **Overview**

This document provides detailed step-by-step instructions for the complete WGS analysis workflow, from data download to population genomics analysis using nf-core pipelines.

## 📋 **Pipeline Summary**

1. **Data Acquisition** → 2. **HPC Setup** → 3. **nf-core/fetchngs** → 4. **nf-core/sarek** → 5. **Population Genomics**

---

## 🔽 **Step 1: Data Acquisition**

### 1.1 SRA Download Setup

```bash
# Install SRA toolkit
conda install -c bioconda sra-tools

# Set up SRA cache directory
mkdir -p ~/.ncbi
export NCBI_SETTINGS=~/.ncbi/user-settings.mkfg
```

### 1.2 Prepare Sample Metadata

```bash
# Create sample sheet for 600 WGS samples
python scripts/download/create_samplesheet.py \
    --input data/metadata/samples.csv \
    --output samplesheet.csv \
    --format paired
```

### 1.3 Download Reference Genome

```bash
# Download AaegL5 reference genome
wget -O data/references/AaegL5.fasta \
    https://vectorbase.org/common/downloads/release-57/AaegyptiLVP_AGWG/fasta/data/VectorBase-57_AaegyptiLVP_AGWG_Genome.fasta

# Download annotation
wget -O data/references/AaegL5.gtf \
    https://vectorbase.org/common/downloads/release-57/AaegyptiLVP_AGWG/gff/data/VectorBase-57_AaegyptiLVP_AGWG.gff

# Index reference for BWA
bwa index data/references/AaegL5.fasta
```

---

## 🖥️ **Step 2: HPC Environment Setup**

### 2.1 Create Conda Environment

```bash
# On HPC system
conda create -n nf-core-wgs python=3.10
conda activate nf-core-wgs

# Install nf-core
pip install nf-core
```

### 2.2 Download nf-core Pipelines

```bash
# Download fetchngs pipeline
nf-core download nf-core/fetchngs

# Download sarek pipeline
nf-core download nf-core/sarek

# Check available versions
nf-core list
```

### 2.3 Configure HPC Settings

```bash
# Copy HPC configuration
cp configs/hpc_batch.conf ~/.nextflow/config

# Test configuration
nextflow run nf-core/fetchngs -profile test,hpc_batch
```

---

## 📥 **Step 3: nf-core/fetchngs Data Retrieval**

### 3.1 Prepare Samplesheet

```bash
# Create samplesheet for fetchngs
python scripts/download/create_fetchngs_samplesheet.py \
    --input data/metadata/sra_accessions.csv \
    --output samplesheet_fetchngs.csv
```

### 3.2 Run nf-core/fetchngs

```bash
# Run fetchngs pipeline
nextflow run nf-core/fetchngs \
    -profile hpc_batch \
    --input samplesheet_fetchngs.csv \
    --outdir results/fetchngs \
    --nf_core_pipeline rnaseq \
    --skip_sra_fastq_dump \
    --skip_fastqc \
    --skip_multiqc
```

### 3.3 Verify Downloads

```bash
# Check file integrity and completeness
python scripts/download/verify_downloads.py \
    --input results/fetchngs \
    --output data/metadata/download_summary.csv
```

---

## 🔬 **Step 4: nf-core/sarek Variant Calling**

### 4.1 Prepare Samplesheet for Sarek

```bash
# Create samplesheet for sarek
python scripts/analysis/create_sarek_samplesheet.py \
    --input results/fetchngs \
    --output samplesheet_sarek.csv \
    --reference AaegL5
```

### 4.2 Run nf-core/sarek

```bash
# Run sarek pipeline for variant calling
nextflow run nf-core/sarek \
    -profile hpc_batch \
    --input samplesheet_sarek.csv \
    --genome AaegL5 \
    --outdir results/sarek \
    --tools gatk4 \
    --skip_tools baserecalibrator \
    --skip_tools applybqsr \
    --skip_tools manta \
    --skip_tools strelka \
    --skip_tools ascat \
    --skip_tools controlfreec \
    --skip_tools cnvkit \
    --skip_tools freebayes \
    --skip_tools manta \
    --skip_tools mpileup \
    --skip_tools tiddit \
    --skip_tools vardict \
    --skip_tools vep \
    --skip_tools snpeff \
    --skip_tools bcftools \
    --skip_tools fastqc \
    --skip_tools markduplicates \
    --skip_tools samtools_stats \
    --skip_tools vcftools \
    --skip_tools multiqc
```

### 4.3 Quality Control

```bash
# Run quality control on variant calls
python scripts/analysis/variant_qc.py \
    --input results/sarek/variants/ \
    --output results/analysis/variant_qc/ \
    --reference data/references/AaegL5.fasta
```

---

## 🧬 **Step 5: Population Genomics Analysis**

### 5.1 Filter Variants

```bash
# Filter variants for population analysis
vcftools --vcf results/sarek/variants/snps.vcf \
    --remove-indels \
    --min-alleles 2 \
    --max-alleles 2 \
    --min-meanDP 8 \
    --max-meanDP 50 \
    --minQ 30 \
    --recode \
    --out results/analysis/filtered_variants
```

### 5.2 Population Structure Analysis

#### Principal Component Analysis

```bash
# Run PCA with PLINK2
plink2 --vcf results/analysis/filtered_variants.recode.vcf \
    --pca 10 \
    --out results/analysis/population_structure/pca
```

#### ADMIXTURE Analysis

```bash
# Convert to PLINK2 format
plink2 --vcf results/analysis/filtered_variants.recode.vcf \
    --make-bed \
    --out results/analysis/population_structure/admixture_data

# Run ADMIXTURE for different K values
for K in {2..10}; do
    admixture --cv results/analysis/population_structure/admixture_data.bed $K
done
```

### 5.3 FST Analysis

```bash
# Calculate FST between populations
vcftools --vcf results/analysis/filtered_variants.recode.vcf \
    --weir-fst-pop data/metadata/pop1.txt \
    --weir-fst-pop data/metadata/pop2.txt \
    --out results/analysis/fst/pop1_vs_pop2
```

### 5.4 Selection Detection

#### Tajima's D with ANGSD

```bash
# Create BAM list
ls results/sarek/bam/*.bam > bamlist.txt

# Calculate theta with ANGSD
angsd -bam bamlist.txt \
    -out results/analysis/selection/tajima \
    -doThetas 1 \
    -pest results/analysis/selection/pest.txt \
    -anc data/references/AaegL5.fasta

# Calculate Tajima's D
thetaStat do_stat results/analysis/selection/tajima.thetas.gz
```

#### iHS Analysis with selscan

```bash
# Calculate iHS using selscan
selscan --ihs --vcf results/analysis/filtered_variants.recode.vcf \
    --out results/analysis/selection/ihs_results

# Calculate XP-EHH
selscan --xpehh --vcf results/analysis/filtered_variants.recode.vcf \
    --ref results/analysis/population_structure/pop1.txt \
    --alt results/analysis/population_structure/pop2.txt \
    --out results/analysis/selection/xpehh_results
```

### 5.5 Haplotype Phasing with BEAGLE

```bash
# Phase haplotypes using BEAGLE
beagle gt=results/analysis/filtered_variants.recode.vcf \
    out=results/analysis/selection/phased_variants \
    nthreads=8
```

### 5.6 Phylogenetic Analysis with IQ-TREE

```bash
# Create alignment for candidate genes
python scripts/analysis/create_gene_alignments.py \
    --vcf results/analysis/filtered_variants.recode.vcf \
    --genes data/metadata/candidate_genes.txt \
    --output results/analysis/phylogenetics/

# Run IQ-TREE for maximum likelihood phylogeny
iqtree -s results/analysis/phylogenetics/gene_alignments.fasta \
    -m MFP \
    -bb 1000 \
    -nt 8 \
    -pre results/analysis/phylogenetics/gene_tree
```

### 5.7 Gene Reconstruction

```python
# Extract complete gene sequences from VCF
python scripts/analysis/gene_reconstruction.py \
    --vcf results/analysis/filtered_variants.recode.vcf \
    --reference data/references/AaegL5.fasta \
    --genes data/metadata/candidate_genes.txt \
    --output results/analysis/gene_reconstruction/
```

---

## 📊 **Step 6: Visualization and Reporting**

### 6.1 Population Structure Plots

```r
# Load libraries
library(ggplot2)
library(dplyr)

# PCA plot
pca_data <- read.table("results/analysis/population_structure/pca.eigenvec")
ggplot(pca_data, aes(x=V3, y=V4, color=population)) +
    geom_point() +
    theme_minimal() +
    labs(x="PC1", y="PC2", title="Population Structure PCA")
```

### 6.2 Selection Signal Plots

```r
# Manhattan plot for FST
fst_data <- read.table("results/analysis/fst/pop1_vs_pop2.weir.fst")
ggplot(fst_data, aes(x=POS, y=WEIR_AND_COCKERHAM_FST)) +
    geom_point() +
    theme_minimal() +
    labs(x="Position", y="FST", title="Population Differentiation")
```

### 6.3 Quality Control Reports

```bash
# Generate MultiQC report
multiqc results/sarek/ \
    --outdir results/analysis/qc_reports/ \
    --filename sarek_multiqc_report.html
```

---

## 🔄 **Step 7: Integration with Other Omics**

### 7.1 Cross-omics Validation

```r
# Load WGS and RNA-seq results
wgs_variants <- read.table("results/analysis/filtered_variants.recode.vcf")
rna_expression <- read.table("results/rnaseq/differential_expression.csv")

# Integrate results
integrated_results <- merge(wgs_variants, rna_expression, by="gene_id")
```

### 7.2 Candidate Gene Prioritization

```python
# Prioritize candidate genes based on multiple criteria
python scripts/analysis/gene_prioritization.py \
    --wgs results/analysis/filtered_variants.recode.vcf \
    --rnaseq results/rnaseq/differential_expression.csv \
    --gwas data/metadata/gwas_results.csv \
    --output results/analysis/gene_prioritization/
```

---

## 📈 **Expected Outputs**

### Key Files Generated

1. **Variant Call Set**: `results/sarek/variants/snps.vcf`
2. **Population Structure**: `results/analysis/population_structure/`
3. **Selection Signals**: `results/analysis/selection/`
4. **Gene Sequences**: `results/analysis/gene_reconstruction/`
5. **Quality Reports**: `results/analysis/qc_reports/`

### Quality Metrics

- **Coverage**: 8-10× minimum depth across samples
- **Variant Quality**: VQSR filtered variants
- **Population Structure**: Clear geographic separation
- **Selection Signals**: Significant deviations from neutral expectations

---

## 🚨 **Troubleshooting**

### Common Issues

1. **Memory Issues**: Adjust resource allocation in HPC config
2. **Storage Issues**: Use scratch directories for temporary files
3. **Pipeline Failures**: Check logs in `results/sarek/logs/`
4. **Quality Issues**: Review MultiQC reports

### Performance Optimization

- **Parallel Processing**: Use appropriate number of cores
- **Storage Management**: Clean up intermediate files
- **Caching**: Use Singularity containers for faster execution

---

## 📚 **References**

- nf-core/fetchngs: [Documentation](https://nf-co.re/fetchngs)
- nf-core/sarek: [Documentation](https://nf-co.re/sarek)
- ANGSD: [Manual](http://www.popgen.dk/angsd/index.php/ANGSD)
- PLINK2: [Documentation](https://www.cog-genomics.org/plink/)
- selscan: [GitHub](https://github.com/szpiech/selscan)
- BEAGLE: [Documentation](https://faculty.washington.edu/browning/beagle/beagle.html)
- IQ-TREE: [Documentation](http://www.iqtree.org/)
- scikit-allel: [Documentation](https://scikit-allel.readthedocs.io/)
- cyvcf2: [Documentation](https://github.com/brentp/cyvcf2)

---

**Last Updated:** [Current Date]
**Pipeline Version:** v1.0.0
**Nextflow Version:** 22.10.1
