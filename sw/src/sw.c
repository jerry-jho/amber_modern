#include <sw.h>

int main(int argc,char ** argv);

void crtmain() {
    main(0,NULL);
    while(1);
}

#define AdrUARTDR 0x02000000
#define AdrUARTFR 0x02000018

void _outb(uint32_t c) {
    uint32_t r = in32(AdrUARTFR);
    while ((r & 0x8) == 0x8) {
        r = in32(AdrUARTFR);
    }
    out32(AdrUARTDR,c);
}

void print(const char *s) {
    while (*s != '\0') _outb(*s++);
}