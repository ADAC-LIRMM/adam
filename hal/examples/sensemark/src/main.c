#include "coremark.h"
#include "sensemark.h"

volatile ee_s32 seed1_volatile = 0;
volatile ee_s32 seed2_volatile = 0;
volatile ee_s32 seed3_volatile = 0;
volatile ee_s32 seed4_volatile = 0;
volatile ee_s32 seed5_volatile = 0;

int main();
int main_lpu();

static ee_u8 cm_memblock[TOTAL_DATA_SIZE];
static core_results cm_res;

static void hw_init(void);
static void cm_init(void);
static void cm_run(void);
static void mem_log(uint32_t n);

int main()
{
    mem_log(MAIN_START);
    hw_init();

    ee_printf("IM ALIVE [CPU]\n");

    mem_log(CM_INIT_START);
    ee_printf("CM_INIT\n");
    cm_init();
    mem_log(CM_INIT_END);

    // Resume LPU0
    RAL.SYSCFG->LPCPU.MR = 1;
    while(RAL.SYSCFG->LPCPU.MR);
    mem_log(RESUME_LPU);

    while (1) {
        mem_log(SLEEP_START);
        sleep();
        mem_log(SLEEP_END);
        
        mem_log(CM_RUN_START);
        ee_printf("CM_RUN\n");
        cm_run();
        mem_log(CM_RUN_END);
    }

    ee_printf("END [CPU]\n");

    mem_log(MAIN_END);
    return 0;
}

int main_lpu()
{
    int counter;

    mem_log(MAIN_LPU_START);

    ee_printf("IM ALIVE [LPU]\n");

    counter = 0;

    while(1) {
        mem_log(WFI_START);
        asm volatile("wfi");
        mem_log(WFI_END);

        while(!RAL.LSPA_SPI[0]->TBE);
        RAL.LSPA_SPI[0]->DR = 0xAB;  

        counter++;

        if (counter >= 44100) {
            counter = 0;
            while(!RAL.SYSCFG->CPU[0].MR);
            RAL.SYSCFG->CPU[0].MR = 1;
            while(RAL.SYSCFG->CPU[0].MR);
            mem_log(RESUME_CPU);
        }
    }

    ee_printf("END [LPU]\n");

    mem_log(MAIN_LPU_END);
    return 0;
}

volatile int is_hw_init = 0;

void hw_init(void)
{
    if (is_hw_init) return;
    is_hw_init = 1;

    // Resume UART0
    RAL.SYSCFG->LSPA.UART[0].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[0].MR);

    // Resume UART1
    RAL.SYSCFG->LSPA.UART[1].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[1].MR);

    // Resume SPI0
    RAL.SYSCFG->LSPA.SPI[0].MR = 1;
    while(RAL.SYSCFG->LSPA.UART[0].MR);

    // Resume TIMER0
    RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
    while(RAL.SYSCFG->LSPA.TIMER[0].MR);

    // Set up UART0
    RAL.LSPA_UART[0]->BRR = 5208; // 9600 @ 50MHz 
    RAL.LSPA_UART[0]->CR  = 0x807; // No parity, 1 stop, 8 data

    // Set up UART1
    RAL.LSPA_UART[1]->BRR = 5208; // 9600 @ 50MHz 
    RAL.LSPA_UART[1]->CR  = 0x807; // No parity, 1 stop, 8 data

    // Set up SPI0
    RAL.LSPA_SPI[0]->TE   = 1;
    RAL.LSPA_SPI[0]->RE   = 0;
    RAL.LSPA_SPI[0]->MS   = 1;
    RAL.LSPA_SPI[0]->CPHA = 0;
    RAL.LSPA_SPI[0]->CPOL = 0;
    RAL.LSPA_SPI[0]->DO   = 0;
    RAL.LSPA_SPI[0]->DL   = 8;
    RAL.LSPA_SPI[0]->BRR  = 50; // 1MHz @ 50 MHz
    RAL.LSPA_SPI[0]->PE   = 1;

    // Set up TIMER0
    RAL.LSPA_TIMER[0]->PR  = 0; // 50MHz @ 50MHz
    RAL.LSPA_TIMER[0]->VR  = 0;
    RAL.LSPA_TIMER[0]->ARR = 1134; // 44100 Hz
    RAL.LSPA_TIMER[0]->ER  = ~0;
    RAL.LSPA_TIMER[0]->IER = ~0;
    RAL.LSPA_TIMER[0]->PE  = 1;

    // Enable all interrupts for LPU
    RAL.SYSCFG->LPCPU.IER = ~0;
}

void cm_init(void)
{   
    ee_u32 i;
    ee_s32 matrix_seed;

    cm_res.seed1 = seed1_volatile;
	cm_res.seed2 = seed2_volatile;
	cm_res.seed3 = seed3_volatile;

    cm_res.memblock[0] = (void *) cm_memblock;
	cm_res.size = TOTAL_DATA_SIZE / NUM_ALGORITHMS;
	cm_res.err = 0;

	for (i = 0; i < NUM_ALGORITHMS; i++) {
		cm_res.memblock[i+1] = (void *) (cm_memblock + cm_res.size*i);
	}

    cm_res.list = core_list_init(cm_res.size, cm_res.memblock[1], 
        cm_res.seed1);

    matrix_seed = cm_res.seed1 | (((ee_s32) cm_res.seed2) << 16);

    core_init_matrix(cm_res.size, cm_res.memblock[2], matrix_seed,
        &(cm_res.mat));

    core_init_state(cm_res.size, cm_res.seed1, cm_res.memblock[3]);
}   

void cm_run(void)
{
    ee_u32 i;
	ee_u16 crc;

	cm_res.iterations = 1;
	cm_res.crc = 0;
	cm_res.crclist = 0;
	cm_res.crcmatrix = 0;
	cm_res.crcstate = 0;

    for (i = 0; i < cm_res.iterations; i++) {
	    crc = core_bench_list(&cm_res, 1);
		cm_res.crc = crcu16(crc, cm_res.crc);
		crc = core_bench_list(&cm_res, -1);
		cm_res.crc = crcu16(crc, cm_res.crc);
		if (i == 0) cm_res.crclist = cm_res.crc;
	}
}

void mem_log(uint32_t n) {
    uint32_t result;
    uint32_t address = 0x10000000 + 16*n;

    // asm volatile(
    //     "lw %0, 0(%1)"
    //     : "=r"(result)
    //     : "r"(address)
    //     : "memory"
    // );
}

void __attribute__((interrupt)) default_handler(void) {
    RAL.LSPA_TIMER[0]->ER = ~0;
}