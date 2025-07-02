# PROJECT_RULES.md - Aedes aegypti Dengue Resistance Multi-Omics Analysis Strategy

## 🎯 **Project Overview**

### Research Context

- **Species**: *Aedes aegypti* (Yellow fever mosquito)
- **Research Goal**: Identify candidate genes associated with dengue resistance through population genomics
- **Main Question**: What genetic variants and population structure patterns are associated with dengue vector competence?
- **Publication Target**: Multi-omics manuscript linking GWAS findings to WGS and RNA-seq validation
- **Data Integration**: GWAS → WGS → RNA-seq validation pipeline

### Experimental Design Details

- **600 WGS Samples** from different geographic locations with varying dengue resistance phenotypes:

#### WGS Data Characteristics
- **Coverage**: ~11× average coverage per sample
- **Sequencing Platform**: Illumina (various runs)
- **Quality Filter**: 8-10× minimum depth for population analyses
- **Reference Genome**: AaegL5 (latest Aedes aegypti assembly)

#### Multi-Omics Integration
- **GWAS Data**: SNP chip results identifying candidate loci
- **WGS Data**: Whole genome sequencing for variant discovery
- **RNA-seq Data**: Expression validation of candidate genes
- **Epidemiological Data**: Dengue resistance/susceptibility phenotypes

## 🔬 **Analysis Strategy**

### Current Workflow (Updated)

1. **Data Acquisition**: nf-core/fetchngs for SRA data retrieval
2. **Variant Calling**: nf-core/sarek for WGS processing
3. **Population Genomics**: ANGSD for genotype likelihood analysis
4. **Selection Detection**: Tajima's D, iHS, XP-EHH analysis
5. **Gene Reconstruction**: Complete sequences of GWAS candidate genes

### Key Analysis Priorities

1. **High Priority**: Population structure analysis and FST calculations
2. **Medium Priority**: Selection detection in candidate regions
3. **Lower Priority**: Genome-wide exploratory analyses

### Candidate Genes

- **Source**: GWAS-identified candidate loci from SNP chip analysis (gene IDs to be provided)
- **Validation**: WGS reconstruction of complete gene sequences
- **Focus**: Prioritize these regions in population genomics analyses
- **Note**: Actual GWAS candidate gene IDs need to be obtained from the GWAS analysis results

## 🏗️ **Computing Environment**

### Docker Strategy

- **Dual deployment**: Same container runs on laptop AND HPC
- **Container includes**: WGS tools (BWA, GATK, ANGSD), population genetics tools (PLINK, ADMIXTURE), R with popgen packages
- **Data persistence**: Bind mounts for data/ and results/ directories
- **Jupyter integration**: Port 8888 for interactive analysis

### Directory Structure

```
aegyptiDengueWGS/
├── data/
│   ├── raw/           # FASTQ files from SRA downloads
│   ├── metadata/      # Sample information and phenotypes
│   └── references/    # AaegL5 genome and annotation files
├── results/
│   ├── organized/     # Organized output from nf-core pipelines
│   │   ├── fetchngs/        # Quality-controlled FASTQ files
│   │   ├── sarek/           # Variant calling results
│   │   ├── qc_reports/      # Quality control reports
│   │   ├── alignment_stats/ # Alignment statistics
│   │   └── multiqc/         # MultiQC reports
│   └── analysis/     # Population genomics results
│       ├── population_structure/ # PCA, ADMIXTURE results
│       ├── selection_detection/  # Tajima's D, iHS, XP-EHH
│       ├── gene_reconstruction/  # Complete gene sequences
│       └── visualization/     # Plots and figures
├── scripts/
│   ├── analysis/     # Population genetics analysis scripts
│   ├── download/     # SRA data download utilities
│   └── visualization/ # Plotting scripts
├── configs/          # nf-core configuration files
├── containers/       # Custom analysis containers
└── logs/            # Analysis logs
```

## 📊 **Statistical Models**

### Population Structure Analysis

**Principal Component Analysis (PCA):**

```r
# Using PLINK for PCA
plink --vcf variants.vcf --pca 10 --out population_pca

# Using R for visualization
pca_result <- read.table("population_pca.eigenvec")
ggplot(pca_result, aes(x=PC1, y=PC2, color=population)) + geom_point()
```

**ADMIXTURE Analysis:**

```bash
# Convert VCF to PLINK format
plink --vcf variants.vcf --make-bed --out population_data

# Run ADMIXTURE for K=2 to K=10
for K in {2..10}; do
    admixture --cv population_data.bed $K
done
```

### Selection Detection

**Tajima's D Calculation:**

```bash
# Using ANGSD for theta estimation
angsd -bam bamlist.txt -out tajima -doThetas 1 -pest pest.txt

# Calculate Tajima's D
thetaStat do_stat tajima.thetas.gz
```

**iHS Analysis:**

```r
# Using rehh package for iHS
library(rehh)
data <- data2haplohh("haplotype_data.txt")
ihs_result <- ihh2ihs(data)
```

**XP-EHH Analysis:**

```r
# Cross-population extended haplotype homozygosity
xpehh_result <- ies2xpehh(pop1_data, pop2_data)
```

### Gene Reconstruction

