
#include "utils.h"

void assert_failed(uint8_t *file, uint32_t line)
{
  ee_printf("Wrong parameters value: file %s on line %d\r\n", file, line);
}
