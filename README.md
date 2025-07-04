# Aedes aegypti WGS Analysis Pipeline

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
- **Output**: Candidate loci for follow-up WGS analysis

#### RNA-seq Data
- **Purpose**: Expression validation of candidate genes
- **Design**: Resistant vs susceptible population comparisons
- **Integration**: Cross-omics validation of WGS findings

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

## 🐳 **Container Usage**

This project provides a comprehensive bioinformatics environment for WGS analysis through Docker and Singularity containers.

### Available Containers

The analysis environment is available from two sources:

#### Docker Hub
```bash
# Pull from Docker Hub (public)
docker pull cosmelab/aegypti-dengue-wgs:latest
```

#### GitHub Container Registry (GHCR)
```bash
# Pull from GHCR (requires authentication for private repos)
docker pull ghcr.io/cosmelab/aegypti-dengue-wgs:latest
```

### Singularity on HPC

For HPC systems without Docker, use Singularity:

#### From Docker Hub
```bash
# Load Singularity module (if required)
module load singularity-ce/3.9.3

# Pull and build Singularity container
singularity pull aegypti-dengue-wgs.sif docker://cosmelab/aegypti-dengue-wgs:latest
```

#### From GHCR (requires authentication)
```bash
# Authenticate with GHCR (requires GitHub token)
echo $GITHUB_TOKEN | singularity remote login --username cosmelab --password-stdin oras://ghcr.io

# Pull and build Singularity container
singularity pull aegypti-dengue-wgs.sif docker://ghcr.io/cosmelab/aegypti-dengue-wgs:latest
```

### Running the Container

#### Interactive Shell
```bash
# Start interactive shell with project directory mounted
singularity shell \
    --cleanenv \
    --bind /path/to/your/project:/proj \
    aegypti-dengue-wgs.sif

# Once inside the container, navigate to the project directory
cd /proj
```

#### Execute Commands
```bash
# Run a single command
singularity exec \
    --cleanenv \
    --bind /path/to/your/project:/proj \
    aegypti-dengue-wgs.sif your-command

# Run Python script
singularity exec \
    --cleanenv \
    --bind /path/to/your/project:/proj \
    aegypti-dengue-wgs.sif python /proj/scripts/your_script.py
```

### Mounting Directories

The container automatically mounts:
- **Home directory** (`$HOME`)
- **Current working directory**
- **Temporary directory** (`/tmp`)

Additional mounts can be specified with `--bind`:
```bash
# Mount multiple directories
singularity exec \
    --bind /path/to/data:/data,/path/to/results:/results \
    aegypti-dengue-wgs.sif your-command

# Mount with read-write permissions
singularity exec \
    --bind /path/to/data:/data:rw \
    aegypti-dengue-wgs.sif your-command
```

### SLURM Batch Script Examples

#### Example 1: Basic WGS Analysis Job
```bash
#!/bin/bash
#SBATCH --job-name=wgs-analysis
#SBATCH --output=wgs_%j.out
#SBATCH --error=wgs_%j.err
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=epyc

# Load Singularity module (if required)
module load singularity-ce/3.9.3

# Set paths
PROJECT_DIR="/path/to/your/project"
CONTAINER="aegypti-dengue-wgs.sif"

# Run WGS analysis
singularity exec \
    --cleanenv \
    --bind ${PROJECT_DIR}:/proj \
    ${CONTAINER} \
    bash -c "cd /proj && python scripts/analysis/wgs_pipeline.py"
```

