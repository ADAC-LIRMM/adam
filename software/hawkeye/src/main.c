#include <stdint.h>

#define PERIPH 0x00090000

typedef struct {
    uint64_t paddr;
    uint32_t set;
    uint64_t pc;
    uint8_t way;
    uint8_t hit : 1;
    uint8_t init : 1;
    uint32_t _reserved : 22;
} req_t;

typedef struct {
    uint8_t victimWay;
    uint32_t _reserved : 24;
} rsp_t;

rsp_t hawkeye(req_t req) {
    rsp_t rsp = {0};
    rsp.victimWay = req.paddr;
    return rsp;
}

int main()
{
    req_t req;
    rsp_t rsp;
    while(1) {
      req = *((req_t *) PERIPH);
      rsp = hawkeye(req);
      *((rsp_t *) PERIPH) = rsp;
    }
}
