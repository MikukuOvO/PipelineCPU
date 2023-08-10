`include "ctrl_encode_def.v"
`include "alu.v"

module EX(
    input clk,
    input rst,

    input [31:0] ALU_A,
    input [31:0] ALU_B,
    input [4:0] ALUOp,

    input [31:0] PC_in,
    input [31:0] immout_in,
    input [2:0] NPCOp_in,

    input MemWrite_in,            // 内存写信号
    input [2:0] dm_ctrl_in,         
    input [31:0] raw_Data_out,   // 写往 DM 的数据

    input RegWrite_in,            // 控制寄存器是否写
    input [4:0] rd_in,
    input [1:0] WDSel_in,

    output reg flush,

    // 冒险
    output [31:0] EX_MEM_Forward_Data,

    // 给 MEM 阶段的信号

    output reg [31:0] PC,
    output reg [31:0] immout,
    output reg [2:0] NPCOp,

    output reg MemWrite,
    output reg [2:0] dm_ctrl,
    output reg [3:0] wea,
    output reg [31:0] dm_Data_out,
    output reg [31:0] aluout,

    // 给 WB 阶段的信号

    output reg RegWrite,
    output reg [4:0] rd,
    output reg [1:0] WDSel,
    output reg [31:0] WD

    );

    reg [3:0] wea_tmp;
    wire Zero;
    wire [31:0] aluout_w;
    wire [31:0] WD_w;


    // 运算单元的接线

    alu U_alu(
        .A(ALU_A),
        .B(ALU_B),
        .PC(PC),
        .ALUOp(ALUOp),
        .C(aluout_w),
        .Zero(Zero)
    );

    // 考虑 Jalr 指令

    assign WD_w=(WDSel_in==`WDSel_FromPC)?PC_in+4:aluout_w;
    assign EX_MEM_Forward_Data=WD_w;

    wire flush_w=(NPCOp_in[0]&Zero)|NPCOp_in[1]|NPCOp_in[2];

    always @(*) begin
        if(MemWrite_in) begin
            case(dm_ctrl_in)
                `dm_word: wea_tmp<=4'b1111;              
                `dm_halfword: wea_tmp<=4'b0011;
                `dm_byte: wea_tmp<=4'b0001;
                default wea_tmp<=4'b0000;
            endcase
        end
        else wea_tmp<=4'b0000;
    end

    always @(posedge clk, posedge rst) begin
        if(rst||flush) begin
            PC<=32'b0;
            immout<=32'b0;
            NPCOp<=3'b0;

            MemWrite<=1'b0;
            dm_ctrl<=3'b0;
            dm_Data_out<=32'b0;
            wea<=4'b0;
            aluout<=32'b0;

            RegWrite<=1'b0;
            rd<=5'b0;
            WDSel<=2'b0;
            WD<=32'b0;
            flush<=1'b0;
        end
        else begin
            PC<=PC_in;
            immout<=immout_in;
            NPCOp[0]<=NPCOp_in[0]&Zero;
            NPCOp[1]<=NPCOp_in[1];
            NPCOp[2]<=NPCOp_in[2];

            MemWrite<=MemWrite_in;
            dm_ctrl<=dm_ctrl_in;
            dm_Data_out<=raw_Data_out;
            wea<=wea_tmp;
            aluout<=aluout_w;

            RegWrite<=RegWrite_in;
            rd<=rd_in;
            WDSel<=WDSel_in;
            WD<=WD_w;
            flush<=flush_w;
        end
    end


endmodule
