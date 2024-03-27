This repo is forked from **[asc seurat]**(https://github.com/KirstLab/asc_seurat). Following changes were made to the Docker and code:

1. Debian repositories were changed from "unstable/testing" to "bookworm"
2. DESeq2 is added as statistical method
3. Seurat package scripts are changed as outlined in https://github.com/satijalab/seurat/issues/6789 and repackaged
4. UMAP and tSNE are drawn in plotly
5. Docker is installed directly from debian repos, instead of ubuntu focal docker repos
6. For installing debian packages, install2.r (from littler) is used.
