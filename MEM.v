module MEM(
    input clk,
    input rst,
    input [31:0] raw_Data_in,
    input [2:0] dm_ctrl,
    input [1:0] bias,

    input RegWrite_in,
    input [4:0] rd_in,
    input [1:0] WDSel_in,
    input [31:0] WD_in,

    output [31:0] MEM_WB_Forward_Data,

    output RegWrite,
    output [4:0] rd,
    output [31:0] WD
    );

    reg [31:0] WD_w;
    reg [31:0] Data_in;

    assign MEM_WB_Forward_Data=WD_w;
    assign RegWrite=RegWrite_in;
    assign rd=rd_in;
    assign WD=WD_w;

    always @(*) begin
        case(dm_ctrl)
            `dm_word: Data_in<=raw_Data_in;
            `dm_halfword: Data_in<={{16{raw_Data_in[15]}}, raw_Data_in[15:0]};
            `dm_byte: Data_in<={{24{raw_Data_in[7]}}, raw_Data_in[7:0]};
            `dm_halfword_unsigned: Data_in<={16'b0, raw_Data_in[15:0]};
            `dm_byte_unsigned: Data_in<={24'b0, raw_Data_in[7:0]};
            default Data_in<=32'b0;
        endcase
        WD_w<=(WDSel_in==`WDSel_FromMEM)?Data_in:WD_in;
    end
endmodule