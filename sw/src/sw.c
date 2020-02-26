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

void _wait_uart1_tx() {
    uint32_t r = in32(REG_UART1_FR);
    while ((r & 0x8) == 0x8) {
        r = in32(REG_UART1_FR);
    }    
}

void _wait_uart1_rx() {
    uint32_t r = in32(REG_UART1_FR);
    while ((r & 0x40) != 0x40) {
        r = in32(REG_UART1_FR);
    }    
}

void putchar1(uint32_t c) {
    _wait_uart1_tx();
    out32(REG_UART1_DR,c);
}

uint32_t getchar1() {
    _wait_uart1_rx();
    return in32(REG_UART1_DR);
}

#ifdef _BLS_UART0_
#define putchar_bls     putchar
#define getchar_bls     getchar
#define _wait_uart_bls  _wait_uart_tx
#else
#define putchar_bls putchar1
#define getchar_bls getchar1
#define _wait_uart_bls  _wait_uart1_tx
#endif

void __attribute__((section(".xinit"))) bls_main() {
    #ifndef _NO_BLS_
    uint8_t ibuf[8];
    uint32_t addr;
    uint32_t data;
    uint32_t cmd;
    uint32_t cnt = 0;
    __asm__ __volatile__("mov r0,#0x00000000");
    __asm__ __volatile__("mcr 15,0,r0,cr2,cr0,0");
    __asm__ __volatile__("mov sp,#0x1000");
    putchar_bls(0x5A);
    while (1) {
        for (uint32_t i=0;i<sizeof(ibuf);i++) {
            ibuf[i] = getchar_bls();
        }
        putchar_bls(cnt++);
        
        addr = ibuf[3];
        addr = addr << 16;
        addr |= ibuf[1];
        addr = addr << 8;
        addr |= ibuf[0];        
       
        data = ibuf[7];
        data = data << 8;
        data |= ibuf[6];
        data = data << 8;
        data |= ibuf[5];
        data = data << 8;
        data |= ibuf[4];  
        
        cmd = ibuf[2];

        if (cmd == 0x1) {
            out32(addr,data);
        } else if (cmd == 0x0) {
            data = in32(addr);
            putchar_bls(data);
            putchar_bls((data)>>8);
            putchar_bls((data)>>16);
            putchar_bls((data)>>24);
        } else {
            _wait_uart_bls();
            __asm__ __volatile__("mcr 15,0,r0,cr1,cr0,0");
            __asm__ __volatile__("swi 0");
        }
    }
    #else
    __asm__ __volatile__("swi 0");
    #endif
}
