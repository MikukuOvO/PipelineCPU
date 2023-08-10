
// data memory
module dm(clk, DMWr, addr, pc, din, dm_ctrl, dout);
   input          clk;
   input          DMWr;
   input  [31:0]  addr;
   input  [31:0]  pc;
   input  [31:0]  din;
   input  [2:0]   dm_ctrl;
   output [31:0]  dout;
     
   reg [7:0] dmem[1023:0];

   wire [9:0] ar;
   assign ar = addr;

   always @(posedge clk)
   begin
      // $display("addr = %h, ar = %h", addr, ar);
      if (DMWr) begin     
         case(dm_ctrl)
            `dm_word:begin
               dmem[ar+0] = din[7:0];
               dmem[ar+1] = din[15:8];
               dmem[ar+2] = din[23:16];
               dmem[ar+3] = din[31:24];
            end
            `dm_halfword:begin
               dmem[ar+0] = din[7:0];
               dmem[ar+1] = din[15:8];
            end
            `dm_byte:begin
               dmem[ar+0] = din[7:0];
            end
         endcase

         // dmem[addr[11:2]] <= din;
//        $display("dmem[0x%8X] = 0x%8X,", addr << 2, din); 
      //   $display("pc = %h: dataaddr = %h, memdata = %h", pc, {addr[31:2], 2'b00}, din);      
      end
   end
   
   // assign dout = dmem[addr[11:2]];
   reg [31:0] douta;
   always @(*) begin
      douta <= {dmem[ar+3], dmem[ar+2], dmem[ar+1], dmem[ar+0]};
   end
   assign dout = douta;
    
endmodule    
