`include "SCPU.v"
`include "dm.v"
`include "im.v"

module xgriscv_pipeline(clk, rstn, pcW);
   input          clk;
   input          rstn;
   output [31:0] pcW;
   
   wire [31:0]    instr;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [2:0] dm_ctrl;
   
   wire rst = rstn;
       
  // instantiation of single-cycle CPU   
   SCPU U_SCPU(
         .clk(clk),                 // input:  cpu clock
         .reset(rst),                 // input:  reset
         .inst_in(instr),             // input:  instruction
         .Data_in(dm_dout),        // input:  data to cpu  
         .mem_w(MemWrite),       // output: memory write signal
         .PC_out(pcW),                   // output: PC
         .Addr_out(dm_addr),          // output: address from cpu to memory
         .Data_out(dm_din),        // output: data from cpu to memory
         .dm_ctrl(dm_ctrl)
      //   .reg_sel(reg_sel),         // input:  register selection
      //   .reg_data(reg_data)        // output: register data
         );
         
  // instantiation of data memory  
   dm    U_dmem(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr), // input:  ram address
         .pc(pcW),
         .din(dm_din),        // input:  data to ram
         .dm_ctrl(dm_ctrl),
         .dout(dm_dout)       // output: data from ram
         );

   // always @(*) begin
   //    $display("dm_din = %h", dm_din);
   // end
         
  // instantiation of intruction memory (used for simulation)
   im    U_imem ( 
      .addr(pcW),     // input:  ram address
      .dout(instr)        // output: instruction
   );
        
endmodule