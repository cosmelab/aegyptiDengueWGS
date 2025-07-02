# Aedes aegypti Dengue Resistance Multi-Omics Analysis Project

## 🎯 **Project Overview**

This repository contains the configuration and analysis pipeline for Whole Genome Sequencing (WGS) analysis of *Aedes aegypti* samples to study dengue resistance through multi-omics integration.

### Research Context

- **Species**: *Aedes aegypti* (Yellow fever mosquito)
- **Research Goal**: Identify candidate genes associated with dengue resistance through population genomics
- **Main Question**: What genetic variants and population structure patterns are associated with dengue vector competence?
- **Publication Target**: Multi-omics manuscript linking GWAS findings to WGS and RNA-seq validation
- **Data Integration**: GWAS → WGS → RNA-seq validation pipeline

### Data Components

#### WGS Data
- **Sample Size**: 600 Aedes aegypti samples
- **Coverage**: ~11× average coverage per sample
- **Sequencing**: Illumina platforms (various runs)
- **Quality**: 8-10× minimum depth filter for population analyses

#### GWAS Data
- **Platform**: SNP chip results
- **Phenotype**: Dengue resistance/susceptibility by locality
- **Output**: Candidate loci for follow-up WGS analysis (gene IDs to be provided)

#### RNA-seq Data
- **Purpose**: Expression validation of candidate genes
- **Design**: Resistant vs susceptible population comparisons
- **Integration**: Cross-omics validation of WGS findings

#### Epidemiological Data
- **Phenotypes**: Dengue resistance/susceptibility by locality
- **Metadata**: Geographic, temporal, and environmental variables

## 🏗️ **Project Structure**

```
aegyptiDengueWGS/
├── configs/              # nf-core configuration files
│   ├── hpc_batch.conf    # HPC-optimized Nextflow config
│   ├── custom.config     # Custom resource allocation
│   └── singularity.conf  # Singularity container config
├── data/
│   ├── raw/             # Raw FASTQ files from SRA
│   ├── references/      # AaegL5 genome and annotation
│   └── metadata/        # Sample sheets and phenotypes
├── scripts/
│   ├── download/        # SRA data download utilities
│   ├── analysis/        # Population genetics analysis
│   └── visualization/   # Plotting and visualization
├── logs/                # Pipeline logs and monitoring
├── containers/          # Custom analysis containers
└── results/
    ├── organized/       # nf-core pipeline outputs
    └── analysis/        # Population genomics results
```

## 🔬 **Technical Framework**

### Primary Analysis Pipeline

#### nf-core/fetchngs
- **Purpose**: Automated SRA data retrieval and preprocessing
- **Input**: Sample sheet with SRA accessions
- **Output**: Quality-controlled FASTQ files
- **Configuration**: HPC-optimized for UCR HPCC

#### nf-core/sarek
- **Purpose**: WGS variant calling pipeline
- **Input**: Quality-controlled FASTQ files
- **Output**: High-quality variant call set (VCF)
- **Reference**: AaegL5 (latest Aedes aegypti assembly)
- **Tools**: BWA, GATK, VQSR filtering

### Downstream Analysis

#### Population Genomics Tools
- **ANGSD**: Genotype likelihood-based analysis, FST, π, diversity
- **VCFtools**: Variant filtering and statistics
- **PLINK2**: Population structure analysis, GWAS integration, LD analysis
- **ADMIXTURE**: Ancestry estimation
- **scikit-allel**: Population genetics analysis (FST, π, diversity)
- **cyvcf2**: Fast VCF parsing (15x faster than PyVCF)

#### Selection Detection
- **Tajima's D**: Neutrality tests (ANGSD)
- **iHS**: Integrated haplotype score (selscan)
- **XP-EHH**: Cross-population extended haplotype homozygosity (selscan)
- **BEAGLE**: Haplotype phasing
- **IQ-TREE**: Phylogenetic inference

#### Phylogenetics
- **Gene trees**: Maximum likelihood phylogenies
- **Haplotype networks**: Network analysis of candidate genes

