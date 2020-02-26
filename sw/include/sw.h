#ifndef _SW_H
#define _SW_H

#include <stdint.h>
#include <stddef.h>

//BASIC IO

#define out64(addr,data)  {*((volatile uint64_t *)(addr)) = (uint64_t)(data);}
#define in64(addr)        (*((volatile uint64_t *)(addr)))

#define out32(addr,data)  {*((volatile uint32_t *)(addr)) = (uint32_t)(data);}
#define tr32(addr)        {*((volatile uint32_t *)(addr)) = 1;}
#define in32(addr)        (*((volatile uint32_t *)(addr)))
#define wait32(addr)      {while(in32(addr)){}}

#define out16(addr,data)  {*((volatile uint16_t *)(addr)) = (uint16_t)(data);}
#define in16(addr)        (*((volatile uint16_t *)(addr)))

#define out8(addr,data)   {*((volatile uint8_t  *)(addr)) = (uint8_t)(data);}
#define in8(addr)         (*((volatile uint8_t *)(addr)))

void putchar(uint32_t c);
uint32_t getchar();

#define set_outb_fake(x) out32(REG_UART_FAKE,x)

void print(const char * s);

///////////////// REGS /////////////////

#define REG_UART_DR     0x02000000
#define REG_UART_FR     0x02000018
#define REG_UART_FAKE   0x02000020

#define REG_UART1_DR    0x03000000
#define REG_UART1_FR    0x03000018
#define REG_UART1_FAKE  0x03000020

#define REG_GPIO        0x01000000
#define REG_CYCLE       0x01000008
#define REG_DONE        0x01FFFFFC


#endif
