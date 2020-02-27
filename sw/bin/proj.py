import serial
import sys
import argparse
import re
from collections import OrderedDict
import time

def out32(s,addr,data,raw=False):
    if not raw:
        addr = addr & 0xFF00FFFF
        addr = addr | 0x00010000
    s.write(bytearray([
        addr&0xFF,(addr>>8)&0xFF,(addr>>16)&0xFF,(addr>>24)&0xFF,
        data&0xFF,(data>>8)&0xFF,(data>>16)&0xFF,(data>>24)&0xFF,
    ]))
    rtn = s.read(1)
    return rtn[0]

def in32(s,addr):
    addr = addr & 0xFF00FFFF
    data = 0
    s.write(bytearray([
        addr&0xFF,(addr>>8)&0xFF,(addr>>16)&0xFF,(addr>>24)&0xFF,
        data&0xFF,(data>>8)&0xFF,(data>>16)&0xFF,(data>>24)&0xFF,
    ]))
    rtn = s.read(5)
    return rtn[0],rtn[1] | (rtn[2] << 8) |  (rtn[3] << 16) | (rtn[4] << 24)  
    
def reset(s):
    print("Try automatic reset by RTS, if no response, press the reset manully")
    s.rts = 0
    s.rts = 1
    s.rts = 0
    while True:
        try:
            rtn = s.read(1)
            if rtn[0] == 0x5A:
                print("Reset OK")
                break
            else:
                print("Reset Sync Failed, read %02X" % rtn[0])
                return False
        except:
            print("Wait reset timeout, Waiting...")
    return True

def load_mem_file(s,filename,w=4,b=0):
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
    cnt = 0
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
            addr_jump = False
        line=''
        saddr = addr
        for _ in range(w):
            line = ("%02x" % mdata.get(addr,0)) + line
            addr += 1
        wdata = int(line,base=16)
        if addr < 0x00007800:
            #print('mwr 0x%08x 0x%08x' % (saddr,wdata))
            r = out32(s, saddr, wdata)
            #print("command sequence: %d" % r)
            r,v = in32(s, saddr)
            #print("command sequence: %d, result 0x%08x, check %d" % (r,v,v==wdata))         
            print('.',end='',flush=True)
            if v != wdata:
                cnt += 1
        if addr > max_addr:
            break    
    print('')
    return cnt
def str2int(s):
    if s[:2] == '0x' or s[:2] == '0X':
        return int(s,base=16)
    else:
        return int(s)

def open_serial():
    return serial.Serial(args.port, 115200, timeout=5)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='A25 bsl programmer')
    parser.add_argument('-p','--port',type=str,help='serial port')
    parser.add_argument('-e','--execute',type=str,help='execute command mrd/mwr/run')
    parser.add_argument('-f','--file',type=str,help='load file')

    args = parser.parse_args()

    
    
    if args.execute:
        cmds = re.split(r'\s+',args.execute)
        if cmds[0] == 'mwr':
            s = open_serial()
            r = out32(s, str2int(cmds[1]), str2int(cmds[2]))
            print("command sequence: %d" % r)
            s.close()
        elif cmds[0] == 'mrd':
            s = open_serial()
            r,v = in32(s, str2int(cmds[1]))
            print("command sequence: %d, result 0x%08x" % (r,v))
            s.close()
        elif cmds[0] == 'run':
            s = open_serial()
            r = out32(s,0x00FF0000,0x0,raw=True)
            print("command sequence: %d" % r)
            s.close()
        elif cmds[0] == 'rst':
            s = open_serial()
            reset(s)
            s.close()

    elif args.file:
        s = open_serial()
        if not reset(s): 
            s.close()
            exit(1)
        s.close()   
        s = open_serial()
        if load_mem_file(s,args.file) == 0:
            print("load successful, you may run the application by -e \"run\"")
        s.close()