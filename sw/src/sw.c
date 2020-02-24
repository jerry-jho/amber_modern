#include <sw.h>

int main(int argc,char ** argv);

void _wait_uart_tx() {
    uint32_t r = in32(REG_UART_FR);
    while ((r & 0x8) == 0x8) {
        r = in32(REG_UART_FR);
    }    
}

void _wait_uart_rx() {
    uint32_t r = in32(REG_UART_FR);
    while ((r & 0x40) != 0x40) {
        r = in32(REG_UART_FR);
    }    
}

void putchar(uint32_t c) {
    _wait_uart_tx();
    out32(REG_UART_DR,c);
}

uint32_t getchar() {
    _wait_uart_rx();
    return in32(REG_UART_DR);
}

void print(const char *s) {
    while (*s != '\0') putchar(*s++);
}

void _exit(uint32_t e) {
    _wait_uart_tx();
    out32(REG_DONE,0x1);
    while(1);    
}

void crtmain() {
    main(0,NULL);
    _exit(0);
}

void bslmain() {
    __asm__ __volatile__("swi 0");
}
