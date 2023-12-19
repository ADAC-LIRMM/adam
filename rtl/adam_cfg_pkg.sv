package adam_cfg_pkg;

    typedef struct {
        int ADDR_WIDTH;
        int DATA_WIDTH;
        int GPIO_WIDTH;

        logic [31:0] RST_BOOT_ADDR;

        int NO_CPUS;
        int NO_DMAS;
        int NO_MEMS;

        bit EN_LPCPU;
        bit EN_LPMEM;
        bit EN_DEBUG;

        int NO_LSBP_GPIOS;
        int NO_LSBP_SPIS;
        int NO_LSBP_TIMERS;
        int NO_LSBP_UARTS;

        int NO_LSIP_GPIOS;
        int NO_LSIP_SPIS;
        int NO_LSIP_TIMERS;
        int NO_LSIP_UARTS; 
    } CFG_T;

    localparam CFG_T CFG = '{
        ADDR_WIDTH : 32,
        DATA_WIDTH : 32,
        GPIO_WIDTH : 16,

        RST_BOOT_ADDR : '0,

        NO_CPUS : 1,
        NO_DMAS : 1,
        NO_MEMS : 3,
        
        EN_LPCPU : 1,
        EN_LPMEM : 1,
        EN_DEBUG : 1,
        
        NO_LSBP_GPIOS  : 1,
        NO_LSBP_SPIS   : 1,
        NO_LSBP_TIMERS : 1,
        NO_LSBP_UARTS  : 1,

        NO_LSIP_GPIOS  : 1,
        NO_LSIP_SPIS   : 1,
        NO_LSIP_TIMERS : 1,
        NO_LSIP_UARTS  : 1        
    };

`ifndef SYNTHESIS    

    typedef struct {
        time CLK_PERIOD;
        int  RST_CYCLES;

        time TA;
        time TT;
    } BHV_CFG_T;

    localparam BHV_CFG_T BHV_CFG = '{
        CLK_PERIOD : 20ns,
        RST_CYCLES : 5,

        TA : 2ns,
        TT : 18ns // CLK_PERIOD - TA       
    };

`endif

endpackage