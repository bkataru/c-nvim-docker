FROM silkeh/clang:latest

# Install required packages for Neovim and AstroNvim
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    wget \
    python3.11 \
    python3-pip \
    python3.11-venv \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    make \
    cmake \
    bear \
    gdb \
    lldb \
    valgrind \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install compiledb-go (faster than Python compiledb)
RUN curl -L -o /tmp/compiledb.txz https://github.com/fcying/compiledb-go/releases/download/v1.5.1/compiledb-linux-amd64.txz \
    && tar -C /tmp -Jxf /tmp/compiledb.txz \
    && mv /tmp/compiledb /usr/bin \
    && chmod +x /usr/bin/compiledb \
    && rm /tmp/compiledb.txz

# Install Neovim
RUN curl -L -o /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz \
    && tar -C /tmp -xzf /tmp/nvim.tar.gz \
    && mv /tmp/nvim-linux-x86_64 /opt/nvim \
    && rm /tmp/nvim.tar.gz

# Add Neovim to PATH
ENV PATH="$PATH:/opt/nvim/bin"

# Create a non-root user for better security
ARG USERNAME=tron
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set working directory to the volume mount point
WORKDIR /workspace

# Set environment variables to keep configurations within /workspace
ENV XDG_CONFIG_HOME=/workspace/.config
ENV XDG_DATA_HOME=/workspace/.local/share
ENV XDG_CACHE_HOME=/workspace/.cache

# Switch to non-root user
USER $USERNAME

# Default command
CMD ["/bin/bash"]
