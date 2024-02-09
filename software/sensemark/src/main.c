#include "sensemark.h"

volatile ee_s32 seed1_volatile = 0x3415; //0;
volatile ee_s32 seed2_volatile = 0x3415; //0;
volatile ee_s32 seed3_volatile = 0x66; //0;
volatile ee_s32 seed4_volatile = 0;
volatile ee_s32 seed5_volatile = 0;

static ee_u8 cm_memblock[TOTAL_DATA_SIZE];
static core_results cm_res;

static void hw_init(void);
static void cm_init(void);
static void cm_run(void);

int main()
{
    // volatile int init_guard = 1;
    // while(init_guard); // Change its value in debug!

    hw_init();

    // Resume LPCPU
    // RAL.SYSCFG->LPCPU.MR = 1;
    // while(RAL.SYSCFG->LPCPU.MR);

    ee_printf("IM ALIVE [CPU]\r\n");

    float f = 3.15;

    ee_printf("floa = %f\r\n", f);

    cm_init();

    while (1) {
        //sleep();
        //RAL.SYSCFG->CPU[0].MR = 2;
        //while(RAL.SYSCFG->CPU[0].MR);

        ee_printf("CM_RUN\r\n");       
        cm_run();
    }

    return 0;
}

int main_lpu()
{
    int i, j;

    ee_printf("IM ALIVE [LPU]\r\n");

    i = 0;
    j = 0;

    while(1) { 
        ee_printf("test\r\n");       
        //asm volatile("wfi");

        while(!RAL.LSPA.SPI[0]->TBE);
        RAL.LSPA.SPI[0]->DR = 0xAB;  

        i++;

        if (i >= 44100) {
            i = 0;

            char *str = " \r\n";
            str[0] = '0' + j++ % 10;
            ee_printf(str);

            RAL.SYSCFG->CPU[0].MR = 1;
            while(RAL.SYSCFG->CPU[0].MR);
        }
    }

    //ee_printf("END [LPU]\n");

    return 0;
}

void hw_init(void)
{
    // // Stop LPCPU
    // RAL.SYSCFG->LPCPU.MR = 3;
    // while(RAL.SYSCFG->LPCPU.MR);

    // Resume LPMEM
    RAL.SYSCFG->LPMEM.MR = 1;
    while(RAL.SYSCFG->LPMEM.MR);

    // Resume MEMs
    for (int i = 0; i < 3; i++) {
        RAL.SYSCFG->MEM[i].MR = 1;
        while(RAL.SYSCFG->MEM[i].MR);
    }

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
    RAL.LSPA.UART[0]->BRR = 5208; // 9600 @ 50MHz 
    RAL.LSPA.UART[0]->CR  = 0x807; // No parity, 1 stop, 8 data

    // Set up UART1
    RAL.LSPA.UART[1]->BRR = 5208; // 9600 @ 50MHz 
    RAL.LSPA.UART[1]->CR  = 0x807; // No parity, 1 stop, 8 data

    // Set up SPI0
    RAL.LSPA.SPI[0]->TE   = 1;
    RAL.LSPA.SPI[0]->RE   = 0;
    RAL.LSPA.SPI[0]->MS   = 1;
    RAL.LSPA.SPI[0]->CPHA = 0;
    RAL.LSPA.SPI[0]->CPOL = 0;
    RAL.LSPA.SPI[0]->DO   = 0;
    RAL.LSPA.SPI[0]->DL   = 8;
    RAL.LSPA.SPI[0]->BRR  = 50; // 1MHz @ 50 MHz
    RAL.LSPA.SPI[0]->PE   = 1;

    // Set up TIMER0
    RAL.LSPA.TIMER[0]->PR  = 0; // 50MHz @ 50MHz
    RAL.LSPA.TIMER[0]->VR  = 0;
    RAL.LSPA.TIMER[0]->ARR = 1134; // 44100 Hz
    RAL.LSPA.TIMER[0]->ER  = ~0;
    RAL.LSPA.TIMER[0]->IER = ~0;
    RAL.LSPA.TIMER[0]->PE  = 1;

    // Enable all interrupts for LPCPU
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

void __attribute__((interrupt)) default_handler(void)
{
    RAL.LSPA.TIMER[0]->ER = ~0;
}
