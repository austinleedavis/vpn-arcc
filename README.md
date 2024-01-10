# Installation
This package contains two scripts to start a Jupyter Notebook (JN) server:
1. **vpn.sh**: Script to connect to the UCF vpn.
1. **startJupyterServer.sh**: Script to start a Jupyter Labs server.

Add the following [bookmarklet](https://en.wikipedia.org/wiki/Bookmarklet) to your browser's favorites bar (or run the code in your [browser console](https://www.codecademy.com/article/running-javascript-in-the-browser-console)):
```js
javascript:(function() {  
    var cookieMatch = document.cookie.match(/webvpn=(.*?);/);  
    if (cookieMatch && cookieMatch[1]) {    
        navigator.clipboard.writeText(cookieMatch[1]);    
        alert(cookieMatch[1]);  
    } else {    
        alert(%27No matching cookie found%27);  
    }})();
```

# Usage

To get started, simply run `vpn.sh` as root and follow the on-screen instructions. 
Then (in a seperate shell) run `startJupyterServer.sh` and follow the on-screen instructions. 
Both scripts provide CLI options using the `--help` argument.

```sh
Usage: ./vpn.sh [option...]

   --kill      Kill the VPN connection
   --help      Display this help message
   --salloc    Specify a custom file for salloc_command
   --server    Server to perform operations on. Default: 'newton'
   --bookmark  Display the bookmarklet code and copy it to clipboard using xclip
Note: This script requires root privileges.


Usage: ./startJupyterServer.sh [option...]

   --help     Display this help message
   --server   Specify the server name. Options are:
              newton - Sets the server to newton.ist.ucf.edu
              stokes - Sets the server to stokes.ist.ucf.edu
              If not specified, defaults to newton.ist.ucf.edu

```

## Running the Jupyter Server

1. Login to https://secure.vpn.ucf.edu/ 
1. Use the bookmarklet from above to get your cookie. It should be automatically copied to your clipboard.
1. Connect to the UCF VPN by running: `sudo ./vpn.sh`
1. When prompted paste in your cookie from step 2 above.
1. Follow the on-screen instructions to ...
   1. ssh to either newton or stokes (default: newton)
   2. Run the `salloc` command copied to your clipboard to start an interactive session on the compute cluster
1. Open a new terminal (keep the other one open -- it's interactive!)
1. Run `./startJupyterServer.sh`. This starts the Jupyter lab server.

You can now access Jupyter Lab at the URL displayed at the end of the `./startJupyterServer.sh` script (look for `http://localhost:PORT/lab?token=...`, but your PORT will be different). 

## Custom Anaconda Environments
Once a conda environment is installed as a Jupyter kernel, it's accessible in future Jupyter sessions without needing to specify it during startup. This feature facilitates seamless switching between different environments.

To use your own conda environment from within a Jupyter notebook, first install the `ipykernel` library. Since package installation typically requires multiple threads (which restricts your ability to do so on the user side of the cluster), you should do this from the compute side of the cluster as follows:
1. Connect to the user side of the cluster with either `ssh newton.ist.ucf.edu` or `ssh stokes.ist.ucf.edu`
2. Start an interactive session on a compute node with `srun --time=0:30:00 /bin/bash`
3. Create or activate the conda environment with `conda activate $ENV_NAME`
4. Run `conda install -c anaconda ipykernel pylint` to manage kernels and ensure linting works correctly
6. Install any other packages/dependencies you need
7. Add your conda environment to the jupyter server kernels list with:
    ```sh
    python -m ipykernel install --user --name "$ENV_NAME" --display-name "Python ($ENV_NAME)"
    ```
8. Close the connection on the compute side with `exit`.

The conda environment is now installed as a Jupyter _kernel_. You can access it in the browser or in VS Code (see below).

## VS Code integration
You can use the compute cluster to run your Jupyter Notebook directly within VS Code. Follow these steps:
1. Open VS code
1. Open any ipynb file
1. From the command palette (Ctrl+Shift+P), select `Notebook: Select Notebook Kernel` > `Existing Jupyter Server` > Paste the localhost url (look for `http://localhost:PORT/lab?token=...` from the output of `./startJupyterServer.sh`. Your PORT will be different)

**Notes**:
- By default, your token (also called password in VS Code) is your newton username. Just type `whoami` while connected to newton. You can change this by modifying the script.
- Adding a kernel for the first time can take a few moments (~30s); monitor the status from the `startJupterServer.sh` terminal. If it seems to be taking too long or you see a 403 Forbidden error, just click `Interrupt` and try adding the kernel again

# Acknowledgement
Thanks to Dr. R. Paul Wiegand who wrote the original scripts (available in the `archive` folder). Special thanks to Sonny Bhatia who wrote `vpn.sh`, the original bookmarklet, and pivoted the original scripts to their interactive versions. 
