#ifndef SENSEMARK_H
#define SENSEMARK_H

#define MAIN_START     (0x00)
#define MAIN_END       (0x01)
#define CM_INIT_START  (0x02)
#define CM_INIT_END    (0x03)
#define RESUME_LPU     (0x04)
#define SLEEP_START    (0x05)
#define SLEEP_END      (0x06)
#define CM_RUN_START   (0x07)
#define CM_RUN_END     (0x08)
#define MAIN_LPU_START (0x09)
#define MAIN_LPU_END   (0x0A)
#define WFI_START      (0x0B)
#define WFI_END        (0x0C)
#define RESUME_CPU     (0x0D)

extern void sleep(void);

static inline uint32_t get_mhartid() {
    uint32_t hartid;
    asm volatile ("csrr %0, mhartid" : "=r"(hartid));
    return hartid;
}

#endif