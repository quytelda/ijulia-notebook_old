FROM docker.io/library/julia:1.5.0-buster

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
           jupyter

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

# Install IJulia and interactive plotting packages.
RUN set -eux; \
    julia -e 'import Pkg; Pkg.update()'; \
    julia -e 'import Pkg; Pkg.add("IJulia"); Pkg.add("Plots"); Pkg.add("GR")'; \
    julia -e 'import Pkg; Pkg.precompile()';

# Install miniconda.
RUN curl -o miniconda.sh 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh' \
    && echo '879457af6a0bf5b34b48c12de31d4df0ee2f06a8e68768e5758c3293b2daf688 miniconda.sh' \
	| sha256sum -c - \
    && /bin/bash ./miniconda.sh -b -p ./miniconda

ENV PATH="$PATH:$JUPYTER_HOME/miniconda/bin"

# Install Jupyter Notebook.
RUN conda install --yes notebook

RUN mkdir \
    "$JUPYTER_HOME/data" \
    "$JUPYTER_HOME/.jupyter"
COPY jupyter_notebook_config.py "$JUPYTER_HOME/.jupyter/"

VOLUME "$JUPYTER_HOME/data"
VOLUME "$JUPYTER_HOME/.jupyter"

EXPOSE 8888/tcp

ENTRYPOINT ["/home/jupyter/miniconda/bin/jupyter", "notebook"]
