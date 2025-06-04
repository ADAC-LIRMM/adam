#include <stdint.h>

#define PERIPH 0x00090000

typedef struct {
    uint32_t a;
    uint32_t b;
} req_t;

typedef struct {
    uint32_t c;
    uint32_t d;
    uint32_t e;
} rsp_t;

rsp_t hawkeye(req_t req) {
    rsp_t rsp;
    rsp.c = 0;
    rsp.d = 1;
    rsp.e = req.b;
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
    while(1);
}
