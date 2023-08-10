
module RF(   
    input         clk, 
    input         rst,
    input         RFWr, 
    input  [4:0]  A1, A2, A3, 
    input  [31:0] WD, 
    input  [31:0] PC,
    output [31:0] RD1, RD2
);

reg [31:0] rf[31:0];

integer i;
always @(negedge clk,posedge rst) begin
  if (rst) begin    //  reset
    for (i=0; i<32; i=i+1)
      rf[i] <= 0; //  i;
  end
  else if (RFWr && A3) begin 
      rf[A3] <= WD;
      $display("pc = %h: x%d = %h", PC, A3, WD);
  end
end

assign RD1 = rf[A1];
assign RD2 = rf[A2];

endmodule 
