module IF(
    input clk,
    input rst,
    input flush,
    input stall,
    input [31:0] PC_in,
    input [31:0] inst_in,
    output reg [31:0] PC_out,     
    output reg [31:0] inst_out
);

    always @(posedge clk, posedge rst)
    begin
        if (rst||flush) begin
            PC_out<=32'b0;
            inst_out<=32'b0;
        end
        else begin
            if(!stall) begin
                PC_out<=PC_in;
                inst_out<=inst_in;
            end
        end
    end
endmodule