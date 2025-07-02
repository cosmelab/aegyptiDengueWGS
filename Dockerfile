FROM mambaorg/micromamba:1.5.0

ENV MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:/usr/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

SHELL ["bash", "-lc"]
USER root

# Update micromamba and all packages to latest versions
RUN micromamba update --all -y

# Install system dependencies in a single layer (removed build-essential, will use conda's gcc/make)
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install lsd manually (not available in conda-forge)
RUN wget https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xzf lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz && \
    mv lsd-v1.1.5-x86_64-unknown-linux-gnu/lsd /usr/local/bin/ && \
    rm -rf lsd-v1.1.5-*

# Install ALL conda packages in a single layer (consolidated)
RUN micromamba install --channel-priority strict -c conda-forge -c bioconda \
    # Core system packages
    libstdcxx-ng \
    python=3.11 \
    starship \
    datamash \
    openjdk \
    pip \
    # Compiler tools (replacing build-essential)
    gcc \
    make \
    # Ruby for colorls
    ruby \
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
    r-base \
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

# Install R packages for population genetics (essential and utility only)
RUN R -e "install.packages(c('data.table', 'tidyverse', 'qqman', 'qqplotr', 'reticulate', 'broom', 'readxl', 'writexl', 'knitr', 'rmarkdown', 'pegas', 'ape', 'phangorn', 'adegenet', 'vcfR', 'genetics'), repos='https://cloud.r-project.org/')"

# Set up Oh My Zsh and shell environment in a single layer
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /home/aedes/.oh-my-zsh && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/aedes/.oh-my-zsh/custom/themes/powerlevel10k && \
    cp /home/aedes/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k.zsh /home/aedes/.p10k.zsh && \
    git clone https://github.com/dracula/zsh.git /home/aedes/.oh-my-zsh/themes/dracula && \
    git clone https://github.com/zsh-users/zsh-completions.git /home/aedes/.oh-my-zsh/custom/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/aedes/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/aedes/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    cp /home/aedes/.oh-my-zsh/templates/zshrc.zsh-template /home/aedes/.zshrc && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="dracula\/dracula"/' /home/aedes/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)/' /home/aedes/.zshrc && \
    echo 'export DISABLE_AUTO_UPDATE="true"' >> /home/aedes/.zshrc && \
    echo 'export DISABLE_UPDATE_PROMPT="true"' >> /home/aedes/.zshrc && \
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> /home/aedes/.zshrc && \
    sed -i 's/typeset -g POWERLEVEL9K_TIME_BACKGROUND=.*/typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta/' /home/aedes/.p10k.zsh || echo 'typeset -g POWERLEVEL9K_TIME_BACKGROUND=magenta' >> /home/aedes/.p10k.zsh && \
    echo 'if command -v lsd > /dev/null; then' >> /home/aedes/.zshrc && \
    echo '  sed -i "/alias ls=/d" /home/aedes/.zshrc' >> /home/aedes/.zshrc && \
    echo '  sed -i "/LS_COLORS=/d" /home/aedes/.zshrc' >> /home/aedes/.zshrc && \
    echo '  export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;94:ex=1;31:bd=1;95:cd=1;96:ur=0;32:uw=0;33:ux=0;31:ue=0;32:gr=0;32:gw=0;33:gx=0;31:tr=0;90:tw=0;93:tx=0;92"' >> /home/aedes/.zshrc && \
    echo '  alias ls="lsd --color=always --header"' >> /home/aedes/.zshrc && \
    echo '  alias ll="colorls --long --almost-all --sort-dirs --git-status"' >> /home/aedes/.zshrc && \
    echo '  alias la="lsd -la --color=always --header"' >> /home/aedes/.zshrc && \
    echo '  alias lt="lsd --tree --color=always --header"' >> /home/aedes/.zshrc && \
    echo 'fi' >> /home/aedes/.zshrc && \
    echo '# Match local colorls environment' >> /home/aedes/.zshrc && \
    echo 'export LSCOLORS="Gxfxcxdxbxegedabagacad"' >> /home/aedes/.zshrc && \
    echo 'export TERM="xterm-256color"' >> /home/aedes/.zshrc && \
    echo 'export COLORTERM="truecolor"' >> /home/aedes/.zshrc && \
    echo 'export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0"' >> /home/aedes/.zshrc && \
    echo 'export COLORFGBG="15;0"' >> /home/aedes/.zshrc && \
    echo '# Ruby gem environment' >> /home/aedes/.zshrc && \
    echo 'export GEM_HOME="/opt/conda/share/rubygems"' >> /home/aedes/.zshrc && \
    echo 'export GEM_PATH="/opt/conda/share/rubygems"' >> /home/aedes/.zshrc && \
    echo 'export PATH="/opt/conda/share/rubygems/bin:$PATH"' >> /home/aedes/.zshrc && \
    echo '# Initialize conda' >> /home/aedes/.zshrc && \
    echo 'export PATH="/opt/conda/bin:${PATH}"' >> /home/aedes/.zshrc && \
    chown -R aedes:aedes /home/aedes

# Set working directory and create ALL project directories in one command
WORKDIR /proj

# Create all project subdirectories at once
RUN mkdir -p /proj/{data/{raw,processed,references,metadata},results/{interim,organized,analysis},scripts/{download,analysis,visualization},configs,containers,logs} \
    && chown -R aedes:aedes /proj

# Expose Jupyter port
EXPOSE 8888

# Create non-root user for security with home directory
RUN groupadd -r aedes && useradd -r -g aedes -m aedes && \
    chown -R aedes:aedes /proj && \
    id aedes

# Switch to non-root user for configuration
USER aedes

# Set up Ruby gem environment and install colorls for aedes user
RUN export GEM_HOME="/opt/conda/share/rubygems" && \
    export GEM_PATH="/opt/conda/share/rubygems" && \
    export PATH="/opt/conda/share/rubygems/bin:$PATH" && \
    /opt/conda/bin/gem install colorls

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

# Zsh configuration is already set up in /home/aedes/.oh-my-zsh and /home/aedes/.zshrc

# Clean up only cache files (keep config files)
RUN rm -rf /var/tmp/* 2>/dev/null || true

# Default command
CMD ["/bin/zsh"]
