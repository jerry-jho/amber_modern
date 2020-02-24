#include <sw.h>

int main(int argc,char ** argv) {
    uint32_t x;
    putchar(0x5A);
    while(1) {
        x = getchar();
        out32(REG_GPIO,x);
    }
    return 0;
}