FROM jupyter/base-notebook
LABEL maintainer="Hiromu Hota <hiromu.hota@hal.hitachi.com>"
USER root

RUN apt-get update && apt-get install -y \
    poppler-utils \
    postgresql-client \
    libmagickwand-dev \
    ghostscript \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN rm /etc/ImageMagick-6/policy.xml

USER $NB_UID

RUN pip install \
    https://download.pytorch.org/whl/cpu/torch-1.1.0-cp37-cp37m-linux_x86_64.whl \
    "fonduer==0.7.0" \
    matplotlib \
    ipywidgets

RUN python -m spacy download en

# Copy notebooks and download data
COPY --chown=jovyan:users hardware hardware
RUN cd hardware && /bin/bash download_data.sh
COPY --chown=jovyan:users hardware_image hardware_image
RUN cd hardware_image && /bin/bash download_data.sh
COPY --chown=jovyan:users intro intro
RUN cd intro && /bin/bash download_data.sh
COPY --chown=jovyan:users wiki wiki
RUN cd wiki && /bin/bash download_data.sh

# Specify the hostname of postgres b/c it's not local
RUN sed -i -e 's/localhost/postgres/g' */*.ipynb
RUN sed -i -e 's/dropdb/dropdb -h postgres/g' */*.ipynb
RUN sed -i -e 's/createdb/createdb -h postgres/g' */*.ipynb
RUN sed -i -e 's/psql/psql -h postgres/g' */*.ipynb
