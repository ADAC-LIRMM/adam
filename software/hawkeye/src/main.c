/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdint.h>
#include "hawkeye.h"

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

rsp_t func(req_t req) {
    rsp_t rsp = {0};

    rsp.victimWay = hawkeye(
        req.init, req.paddr, req.set, req.pc, req.way, req.hit);

    return rsp;
}

int main()
{
    req_t req;
    rsp_t rsp;
    while(1) {
      req = *((req_t *) PERIPH);
      rsp = func(req);
      *((rsp_t *) PERIPH) = rsp;
    }
}
