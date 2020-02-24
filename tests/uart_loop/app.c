#include <sw.h>

int main(int argc,char ** argv) {
    putchar(0x5A);
    out32(REG_GPIO,getchar());
    return 0;
}