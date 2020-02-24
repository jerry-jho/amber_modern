#include <sw.h>

int main(int argc,char ** argv);

void crtmain() {
    main(0,NULL);
    out32(REG_DONE,0x1);
    while(1);
}

void _outb(uint32_t c) {
    uint32_t r = in32(REG_UART_FR);
    while ((r & 0x8) == 0x8) {
        r = in32(REG_UART_FR);
    }
    out32(REG_UART_DR,c);
}


void print(const char *s) {
    while (*s != '\0') _outb(*s++);
}