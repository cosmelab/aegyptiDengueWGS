FROM mambaorg/micromamba:1.5.0

ENV MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:/usr/bin:$PATH

SHELL ["bash", "-lc"]
USER root

# Update micromamba and all packages to latest versions
RUN micromamba update --all -y

# Install system dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libcairo2-dev \
    libbz2-dev \
    liblzma-dev \
    wget \
    lsb-release \
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
    -y && micromamba clean --all --yes







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
    scikit-allel cyvcf2 pandas numpy scipy matplotlib seaborn plotly scikit-learn pyfaidx pysam biopython \
    # Essential WGS analysis tools
    angsd samtools bcftools vcftools \
    # Population genetics tools
    plink plink2 \
    -y && micromamba clean --all --yes

# Install R base and Bioconductor packages (conda-forge + bioconda)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    r-base \
    r-devtools \
    bioconductor-variantannotation \
    bioconductor-snpRelate \
    bioconductor-annotationdbi \
    bioconductor-biomart \
    sra-tools \
    entrez-direct \
    -y && micromamba clean --all --yes

# Install workflow management tools (optional - remove if not needed)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    snakemake \
    -y && micromamba clean --all --yes

# Set locale to avoid warnings
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8



# Install R packages for population genetics (essential and utility only)
RUN R -e "install.packages(c('data.table', 'tidyverse', 'qqman', 'qqplotr', 'reticulate', 'broom', 'readxl', 'writexl', 'knitr', 'rmarkdown', 'pegas', 'ape', 'phangorn', 'adegenet', 'vcfR', 'genetics', 'HardyWeinberg'), repos='https://cloud.r-project.org/')"

# Install and configure shell environment in a single layer (as root, then transfer to aedes)
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /tmp/.oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /tmp/.oh-my-zsh/custom/themes/powerlevel10k && \
    git clone https://github.com/dracula/zsh.git /tmp/.oh-my-zsh/themes/dracula && \
    git clone https://github.com/zsh-users/zsh-completions.git /tmp/.oh-my-zsh/custom/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /tmp/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /tmp/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    cp /tmp/.oh-my-zsh/templates/zshrc.zsh-template /tmp/.zshrc && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="dracula\/dracula"/' /tmp/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/' /tmp/.zshrc && \
    echo 'export DISABLE_AUTO_UPDATE="true"' >> /tmp/.zshrc && \
    echo 'export DISABLE_UPDATE_PROMPT="true"' >> /tmp/.zshrc && \
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> /tmp/.zshrc && \
    sed -i 's/typeset -g POWERLEVEL9K_TIME_BACKGROUND=.*/typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta/' /tmp/.p10k.zsh || echo 'typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta' >> /tmp/.p10k.zsh && \
    echo 'if command -v lsd > /dev/null; then' >> /tmp/.zshrc && \
    echo '  sed -i "/alias ls=/d" /tmp/.zshrc' >> /tmp/.zshrc && \
    echo '  sed -i "/LS_COLORS=/d" /tmp/.zshrc' >> /tmp/.zshrc && \
    echo '  export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;94:ex=1;31:bd=1;95:cd=1;96:ur=0;32:uw=0;33:ux=0;31:ue=0;32:gr=0;32:gw=0;33:gx=0;31:tr=0;90:tw=0;93:tx=0;92"' >> /tmp/.zshrc && \
    echo '  alias ls="lsd --color=always --header"' >> /tmp/.zshrc && \
    echo '  alias ll="colorls --long --almost-all --sort-dirs --git-status"' >> /tmp/.zshrc && \
    echo '  alias la="lsd -la --color=always --header"' >> /tmp/.zshrc && \
    echo '  alias lt="lsd --tree --color=always --header"' >> /tmp/.zshrc && \
    echo 'fi' >> /tmp/.zshrc && \
    echo '# Match local colorls environment' >> /tmp/.zshrc && \
    echo 'export LSCOLORS="Gxfxcxdxbxegedabagacad"' >> /tmp/.zshrc && \
    echo 'export TERM="xterm-256color"' >> /tmp/.zshrc && \
    echo 'export COLORTERM="truecolor"' >> /tmp/.zshrc && \
    echo 'export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0"' >> /tmp/.zshrc && \
    echo 'export COLORFGBG="15;0"' >> /tmp/.zshrc && \
    echo '# Ruby gem environment' >> /tmp/.zshrc && \
    echo 'export GEM_HOME="/opt/conda/share/rubygems"' >> /tmp/.zshrc && \
    echo 'export GEM_PATH="/opt/conda/share/rubygems"' >> /tmp/.zshrc && \
    echo 'export PATH="/opt/conda/share/rubygems/bin:$PATH"' >> /tmp/.zshrc && \
    echo '# Initialize conda' >> /tmp/.zshrc && \
    echo 'export PATH="/opt/conda/bin:${PATH}"' >> /tmp/.zshrc

# Set working directory and create directory structure
WORKDIR /proj

# Create necessary directories
RUN mkdir -p /proj/data/raw /proj/data/processed /proj/data/references /proj/data/metadata \
    /proj/results/interim /proj/results/organized /proj/results/analysis \
    /proj/scripts /proj/scripts/analysis /proj/scripts/visualization \
    /proj/configs /proj/containers /proj/logs && \
    chown -R aedes:aedes /proj



# Expose Jupyter port
EXPOSE 8888

# Create non-root user for security
RUN groupadd -r aedes && useradd -r -g aedes aedes && \
    chown -R aedes:aedes /proj

# Switch to non-root user for configuration
USER aedes

# Set up Ruby gem environment and install colorls for aedes user
RUN export GEM_HOME="/opt/conda/share/rubygems" && \
    export GEM_PATH="/opt/conda/share/rubygems" && \
    export PATH="/opt/conda/share/rubygems/bin:$PATH" && \
    gem install colorls

# Create colorls configuration directory and file for aedes user
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

# Copy zsh configuration from root to aedes user and set ownership
RUN cp -r /tmp/.oh-my-zsh ~/.oh-my-zsh && \
    cp /tmp/.zshrc ~/.zshrc && \
    cp /tmp/.p10k.zsh ~/.p10k.zsh && \
    chown -R aedes:aedes ~/.oh-my-zsh ~/.zshrc ~/.p10k.zsh && \
    rm -rf /tmp/.oh-my-zsh /tmp/.zshrc /tmp/.p10k.zsh



# Clean up only cache files (keep config files)
RUN rm -rf /var/tmp/* 2>/dev/null || true

# Default command
CMD ["/bin/zsh"]
