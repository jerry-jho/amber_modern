import sys

task = sys.argv[1]

mo_ports = [
    'adr','sel','dat','cyc','stb','we'
]

mi_ports = [
    'dat','ack','err'
]

if task == "mp" or task == "m":
    mw = sys.argv[2]
    for p in mo_ports:
        if p == 'dat':
            pw = 'dat_w'
        else:
            pw = p
        if task == "m":
            print("        .o_wb_%s(%s_wb_%s)," % (p,mw,pw))
        else:
            print("        .o_m_wb_%s(%s_wb_%s)," % (p,mw,pw))
    for p in mi_ports:
        if p == 'dat':
            pw = 'dat_r'
        else:
            pw = p
        if task == "m":
            print("        .i_wb_%s(%s_wb_%s)," % (p,mw,pw))
        else:
            print("        .i_m_wb_%s(%s_wb_%s)," % (p,mw,pw))        
if task == "sp" or task == "s":
    sw = sys.argv[2]
    for p in mo_ports:
        if p == 'dat':
            pw = 'dat_w'
        else:
            pw = p
        if task == "s":
            print("        .i_wb_%s(%s_wb_%s)," % (p,sw,pw))
        else:
            print("        .i_s_wb_%s(%s_wb_%s)," % (p,sw,pw))
    for p in mi_ports:
        if p == 'dat':
            pw = 'dat_r'
        else:
            pw = p
        if task == "s":
            print("        .o_wb_%s(%s_wb_%s)," % (p,sw,pw))
        else:
            print("        .o_s_wb_%s(%s_wb_%s)," % (p,sw,pw))    