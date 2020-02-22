#include <sw.h>

int main(int argc,char ** argv) {
    out32(0x21000000,0x2233);
    out32(0x21000004,0x1234);
    return 0x3456;
}