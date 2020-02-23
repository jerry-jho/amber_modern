
from collections import OrderedDict
import math

def PyMem_Iter(_mdata):
    _addr  = 0
    _max_addr = list(_mdata.keys())[-1]
    while True:
        if _addr > _max_addr:
            return
        else:
            v = _addr
            _addr += 1
            yield v

class PyMEM:
    FORMAT_VLOG_B8 = 1

    def __init__(self,file_or_fileobj,FORMAT=None):
        obj_close_flag = type(file_or_fileobj) == type("")
        if obj_close_flag:
            file_or_fileobj = open(file_or_fileobj,"r")
        self._mdata = OrderedDict()   
        if FORMAT is None:
            self.__read_vlog_b8(self._mdata, file_or_fileobj)
        if obj_close_flag:
            file_or_fileobj.close()

    def __read_vlog_b8(self,mdata,fileobj):
        addr = 0
        for line in fileobj:
            segs = line.strip().split(' ')
            for seg in segs:
                if seg == '':
                    continue
                if seg.startswith('@'):
                    addr = int(seg[1:],base=16)
                else:
                    data = int(seg,base=16)
                    mdata[addr] = data
                    addr += 1
    def __getitem__(self,addr):
        if not addr in self._mdata.keys():
            return 0
        return self._mdata[addr]
    def __setitem__(self,addr,data):
        self._mdata[addr] = data
    def keys(self):
        return PyMem_Iter(self._mdata)
    
