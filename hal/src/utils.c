
#include "utils.h"

void assert_failed(uint8_t *file, uint32_t line)
{
  myprintf("Wrong parameters value: file %s on line %d\r\n", file, line);
}
