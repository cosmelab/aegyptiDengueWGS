# Aedes aegypti Dengue Resistance Multi-Omics Analysis Project

## ⚠️ **IMPORTANT: AI Assistant Rules**

**BEFORE responding to any request, the AI assistant MUST:**

1. Read USER_RULES.md completely
2. Follow the exact format specified there
3. Never make changes without permission
4. Always ask for confirmation before modifications

---

A comprehensive multi-omics analysis pipeline to study dengue resistance in *Aedes aegypti* mosquitoes, integrating GWAS, WGS, and RNA-seq data to identify and validate candidate genes associated with dengue vector competence.

## 🎯 **Project Overview**

### Research Goal

Develop a comprehensive multi-omics analysis pipeline to bridge SNP chip GWAS findings with whole genome sequencing, reconstructing complete gene sequences and performing population genomics analyses to identify candidate genes associated with dengue resistance in *Aedes aegypti*.

### Data Components

- **GWAS data**: SNP chip results identifying candidate loci for dengue resistance (gene IDs to be provided)
- **WGS data**: 600 Aedes aegypti samples at ~11× coverage for population genomics
- **RNA-seq data**: Expression validation of candidate genes
- **Epidemiological data**: Dengue resistance/susceptibility phenotypes by locality

### Key Features

- **Multi-omics integration**: GWAS → WGS → RNA-seq validation pipeline
- **Population genomics**: FST, π, neutrality tests using ANGSD genotype likelihoods
- **Gene reconstruction**: Complete sequences of GWAS candidate genes
- **Selection detection**: Tajima's D, iHS, XP-EHH on candidate regions
- **Phylogenetics**: Gene trees and haplotype networks

## 🚀 **Quick Start**

### Using Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/cosmelab/aegyptiDengueWGS.git
cd aegyptiDengueWGS

# Build and start the environment
docker-compose up -d

# Access Jupyter Lab
# Open http://localhost:8888 in your browser
```

### Using Docker directly

```bash
# Build the image
docker build -t aegypti-dengue-wgs .

# Run the container
docker run -it -p 8888:8888 -v $(pwd):/proj aegypti-dengue-wgs
```

## 📚 **Documentation**

### Core Documentation

- **[PROJECT_RULES.md](PROJECT_RULES.md)**: Analysis strategy, statistical models, and project rules
- **[WORKFLOW.md](WORKFLOW.md)**: Step-by-step pipeline instructions
- **[USER_RULES.md](USER_RULES.md)**: AI assistant guidelines and transparency rules

### Additional Resources

- **[README_WGS.md](README_WGS.md)**: Detailed WGS analysis specifications
- **[hpcc_nfcore_install.md](hpcc_nfcore_install.md)**: HPC configuration guide
- **[GitHub_DockerHub_Setup.md](GitHub_DockerHub_Setup.md)**: Container registry setup

## 🏗️ **Project Structure**

```
aegyptiDengueWGS/
├── data/
│   ├── raw/           # FASTQ files from SRA downloads
│   ├── metadata/      # Sample information and phenotypes
│   └── references/    # AaegL5 genome and annotation files
├── results/
│   ├── organized/     # Organized output from nf-core pipelines
│   └── analysis/      # Population genomics analysis results
├── scripts/
│   ├── analysis/      # Population genetics analysis scripts
│   ├── download/      # SRA data download utilities
│   └── visualization/ # Plotting scripts
├── configs/           # nf-core configuration files
├── containers/        # Custom analysis containers
├── logs/              # Pipeline logs
├── Dockerfile         # Container definition
├── docker-compose.yml # Multi-container setup
└── setup.sh          # Environment setup script
```

## 🔬 **Analysis Pipeline**

### 1. Data Acquisition

```bash
# Download SRA datasets for 600 WGS samples
python scripts/download/sra_download.py --accession PRJNAXXXXXX --output data/raw/WGS_samples
```

### 2. nf-core Pipeline Processing

```bash
# Run nf-core/fetchngs for data retrieval
nextflow run nf-core/fetchngs -profile hpc_batch --input samplesheet.csv

