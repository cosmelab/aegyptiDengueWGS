#!/bin/bash

# Setup script for Aedes aegypti Dengue Resistance Multi-Omics Analysis Project
# This script initializes the environment and downloads necessary data

set -e  # Exit on any error

echo "🐛 Setting up Aedes aegypti Dengue Resistance Multi-Omics Analysis Project"
echo "=================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running in container
if [ -f /.dockerenv ]; then
    print_status "Running inside Docker container"
else
    print_warning "Not running in Docker container - some features may not work"
fi

# Create directory structure
print_status "Creating directory structure..."
mkdir -p data/{raw,references,metadata}
mkdir -p results/{organized,analysis/{population_structure,selection_detection,gene_reconstruction,visualization,qc_reports}}
mkdir -p scripts/{download,analysis,visualization}
mkdir -p configs
mkdir -p containers
mkdir -p logs

print_success "Directory structure created"

# Download reference genome
print_status "Downloading AaegL5 reference genome..."
if [ ! -f "data/references/AaegL5.fasta" ]; then
    wget -O data/references/AaegL5.fasta \
        https://vectorbase.org/common/downloads/release-57/AaegyptiLVP_AGWG/fasta/data/VectorBase-57_AaegyptiLVP_AGWG_Genome.fasta

    # Index for BWA
    print_status "Indexing reference genome for BWA..."
    bwa index data/references/AaegL5.fasta

    # Index for samtools
    print_status "Indexing reference genome for samtools..."
    samtools faidx data/references/AaegL5.fasta

    print_success "Reference genome downloaded and indexed"
else
    print_status "Reference genome already exists"
fi

# Download annotation
print_status "Downloading AaegL5 annotation..."
if [ ! -f "data/references/AaegL5.gtf" ]; then
    wget -O data/references/AaegL5.gtf \
        https://vectorbase.org/common/downloads/release-57/AaegyptiLVP_AGWG/gff/data/VectorBase-57_AaegyptiLVP_AGWG.gff
    print_success "Annotation downloaded"
else
    print_status "Annotation already exists"
fi

# Set up SRA toolkit
print_status "Setting up SRA toolkit..."
mkdir -p data/sra
export NCBI_SETTINGS=data/sra/user-settings.mkfg

# Create SRA configuration
cat > data/sra/user-settings.mkfg << EOF
/LIBS/GUID = "your-guid-here"
/config/default = "false"
/sra/default = "false"
/tools/vdb-config/root = "data/sra"
/tools/vdb-config/root/volumes/vol1/path = "data/sra"
/tools/vdb-config/root/volumes/vol1/type = "cache"
/tools/vdb-config/root/volumes/vol1/remote = "true"
/tools/vdb-config/root/volumes/vol1/allow = "true"
/tools/vdb-config/root/volumes/vol1/vol1/remote = "true"
/tools/vdb-config/root/volumes/vol1/vol1/allow = "true"
/tools/vdb-config/root/volumes/vol1/vol1/path = "data/sra"
/tools/vdb-config/root/volumes/vol1/vol1/type = "cache"
EOF

print_success "SRA toolkit configured"

# Create sample metadata template
print_status "Creating sample metadata template..."
cat > data/metadata/samples_template.csv << EOF
sample,fastq_1,fastq_2,strandedness
sample1,data/raw/sample1_R1.fastq.gz,data/raw/sample1_R2.fastq.gz,forward
sample2,data/raw/sample2_R1.fastq.gz,data/raw/sample2_R2.fastq.gz,forward
EOF

print_success "Sample metadata template created"

