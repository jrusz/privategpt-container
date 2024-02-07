# Use Arch Linux latest image
FROM archlinux:latest

# Install all the system dependencies
RUN curl -O https://archive.archlinux.org/packages/g/gcc/gcc-12.2.1-4-x86_64.pkg.tar.zst && \
    curl -O https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-12.2.1-4-x86_64.pkg.tar.zst && \
    pacman -Sy vim git tmux pyenv poetry make cuda-tools --noconfirm && \
    pacman -U gcc-* --noconfirm && \
    useradd -m -u 1000 user

ENV PATH="/opt/cuda/bin:${PATH}"

# Switch to user
USER 1000
WORKDIR /home/user

# Install all the user dependencies
RUN git clone https://github.com/imartinez/privateGPT && \
    cd privateGPT && \
    pyenv install 3.11 && \
    pyenv local 3.11 && \
    poetry install --with ui && \
    poetry install --with local && \
    CMAKE_ARGS='-DLLAMA_CUBLAS=on' poetry run pip install --force-reinstall --no-cache-dir llama-cpp-python
