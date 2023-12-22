`ifndef SYNTHESIS 
    `timescale 1ns/1ps
`endif

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

        int NO_LSPA_GPIOS;
        int NO_LSPA_SPIS;
        int NO_LSPA_TIMERS;
        int NO_LSPA_UARTS;

        int NO_LSPB_GPIOS;
        int NO_LSPB_SPIS;
        int NO_LSPB_TIMERS;
        int NO_LSPB_UARTS;

        int EN_BOOTSTRAP_CPU0;
        int EN_BOOTSTRAP_MEM0;
        int EN_BOOTSTRAP_LPCPU;
        int EN_BOOTSTRAP_LPMEM;
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
        
        NO_LSPA_GPIOS  : 1,
        NO_LSPA_SPIS   : 1,
        NO_LSPA_TIMERS : 1,
        NO_LSPA_UARTS  : 1,

        NO_LSPB_GPIOS  : 1,
        NO_LSPB_SPIS   : 1,
        NO_LSPB_TIMERS : 1,
        NO_LSPB_UARTS  : 1,

        EN_BOOTSTRAP_CPU0  : 1,
        EN_BOOTSTRAP_MEM0  : 1,
        EN_BOOTSTRAP_LPCPU : 0,
        EN_BOOTSTRAP_LPMEM : 0
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