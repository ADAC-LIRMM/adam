#include <stdint.h>
#include <stdio.h>

#include "system.h"

static inline void csr_write(uint32_t csr, uint32_t value) {
    asm volatile (
        "csrrw x0, %0, %1"
        :
        : "i"(csr), "r"(value)
    );
}

static inline void mvin(void *rs1, uint32_t rs2, uint32_t cfg)
{
    asm volatile (
        ".insn r CUSTOM_0, 0, %c[imm], x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2), [imm] "i" (((0 & 0x3) << 5) | 0)
    );
}

static inline void mvout(void *rs1, uint32_t rs2, uint32_t cfg)
{
    asm volatile (
        ".insn r CUSTOM_0, 0, %c[imm], x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2), [imm] "i" (((0 & 0x3) << 5) | 1)
    );
}

static inline void fence(uint32_t cfg)
{
    asm volatile (
        ".insn r CUSTOM_0, 0, %c[imm], x0, x0, x0"
        :
        : [imm] "i" (((cfg & 0x3) << 5) | 1)
    );
}

static inline void matmul_preload(uint32_t rs1, uint32_t rs2, uint32_t cfg)
{
    asm volatile (
        ".insn r CUSTOM_0, 1, %c[imm], x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2), [imm] "i" (((0 & 0x3) << 5) | 0)
    );
}

static inline void matmul_compute(
    uint32_t rs1,
    uint32_t rs2,
    uint32_t end,
    uint32_t cfg
)
{
    uint32_t funct7 = (((0 & 0x3) << 5) | (((1 & 0x1) << 2) | 1));
    asm volatile (
        ".insn r CUSTOM_0, 1, %c[imm], x0, %0, %1"
        :
        : "r"(rs1), "r"(rs2), [imm] "i"((((0 & 0x3) << 5) | (((1 & 0x1) << 2) | 1)))
    );
}

static inline void matmul(
    uint32_t mat_a,
    uint32_t mat_b,
    uint32_t mat_c,
    uint32_t mat_r,
    uint32_t cfg
)
{
    matmul_preload(mat_c, mat_r, cfg);
    matmul_compute(mat_a, mat_b, 1, cfg);
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

  mvin(mat_a, spad_a, 0);
  mvin(mat_b, spad_b, 0);
  mvin(mat_c, spad_c, 0);
  matmul(spad_a, spad_b, spad_c, spad_r, 0);

  for(volatile int i = 0; i < 100; i++);

  mvout(mat_r, spad_r, 0);
}