# Create SRA accessions template
print_status "Creating SRA accessions template..."
cat > data/metadata/sra_accessions_template.csv << EOF
run_accession,experiment_accession,study_accession,experiment_title,study_title,base_count,read_count,instrument_platform,instrument_model,library_layout,library_source,library_selection,fastq_ftp,fastq_aspera,fastq_bytes,fastq_md5,submitted_ftp,submitted_aspera,submitted_bytes,submitted_md5,submitted_format,submitted_md5,first_public,last_updated,experiment_alias,experiment_title,study_alias,base_count,read_count,instrument_platform,instrument_model,library_layout,library_source,library_selection,fastq_ftp,fastq_aspera,fastq_bytes,fastq_md5,submitted_ftp,submitted_aspera,submitted_bytes,submitted_md5,submitted_format,submitted_md5,first_public,last_updated
SRR1234567,SRX1234567,SRP1234567,Example WGS sample,Example study,1000000000,100000000,ILLUMINA,Illumina HiSeq 2500,PAIRED,GENOMIC,Random,ftp.sra.ebi.ac.uk/vol1/fastq/SRR123/007/SRR1234567/SRR1234567_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/SRR123/007/SRR1234567/SRR1234567_2.fastq.gz,era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/SRR123/007/SRR1234567/SRR1234567_1.fastq.gz;era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/SRR123/007/SRR1234567/SRR1234567_2.fastq.gz,1000000000;1000000000,abc123;def456,ftp.sra.ebi.ac.uk/vol1/srr/SRR123/007/SRR1234567,era-fasp@fasp.sra.ebi.ac.uk:/vol1/srr/SRR123/007/SRR1234567,1000000000,ghi789,sra,2023-01-01,2023-01-01
EOF

print_success "SRA accessions template created"

# Create candidate genes template
print_status "Creating candidate genes template..."
cat > data/metadata/candidate_genes_template.txt << EOF
# GWAS candidate genes for dengue resistance
# Format: gene_id,chromosome,start,end,description
# TODO: Replace with actual GWAS candidate gene IDs from dengue resistance study
# Example format:
# GENE_ID,CHROMOSOME,START,END,DESCRIPTION
# LOC123456789,1,1000000,1005000,Dengue resistance candidate gene 1
# LOC987654321,2,2000000,2005000,Dengue resistance candidate gene 2
EOF

print_success "Candidate genes template created"

# Create population metadata template
print_status "Creating population metadata template..."
cat > data/metadata/populations_template.csv << EOF
sample,population,geographic_region,dengue_resistance_phenotype
sample1,pop1,region1,resistant
sample2,pop1,region1,resistant
sample3,pop2,region2,susceptible
sample4,pop2,region2,susceptible
EOF

print_success "Population metadata template created"

# Check if nf-core is available
print_status "Checking nf-core installation..."
if command -v nf-core &> /dev/null; then
    print_success "nf-core is installed"

    # Download nf-core pipelines
    print_status "Downloading nf-core pipelines..."
    nf-core download nf-core/fetchngs --outdir containers/nf-core/fetchngs
    nf-core download nf-core/sarek --outdir containers/nf-core/sarek

    print_success "nf-core pipelines downloaded"
else
    print_warning "nf-core not found - please install with: pip install nf-core"
fi

# Check if Nextflow is available
print_status "Checking Nextflow installation..."
if command -v nextflow &> /dev/null; then
    print_success "Nextflow is installed"
    nextflow --version
else
    print_warning "Nextflow not found - please install from: https://nextflow.io/"
fi

# Check bioinformatics tools
print_status "Checking bioinformatics tools..."
tools=("bwa" "samtools" "bcftools" "gatk" "angsd" "plink2" "vcftools" "fastqc" "multiqc" "iqtree" "selscan" "beagle")

for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        print_success "$tool is available"
    else
        print_warning "$tool not found"
    fi
done

# Create analysis scripts templates
print_status "Creating analysis script templates..."

# Download script template
cat > scripts/download/sra_download.py << 'EOF'
#!/usr/bin/env python3
"""
SRA Download Script for Aedes aegypti WGS Analysis
Downloads SRA data for the dengue resistance study
"""

import argparse
import subprocess
import os
import sys
from pathlib import Path

