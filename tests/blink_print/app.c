#include <sw.h>

int main(int argc,char ** argv) {
    int i;
    print("============ A25 Blink Test ============\n\r");
    while (1) {
        for (i=0;i<2400000;i++) out32(0x01000000,0x1);
        for (i=0;i<2400000;i++) out32(0x01000000,0x2);
        for (i=0;i<2400000;i++) out32(0x01000000,0x4);
        for (i=0;i<2400000;i++) out32(0x01000000,0x8);
        print("============ Hello! ============\n\r");
    }
    return 0;
}