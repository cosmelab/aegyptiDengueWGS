FROM mambaorg/micromamba:1.5.0

ENV MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:/usr/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

SHELL ["bash", "-lc"]
USER root

# Update micromamba and all packages to latest versions
RUN micromamba update --all -y

# Install system dependencies and create user in a single layer
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
    libz-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libtinfo5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && groupadd -r aedes && useradd -r -g aedes aedes \
    && mkdir -p /home/aedes && chown aedes:aedes /home/aedes

# Install lsd manually (not available in conda-forge)
RUN wget https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xzf lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz && \
    mv lsd-v1.1.5-x86_64-unknown-linux-gnu/lsd /usr/local/bin/ && \
    rm -rf lsd-v1.1.5-*

# Install ALL conda packages with pinned versions in a single layer
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    # Core system packages
    libstdcxx-ng \
    python=3.11.7 \
    starship \
    datamash \
    openjdk=17 \
    pip \
    # Compiler tools (replacing build-essential)
    gcc \
    make \
    # Jupyter ecosystem
    jupyter \
    jupyterlab \
    notebook \
    ipykernel \
    # Core Python stack for population genetics
    scikit-allel \
    cyvcf2 \
    pandas \
    numpy \
    scipy \
    matplotlib \
    seaborn \
    plotly \
    scikit-learn \
    pyfaidx \
    pysam \
    biopython \
    # Essential WGS analysis tools
    angsd \
    samtools \
    bcftools \
    vcftools \
    # Population genetics tools
    plink \
    plink2 \
    # R base and Bioconductor packages
    r-base=4.3.2 \
    r-devtools \
    bioconductor-variantannotation \
    bioconductor-snpRelate \
    bioconductor-annotationdbi \
    bioconductor-biomart \
    sra-tools \
    entrez-direct \
    # Workflow management tools
    snakemake \
    -y && micromamba clean --all --yes

# Install Ruby separately (with its bundled gem)
RUN micromamba install -c conda-forge ruby=3.2.2 -y && micromamba clean --all --yes

# Install missing R dependencies via conda (preferred over R install.packages)
RUN micromamba install -y -c conda-forge -c bioconda \
    r-ade4 r-mass r-ggplot2 r-vegan r-seqinr r-qqconf \
    && micromamba clean --all --yes

# Install R packages for population genetics (essential and utility only)
RUN R -e "install.packages(c('data.table', 'tidyverse', 'qqman', 'qqplotr', 'reticulate', 'broom', 'readxl', 'writexl', 'knitr', 'rmarkdown', 'pegas', 'ape', 'phangorn', 'vcfR', 'genetics'), repos='https://cloud.r-project.org/', dependencies=TRUE)"

# Install colorls globally as root (fixes permission issue)
RUN /opt/conda/bin/gem install colorls --no-document -n /usr/local/bin && \
    chmod +x /usr/local/bin/colorls

# Switch to aedes user early to avoid unnecessary root-owned layers
USER aedes

# Install and configure Oh-My-Zsh, Powerlevel10k, and all plugins in a single layer
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /tmp/powerlevel10k \
  && cp /tmp/powerlevel10k/config/p10k.zsh /home/aedes/.p10k.zsh \
  && git clone https://github.com/ohmyzsh/ohmyzsh.git /home/aedes/.oh-my-zsh \
  && git clone https://github.com/dracula/zsh.git /home/aedes/.oh-my-zsh/themes/dracula \
  && git clone https://github.com/zsh-users/zsh-completions.git /home/aedes/.oh-my-zsh/custom/plugins/zsh-completions \
  && git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/aedes/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/aedes/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
  && cp /home/aedes/.oh-my-zsh/templates/zshrc.zsh-template /home/aedes/.zshrc \
  && sed -i 's/ZSH_THEME=".*"/ZSH_THEME="dracula\/dracula"/' /home/aedes/.zshrc \
  && sed -i 's/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/' /home/aedes/.zshrc \
  && echo 'export DISABLE_AUTO_UPDATE="true"' >> /home/aedes/.zshrc \
  && echo 'export DISABLE_UPDATE_PROMPT="true"' >> /home/aedes/.zshrc \
  && echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> /home/aedes/.zshrc \
  && sed -i 's/typeset -g POWERLEVEL9K_TIME_BACKGROUND=.*/typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta/' /home/aedes/.p10k.zsh || echo 'typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta' >> /home/aedes/.p10k.zsh \
  && echo 'if command -v lsd > /dev/null; then' >> /home/aedes/.zshrc \
  && echo '  sed -i "/alias ls=/d" /home/aedes/.zshrc' >> /home/aedes/.zshrc \
  && echo '  sed -i "/LS_COLORS=/d" /home/aedes/.zshrc' >> /home/aedes/.zshrc \
  && echo '  export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;94:ex=1;31:bd=1;95:cd=1;96:ur=0;32:uw=0;33:ux=0;31:ue=0;32:gr=0;32:gw=0;33:gx=0;31:tr=0;90:tw=0;93:tx=0;92"' >> /home/aedes/.zshrc \
  && echo '  alias ls="lsd --color=always --header"' >> /home/aedes/.zshrc \
  && echo '  alias ll="colorls --long --almost-all --sort-dirs --git-status"' >> /home/aedes/.zshrc \
  && echo '  alias la="lsd -la --color=always --header"' >> /home/aedes/.zshrc \
  && echo '  alias lt="lsd --tree --color=always --header"' >> /home/aedes/.zshrc \
  && echo 'fi' >> /home/aedes/.zshrc \
  && echo '# Match local colorls environment' >> /home/aedes/.zshrc \
  && echo 'export LSCOLORS="Gxfxcxdxbxegedabagacad"' >> /home/aedes/.zshrc \
  && echo 'export TERM="xterm-256color"' >> /home/aedes/.zshrc \
  && echo 'export COLORTERM="truecolor"' >> /home/aedes/.zshrc \
  && echo 'export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0"' >> /home/aedes/.zshrc \
  && echo 'export COLORFGBG="15;0"' >> /home/aedes/.zshrc \
  && echo '# Initialize conda' >> /home/aedes/.zshrc \
  && echo 'export PATH="/opt/conda/bin:${PATH}"' >> /home/aedes/.zshrc

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

# Set working directory and create ALL project directories in one command
WORKDIR /proj

# Create all project subdirectories at once using brace expansion
RUN mkdir -p /proj/{data/{raw,processed,references,metadata},results/{interim,organized,analysis},scripts/{download,analysis,visualization},configs,containers,logs}

# Expose Jupyter port
EXPOSE 8888

# Clean up only cache files (keep config files)
RUN rm -rf /var/tmp/* 2>/dev/null || true

# Default command
CMD ["/bin/zsh"]