def download_sra_data(accession, output_dir, max_retries=3):
    """Download SRA data using prefetch and fasterq-dump"""

    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    print(f"Downloading {accession} to {output_path}")

    # Use prefetch to download
    prefetch_cmd = f"prefetch {accession} -O {output_path}"
    subprocess.run(prefetch_cmd, shell=True, check=True)

    # Use fasterq-dump to convert to FASTQ
    fasterq_cmd = f"fasterq-dump {accession} -O {output_path} -t {output_path}"
    subprocess.run(fasterq_cmd, shell=True, check=True)

    print(f"Successfully downloaded {accession}")

def main():
    parser = argparse.ArgumentParser(description="Download SRA data for WGS analysis")
    parser.add_argument("--accession", required=True, help="SRA accession number")
    parser.add_argument("--output", required=True, help="Output directory")
    parser.add_argument("--retries", type=int, default=3, help="Maximum retries")

    args = parser.parse_args()

    try:
        download_sra_data(args.accession, args.output, args.retries)
    except subprocess.CalledProcessError as e:
        print(f"Error downloading {args.accession}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# Population structure analysis script template
cat > scripts/analysis/population_structure.R << 'EOF'
#!/usr/bin/env Rscript
"""
Population Structure Analysis Script
Performs PCA and ADMIXTURE analysis for Aedes aegypti populations
"""

library(ggplot2)
library(dplyr)
library(adegenet)
library(vcfR)

# Function to perform PCA analysis
perform_pca <- function(vcf_file, output_prefix) {
    # Read VCF file
    vcf <- read.vcfR(vcf_file)

    # Convert to genind object
    genind <- vcfR2genind(vcf)

    # Perform PCA
    pca <- dudi.pca(genind, scale = FALSE, scannf = FALSE, nf = 10)

    # Save results
    write.table(pca$li, file = paste0(output_prefix, "_pca.txt"),
                quote = FALSE, sep = "\t")

    return(pca)
}

# Function to create PCA plot
create_pca_plot <- function(pca_result, population_info, output_file) {
    pca_data <- data.frame(
        PC1 = pca_result$li$Axis1,
        PC2 = pca_result$li$Axis2,
        Population = population_info$population
    )

    p <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Population)) +
        geom_point(size = 3, alpha = 0.7) +
        theme_minimal() +
        labs(title = "Population Structure PCA",
             x = "Principal Component 1",
             y = "Principal Component 2") +
        theme(legend.position = "bottom")

    ggsave(output_file, p, width = 10, height = 8, dpi = 300)
}

# Main analysis
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("Usage: Rscript population_structure.R <vcf_file> <population_info> <output_prefix>")
}

vcf_file <- args[1]
population_info_file <- args[2]
output_prefix <- args[3]

# Read population information
population_info <- read.csv(population_info_file)

# Perform PCA
pca_result <- perform_pca(vcf_file, output_prefix)

# Create PCA plot
create_pca_plot(pca_result, population_info, paste0(output_prefix, "_pca.png"))

cat("Population structure analysis completed\n")
EOF

# Selection detection script template
cat > scripts/analysis/selection_detection.R << 'EOF'
#!/usr/bin/env Rscript
"""
Selection Detection Script
Performs Tajima's D, iHS, and XP-EHH analysis for selection detection
"""

library(rehh)
library(ggplot2)
library(dplyr)

# Function to calculate Tajima's D
calculate_tajima_d <- function(vcf_file, window_size = 10000) {
    # This would integrate with ANGSD output
    # For now, placeholder function
    cat("Tajima's D calculation would be implemented here\n")
}

# Function to calculate iHS
calculate_ihs <- function(haplotype_file) {
    # Read haplotype data
    data <- data2haplohh(haplotype_file)

    # Calculate iHS
    ihs_result <- ihh2ihs(data)

    return(ihs_result)
}

# Function to create Manhattan plot
create_manhattan_plot <- function(data, output_file) {
    p <- ggplot(data, aes(x = position, y = statistic)) +
        geom_point(alpha = 0.6) +
        theme_minimal() +
        labs(title = "Selection Signal Manhattan Plot",
             x = "Genomic Position",
             y = "Statistic Value") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    ggsave(output_file, p, width = 12, height = 6, dpi = 300)
}

