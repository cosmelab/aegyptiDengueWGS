FROM mambaorg/micromamba:1.5.0

ENV MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:/usr/bin:$PATH

SHELL ["bash", "-lc"]
USER root

# Update micromamba and all packages to latest versions
RUN micromamba update --all -y

# Install system dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    ca-certificates \
    curl \
    git \
    unzip \
    zsh \
    bash \
    libcairo2-dev \
    libbz2-dev \
    liblzma-dev \
    wget \
    software-properties-common \
    dirmngr \
    lsb-release \
    gnupg2 \
    build-essential \
    libz-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libtinfo5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install core system packages first (conda-forge only)
RUN micromamba install --channel-priority strict -c conda-forge \
    libstdcxx-ng \
    python=3.11 \
    starship \
    cmake \
    make \
    gcc \
    gxx \
    datamash \
    openjdk \
    pip \
    -y && micromamba clean --all --yes

# Install lsd manually (not available in conda-forge)
RUN wget https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xzf lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz && \
    mv lsd-v1.1.5-x86_64-unknown-linux-gnu/lsd /usr/local/bin/ && \
    rm -rf lsd-v1.1.5-*

# Install Ruby and colorls
RUN micromamba install --channel-priority strict -c conda-forge \
    ruby \
    gcc \
    make \
    -y && micromamba clean --all --yes

# Set up Ruby gem environment and install colorls
RUN export GEM_HOME="/opt/conda/share/rubygems" && \
    export GEM_PATH="/opt/conda/share/rubygems" && \
    export PATH="/opt/conda/share/rubygems/bin:$PATH" && \
    gem install colorls

# Create colorls configuration directory and file
RUN mkdir -p ~/.config/colorls && \
    echo "unrecognized_file: white" > ~/.config/colorls/dark_colors.yaml && \
    echo "recognized_file: white" >> ~/.config/colorls/dark_colors.yaml && \
    echo "executable_file: red" >> ~/.config/colorls/dark_colors.yaml && \
    echo "dir: blue" >> ~/.config/colorls/dark_colors.yaml && \
    echo "user: magenta" >> ~/.config/colorls/dark_colors.yaml && \
    echo "group: cyan" >> ~/.config/colorls/dark_colors.yaml && \
    echo "date: yellow" >> ~/.config/colorls/dark_colors.yaml && \
    echo "time: darkgreen" >> ~/.config/colorls/dark_colors.yaml && \
    echo "file_size: palegreen" >> ~/.config/colorls/dark_colors.yaml && \
    echo "read: darkgreen" >> ~/.config/colorls/dark_colors.yaml && \
    echo "write: yellow" >> ~/.config/colorls/dark_colors.yaml && \
    echo "exec: red" >> ~/.config/colorls/dark_colors.yaml && \
    echo "no_access: gray" >> ~/.config/colorls/dark_colors.yaml && \
    echo "image: magenta" >> ~/.config/colorls/dark_colors.yaml && \
    echo "video: blue" >> ~/.config/colorls/dark_colors.yaml && \
    echo "music: cyan" >> ~/.config/colorls/dark_colors.yaml && \
    echo "log: yellow" >> ~/.config/colorls/dark_colors.yaml

# Install Jupyter ecosystem (conda-forge only)
RUN micromamba install --channel-priority strict -c conda-forge \
    jupyter \
    jupyterlab \
    notebook \
    ipykernel \
    -y && micromamba clean --all --yes

# Install all bioinformatics tools in a single layer (optimized)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    # Core Python stack for population genetics
    scikit-allel cyvcf2 pandas numpy scipy matplotlib seaborn plotly \
    # Essential WGS analysis tools
    angsd iqtree bcftools bedtools samtools bwa gatk4 fastqc multiqc trim-galore \
    # Specialized analysis tools
    selscan beagle plink2 vcftools admixture \
    -y && micromamba clean --all --yes

# Install R base and Bioconductor packages (conda-forge + bioconda)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    r-base \
    r-devtools \
    bioconductor-variantannotation \
    bioconductor-snprelate \
    bioconductor-annotationdbi \
    bioconductor-biomart \
    sra-tools \
    entrez-direct \
    -y && micromamba clean --all --yes

# Install workflow management tools (optional - remove if not needed)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    snakemake \
    mamba \
    -y && micromamba clean --all --yes

# Set LD_LIBRARY_PATH to use conda's libstdc++
ENV LD_LIBRARY_PATH=/opt/conda/lib

