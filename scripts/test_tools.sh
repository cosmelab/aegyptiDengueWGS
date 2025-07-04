#!/bin/bash

# Test script for tools inside the aegypti-dengue-wgs container
# Run this script AFTER starting the container with: singularity shell --cleanenv --bind /path/to/project:/proj aegypti-dengue-wgs.sif

# Don't exit on error, let all tests run

echo "🧪 Testing Tools Inside aegypti-dengue-wgs Container"
echo "=================================================="

# Check if we're in the container by looking for micromamba
if ! command -v micromamba &> /dev/null; then
    echo "❌ Error: This script must be run inside the aegypti-dengue-wgs container"
    echo "Start the container first: singularity shell --cleanenv --bind /path/to/project:/proj aegypti-dengue-wgs.sif"
    echo "Then run: cd /proj && ./scripts/test_tools.sh"
    echo ""
    echo "Current directory: $(pwd)"
    echo "micromamba command: $(which micromamba 2>/dev/null || echo 'Not found')"
    exit 1
fi

echo "✅ Running inside aegypti-dengue-wgs container"
echo ""

# Function to test command
test_command() {
    local name="$1"
    local command="$2"
    local expected_output="$3"

    echo "Testing $name..."
    if bash -c "$command" 2>/dev/null | grep -q "$expected_output"; then
        echo "  ✅ $name: OK"
        return 0
    else
        echo "  ❌ $name: FAILED"
        return 1
    fi
}

# Function to test Python import
test_python_import() {
    local package="$1"
    local import_name="$2"

    echo "Testing Python package: $package..."
    if /opt/conda/bin/python -c "import $import_name; print('OK')" 2>/dev/null | grep -q "OK"; then
        echo "  ✅ $package: OK"
        return 0
    else
        echo "  ❌ $package: FAILED"
        return 1
    fi
}

# Function to test R package
test_r_package() {
    local package="$1"

    echo "Testing R package: $package..."
    if R -e "library($package); cat('OK')" 2>/dev/null | grep -q "OK"; then
        echo "  ✅ $package: OK"
        return 0
    else
        echo "  ❌ $package: FAILED"
        return 1
    fi
}

# Initialize counters
total_tests=0
passed_tests=0

echo "🔧 Testing Core System Tools"
echo "----------------------------"

# Test core system tools
test_command "micromamba" "micromamba --version" "1.5.0" && ((passed_tests++))
((total_tests++))

test_command "Python" "python --version" "Python 3.11.7" && ((passed_tests++))
((total_tests++))

test_command "Java" "java -version 2>&1" "OpenJDK" && ((passed_tests++))
((total_tests++))

test_command "gcc" "gcc --version" "gcc" && ((passed_tests++))
((total_tests++))

test_command "make" "make --version" "GNU Make" && ((passed_tests++))
((total_tests++))

echo ""
echo "🧬 Testing Bioinformatics Tools"
echo "-------------------------------"

# Test bioinformatics tools
test_command "samtools" "samtools --version" "samtools 1.22" && ((passed_tests++))
((total_tests++))

test_command "bcftools" "bcftools --version" "bcftools 1.22" && ((passed_tests++))
((total_tests++))

test_command "vcftools" "vcftools --version" "VCFtools" && ((passed_tests++))
((total_tests++))

test_command "angsd" "angsd --version 2>&1" "angsd version" && ((passed_tests++))
((total_tests++))

test_command "plink" "plink --version" "PLINK v1.9" && ((passed_tests++))
((total_tests++))

test_command "plink2" "plink2 --version" "PLINK v2.0" && ((passed_tests++))
((total_tests++))

test_command "fastq-dump" "fastq-dump --version" "fastq-dump" && ((passed_tests++))
((total_tests++))

echo ""
echo "🐍 Testing Python Packages"
echo "-------------------------"

# Test Python packages
test_python_import "pandas" "pandas" && ((passed_tests++))
((total_tests++))

test_python_import "numpy" "numpy" && ((passed_tests++))
((total_tests++))

test_python_import "scipy" "scipy" && ((passed_tests++))
((total_tests++))

test_python_import "matplotlib" "matplotlib" && ((passed_tests++))
((total_tests++))

test_python_import "seaborn" "seaborn" && ((passed_tests++))
((total_tests++))

test_python_import "plotly" "plotly" && ((passed_tests++))
((total_tests++))

test_python_import "sklearn" "sklearn" && ((passed_tests++))
((total_tests++))

test_python_import "pysam" "pysam" && ((passed_tests++))
((total_tests++))

test_python_import "biopython" "Bio" && ((passed_tests++))
((total_tests++))

test_python_import "scikit-allel" "allel" && ((passed_tests++))
((total_tests++))

test_python_import "cyvcf2" "cyvcf2" && ((passed_tests++))
((total_tests++))

test_python_import "pyfaidx" "pyfaidx" && ((passed_tests++))
((total_tests++))

echo ""
echo "📊 Testing R Packages"
echo "-------------------"

# Test R packages
test_r_package "ade4" && ((passed_tests++))
((total_tests++))

test_r_package "MASS" && ((passed_tests++))
((total_tests++))

test_r_package "ggplot2" && ((passed_tests++))
((total_tests++))

test_r_package "vegan" && ((passed_tests++))
((total_tests++))

test_r_package "seqinr" && ((passed_tests++))
((total_tests++))

test_r_package "qqconf" && ((passed_tests++))
((total_tests++))

test_r_package "data.table" && ((passed_tests++))
((total_tests++))

test_r_package "tidyverse" && ((passed_tests++))
((total_tests++))

test_r_package "pegas" && ((passed_tests++))
((total_tests++))

test_r_package "ape" && ((passed_tests++))
((total_tests++))

test_r_package "vcfR" && ((passed_tests++))
((total_tests++))

test_r_package "genetics" && ((passed_tests++))
((total_tests++))

echo ""
echo "🛠️ Testing Workflow Tools"
echo "------------------------"

# Test workflow tools
test_command "snakemake" "snakemake --version 2>&1" "9.6" && ((passed_tests++))
((total_tests++))

test_command "jupyter" "jupyter --version" "jupyter" && ((passed_tests++))
((total_tests++))

test_command "jupyterlab" "jupyter lab --version 2>&1" "4.4" && ((passed_tests++))
((total_tests++))

echo ""
echo "🐚 Testing Shell Tools"
echo "--------------------"

# Test shell tools
test_command "zsh" "zsh --version" "zsh" && ((passed_tests++))
((total_tests++))

test_command "starship" "starship --version" "starship" && ((passed_tests++))
((total_tests++))

test_command "lsd" "lsd --version" "lsd" && ((passed_tests++))
((total_tests++))

test_command "colorls" "colorls --version 2>&1" "1.5" && ((passed_tests++))
((total_tests++))

echo ""
echo "📋 Test Summary"
echo "==============="
echo "Total tests: $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $((total_tests - passed_tests))"

if [ $passed_tests -eq $total_tests ]; then
    echo ""
    echo "🎉 All tests passed! The container is ready for use."
    echo ""
    echo "You can now run your WGS analysis pipeline!"
else
    echo ""
    echo "⚠️  Some tests failed. Please check the container installation."
    echo "You may need to rebuild the container or check for missing dependencies."
    exit 1
fi