#### Example 2: Population Genetics Analysis
```bash
#!/bin/bash
#SBATCH --job-name=popgen-analysis
#SBATCH --output=popgen_%j.out
#SBATCH --error=popgen_%j.err
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=epyc

module load singularity-ce/3.9.3

PROJECT_DIR="/path/to/your/project"
CONTAINER="aegypti-dengue-wgs.sif"

# Run ANGSD analysis
singularity exec \
    --cleanenv \
    --bind ${PROJECT_DIR}:/proj \
    ${CONTAINER} \
    bash -c "cd /proj && angsd -bam bam_list.txt -GL 2 -doMaf 2 -out results/angsd_maf -doMajorMinor 1 -P 16"

# Run PLINK analysis
singularity exec \
    --cleanenv \
    --bind ${PROJECT_DIR}:/proj \
    ${CONTAINER} \
    bash -c "cd /proj && plink2 --vcf results/variants.vcf.gz --pca 10 --out results/pca"
```

#### Example 3: R Analysis with Multiple Mounts
```bash
#!/bin/bash
#SBATCH --job-name=r-analysis
#SBATCH --output=r_analysis_%j.out
#SBATCH --error=r_analysis_%j.err
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=epyc

module load singularity-ce/3.9.3

PROJECT_DIR="/path/to/your/project"
DATA_DIR="/path/to/large/data"
RESULTS_DIR="/path/to/results"
CONTAINER="aegypti-dengue-wgs.sif"

# Run R analysis with multiple directory mounts
singularity exec \
    --cleanenv \
    --bind ${PROJECT_DIR}:/proj,${DATA_DIR}:/data,${RESULTS_DIR}:/results \
    ${CONTAINER} \
    bash -c "cd /proj && Rscript scripts/analysis/population_analysis.R"
```

#### Example 4: Python Analysis with Jupyter
```bash
#!/bin/bash
#SBATCH --job-name=jupyter-analysis
#SBATCH --output=jupyter_%j.out
#SBATCH --error=jupyter_%j.err
#SBATCH --time=8:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=epyc

module load singularity-ce/3.9.3

PROJECT_DIR="/path/to/your/project"
CONTAINER="aegypti-dengue-wgs.sif"

# Start Jupyter server in background
singularity exec \
    --cleanenv \
    --bind ${PROJECT_DIR}:/proj \
    ${CONTAINER} \
    bash -c "cd /proj && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root" &

# Wait for Jupyter to start
sleep 10

# Print connection information
echo "Jupyter Lab is running. Connect via SSH tunnel:"
echo "ssh -L 8888:localhost:8888 username@hpc-server"
echo "Then open: http://localhost:8888"
```

## 🔗 **Remote Development Setup**

### SSH Configuration for HPC Access

To access your HPC system remotely via Cursor, VS Code, or other SSH clients, configure your SSH settings:

#### 1. SSH Config Setup
Add this to your `~/.ssh/config` file:

```bash
# HPC SSH Configuration
Host ucr-hpc
  HostName cluster.hpcc.ucr.edu
  User your-username
  IdentityFile ~/.ssh/id_rsa
  AddKeysToAgent yes
  UseKeychain yes
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 600
```

#### 2. SSH Key Setup
```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Copy public key to HPC
ssh-copy-id -i ~/.ssh/id_rsa.pub your-username@cluster.hpcc.ucr.edu

# Test connection
ssh ucr-hpc
```

### Remote Development with Cursor/VS Code

#### 1. Install SSH Extension
- **Cursor**: Built-in SSH support
- **VS Code**: Install "Remote - SSH" extension

#### 2. Connect to HPC
1. Open Cursor/VS Code
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type "Remote-SSH: Connect to Host"
4. Select your configured host (e.g., `ucr-hpc`)
5. Choose platform (Linux)
6. Enter password if prompted

#### 3. Open Project Directory
1. Once connected, click "Open Folder"
2. Navigate to your project directory (e.g., `/path/to/your/project`)
3. Open the project

#### 4. Use Integrated Terminal
- Open terminal in Cursor/VS Code
- Run Singularity commands directly
- Access all HPC resources

### SSH Tunneling for Jupyter

