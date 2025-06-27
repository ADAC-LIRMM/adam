#include <stdint.h>
#include <stdio.h>

#include "system.h"

#define CSR_WRITE(CSR, VALUE) \
    asm volatile ("csrrw x0, " #CSR ", %0" :: "r"(VALUE))

#define MVIN(RS1, RS2, CFG) \
    asm volatile ( \
        ".insn r CUSTOM_0, 0, %c0, x0, %1, %2" :: \
        "i"(((CFG) & 0x3) << 5), "r"(RS1), "r"(RS2))

#define MVOUT(RS1, RS2, CFG) \
    asm volatile ( \
        ".insn r CUSTOM_0, 0, %c0, x0, %1, %2" :: \
        "i"((((CFG) & 0x3) << 5) | 1), "r"(RS1), "r"(RS2))

#define FENCE(CFG) \
    asm volatile ( \
        ".insn r CUSTOM_0, 0, %c0, x0, x0, x0" :: \
        "i"((((CFG) & 0x3) << 5) | 1))

#define MATMUL_PRELOAD(RS1, RS2, CFG) \
    asm volatile ( \
        ".insn r CUSTOM_0, 1, %c0, x0, %1, %2" :: \
        "i"(((CFG) & 0x3) << 5), "r"(RS1), "r"(RS2))

#define MATMUL_COMPUTE(RS1, RS2, END, CFG) \
    asm volatile ( \
        ".insn r CUSTOM_0, 1, %c0, x0, %1, %2" :: \
        "i"(((((CFG) & 0x3) << 5) | (((END) & 0x1) << 2) | 1)), \
        "r"(RS1), "r"(RS2))

#define MATMUL(MAT_A, MAT_B, MAT_C, MAT_R, CFG) \
    do { \
        MATMUL_PRELOAD(MAT_C, MAT_R, CFG); \
        MATMUL_COMPUTE(MAT_A, MAT_B, 1, CFG); \
    } while (0)

static void print_matrix(uint8_t mat[4][4]) {
    printf("{\n");
    for (int i = 0; i < 4; i++) {
        printf("    {");
        for (int j = 0; j < 4; j++) {
            printf("%u", mat[i][j]);
            if (j < 3) {
                printf(", ");
            }
        }
        printf("}");
        if (i < 3) {
            printf(",\n");
        } else {
            printf("\n");
        }
    }
    printf("}\n");
}

static void hw_init(void) {
  // Resume LPMEM
  RAL.SYSCFG->LPMEM.MR = 1;
  while (RAL.SYSCFG->LPMEM.MR);

  // Resume MEMs
  for (int i = 0; i < 3; i++) {
    RAL.SYSCFG->MEM[i].MR = 1;
    while (RAL.SYSCFG->MEM[i].MR);
  }

  // Resume UART0
  RAL.SYSCFG->LSPA.UART[0].MR = 1;
  while (RAL.SYSCFG->LSPA.UART[0].MR);

  // Resume TIMER0
  RAL.SYSCFG->LSPA.TIMER[0].MR = 1;
  while (RAL.SYSCFG->LSPA.TIMER[0].MR);

  // Resume GPIO0
  RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
  while (RAL.SYSCFG->LSPA.GPIO[0].MR);

  // Resume SPI
  RAL.SYSCFG->LSPA.SPI[0].MR = 1;
  while (RAL.SYSCFG->LSPA.SPI[0].MR);

  // Enable CPU Interrupt
  RAL.SYSCFG->CPU[0].IER = ~0;
}

uint8_t mat_a[4][4] = {
    {1, 9, 7, 6},
    {3, 2, 1, 8},
    {4, 7, 9, 5},
    {6, 5, 2, 3}
};

uint8_t mat_b[4][4] = {
    {2, 5, 8, 1},
    {7, 3, 6, 9},
    {4, 2, 1, 7},
    {9, 3, 5, 8}
};

uint8_t mat_c[4][4] = {
    {4, 8, 3, 1},
    {7, 6, 2, 2},
    {5, 9, 1, 3},
    {6, 4, 8, 7}
};

uint8_t mat_r[4][4] = {
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0}
};

uint32_t spad_a = 0x00;
uint32_t spad_b = 0x08;
uint32_t spad_c = 0x10;
uint32_t spad_r = 0x18;

int main() {
    hw_init();
    uart_init(RAL.LSPA.UART[0], SYSTEM_CLOCK/2);

    CSR_WRITE(0x800, 0);
    CSR_WRITE(0x801, 4);
    CSR_WRITE(0x802, 4);
    CSR_WRITE(0x803, 4);

    // printf("Hello, World!\n");

    MVIN(mat_a, spad_a, 0);
    MVIN(mat_b, spad_b, 0);
    MVIN(mat_c, spad_c, 0);
    MATMUL(spad_a, spad_b, spad_c, spad_r, 0);

    for(volatile int i = 0; i < 100; i++);

    MVOUT(mat_r, spad_r, 0);

    print_matrix(mat_r);
}

int _write(int file, char* buf, int nbytes) {
    ral_uart_t *uart = RAL.LSPA.UART[0];

    for (int i = 0; i < nbytes; i++) {
        while(!uart->TBE);
        uart->DR = *buf;
        buf++;
    }

  return nbytes;
}

