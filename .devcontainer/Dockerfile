# Use the official Python image from the Docker Hub
FROM continuumio/anaconda3 as upstream

# verify expected
RUN . /etc/os-release \
    && echo "OS: $NAME $VERSION" \
    && echo "Python: $(python --version)" \
    && echo "Pip: $(pip --version)" \
    && echo "Conda: $(conda --version)"

# Set the working directory in the container
WORKDIR /workspace

# Install Jupyter Notebook
RUN conda install -y notebook

# Expose the port Jupyter Notebook runs on
EXPOSE 8888

# Run Jupyter Notebook
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
CMD ["bash"]