#### Method 1: Command Line
```bash
# Create SSH tunnel for Jupyter
ssh -L 8888:localhost:8888 ucr-hpc

# On HPC, start Jupyter
singularity exec --cleanenv --bind /path/to/project:/proj aegypti-dengue-wgs.sif \
    bash -c "cd /proj && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"

# Open in browser: http://localhost:8888
```

#### Method 2: VS Code/Cursor Port Forwarding
1. Connect to HPC via SSH extension
2. Start Jupyter in terminal
3. VS Code/Cursor will automatically detect the port
4. Click "Open in Browser" when prompted

### Best Practices

#### 1. Environment Variables
Add to your `~/.bashrc` or `~/.zshrc`:
```bash
# HPC environment setup
export HPC_HOST="ucr-hpc"
export HPC_USER="your-username"
export HPC_PROJECT="/path/to/your/project"
```

#### 2. Alias for Quick Access
```bash
# Add to ~/.bashrc
alias hpc="ssh ucr-hpc"
alias hpc-project="ssh ucr-hpc 'cd $HPC_PROJECT && singularity shell --cleanenv --bind $HPC_PROJECT:/proj aegypti-dengue-wgs.sif'"
```

#### 3. VS Code/Cursor Settings
Create `.vscode/settings.json` in your project:
```json
{
    "remote.SSH.defaultExtensions": [
        "ms-python.python",
        "ms-python.black-formatter",
        "ms-vscode.vscode-json"
    ],
    "python.defaultInterpreterPath": "/opt/conda/bin/python",
    "terminal.integrated.shell.linux": "/bin/zsh"
}
```

### Troubleshooting

#### Common Issues
1. **Permission denied**: Check SSH key permissions (`chmod 600 ~/.ssh/id_rsa`)
2. **Connection timeout**: Verify hostname and network connectivity
3. **Port already in use**: Change Jupyter port (e.g., `--port=8889`)
4. **Container not found**: Ensure `.sif` file is in project directory

#### Debug SSH Connection
```bash
# Test with verbose output
ssh -v ucr-hpc

# Check SSH agent
ssh-add -l

# Test specific key
ssh -i ~/.ssh/id_rsa your-username@cluster.hpcc.ucr.edu
```

## 🔬 **Available Tools**

The container includes a comprehensive bioinformatics environment:

### Core Bioinformatics Tools
- **samtools** (1.22) - SAM/BAM file manipulation
- **bcftools** (1.22) - VCF/BCF file manipulation
- **vcftools** (0.1.17) - VCF file processing
- **angsd** (0.940) - Genotype likelihood-based analysis
- **plink** (v1.9.0-b.8) - Population genetics analysis
- **plink2** (v2.0.0-a.6.9LM) - Modern PLINK for large datasets
- **fastq-dump** (2.9.6) - SRA data download

### Python Environment
- **Python** (3.11.7) with comprehensive bioinformatics packages:
  - `pandas`, `numpy`, `scipy` - Data analysis
  - `matplotlib`, `seaborn`, `plotly` - Visualization
  - `sklearn` - Machine learning
  - `pysam` - SAM/BAM file processing
  - `Bio` (biopython) - Bioinformatics utilities
  - `allel` (scikit-allel) - Population genetics
  - `cyvcf2` - Fast VCF parsing
  - `pyfaidx` - FASTA file indexing

### R Environment
- **R** (4.4.2) with population genetics packages:
  - `ade4`, `MASS`, `ggplot2`, `vegan`, `seqinr`, `qqconf`
  - `data.table`, `tidyverse` - Data manipulation
  - `pegas`, `ape`, `vcfR`, `genetics` - Population genetics
  - `qqman`, `qqplotr` - Manhattan plots
  - `reticulate`, `broom`, `readxl`, `writexl` - Utilities

### Workflow Management
- **snakemake** (9.6.2) - Workflow management
- **jupyter** (4.4.4) - Interactive analysis
- **jupyterlab** (4.4.4) - JupyterLab interface

