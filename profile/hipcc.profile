printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" >&2
printf "@ Do not forget to increase the GCD's reserved memory in  @\n" >&2
printf "@ memory.param by setting                                 @\n" >&2
printf "@   constexpr size_t reservedGpuMemorySize =              @\n" >&2
printf "@       uint64_t(2147483648); // 2 GiB                    @\n" >&2
printf "@ Further, set the initial buffer size in your ADIOS2     @\n" >&2
printf "@ configuration of your job's *.cfg file to 28GiB,        @\n" >&2
printf "@ and do not use more than this amount of memory per GCD  @\n" >&2
printf "@ in your setup, or you will see out-of-memory errors.    @\n" >&2
printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" >&2

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
#   - project for allocation and shared directories
export PROJID=csc380

# Text Editor for Tools ###################################### (edit this line)
#   - examples: "nano", "vim", "emacs -nw", "vi" or without terminal: "gedit"
#export EDITOR="vim"

# General modules #############################################################
#
# There are a lot of required modules already loaded when connecting
# such as mpi, libfabric and others.
# The following modules just add to these.
module load PrgEnv-cray/8.2.0 # Compiling with cray compiler wrapper CC

module load craype-accel-amd-gfx90a
module load rocm/5.1.0

export MPICH_GPU_SUPPORT_ENABLED=1
module load cray-mpich/8.1.21

module load cmake/3.21.3
module load zlib/1.2.11

module load boost/1.79.0-cxx17

module load git/2.31.1
module load cray-python/3.9.12.1

## set environment variables required for compiling and linking w/ hipcc
##   see (https://docs.olcf.ornl.gov/systems/crusher_quick_start_guide.html#compiling-with-hipcc)
export CXX=hipcc
export CXXFLAGS="$CXXFLAGS -I${MPICH_DIR}/include"
export LDFLAGS="$LDFLAGS -L${MPICH_DIR}/lib -lmpi -L${CRAY_MPICH_ROOTDIR}/gtl/lib -lmpi_gtl_hsa"
export CFLAGS="$CXXFLAGS -I${MPICH_DIR}/include"
export PIC_BACKEND="hip:gfx90a"

# Other Software ##############################################################
#
module load zlib/1.2.11
module load git/2.35.1
module load libpng/1.6.37 freetype/2.11.0

# "tbg" default options #######################################################
#   - SLURM (sbatch)
#   - "caar" queue
export TBG_SUBMIT="sbatch"