# Main analysis
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
    stop("Usage: Rscript selection_detection.R <haplotype_file> <output_prefix>")
}

haplotype_file <- args[1]
output_prefix <- args[2]

# Calculate iHS
ihs_result <- calculate_ihs(haplotype_file)

# Save results
write.table(ihs_result, file = paste0(output_prefix, "_ihs.txt"),
            quote = FALSE, sep = "\t")

# Create Manhattan plot
create_manhattan_plot(ihs_result, paste0(output_prefix, "_manhattan.png"))

cat("Selection detection analysis completed\n")
EOF

print_success "Analysis script templates created"

# Set permissions
print_status "Setting script permissions..."
chmod +x scripts/download/sra_download.py
chmod +x scripts/analysis/population_structure.R
chmod +x scripts/analysis/selection_detection.R

print_success "Script permissions set"

# Create README for the project
print_status "Creating project README..."
cat > README_SETUP.md << 'EOF'
# Aedes aegypti Dengue Resistance Multi-Omics Analysis Project - Setup Guide

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/cosmelab/aegyptiDengueWGS.git
   cd aegyptiDengueWGS
   ```

2. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

3. **Start the Docker environment:**
   ```bash
   docker-compose up -d
   ```

4. **Access Jupyter Lab:**
   Open http://localhost:8888 in your browser

## Project Structure

```
aegyptiDengueWGS/
├── data/
│   ├── raw/           # FASTQ files from SRA downloads
│   ├── references/    # AaegL5 genome and annotation
│   └── metadata/      # Sample information and phenotypes
├── results/
│   ├── organized/     # nf-core pipeline outputs
│   └── analysis/      # Population genomics results
├── scripts/
│   ├── download/      # SRA data download utilities
│   ├── analysis/      # Population genetics analysis
│   └── visualization/ # Plotting scripts
├── configs/           # nf-core configuration files
├── containers/        # Custom analysis containers
└── logs/              # Pipeline logs
```

## Next Steps

1. **Prepare your data:**
   - Update `data/metadata/samples.csv` with your sample information
   - Update `data/metadata/sra_accessions.csv` with SRA accessions
   - **Get actual GWAS candidate gene IDs** from the GWAS analysis results
   - Update `data/metadata/candidate_genes.txt` with real GWAS candidate genes

2. **Run nf-core/fetchngs:**
   ```bash
   nextflow run nf-core/fetchngs -profile hpc_batch --input samplesheet.csv
   ```

3. **Run nf-core/sarek:**
   ```bash
   nextflow run nf-core/sarek -profile hpc_batch --input samplesheet.csv --genome AaegL5
   ```

4. **Perform population genomics analysis:**
   ```bash
   Rscript scripts/analysis/population_structure.R
   Rscript scripts/analysis/selection_detection.R
   ```

## Documentation

- [README.md](README.md) - Main project overview
- [README_WGS.md](README_WGS.md) - Detailed WGS specifications
- [PROJECT_RULES.md](PROJECT_RULES.md) - Analysis strategy
- [WORKFLOW.md](WORKFLOW.md) - Step-by-step pipeline instructions
- [USER_RULES.md](USER_RULES.md) - AI assistant guidelines

## Support

- **Issues:** [GitHub Issues](https://github.com/cosmelab/aegyptiDengueWGS/issues)
- **Email:** <degopwn@gmail.com>
EOF

print_success "Project README created"

# Final status
echo ""
echo "=================================================================="
print_success "Setup completed successfully!"
echo ""
print_status "Next steps:"
echo "1. Update metadata files in data/metadata/"
echo "2. Get actual GWAS candidate gene IDs from the GWAS analysis"
echo "3. Update data/metadata/candidate_genes.txt with real gene IDs"
echo "4. Run: docker-compose up -d"
echo "5. Access Jupyter Lab at http://localhost:8888"
echo "6. Follow the workflow in WORKFLOW.md"
echo ""
print_status "For more information, see README_SETUP.md"
echo "=================================================================="
