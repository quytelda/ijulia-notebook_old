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
