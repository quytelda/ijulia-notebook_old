FROM docker.io/library/julia:latest

ENV JUPYTER_UID=1000
ENV JUPYTER_GID=1000
ENV JUPYTER_HOME=/home/jupyter

# Create a user to run the server daemon.
RUN groupadd --gid "$JUPYTER_GID" jupyter \
    && useradd \
           --create-home \
           --home-dir "$JUPYTER_HOME" \
           --gid "$JUPYTER_GID" \
           --uid "$JUPYTER_UID" \
           jupyter \
    && mkdir /data \
    && chown jupyter:jupyter /data

# Install Jupyter Notebook dependencies.
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	       bzip2 \
	       fonts-liberation \
	       locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

USER jupyter:jupyter
WORKDIR "$JUPYTER_HOME"

# Install miniconda and Jupyter Notebook.
ARG CONDA_URL='https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh'
ARG CONDA_SHA256='1ea2f885b4dbc3098662845560bc64271eb17085387a70c2ba3f29fff6f8d52f'

ENV CONDA_DIR="$JUPYTER_HOME/miniconda"

RUN curl -o /tmp/miniconda.sh "$CONDA_URL" \
    && echo "$CONDA_SHA256 /tmp/miniconda.sh" \
	| sha256sum -c - \
    && /bin/bash /tmp/miniconda.sh -b -p "$CONDA_DIR" \
    && rm /tmp/miniconda.sh \
    \
    && $CONDA_DIR/bin/conda install --yes notebook \
    && $CONDA_DIR/bin/conda clean --all --force-pkgs-dirs --yes \
    \
    && mkdir "$JUPYTER_HOME/.jupyter"

COPY --chown=jupyter:jupyter jupyter_notebook_config.py "$JUPYTER_HOME/.jupyter/"

ENV PATH="$PATH:$CONDA_DIR/bin"

# Install IJulia and interactive plotting packages.
COPY --chown=jupyter:jupyter installpkgs.jl /tmp/
RUN julia /tmp/installpkgs.jl \
          IJulia \
          Plots \
          GR \
    && rm -rf "$JUPYTER_HOME/.julia/registries/General" \
    && rm /tmp/installpkgs.jl

VOLUME "/data"
VOLUME "$JUPYTER_HOME/.jupyter"

EXPOSE 8888/tcp

ENTRYPOINT ["jupyter", "notebook"]
