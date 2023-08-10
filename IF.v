// IF 阶段就是将指令读入然后保存到流水线寄存器中传给下一级就可以了
// 注意考虑下阻塞和结构冒险
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