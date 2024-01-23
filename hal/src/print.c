
#include "print.h"

#define _putc(output, c)  (output(c))

void print(void (*output)(char), const char* str, ...)
{
	va_list ap;
	va_start(ap, str);
	vprint(output, str, ap);
}

void vprint(void (*output)(char), const char* str, va_list ap)
{
	char tmp[20];
	char* c = (char*)str;

	union
	{
		char* str;
		int i;
		unsigned int ui;
		long l;
		unsigned long ul;
		long long ll;
		unsigned long long ull;
	} var;

	int size;
	int sign;
	int p;
	char fill;

	while (*c)
	{
		if (*c == '%')
		{
			c++;
			size = 0;
			sign = 0;
			p = 0;

			fill = *c == '0' ? '0' : ' ';

			while (*c >= '0' && *c <= '9')
				size = size*10 + *(c++) - '0';


			switch (*c)
			{
			case 0:
				return;


			case 'c':
				_putc(output, va_arg(ap, unsigned int));
				break;


			case 's':
				var.str = va_arg(ap, char*);
				while (*var.str) _putc(output, *(var.str++));
				break;


			case 'd':
			case 'i':
				var.i = va_arg(ap, int);

				if (var.i < 0)
				{
					var.i = -var.i;
					sign = 1;
				}

				goto _pui;


			case 'u':
				var.ui = va_arg(ap, unsigned int);

_pui:
				do
				{
					tmp[p++] = '0' + (var.ui%10);
					var.ui /= 10;
				} while (var.ui);

				break;


			case 'l':
				if (c[1] == 'l')
				{
					c++;
					if (c[1] == 'u')
					{
						c++;
						var.ull = va_arg(ap, unsigned long long);
					}
					else
					{
						var.ll = va_arg(ap, long long);

						if (var.ll < 0)
						{
							var.ll = -var.ll;
							sign = 1;
						}
					}

					do
					{
						tmp[p++] = '0' + (var.ull%10);
						var.ull /= 10;
					} while (var.ull);

					break;
				}
				else if (c[1] == 'u')
				{
					c++;
					var.ul = va_arg(ap, unsigned long);
				}
				else
				{
					var.l = va_arg(ap, long);

					if (var.l < 0)
					{
						var.l = -var.l;
						sign = 1;
					}
				}

				do
				{
					tmp[p++] = '0' + (var.ul%10);
					var.ul /= 10;
				} while (var.ul);

				break;


			case 'x':
				sign = 0x20;
				// fall through
			case 'X':
				var.ui = va_arg(ap, unsigned int);

				do
				{
					tmp[p] = 0x30 | (var.ui & 0xF);

					if (tmp[p] > 0x39)
						tmp[p] = (tmp[p] + 7) | sign;

					p++;
					var.ui >>= 4;
				} while (var.ui);

				sign = 0;
				break;


			default:
				goto _pchar;
			}

			if (sign)
			{
				if (fill == '0')
				{
					_putc(output, '-');
					size--;
				}
				else
					tmp[p++] = '-';
			}

			while (size > p)
			{
				_putc(output, fill);
				size--;
			}

			while (p--)
				_putc(output, tmp[p]);
		}
		else
		{
_pchar:
			_putc(output, *c);
		}

		c++;
	}
}