# Run nf-core/sarek for variant calling
nextflow run nf-core/sarek -profile hpc_batch --input samplesheet.csv --genome AaegL5
```

### 3. Population Genomics Analysis

```bash
# ANGSD genotype likelihood analysis
angsd -bam bamlist.txt -out pop1 -doMajorMinor 1 -doMaf 1 -doGeno 32 -doPost 1

# Population structure analysis
Rscript scripts/analysis/population_structure.R
```

### 4. Selection Detection

```bash
# Tajima's D calculation
angsd -bam bamlist.txt -out tajima -doThetas 1 -pest pest.txt

# iHS and XP-EHH analysis
Rscript scripts/analysis/selection_detection.R
```

## 🐳 **Docker Environment**

### Available Tools

- **Core Python Stack**: scikit-allel, cyvcf2, pandas, numpy, scipy, matplotlib, seaborn, plotly
- **Essential External Tools**: ANGSD, IQ-TREE, bcftools, bedtools, samtools, BWA, GATK
- **Specialized Analysis**: selscan (iHS, XP-EHH), BEAGLE (haplotype phasing), PLINK2 (GWAS integration)
- **Quality Control**: FastQC, MultiQC, TrimGalore
- **Population Genetics**: VCFtools, ADMIXTURE, R with population genetics packages
- **Workflow Management**: Snakemake, Nextflow, nf-core
- **Development**: Jupyter Lab, VS Code integration

### Docker Image

```bash
# Pull from Docker Hub
docker pull cosmelab/aegypti-dengue-wgs:latest

# Multi-architecture support (amd64, arm64)
docker pull cosmelab/aegypti-dengue-wgs:latest
```

## 🖥️ **HPC Deployment**

### Singularity/Apptainer

```bash
# Convert Docker image to Singularity
singularity pull docker://cosmelab/aegypti-dengue-wgs:latest

# Run on HPC
singularity exec aegypti-dengue-wgs.sif bash
```

### SLURM Integration

- Use `configs/hpc_batch.conf` for Nextflow
- Configure resource limits in `custom.config`
- Submit jobs with appropriate resource requests

## 📊 **Expected Results**

### Key Deliverables

1. **Variant call set**: High-quality SNPs and indels across 600 samples
2. **Population structure**: PCA, ADMIXTURE, and FST analyses
3. **Selection signals**: Tajima's D, iHS, XP-EHH results
4. **Gene reconstruction**: Complete sequences of GWAS candidate genes
5. **Phylogenetic analysis**: Gene trees and haplotype networks

### Quality Metrics

- **Coverage**: 8-10× minimum depth filter for population analyses
- **Variant quality**: VQSR filtering with GATK best practices
- **Population structure**: Clear separation of geographic populations
- **Selection signals**: Significant deviations from neutral expectations

## 🔍 **Quality Control**

### Pre-processing

- Adapter trimming with TrimGalore
- Quality filtering and read length distribution
- Duplicate marking and base quality recalibration

### Post-alignment

- Mapping statistics and coverage analysis
- VQSR filtering for variant quality
- Population-level quality metrics

## 📈 **Visualization**

### Built-in Plots

- PCA plots for population structure
- Manhattan plots for selection signals
- Heatmaps for FST and genetic diversity
- Quality control summaries

### Custom Visualizations

- Use Python plotting libraries (matplotlib, seaborn)
- R-based plots with ggplot2 and popgen packages
- Interactive plots with bokeh and plotly

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- nf-core community
- Population genetics community
- Bioconductor project
- Docker and containerization community

## 📞 **Support**

- **Issues**: [GitHub Issues](https://github.com/cosmelab/aegyptiDengueWGS/issues)
- **Documentation**: Check the documentation files above
- **Email**: <degopwn@gmail.com>

## 🔄 **Version History**

- **v1.0.0**: Initial release with nf-core fetchngs implementation
- **v1.1.0**: Added nf-core sarek variant calling pipeline
- **v1.2.0**: Integrated population genomics analysis tools
- **v1.3.0**: Multi-omics integration framework

---

**Last Updated:** [Current Date]
**Project:** aegyptiDengueWGS Analysis
**Purpose:** Population genomics analysis for dengue resistance in Aedes aegypti
# Updated to use main branch and latest tags
