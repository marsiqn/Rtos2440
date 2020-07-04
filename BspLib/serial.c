
#include"s3c2440.h"
#define UART_NR	S3C24X0_UART0
void serial_putc(const char c);


void _serial_putc (const char c, const int dev_index)
{
	S3C24X0_UART * const uart = S3C24X0_GetBase_UART(dev_index);

	/* wait for room in the tx FIFO */
	while (!(uart->UTRSTAT & 0x2));
	uart->UTXH = c;

	/* If \n, also do \r */
	if (c == '\n')
		serial_putc('\r');
}

void serial_putc(const char c)
{
	_serial_putc(c, UART_NR);
}
void _serial_puts(const char *s, const int dev_index)
{
	while (*s) {
		_serial_putc (*s++, dev_index);
	}
}
int putc(const char c){

	serial_putc(c);
}

void puts (const char *s)
{
		_serial_puts(s, UART_NR);
}



