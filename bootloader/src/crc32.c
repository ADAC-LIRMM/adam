#include "crc32.h"

static uint32_t crc32_table[256];

void generate_crc32_table(void) {
    uint32_t i, j, crc;
    for (i = 0; i < 256; i++) {
        crc = i;
        for (j = 0; j < 8; j++) {
            if (crc & 1) {
                crc = (crc >> 1) ^ 0xEDB88320;
            } else {
                crc >>= 1;
            }
        }
        crc32_table[i] = crc;
    }
}

uint32_t crc32(const uint8_t* data, size_t len, uint32_t crc)
{
    crc = ~crc;

    while(len > 0) {
        crc = (crc >> 8) ^ crc32_table[(crc ^ *data) & 0xFF];
        data++, len--;
    }

    crc = ~crc;

    return crc;
}
