FROM mambaorg/micromamba:1.5.9

# Create a solid geo/data stack in the base env
RUN micromamba install -y -n base -c conda-forge \
    python=3.11 jupyterlab pandas numpy geopandas matplotlib shapely fiona pyproj tabulate \
  && micromamba clean -a -y

WORKDIR /workspace

# Default command: start Jupyter (no token) on 0.0.0.0:8888
CMD ["bash","-lc","jupyter lab --NotebookApp.token='' --ip=0.0.0.0 --port=8888 --no-browser"]
