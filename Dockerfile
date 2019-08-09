FROM hiromuhota/fonduer
LABEL maintainer="Hiromu Hota <hiromu.hota@hal.hitachi.com>"

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ghostscript \
    curl \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/

# https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#docker-cmd
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]

USER user
RUN pip install --upgrade pip \
 && pip install \
    matplotlib \
    ipywidgets \
    jupyter \
 && python -m spacy download en

# Copy notebooks and download data
COPY --chown=user:user hardware hardware
RUN cd hardware && /bin/bash download_data.sh
COPY --chown=user:user hardware_image hardware_image
RUN cd hardware_image && /bin/bash download_data.sh
COPY --chown=user:user intro intro
RUN cd intro && /bin/bash download_data.sh
COPY --chown=user:user wiki wiki
RUN cd wiki && /bin/bash download_data.sh

# Specify the hostname of postgres b/c it's not local
RUN sed -i -e 's/localhost/postgres/g' */*.ipynb
RUN sed -i -e 's/dropdb/dropdb -h postgres/g' */*.ipynb
RUN sed -i -e 's/createdb/createdb -h postgres/g' */*.ipynb
RUN sed -i -e 's/psql/psql -h postgres/g' */*.ipynb
