#
# sample ~/.bashrc login script for Bash Linux shell
#
echo -e "\nLoading $HOME/.bashrc\n"


# variable to locate the main Xilinx Vivado installation directory, e.g. /opt/Xilinx
export XILINX_DIR=/opt/Xilinx


# add Vivado executables to system search path
source $XILINX_DIR/Vivado/<version>/settings64.sh

# add here additional user customizations