### Shell Environment
- **zsh** (5.9) with Oh-My-Zsh and Powerlevel10k
- **starship** (1.23.0) - Cross-shell prompt
- **lsd** (1.1.5) - Modern ls replacement
- **colorls** (1.5.0) - Colored ls with git status

## 🧪 **Testing the Container**

### Method 1: Test Inside Container (Recommended)
Start the container and run the test script inside:

```bash
# Start interactive session
singularity shell --cleanenv --bind /path/to/your/project:/proj aegypti-dengue-wgs.sif

# Once inside the container, navigate to project and run test
cd /proj
./scripts/test_tools.sh
```

### Method 2: Test from Host System
Run tests from the host system (requires Singularity module):

```bash
# Load Singularity module (if required)
module load singularity-ce/3.9.3

# Run tests manually
singularity exec aegypti-dengue-wgs.sif /opt/conda/bin/python -c "import pandas, numpy, scipy, matplotlib, seaborn, plotly, sklearn, pysam, Bio, allel, cyvcf2, pyfaidx; print('All Python packages imported successfully!')"
```

### Method 3: Manual Testing
Test specific tools manually:

```bash
# Test Python packages
singularity exec aegypti-dengue-wgs.sif /opt/conda/bin/python -c "import pandas, numpy, scipy, matplotlib, seaborn, plotly, sklearn, pysam, Bio, allel, cyvcf2, pyfaidx; print('All Python packages imported successfully!')"

# Test R packages
singularity exec aegypti-dengue-wgs.sif R -e "library(ade4); library(MASS); library(ggplot2); library(vegan); library(seqinr); library(qqconf); library(data.table); library(tidyverse); library(pegas); library(ape); library(vcfR); library(genetics); cat('All R packages loaded successfully!')"
```

## 🔬 **Technical Framework**

### Primary Analysis Pipeline

#### nf-core/fetchngs
- **Purpose**: Automated SRA data retrieval and preprocessing
- **Input**: Sample sheet with SRA accessions
- **Output**: Quality-controlled FASTQ files
- **Configuration**: HPC-optimized for SLURM systems

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

### SLURM Integration
- **Job Submission**: Custom configs for SLURM job submission
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

## 🚀 **Getting Started**

### 1. Environment Setup

```bash
# Clone repository
git clone https://github.com/cosmelab/aegyptiDengueWGS.git
cd aegyptiDengueWGS

# Pull Singularity container
singularity pull aegypti-dengue-wgs.sif docker://cosmelab/aegypti-dengue-wgs:latest

# Test the container (after starting it)
singularity shell --cleanenv --bind /path/to/your/project:/proj aegypti-dengue-wgs.sif
cd /proj
./scripts/test_tools.sh
```

### 2. Data Preparation

