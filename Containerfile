FROM nvidia/cuda:12.3.1-devel-ubi9 as builder

# install deps
RUN dnf install -y pip git zlib-devel bzip2-devel openssl-devel xz-devel sqlite-devel libffi-devel ncurses-devel

# install pyenv
RUN curl https://pyenv.run | bash

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

RUN pyenv which python

ENV POETRY_VIRTUALENVS_IN_PROJECT true

RUN poetry env use $(pyenv which python) && \
    poetry install --with ui && \
    poetry install --with local

RUN CMAKE_ARGS='-DLLAMA_CUBLAS=on' poetry run pip install --force-reinstall --no-cache-dir llama-cpp-python

FROM nvidia/cuda:12.3.1-devel-ubi9

# install deps
RUN dnf install -y pip git zlib-devel bzip2-devel openssl-devel xz-devel sqlite-devel libffi-devel ncurses-devel

# install pyenv
RUN curl https://pyenv.run | bash

ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH

# install python 3.11
RUN pyenv install 3.11 && \
    pyenv global 3.11

# install poetry
RUN pip install poetry

RUN git clone https://github.com/imartinez/privateGPT.git /app

WORKDIR /app

RUN poetry config virtualenvs.create false && \
    poetry env use python3.11 && \
    poetry install --wht ui && \
    poetry install --with local

# Cleanup 
RUN rm -rf /root/.pyenv/cache && \
    poetry cache clear --all

# Define the base image for the production stage
FROM registry.access.redhat.com/ubi9/ubi:latest as production

# Install make and poetry
RUN dnf -y install make

# Copy Python 3.11 installation from the builder stage
COPY --from=builder /root/.pyenv /root/.pyenv

# Set environment variables to use Python 3.11 installed via pyenv
ENV HOME  /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV POETRY_VIRTUALENVS_IN_PROJECT true

# Install poetry
RUN pip install poetry

# Copy your application code
COPY --from=builder /app /app

# Set the working directory in the production image
WORKDIR /app