def generate_init_parameters(mem,start_addr,row_width,row_stride,row_count,output_w):
    mem_in_bytes = []
    rtn = ""
    addr = start_addr
    for row in range(row_count):
        for b in range(row_width):
            mem_in_bytes.append(mem[addr+b])
        addr += row_stride
    
    line = ''
    for i,b in enumerate(mem_in_bytes):
        line = "%02X" % b + line
        if i%(output_w//8)== (output_w//8)-1:
            rtn += ("       .INIT_%02X(%d'h" % (i*8//output_w,output_w)) + line + "),\n"
            line = ""
    return rtn
    
    
def generate_bram(mem = None,mwdith = 32, mdepth= 1024,mname = None):
    
    if mname is None:
        mname = "sram_sp_%dx%d" % (mwdith,mdepth)
    
    rtn = ''
    FIX_MWIDTH   = 32
    FIX_MWEWIDTH = FIX_MWIDTH // 8
    FIX_MDEPTH   = 1024
    
    col_cnt = mwdith // FIX_MWIDTH
    row_cnt = mdepth // FIX_MDEPTH
    
    addr_w = int(math.log2(mdepth))
    FIX_MADDRW = int(math.log2(FIX_MDEPTH))
    
    
    rtn += """

module %s #(parameter AW=32) (
    input         clk,
    input         rst_n,
    input  [AW-1:0] i_wb_adr,
    input  [%d:0] i_wb_dat,
    input         i_wb_we,
    input  [%d:0] i_wb_sel,
    input         i_wb_cyc,
    input         i_wb_stb,
    output [%d:0] o_wb_dat,
    output        o_wb_ack,
    output        o_wb_err
);  

    reg istat;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) istat <= 1'b1;
        else if (istat == 1'b1 && i_wb_cyc == 1'b1) istat <= 1'b0;
        else if (istat == 1'b0) istat <= 1'b1;
    end
    
    wire CE = i_wb_cyc & istat;
    assign o_wb_ack = ~istat;
    assign o_wb_err = 1'b0;

    """ % (mname,mwdith-1,mwdith//8-1,mwdith-1)
    
    byte_addr_w = int(math.log2(mwdith>>3))
    
    rtn += """
    wire [%d:0] addr_m = i_wb_adr[%d:%d];
    """ % (addr_w-1,addr_w+byte_addr_w-1,byte_addr_w)
    
    rtn += """
    wire [%d:0] MWE = i_wb_we ? i_wb_sel : 'd0;
    """ % (mwdith//8-1)
    
    rtn += """
    wire [%d:0] row_addr   = addr_m[%d:0];
    wire [%d:0] row_sel    = addr_m[%d:%d]; 
    """ % (FIX_MADDRW-1,FIX_MADDRW-1,
           addr_w-FIX_MADDRW-1,addr_w-1,FIX_MADDRW)    
    
    
    for row in range(row_cnt):
        rtn += """
    wire en_row_%d = (row_sel == %d) & CE;
    
                """ % (row,row)
        for col in range(col_cnt):

            rtn += """
    wire [%d:0] d_row_%d_col_%d = i_wb_dat[%d:%d];        
            """ % (FIX_MWIDTH-1,row,col,(col+1)*FIX_MWIDTH-1,col*FIX_MWIDTH)
            
            rtn += """
    wire [%d:0] q_row_%d_col_%d;        
                    """ % (FIX_MWIDTH-1,row,col)            

            rtn += """
    wire [%d:0] we_row_%d_col_%d = MWE[%d:%d];        
                    """ % (FIX_MWEWIDTH-1,row,col,(col+1)*FIX_MWEWIDTH-1,col*FIX_MWEWIDTH)
            
            rtn += """
    BRAM_SINGLE_MACRO #(
       .BRAM_SIZE("36Kb"), // Target BRAM, "18Kb" or "36Kb" 
       .DEVICE("7SERIES"), // Target Device: "7SERIES" 
       .DO_REG(0), // Optional output register (0 or 1)
       .INIT(256'h0), // Initial values on output port
       .INIT_FILE ("NONE"),
       .WRITE_WIDTH(32), // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
       .READ_WIDTH(32),  // Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
       .SRVAL(36'h0), // Set/Reset value for port output
       .WRITE_MODE("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"             
            \n"""
            rtn += generate_init_parameters(mem, row*FIX_MDEPTH*FIX_MWEWIDTH+col*FIX_MWEWIDTH, 
                                            FIX_MWEWIDTH, 
                                           mwdith//8, 
                                           FIX_MDEPTH, 
                                           256)
            rtn += """
       // The next set of INITP_xx are for the parity bits
       .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),

       // The next set of INIT_xx are valid when configured as 36Kb
       .INITP_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
       .INITP_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
    ) mem_row_%d_col_%d (
       .DO(q_row_%d_col_%d),       // Output data, width defined by READ_WIDTH parameter
       .ADDR(row_addr),   // Input address, width defined by read/write port depth
       .CLK(clk),     // 1-bit input clock
       .DI(d_row_%d_col_%d),       // Input data port, width defined by WRITE_WIDTH parameter
       .EN(en_row_%d),// 1-bit input RAM enable
       .REGCE(1'b0),  // 1-bit input output register enable
       .RST(1'b0),    // 1-bit input reset
       .WE(we_row_%d_col_%d)        // Input write enable, width defined by write port depth
    );            
            \n""" % (row,col,row,col,row,col,row,row,col)
            
    for row in range(row_cnt):
        rtn += ("    wire [%d:0] q_row_%d = {" % (mwdith-1,row)) + \
            ",".join(["q_row_%d_col_%d" % (row,x) for x in reversed(range(col_cnt))]) + \
            "};\n"

    rtn += """
    
    reg [%d:0] row_sel_q;
    always @(posedge clk) row_sel_q <= row_sel;
    \n""" % (addr_w-FIX_MADDRW-1)  
    
    rtn += """
    reg [%d:0] QS;
    always @(*) begin
        case(row_sel_q)
    \n""" % (mwdith-1)
    
    for row in range(row_cnt):
        rtn += "            %d : QS = q_row_%d;\n" % (row,row)

    rtn += """
            default : QS = 'd0;
        endcase
    end
    assign o_wb_dat = i_wb_cyc ? QS : 'd0;
    \n"""
        
    rtn += "\nendmodule\n"
            
    return rtn

if __name__ == '__main__':
    import sys
    x = generate_bram(mem=PyMEM(sys.argv[1]),mwdith=int(sys.argv[2]),mdepth=int(sys.argv[3]))
    print(x)