# Install additional Python packages for WGS analysis
RUN pip3 install --no-cache-dir \
    pyfaidx \
    pysam \
    allel \
    bokeh \
    requests \
    beautifulsoup4 \
    xmltodict \
    lxml \
    biopython \
    scikit-learn

# Install R packages for population genetics (removed duplicates)
RUN R -e "install.packages(c('here', 'data.table', 'tidyverse', 'ggplot2', 'qqman', 'qqplotr', 'reticulate', 'broom', 'readxl', 'writexl', 'knitr', 'rmarkdown', 'rehh', 'pegas', 'ape', 'phangorn', 'adegenet', 'poppr', 'hierfstat', 'genepop', 'popgenome', 'vcfR', 'dartR', 'LEA', 'snpStats', 'genetics', 'HardyWeinberg'), repos='https://cloud.r-project.org/')"

# Install and configure shell environment in a single layer
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/dracula/zsh.git ~/.oh-my-zsh/themes/dracula && \
    git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="dracula\/dracula"/' ~/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc && \
    echo 'export DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc && \
    echo 'export DISABLE_UPDATE_PROMPT="true"' >> ~/.zshrc && \
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc && \
    sed -i 's/typeset -g POWERLEVEL9K_TIME_BACKGROUND=.*/typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta/' ~/.p10k.zsh || echo 'typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta' >> ~/.p10k.zsh && \
    echo 'if command -v lsd > /dev/null; then' >> ~/.zshrc && \
    echo '  sed -i "/alias ls=/d" ~/.zshrc' >> ~/.zshrc && \
    echo '  sed -i "/LS_COLORS=/d" ~/.zshrc' >> ~/.zshrc && \
    echo '  export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;94:ex=1;31:bd=1;95:cd=1;96:ur=0;32:uw=0;33:ux=0;31:ue=0;32:gr=0;32:gw=0;33:gx=0;31:tr=0;90:tw=0;93:tx=0;92"' >> ~/.zshrc && \
    echo '  alias ls="lsd --color=always --header"' >> ~/.zshrc && \
    echo '  alias ll="colorls --long --almost-all --sort-dirs --git-status"' >> ~/.zshrc && \
    echo '  alias la="lsd -la --color=always --header"' >> ~/.zshrc && \
    echo '  alias lt="lsd --tree --color=always --header"' >> ~/.zshrc && \
    echo 'fi' >> ~/.zshrc && \
    echo '# Match local colorls environment' >> ~/.zshrc && \
    echo 'export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;94:ex=1;31:bd=1;95:cd=1;96:ur=0;32:uw=0;33:ux=0;31:ue=0;32:gr=0;32:gw=0;33:gx=0;31:tr=0;90:tw=0;93:tx=0;92"' >> ~/.zshrc && \
    echo 'export LSCOLORS="Gxfxcxdxbxegedabagacad"' >> ~/.zshrc && \
    echo 'export TERM="xterm-256color"' >> ~/.zshrc && \
    echo 'export COLORTERM="truecolor"' >> ~/.zshrc && \
    echo 'export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0"' >> ~/.zshrc && \
    echo 'export COLORFGBG="15;0"' >> ~/.zshrc && \
    echo '# Ruby gem environment' >> ~/.zshrc && \
    echo 'export GEM_HOME="/opt/conda/share/rubygems"' >> ~/.zshrc && \
    echo 'export GEM_PATH="/opt/conda/share/rubygems"' >> ~/.zshrc && \
    echo 'export PATH="/opt/conda/share/rubygems/bin:$PATH"' >> ~/.zshrc && \
    echo '# Initialize conda' >> ~/.zshrc && \
    echo 'export PATH="/opt/conda/bin:${PATH}"' >> ~/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc && \
    echo 'export PATH="/opt/conda/bin:${PATH}"' >> ~/.bashrc

# Set working directory and create directory structure
WORKDIR /proj

# Create necessary directories
RUN mkdir -p /proj/data/raw /proj/data/references /proj/data/metadata \
    /proj/results/organized /proj/results/analysis \
    /proj/scripts/download /proj/scripts/analysis /proj/scripts/visualization \
    /proj/configs /proj/containers /proj/logs

# Set Python environment
ENV PYTHONPATH=/opt/conda/lib/python3.11/site-packages

# Expose Jupyter port
EXPOSE 8888

# Create non-root user for security
RUN groupadd -r aegypti && useradd -r -g aegypti aegypti && \
    chown -R aegypti:aegypti /proj && \
    # Clean up caches while still root
    rm -rf /tmp/* /var/tmp/* /root/.cache 2>/dev/null || true

# Switch to non-root user
USER aegypti

# Default command
CMD ["/bin/bash"]
