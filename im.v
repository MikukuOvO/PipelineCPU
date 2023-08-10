
// instruction memory
module im(input  [31:0]  addr,
            output [31:0] dout );

  reg  [31:0] RAM[511:0];
  assign dout = RAM[addr[11:2]]; // word aligned
endmodule  
