FROM nvidia/cuda:12.3.1-devel-ubi9 as builder

# install deps
RUN dnf install -y pip git zlib-devel bzip2-devel openssl-devel xz-devel sqlite-devel libffi-devel ncurses-devel

# install pyenv
RUN curl https://pyenv.run | bash

# set env vars for pyenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH

# install python 3.11
RUN pyenv install 3.11 && \
    pyenv global 3.11 && \
    pyenv rehash

# install poetry
RUN pip install poetry

RUN git clone https://github.com/imartinez/privateGPT.git /app

WORKDIR /app

# create the .venv inside the project
ENV POETRY_VIRTUALENVS_IN_PROJECT true

# install deps with poetry
RUN poetry env use $(pyenv which python) && \
    poetry install --with ui && \
    poetry install --with local

# recompile llama-cpp with cuda support
RUN CMAKE_ARGS='-DLLAMA_CUBLAS=on' poetry run pip install --force-reinstall --no-cache-dir llama-cpp-python

# Cleanup 
RUN rm -rf /root/.pyenv/cache && \
    poetry cache clear PyPI --all && \
    poetry cache clear _default_cache --all

# Define the base image for the production stage
FROM registry.access.redhat.com/ubi9/ubi:latest as production

# Copy Python 3.11 installation and venv from the builder stage
COPY --from=builder /root/.pyenv /root/.pyenv
COPY --from=builder /app/.venv /venv

# Set environment variables to use Python 3.11 installed via pyenv
ENV HOME  /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV POETRY_VIRTUALENVS_IN_PROJECT true

# Install make and poetry
RUN dnf -y install make && \
    pip install poetry

# Run entrypoint script
COPY entrypoint.sh entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# Set the working directory in the production image
WORKDIR /app

# run privateGPT by default
CMD ["make", "run"]
