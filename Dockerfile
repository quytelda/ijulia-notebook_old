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

USER jupyter:jupyter
WORKDIR "$JUPYTER_HOME"

# Install IJulia and interactive plotting packages.
RUN set -eux; \
    julia -e 'import Pkg; Pkg.update()'; \
    julia -e 'import Pkg; Pkg.add("IJulia"); Pkg.add("Plots"); Pkg.add("GR")'; \
    julia -e 'import Pkg; Pkg.precompile()';

# Install Jupyter notebook interface via miniconda.
    RUN echo 'y' | julia -e 'import IJulia; IJulia.find_jupyter_subcommand("notebook")'

RUN mkdir \
    "$JUPYTER_HOME/data" \
    "$JUPYTER_HOME/.jupyter"
COPY jupyter_notebook_config.py "$JUPYTER_HOME/.jupyter/"

VOLUME "$JUPYTER_HOME/data"
VOLUME "$JUPYTER_HOME/.jupyter"

EXPOSE 8888/tcp

ENTRYPOINT ["/usr/bin/julia", "-e", "import IJulia; IJulia.notebook()"]
