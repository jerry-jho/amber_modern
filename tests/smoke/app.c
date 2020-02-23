#include <sw.h>

int main(int argc,char ** argv) {
    int i;
    while (1) {
        for (i=0;i<2400000;i++) out32(0x01000000,0x1);
        for (i=0;i<2400000;i++) out32(0x01000000,0x2);
    }
    return 0;
}