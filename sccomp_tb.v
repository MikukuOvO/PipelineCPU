`include "sccomp.v"

// testbench for simulation
module sccomp_tb();
    
   reg  clk, rstn;
   wire[31:0] pc;
    
// instantiation of sccomp
    xgriscv_pipeline xgriscv(clk, rstn, pc);

  	integer foutput;
  	integer counter = 0;
   
   initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, xgriscv.U_SCPU);

      $readmemh( "Test_37_Instr.dat" , xgriscv.U_imem.RAM); // load instructions into instruction memory
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
      #20 ;
      rstn = 0;
      // #1000 ;
      // reg_sel = 7;
   end
   
    always begin
    #(50) clk = ~clk;
	   
    if (clk == 1'b1) begin      
      if ((counter == 50) || (xgriscv.U_SCPU.PC_out=== 32'hxxxxxxxx)) begin
        $stop;
      end
      else begin
        if (xgriscv.pcW == 32'h0c000048) begin
          counter = counter + 1;
          $stop;
        end
        else begin
          counter = counter + 1;
        end
      end
    end
  end //end always
   
endmodule
