--------------------------------------------------------------------------------------
**Author:**        R. Paul Wiegand  
**Date Created:**  2018-11-26  
**Modified By:**   Austin Davis, 2023-11-24  
--------------------------------------------------------------------------------------

# Installation
This package contains three scripts to start a Jupyter Notebook (JN) server:
1. **startJupyterNotebooks.sh**: Script to start Jupyter Notebooks.
1. **stopJupyterNotebooks.sh**: Script to stop running Jupyter Notebooks.
1. **submit-jupyter-notebook-server.slurm**: SLURM script for resource allocation.

# Usage

**Starting Jupyter Notebooks:**
Log into the user node of your cluster and execute:
```sh
./startJupyterNotebooks.sh
```
This command submits a SLURM batch job to initialize JN, providing a connection via a web browser. *(See below for option to specify conda environment)*

> **NOTE!** *Default Resources:* The start script requests 1 core, 1 node, and 8GB of memory for two hours. Modify `jupyter-notebooks.slurm` for different resource allocations.

**Stopping Jupyter Notebooks:**
When finished, terminate JN using:
```sh
./stopJupyterNotebooks.sh
```


## Arguments

The `startJupyterNotebooks.sh` script optionally accepts an environment specification for JN.

- **Environment File**: Specify a conda environment with an `environment.yml` file:
  ```sh
  ./startJupyterNotebooks.sh /path/to/environment.yml
  ```
  If the environment doesn't exist, it's created and set up as a Jupyter kernel, accessible in future sessions.

- **Existing Environment Name**: Use an existing conda environment:
  ```sh
  ./startJupyterNotebooks.sh existing_env_name
  ```
  This environment, once used, is available as a Jupyter kernel for future sessions.

- **Default Behavior**: Without arguments, the script uses the base conda environment:
  ```sh
  ./startJupyterNotebooks.sh
  ```

### Environment Persistence

Once a conda environment is installed as a Jupyter kernel, it's accessible in future Jupyter sessions without needing to specify it during startup. This feature facilitates seamless switching between different environments.
