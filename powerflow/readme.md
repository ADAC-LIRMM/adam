ADD The following PATHs to your bashrc to get access to the different tools : 

```
# User specific aliases and functions
export CMOS28FDSOI_DIR="/tools/DKits/ST/cmos28fdsoi_10a"

export SNPS_SYN_PATH="/prog/Synopsys/2022/syn/T-2022.03-SP4"
export PATH="$SNPS_SYN_PATH/bin:$PATH"

export SNPS_PWR_PATH="/prog/Synopsys/2019/pwr/O-2018.06-SP5"
export SYNOPSYS_LC_ROOT="$SNPS_PWR_PATH"
export PATH="$SNPS_PWR_PATH/bin:$PATH"

export MODELSIM_PATH="/prog/Mentor/2019/ModelSim_SE/modeltech"
#export PATH="$MODELSIM_PATH/bin:$PATH"

export QUESTA_PATH="/prog/Mentor/2024/questasim"
export PATH="/prog/Mentor/2024/questasim/linux_x86_64:$PATH"

export LM_LICENSE_FILE="5280@mentor.cnfm.fr"
export SNPSLMD_LICENSE_FILE="27000@synopsys.cnfm.fr"

export XILINX_PATH=/prog/Vitis_Vivado_2023.2
export PATH=$XILINX_PATH/Vivado/2023.2/bin:$PATH
``` 
Some Errors you may encounter : 
