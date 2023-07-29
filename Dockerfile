# Ubuntu latest
FROM kirstlab/asc_seurat:dynverse_v2.2

# Owner
LABEL Wendell Jacinto Pereira <wendelljpereira@gmail.com>
SHELL ["/bin/bash", "-c"]

# Set workdir
WORKDIR /app
COPY www /app/www
COPY R /app/R

# Get server files
COPY global.R /app/global.R
COPY server.R /app/server.R
COPY ui.R /app/ui.R
COPY /scripts/bscripts/init_app.sh /app/init_app.sh

## Remove all unstable and testing entries
RUN sed -i 's/testing/bookworm/' /etc/apt/apt.conf.d/default
RUN rm -rf /etc/apt/sources.list.d/debian-unstable.list
RUN sed -i 's/testing/bookworm/' /etc/apt/sources.list

RUN apt-get update --allow-releaseinfo-change && apt-get upgrade -y && apt-get clean
RUN apt-get remove -y binutils && apt-get clean
RUN apt-get update --allow-releaseinfo-change
RUN apt-get install -y binutils xml2 libxml2-dev libssl-dev libcurl4-openssl-dev unixodbc-dev libhdf5-dev libcairo2-dev libxt-dev libfontconfig1-dev build-essential libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libgsl-dev libfftw3-dev libv8-dev gdal-bin libgdal-dev
RUN apt-get update && apt-get clean

# Install CRAN packages
## set cores assuming that users are using a computer with 4 cores minimum
RUN echo 'options(Ncpus = 4)' >> ~/.Rprofile

# littler
RUN R -e 'install.packages("littler", dep = T)'
RUN R -e 'library(littler)'
RUN apt-get install -y gfortran

## RUN install2.r
RUN install2.r -e -n 4 BiocManager tidyverse Seurat SeuratObject patchwork patchwork vroom plotly svglite circlize reactable shinyWidgets shinyFeedback shinycssloaders rclipboard future ggthemes

# # install multiple packages
RUN R -e 'BiocManager::install(c("multtest", "ComplexHeatmap", "tradeSeq", "SingleCellExperiment", "slingshot", "biomaRt","topGO", "glmGamPoi", "DESeq2"))'

# ## Load installed packages
RUN  Rscript -e 'lapply(list("multtest", "ComplexHeatmap", "tradeSeq", "SingleCellExperiment", "slingshot", "biomaRt","topGO", "glmGamPoi","DESeq2"), require, character.only = TRUE)'

# ## RUN install2.r for few more packages
RUN install2.r -e -n 4 DT hdf5r metap 

## Copy edited Seurat
COPY  Seurat.tar.gz /app/
RUN install2.r -e -n 4 /app/Seurat.tar.gz

#Configuring Docker
RUN usermod -aG docker root

# expose port
EXPOSE 3838

# # Fix permissions
RUN chmod a+rwx -R /app/*
RUN chmod a+rwx -R /app

# # Init image
CMD ./init_app.sh
