#ifndef CRC32_H
#define CRC32_H

#include <stddef.h>
#include <stdint.h>

void generate_crc32_table(void);
uint32_t crc32(const uint8_t* data, size_t len, uint32_t crc);

#endif