## 🚀 **Getting Started**

### 1. Environment Setup

```bash
# Clone repository
git clone https://github.com/cosmelab/aegyptiDengueWGS.git
cd aegyptiDengueWGS

# Build Docker environment
docker-compose up -d

# Or build directly
docker build -t aegypti-dengue-wgs .
```

### 2. Data Preparation

```bash
# Create sample sheet for nf-core/fetchngs
python scripts/download/create_samplesheet.py --input metadata/samples.csv --output samplesheet.csv

# Download reference genome
wget https://vectorbase.org/common/downloads/release-57/AaegyptiLVP_AGWG/fasta/data/VectorBase-57_AaegyptiLVP_AGWG_Genome.fasta
```

### 3. Pipeline Execution

```bash
# Run nf-core/fetchngs
nextflow run nf-core/fetchngs \
    -profile hpc_batch \
    --input samplesheet.csv \
    --outdir results/fetchngs

# Run nf-core/sarek
nextflow run nf-core/sarek \
    -profile hpc_batch \
    --input samplesheet.csv \
    --genome AaegL5 \
    --outdir results/sarek
```

## 📊 **Analytical Goals**

### Gene Reconstruction
- **Objective**: Use WGS to get complete sequences of GWAS candidate genes
- **Method**: Extract gene sequences from VCF and reference genome
- **Output**: Complete gene sequences for downstream analysis

### Population Genetics
- **FST Analysis**: Measure genetic differentiation between populations
- **π Calculation**: Estimate nucleotide diversity within populations
- **Neutrality Tests**: Identify deviations from neutral expectations

### Selection Detection
- **Tajima's D**: Detect balancing and directional selection
- **iHS**: Identify recent positive selection within populations
- **XP-EHH**: Detect selection differences between populations

### Phylogenetics
- **Gene Trees**: Maximum likelihood phylogenies for candidate genes
- **Haplotype Networks**: Network analysis of genetic variation
- **Population Structure**: PCA, ADMIXTURE, and FST analyses

### Functional Validation
- **RNA-seq Integration**: Expression analysis in resistant vs susceptible populations
- **Cross-omics Validation**: Link WGS variants to expression differences
- **Phenotype Association**: Statistical association with dengue resistance

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

## 📈 **Expected Outcomes**

### Key Deliverables
1. **High-quality variant call set** across 600 samples
2. **Population structure analysis** with geographic patterns
3. **Selection signals** in candidate regions
4. **Gene reconstruction** of GWAS candidate genes
5. **Cross-omics validation** with RNA-seq data

### Publication Strategy
- **Reproducibility**: Version-controlled pipelines with exact parameters
- **Containers**: GHCR/DockerHub for downstream analysis tools
- **Documentation**: Complete computational methods for peer review
- **Data Integration**: Multi-omics approach linking genotype to phenotype

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

## 📚 **Documentation**

### Core Files
- **[README.md](README.md)**: Main project overview and quick start
- **[PROJECT_RULES.md](PROJECT_RULES.md)**: Analysis strategy and rules
- **[WORKFLOW.md](WORKFLOW.md)**: Step-by-step pipeline instructions
- **[USER_RULES.md](USER_RULES.md)**: AI assistant guidelines

### Technical Documentation
- **[hpcc_nfcore_install.md](hpcc_nfcore_install.md)**: HPC setup guide
- **[GitHub_DockerHub_Setup.md](GitHub_DockerHub_Setup.md)**: Container registry setup

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

## 📞 **Support and Contact**

- **Issues**: [GitHub Issues](https://github.com/cosmelab/aegyptiDengueWGS/issues)
- **Documentation**: Check the documentation files above
- **Email**: <degopwn@gmail.com>
- **Repository**: [aegyptiDengueWGS](https://github.com/cosmelab/aegyptiDengueWGS)

---

**Last Updated:** [Current Date]
**Project:** Aedes aegypti Dengue Resistance Multi-Omics Analysis
**Purpose:** Population genomics analysis for dengue resistance in Aedes aegypti
