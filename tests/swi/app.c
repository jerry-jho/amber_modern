#include <sw.h>

int main(int argc,char ** argv) {
    int i;
    out32(REG_GPIO,0x1);
    out32(REG_GPIO,0x2);
    return 0;
}