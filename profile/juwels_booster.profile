# Name and Path of this Script ############################### (DO NOT change!)
export PIC_PROFILE=$(cd $(dirname $BASH_SOURCE) && pwd)"/"$(basename $BASH_SOURCE)

# User Information ################################# (edit the following lines)
#   - automatically add your name and contact to output file meta data
#   - send me a mail on batch system jobs: NONE, BEGIN, END, FAIL, REQUEUE, ALL,
#     TIME_LIMIT, TIME_LIMIT_90, TIME_LIMIT_80 and/or TIME_LIMIT_50
export MY_MAILNOTIFY="NONE"
export MY_MAIL="someone@example.com"
export MY_NAME="$(whoami) <$MY_MAIL>"

# Project Information ######################################## (edit this line)
#   - project and account for allocation
#   jutil user projects will return a table of project associations.
#   Each row contains: project,unixgroup,PI-uid,project-type,budget-accounts
#   We need the first and last entry.
#   Here: select the last available project.
export proj=$( jutil user projects --noheader | awk '{print $1}' | tail -n 1 )
export account=$(jutil user projects -n | awk '{print $NF}' | tail -n 1)

# Text Editor for Tools ###################################### (edit this line)
#   - examples: "nano", "vim", "emacs -nw", "vi" or without terminal: "gedit"
#export EDITOR="nano"

# Set up environment, including $SCRATCH and $PROJECT
# Handle a case where the budgeting account is not set.
if [ "$account" = "-" ]; then
    jutil env activate --project $proj;
else
    jutil env activate --project $proj --budget $account
fi

# General modules #############################################################
#
module purge
module load Stages/2022
module load GCC/11.2.0
module load CUDA/11.5
module load CMake/3.21.1
module load ParaStationMPI/5.5.0-1
module load mpi-settings/CUDA
module load Python/3.9.6
module load libpng/.1.6.37

module load HDF5/1.12.1
module load Boost/1.78.0

# necessary for evaluations (NumPy, SciPy, Matplotlib, SymPy, Pandas, IPython)
module load SciPy-bundle/2021.10
module load h5py

module load git


# "tbg" default options #######################################################
#   - SLURM (sbatch)
#   - "gpus" queue
export TBG_SUBMIT="sbatch"
export TBG_TPLFILE="etc/picongpu/juwels-jsc/booster.tpl"

# allocate an interactive shell for one hour
#   getNode 2  # allocates 2 interactive nodes (default: 1)
function getNode() {
    if [ -z "$1" ] ; then
        numNodes=1
    else
        numNodes=$1
    fi
    if [ $numNodes -gt 4 ] ; then
        echo "The maximal number of interactive nodes is 4." 1>&2
        return 1
    fi
    echo "Hint: please use 'srun --cpu_bind=sockets <COMMAND>' for launching multiple processes in the interactive mode"
    salloc --time=1:00:00 --nodes=$numNodes --ntasks-per-node=4 --gres=gpu:4 --mem=488G -A $account -p develbooster bash
}

# allocate an interactive shell for one hour
#   getDevice 2  # allocates 2 interactive devices (default: 1)
function getDevice() {
    if [ -z "$1" ] ; then
        numDevices=1
    else
        if [ "$1" -gt 4 ] ; then
            echo "The maximal number of devices per node is 4." 1>&2
            return 1
        else
            numDevices=$1
        fi
    fi
    srun --time=1:00:00 --ntasks-per-node=$(($numDevices)) --gres=gpu:$(($numDevices)) --mem=488G -A $account -p develbooster --pty bash
}

# Load autocompletion for PIConGPU commands
BASH_COMP_FILE=$PICSRC/bin/picongpu-completion.bash
if [ -f $BASH_COMP_FILE ] ; then
    source $BASH_COMP_FILE
else
    echo "bash completion file '$BASH_COMP_FILE' not found." >&2
fi
