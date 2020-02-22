import sys
from collections import OrderedDict

_,filename,w,b,ost = sys.argv
w = int(w) >> 3
b = int(b,base=16)
mdata = OrderedDict()
addr = 0
min_addr = None
for line in open(filename):
    segs = line.strip().split(' ')
    for seg in segs:
        if seg == '':
            continue
        if seg.startswith('@'):
            addr = int(seg[1:],base=16)
            if min_addr is None:
                min_addr = addr
        else:
            if min_addr is None:
                min_addr = addr            
            data = int(seg,base=16)
            mdata[addr] = data
            addr += 1

max_addr = addr - 1

#print(min_addr,max_addr)
if min_addr % w != 0:
    min_addr -= 1
    while True:
        mdata[min_addr] = 0
        if min_addr % w == 0:
            break
        min_addr -= 1
if max_addr % w != (w-1):
    max_addr += 1
    while True:
        mdata[max_addr] = 0
        if max_addr % w == (w-1):
            break
        max_addr += 1
        
addr_jump = True
addr = min_addr
while True:
    line_empty = True
    for i in range(w):
        if addr+i in mdata.keys():
            line_empty = False
            break
    if line_empty:
        addr += w
        addr_jump = True
        continue
    if addr_jump:
        if ost == "mem":
            print('@%08X' % ((addr-b) // w))    
        addr_jump = False
    line=''
    saddr = addr
    for _ in range(w):
        line = ("%02X" % mdata.get(addr,0)) + line
        addr += 1
    if ost == "mem":
        print(line)
    elif ost == "xsct":
        print('mwr 0x%08X 0x' % saddr + line)
    if addr > max_addr:
        break
        
#for k,v in mdata.items():
#    print("%04X:%02X"%(k,v))