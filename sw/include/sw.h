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


#endif