```bash
# Start interactive session
singularity shell --cleanenv --bind /path/to/your/project:/proj aegypti-dengue-wgs.sif

# Once inside the container, navigate to the project directory
cd /proj

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

## 📚 **Documentation**

- **README_WGS.md**: Detailed WGS analysis documentation
- **WORKFLOW.md**: Pipeline workflow and execution guide
- **PROJECT_RULES.md**: Project-specific rules and guidelines
- **USER_RULES.md**: AI assistant interaction guidelines

## 🤝 **Contributing**

This project is designed for publication purposes. For questions or issues, please open a GitHub issue or contact the maintainers.

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔧 **Container Development Guide**

### Setting Up Your Own Container Build

If you want to build your own container or modify the existing one:

#### 1. Repository Setup

**Fork or Clone the Repository:**
```bash
git clone https://github.com/cosmelab/aegyptiDengueWGS.git
cd aegyptiDengueWGS
```

#### 2. GitHub Secrets Configuration

Add these secrets to your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

**Required Secrets:**
- `DOCKERHUB_TOKEN`: Your Docker Hub access token
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `GHCR_TOKEN`: GitHub Container Registry token (if using GHCR)

**How to Get Tokens:**
- **Docker Hub**: Go to `Account Settings` → `Security` → `New Access Token`
- **GitHub**: Go to `Settings` → `Developer settings` → `Personal access tokens` → `Tokens (classic)`

#### 3. GitHub Actions Workflow

Create `.github/workflows/docker-build.yml`:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    paths:
      - 'Dockerfile'
      - '.github/workflows/docker-build.yml'
  pull_request:
    branches: [ main ]
    paths:
      - 'Dockerfile'
      - '.github/workflows/docker-build.yml'
  workflow_dispatch:
    inputs:
      platform:
        description: 'Platform to build for'
        required: true
        default: 'linux/amd64'
        type: choice
        options:
        - linux/amd64
        - linux/arm64
        - linux/amd64,linux/arm64

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}

    - name: Login to GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.GHCR_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: |
          ${{ secrets.DOCKERHUB_USERNAME }}/aegypti-dengue-wgs
          ghcr.io/${{ github.repository_owner }}/aegypti-dengue-wgs
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: ${{ github.event.inputs.platform || 'linux/amd64' }}
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

#### 4. Multi-Architecture Support

**Build for Multiple Architectures:**
- **AMD64**: Standard x86_64 systems
- **ARM64**: Apple Silicon (M1/M2), ARM servers

**Manual Build Commands:**
```bash
# Build for AMD64 only
docker buildx build --platform linux/amd64 -t your-username/aegypti-dengue-wgs:latest .

# Build for ARM64 only
docker buildx build --platform linux/arm64 -t your-username/aegypti-dengue-wgs:latest .

# Build for both architectures
docker buildx build --platform linux/amd64,linux/arm64 -t your-username/aegypti-dengue-wgs:latest .
```

#### 5. Local Development

**Build Locally:**
```bash
# Build without pushing
docker build -t aegypti-dengue-wgs:local .

# Test locally
docker run -it aegypti-dengue-wgs:local /bin/zsh

# Build with BuildKit for better performance
DOCKER_BUILDKIT=1 docker build -t aegypti-dengue-wgs:local .
```

#### 6. Push Without Triggering Workflows

**Skip CI/CD:**
```bash
# Add [skip ci] to commit message
git commit -m "feat: add new feature [skip ci]"

# Or use [no ci]
git commit -m "docs: update documentation [no ci]"

# Push without triggering workflows
git push origin main
```

**GitHub Actions Skip Patterns:**
- `[skip ci]`
- `[no ci]`
- `[ci skip]`
- `***NO_CI***`

#### 7. Customization Options

**Modify Dockerfile:**
- Add new packages to conda installation
- Change Python/R versions
- Add custom scripts or configurations
- Modify user environment

**Example Package Addition:**
```dockerfile
# Add new conda packages
RUN micromamba install -c conda-forge -c bioconda \
    your-new-package \
    another-package \
    -y && micromamba clean --all --yes
```

**Example R Package Addition:**
```dockerfile
# Add new R packages
RUN R -e "install.packages(c('new-package', 'another-package'), repos='https://cloud.r-project.org/', dependencies=TRUE)"
```

#### 8. Testing Your Container

**Test Locally:**
```bash
# Build your container
docker build -t my-aegypti-wgs:test .

# Test with the test script
docker run -it --rm -v $(pwd):/proj my-aegypti-wgs:test bash -c "cd /proj && ./scripts/test_tools.sh"
```

**Test on HPC:**
```bash
# Convert to Singularity
singularity pull my-aegypti-wgs.sif docker://your-username/aegypti-dengue-wgs:latest

# Test in container
singularity shell --cleanenv --bind /path/to/project:/proj my-aegypti-wgs.sif
cd /proj
./scripts/test_tools.sh
```

## 🙏 **Acknowledgments**

- **nf-core community** for pipeline development
- **Bioconductor** for R package ecosystem
- **Conda-forge** for Python package management
- **Singularity** for HPC containerization