**Extract Gene Sequences:**

```python
# Extract complete gene sequences from VCF and reference
import vcf
import pyfaidx

def extract_gene_sequence(gene_id, vcf_file, reference_file):
    # Extract variants in gene region
    # Reconstruct complete sequence
    # Return gene sequence
```

## 🔍 **Quality Control Strategy**

### Pre-processing QC

- **Adapter trimming**: TrimGalore for adapter removal
- **Quality filtering**: Minimum quality scores and read lengths
- **Duplicate marking**: Mark duplicates with GATK
- **Base quality recalibration**: BQSR with GATK

### Post-alignment QC

- **Mapping statistics**: Alignment rates and coverage
- **VQSR filtering**: GATK Variant Quality Score Recalibration
- **Population-level QC**: Sample-level and population-level metrics
- **Coverage filtering**: 8-10× minimum depth for population analyses

### Quality Metrics

- **Alignment rate**: >80% for each sample
- **Coverage**: 8-10× minimum depth for population analyses
- **Variant quality**: VQSR filtering with GATK best practices
- **Population structure**: Clear separation of geographic populations

## 📈 **Expected Results**

### Key Deliverables

1. **High-quality variant call set** across 600 samples
2. **Population structure analysis** with geographic patterns
3. **Selection signals** in candidate regions
4. **Gene reconstruction** of GWAS candidate genes
5. **Cross-omics validation** with RNA-seq data

### Quality Metrics

- **Coverage**: 8-10× minimum depth filter for population analyses
- **Variant quality**: VQSR filtering with GATK best practices
- **Population structure**: Clear separation of geographic populations
- **Selection signals**: Significant deviations from neutral expectations

## 🔄 **Repository Strategy**

### Split Approach for Modularity

- **aegyptiDengueWGS**: WGS processing pipeline (fetchngs + sarek)
- **aegyptiDengueGWAS**: GWAS analysis and candidate gene identification
- **aegyptiDengueRNAseq**: Expression analysis and validation
- **aegyptiDengueIntegration**: Cross-omics analyses (optional)

### Citation Strategy

- **Modular Citations**: Each repository can be cited independently
- **Pipeline Citations**: nf-core pipeline citations
- **Tool Citations**: Individual tool citations (ANGSD, GATK, etc.)
- **Data Citations**: SRA and reference genome citations

## 🖥️ **HPC Configuration**

### UCR HPCC Optimization

- **SLURM Integration**: Custom configs for SLURM job submission
- **Resource Allocation**: Optimized for limited home directory space
- **Singularity Caching**: Local container builds for faster execution
- **Storage Management**: Efficient use of scratch and home directories

### Quality Control Strategy

- **Coverage Filtering**: 8-10× minimum depth (not 20×) for population analyses
- **Joint Calling**: Leverage 600 samples for improved variant detection
- **VQSR Filtering**: GATK best practices for variant quality
- **Population-level QC**: Sample-level and population-level quality metrics

## 📊 **Publication Strategy**

### Reproducibility

- **Version-controlled pipelines**: Exact parameter documentation
- **Containers**: GHCR/DockerHub for downstream analysis tools
- **Documentation**: Complete computational methods for peer review
- **Data integration**: Multi-omics approach linking genotype to phenotype

### Computational Methods

- **Pipeline versions**: Exact nf-core pipeline versions
- **Tool versions**: All bioinformatics tool versions documented
- **Parameters**: Complete parameter sets for all analyses
- **Quality metrics**: Detailed quality control procedures

## 🎯 **Current Phase**

### Implementation Status

- ✅ **Repository structure** established
- ✅ **Documentation framework** setup
- 🔄 **nf-core fetchngs** implementation in progress
- ⏳ **HPC configuration** and testing
- ⏳ **SRA data download** for 600 WGS samples

### Next Steps

1. Complete nf-core/fetchngs implementation
2. Test HPC configuration with sample data
3. Implement nf-core/sarek variant calling
4. Develop downstream population genomics scripts
5. Integrate with GWAS and RNA-seq repositories

## 📚 **Documentation**

### Core Files

- **[README.md](README.md)**: Main project overview and quick start
- **[README_WGS.md](README_WGS.md)**: Detailed WGS analysis specifications
- **[WORKFLOW.md](WORKFLOW.md)**: Step-by-step pipeline instructions
- **[USER_RULES.md](USER_RULES.md)**: AI assistant guidelines

### Technical Documentation

- **[hpcc_nfcore_install.md](hpcc_nfcore_install.md)**: HPC setup guide
- **[GitHub_DockerHub_Setup.md](GitHub_DockerHub_Setup.md)**: Container registry setup

## 📞 **Support and Contact**

- **Issues**: [GitHub Issues](https://github.com/cosmelab/aegyptiDengueWGS/issues)
- **Documentation**: Check the documentation files above
- **Email**: <degopwn@gmail.com>
- **Repository**: [aegyptiDengueWGS](https://github.com/cosmelab/aegyptiDengueWGS)

---

**Last Updated:** [Current Date]
**Project:** Aedes aegypti Dengue Resistance Multi-Omics Analysis
**Purpose:** Population genomics analysis for dengue resistance in Aedes aegypti
