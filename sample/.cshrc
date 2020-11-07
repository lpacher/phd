#
# sample ~/.cshrc for sh/tcsh Linux shells
#
echo -e "\nLoading $HOME/.cshrc\n"


# variable to locate the main Xilinx Vivado installation directory e.g. /opt/Xilinx
setenv  XILINX_DIR /opt/Xilinx


# add Vivado executables to system search path
source $XILINX_DIR/Vivado/<version>/settings64.sh


# add here additional user customizations
