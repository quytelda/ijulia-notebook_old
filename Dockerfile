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

USER jupyter:jupyter
WORKDIR "$JUPYTER_HOME"

# Install IJulia and interactive plotting packages.
RUN set -eux; \
    julia -e 'import Pkg; Pkg.update()'; \
    julia -e 'import Pkg; Pkg.add("IJulia"); Pkg.add("Plots"); Pkg.add("GR")'; \
    julia -e 'import Pkg; Pkg.precompile()';
