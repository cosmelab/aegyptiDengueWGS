# GitHub and Docker Hub Setup Guide for Aedes aegypti WGS Project

## Overview
This guide explains how to set up your WGS analysis project on GitHub and connect it to Docker Hub for automated image builds.

## ✅ Pre-Push Checklist

### Repository Files Check
- [x] **README.md** - Updated for WGS project
- [x] **README_WGS.md** - Detailed WGS specifications
- [x] **PROJECT_RULES.md** - Analysis strategy
- [x] **WORKFLOW.md** - Step-by-step pipeline
- [x] **USER_RULES.md** - AI assistant guidelines
- [x] **Dockerfile** - Optimized for population genetics tools
- [x] **docker-compose.yml** - Updated for WGS environment
- [x] **setup.sh** - Environment setup script
- [x] **.gitignore** - Appropriate for WGS analysis
- [x] **.github/workflows/docker-build.yml** - Updated for WGS project
- [x] **configs/hpc_batch.conf** - HPC configuration
- [x] **configs/custom.config** - Custom parameters

### Project Structure Check
- [x] **data/** - Directory structure created
- [x] **results/** - Directory structure created
- [x] **scripts/** - Directory structure created
- [x] **configs/** - Configuration files present
- [x] **containers/** - Container directory created
- [x] **logs/** - Logs directory created

## Step 1: Create GitHub Repository

### Option A: Web Browser (Recommended)
1. Go to [github.com](https://github.com) and log in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Fill in the details:
   - **Repository name**: `aegyptiDengueWGS`
   - **Description**: `Aedes aegypti Dengue Resistance Multi-Omics Analysis Project`
   - **Visibility**: Choose Public or Private
   - **DO NOT** check "Add a README file", "Add .gitignore", or "Choose a license"
5. Click "Create repository"

### Option B: GitHub CLI
```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Create repository from current directory
gh repo create aegyptiDengueWGS --public --description "Aedes aegypti Dengue Resistance Multi-Omics Analysis Project" --source=. --remote=origin --push
```

### Option C: Manual Setup (Recommended for HPC)
```bash
# Initialize git in current directory
git init

# Set the default branch to main (modern standard)
git branch -M main

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: Aedes aegypti Dengue Resistance Multi-Omics Analysis Project"

# Create repository and push to main branch
gh repo create aegyptiDengueWGS --public --description "Aedes aegypti Dengue Resistance Multi-Omics Analysis Project - WGS data integration with GWAS and RNA-seq" --source=. --remote=origin --push
```

## Step 2: Push Your Code to GitHub

After creating the repository, run these commands in your terminal:

```bash
# Initialize git if not already done
git init

# Add all files to git
git add .

# Make your first commit
git commit -m "Initial commit: Aedes aegypti Dengue Resistance Multi-Omics Analysis Project"

# Add the GitHub repository as remote
git remote add origin https://github.com/cosmelab/aegyptiDengueWGS.git

# Push to GitHub
git push -u origin main
```

## Step 3: Set Up Docker Hub

### Create Docker Hub Account (if not exists)
1. Go to [hub.docker.com](https://hub.docker.com)
2. Click "Sign Up" and create an account
3. Verify your email address

### Create Docker Hub Repository
1. Log in to Docker Hub
2. Click "Create Repository"
3. Fill in the details:
   - **Repository name**: `aegypti-dengue-wgs`
   - **Description**: `Aedes aegypti Dengue Resistance Multi-Omics Analysis Environment`
   - **Visibility**: Choose Public or Private
4. Click "Create"

## Step 4: Set Up GitHub Secrets

### Required Secrets
You need to add these secrets to your GitHub repository:

1. **Go to your GitHub repository**
   - Click "Settings" → "Secrets and variables" → "Actions"
   - Click "New repository secret"

2. **Add these secrets:**
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub access token

### Create Docker Hub Access Token
1. Log in to Docker Hub
2. Go to "Account Settings" → "Security"
3. Click "New Access Token"
4. Give it a name (e.g., "GitHub Actions")
5. Copy the token (you won't see it again)
6. Add it to GitHub secrets as `DOCKER_PASSWORD`

## Step 5: Test the Setup

### Test GitHub Repository
```bash
# Make a small change
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "Test commit"
git push
```

### Test Docker Build
1. Check GitHub Actions tab to see if the build runs
2. Check Docker Hub to see if the image is built
3. Test pulling the image:
```bash
docker pull cosmelab/aegypti-dengue-wgs:latest
```

## Step 6: Verify Everything Works

### Local Testing
```bash
# Test local build
docker build -t aegypti-dengue-wgs .

# Test local run
docker run -it aegypti-dengue-wgs

# Test with docker-compose
docker-compose up -d
```

### Remote Testing
```bash
# Pull from Docker Hub
docker pull cosmelab/aegypti-dengue-wgs:latest

# Pull from GitHub Container Registry
docker pull ghcr.io/cosmelab/aegypti-dengue-wgs:latest
```

## Repository Information

### GitHub Repository
- **URL**: `https://github.com/cosmelab/aegyptiDengueWGS`
- **Description**: Aedes aegypti Dengue Resistance Multi-Omics Analysis Project
- **Topics**: `wgs`, `population-genetics`, `aedes-aegypti`, `dengue-resistance`, `multi-omics`

### Docker Images
- **Docker Hub**: `cosmelab/aegypti-dengue-wgs:latest`
- **GitHub Container Registry**: `ghcr.io/cosmelab/aegypti-dengue-wgs:latest`

### Key Features
- **Multi-omics integration**: GWAS → WGS → RNA-seq validation
- **Population genomics**: ANGSD, PLINK2, ADMIXTURE, selscan
- **Selection detection**: Tajima's D, iHS, XP-EHH
- **Phylogenetics**: IQ-TREE, BEAGLE haplotype phasing
- **HPC optimized**: nf-core pipelines with SLURM support

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify Docker Hub username and token in GitHub secrets
   - Ensure token has write permissions

2. **Build Failures**
   - Check Dockerfile syntax
   - Verify all required files are in the repository
   - Check GitHub Actions logs for specific errors

3. **Push Failures**
   - Ensure you have write access to the Docker Hub repository
   - Verify the repository name matches exactly

### Useful Commands

```bash
# Check git remote
git remote -v

# Check Docker Hub login
docker login

# Test local build
docker build -t aegypti-dengue-wgs .

# Test local run
docker run -it aegypti-dengue-wgs

# Check GitHub Actions status
gh run list
```

## Next Steps

1. **Set up branch protection** in GitHub
2. **Configure automated testing** in GitHub Actions
3. **Set up version tagging** for releases
4. **Configure multi-platform builds** (AMD64 + ARM64)
5. **Add project documentation** to GitHub Pages
6. **Set up issue templates** for bug reports and feature requests

## Security Notes

- Never commit secrets directly to your repository
- Use GitHub secrets for sensitive information
- Regularly rotate Docker Hub access tokens
- Consider using Docker Hub's vulnerability scanning
- Enable Dependabot for security updates

## Support

- [GitHub Documentation](https://docs.github.com/)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

## Project Status

- [x] **Repository structure** - Complete
- [x] **Documentation** - Complete
- [x] **Docker environment** - Complete
- [x] **GitHub Actions** - Configured
- [ ] **GitHub repository** - To be created
- [ ] **Docker Hub repository** - To be created
- [ ] **Secrets configuration** - To be done
- [ ] **First build** - To be tested
