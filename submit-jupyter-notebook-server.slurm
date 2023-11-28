#!/bin/bash
#SBATCH --job-name=JN-%u
#SBATCH --output=jupyter-logs/jupyter-log-%j.out
#SBATCH --error=jupyter-logs/jupyter-log-%J.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16gb
#SBATCH --time=02:00:00
#SBATCH --gres=gpu:1
#SBATCH --constraint=h100

# Print the name of the output/err files at the top of the files
echo "# Output file: jupyter-log-$SLURM_JOB_ID.out"
echo "# Error file: jupyter-log-$SLURM_JOB_ID.err" 1>&2

PORT=$1
ENV_ARG=$2

# If the port is not passed in, then get the user's UID
if [[ $# -lt 1 ]] ; then
  PORT="$UID"
fi

# If the User Token is not set, set it to 'Test'
if [[ ! $USER_TOKEN ]] ; then
  USER_TOKEN="Test"
fi


mkdir $HOME/tmp >> /dev/null  2>&1
export XDG_RUNTIME_DIR=$HOME/tmp


module purge
module load anaconda/anaconda3

# Helpful for Debugging
{
  cat <<EOF
-------------------------------
Job Information:
date: $(date)
hostname: $(hostname)
pwd: $(pwd)
SLURM Nodes:  ${SLURM_NODELIST}
-------------------------------
Arguments:
Port: $PORT
ENV_ARG: "$ENV_ARG"
-------------------------------
Loaded Modules:
$(module list)
EOF
} 1>&2


# Determine if ENV_ARG is a .yml file or an environment name
if [[ $ENV_ARG == *.yml ]]; then
    # .yml file provided, parse for environment name and use the file to set up the environment
    export conda_env_name=$(grep 'name:' $ENV_ARG | cut -d ' ' -f 2)
    export conda_env_dir="/home/$(whoami)/my-envs/$conda_env_name"

    if { conda env list | grep "$conda_env_name"; } >/dev/null 2>&1
    then 
        echo "Environment '$conda_env_name' already exists" 1>&2
    else 
        echo "Creating environment '$conda_env_name' from $ENV_ARG" 1>&2
        conda env create -f $ENV_ARG 2>&1
        if { conda env list | grep "$conda_env_name"; } >/dev/null 2>&1
        then 
            echo "Environment '$conda_env_name' created" 
        else 
            echo "Environment '$conda_env_name' failed to create" 1>&2
            exit 1
        fi
    fi
    use_base_env=false
elif [[ -n $ENV_ARG ]]; then
    # Non-.yml argument provided, treat it as the name of an existing environment
    export conda_env_name=$ENV_ARG
    export conda_env_dir="/home/$(whoami)/my-envs/$conda_env_name"
    use_base_env=false
else
    # No argument or invalid argument, load the base conda environment
    export conda_env_name="base"
    export conda_env_dir="/apps/anaconda/anaconda3"
    use_base_env=true
fi

source activate $conda_env_dir && \

if [[ $use_base_env == false ]]; then
    python -m ipykernel install --user --name "$conda_env_name" --display-name "Python ($conda_env_name)"
fi && \

{
  cat <<EOF
-------------------------------
Target Environment $conda_env_name 
Target Env directory: $conda_env_dir
Python Version: $(python -V)
===============================
EOF
} 1>&2 && \

# Start Jupyter Notebook
jupyter notebook --no-browser --port=$1 --ip='*' --NotebookApp.token=$USER_TOKEN


echo "Slurm script hack at $(date)" 1>&2

mkdir -p jupyter-logs/$SLURM_JOB_ID
mv jupyter-logs/jupyter-log-$SLURM_JOB_ID.err jupyter-logs/$SLURM_JOB_ID/
mv jupyter-logs/jupyter-log-$SLURM_JOB_ID.out jupyter-logs/$SLURM_JOB_ID/