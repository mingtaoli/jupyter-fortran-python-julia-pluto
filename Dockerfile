FROM jupyter/datascience-notebook:ubuntu-20.04

LABEL maintainer="XJTU Ai4energy Team <mingtao@xjtu.edu.cn>"

USER ${NB_USER}

RUN mamba install --quiet --yes \
    'fortran-magic' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

WORKDIR ${HOME}

COPY --chown=${NB_USER}:users ./jupyter-gfort-kernel ./jupyter-gfort-kernel
COPY --chown=${NB_USER}:users ./jupyter-pluto ./jupyter-pluto

COPY --chown=${NB_USER}:users ./runpluto.sh ./runpluto.sh
COPY --chown=${NB_USER}:users ./notebooks ./notebooks
COPY --chown=${NB_USER}:users ./Project.toml ./Project.toml
COPY --chown=${NB_USER}:users ./Manifest.toml ./Manifest.toml

RUN cd ${HOME} && \
    pip install --user ./jupyter-gfort-kernel --no-cache-dir && \
    jupyter kernelspec install ./jupyter-gfort-kernel/gfort_spec --user

ENV JULIA_PROJECT=/home/jovyan

RUN julia -e "import Pkg; Pkg.Registry.update(); Pkg.instantiate(); Pkg.status(); Pkg.precompile()"

RUN cd ${HOME} &&\
    jupyter labextension install @jupyterlab/server-proxy && \
    jupyter lab build && \
    jupyter lab clean && \
    pip install ./jupyter-pluto --no-cache-dir && \
    rm -rf ~/.cache