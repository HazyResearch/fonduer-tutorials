# To avoid HazyResearch/metal#101, pin tag of the base image to have python 3.6.X
FROM jupyter/minimal-notebook:9e8682c9ea54
LABEL maintainer="Hiromu Hota <hiromu.hota@hal.hitachi.com>"
USER root

RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libxslt-dev \
    python-matplotlib \
    poppler-utils \
    postgresql-client \
    libmagickwand-dev \
    ghostscript \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN rm /etc/ImageMagick-6/policy.xml

RUN pip install torch==0.4.1
RUN pip install \
    fonduer==0.4.0 \
    matplotlib

RUN python -m spacy download en
RUN conda install -y -c conda-forge ipywidgets

USER $NB_UID

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
