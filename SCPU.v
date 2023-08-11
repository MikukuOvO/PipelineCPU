`include "ctrl_encode_def.v"
`include "PC.v"
`include "NPC.v"
`include "IF.v"
`include "ID.v"
`include "EX.v"
`include "MEM.v"
`include "RF.v"

module SCPU(
    input INT,
    input MIO_ready,
    output CPU_MIO,

    input clk,
    input reset,

    input [31:0] inst_in,
    output [31:0] PC_out,

    output mem_w,
    input [31:0] Data_in,
    output [31:0] Addr_out,
    output [31:0] Data_out,
    output [2:0] dm_ctrl
);

    wire [31:0] PC;
    wire [31:0] IF_ID_PC;
    wire [31:0] IF_ID_inst;

    assign PC_out = PC;

    wire stall;

    //assign  stall = 1'b0;

    wire [31:0] MEM_NPC;

    wire [31:0] EX_MEM_Forward_Data;
    wire [31:0] MEM_WB_Forward_Data;

    PC U_PC(
        .clk(clk),
        .rst(reset),
        .stall(stall),
        .NPCOP(EX_MEM_NPCOp),
        .NPC(MEM_NPC),
        .PC(PC)
    );

    // assign flush = 1'b0;
    wire flush;

    IF U_IF(
        .clk(clk),
        .rst(reset),
        .stall(stall),
        .flush(flush),
        .PC_in(PC),
        .inst_in(inst_in),

        .PC_out(IF_ID_PC),
        .inst_out(IF_ID_inst)
    );

    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [4:0] rs1;
    wire [4:0] rs2;

    RF U_RF(
        .clk(clk),
        .rst(reset),
        .A1(rs1), .A2(rs2), .RD1(RD1), .RD2(RD2),
        .PC(PC),
        .RFWr(MEM_WB_RegWrite), .A3(MEM_WB_rd), .WD(MEM_WB_WD)
    );

    wire [31:0] ID_EX_ALU_A;
    wire [31:0] ID_EX_ALU_B;
    wire [4:0] ID_EX_ALUOp;
    wire [31:0] ID_EX_PC;
    wire [31:0] ID_EX_immout;
    wire [2:0] ID_EX_NPCOp;
    wire ID_EX_MemWrite;
    wire [2:0] ID_EX_dm_ctrl;
    wire [31:0] ID_EX_DataWrite;
    wire ID_EX_RegWrite;
    wire [4:0] ID_EX_rd;
    wire [1:0] ID_EX_WDSel;

    
    ID U_ID(
        .clk(clk),
        .rst(reset),
        .flush(flush),
        .PC_in(IF_ID_PC), .inst_in(IF_ID_inst),

        .RD1(RD1), .RD2(RD2), .rs1(rs1), .rs2(rs2),    

        .ID_EX_RegWrite(ID_EX_RegWrite),
        .ID_EX_rd(ID_EX_rd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .EX_MEM_rd(EX_MEM_rd),
        .ID_EX_WDSel(ID_EX_WDSel),
        .EX_MEM_Forward_Data(EX_MEM_Forward_Data),
        .MEM_WB_Forward_Data(MEM_WB_Forward_Data),

        .stall(stall),                
        .ALU_A(ID_EX_ALU_A),             
        .ALU_B(ID_EX_ALU_B),
        .ALUOp(ID_EX_ALUOp),
        .PC(ID_EX_PC),
        .immout(ID_EX_immout),
        .NPCOp(ID_EX_NPCOp),
        .MemWrite(ID_EX_MemWrite),
        .dm_ctrl(ID_EX_dm_ctrl),
        .DataWrite(ID_EX_DataWrite),
        .RegWrite(ID_EX_RegWrite),
        .rd(ID_EX_rd),
        .WDSel(ID_EX_WDSel)
    );

    wire [31:0] EX_MEM_PC;
    wire [31:0] EX_MEM_immout;
    wire [2:0] EX_MEM_NPCOp;
    wire EX_MEM_MemWrite;
    wire [2:0] EX_MEM_dm_ctrl;
    wire [3:0] EX_MEM_wea;
    wire [31:0] EX_MEM_DataWrite;
    wire [31:0] EX_MEM_aluout;
    wire EX_MEM_RegWrite;
    wire [4:0] EX_MEM_rd;
    wire [1:0] EX_MEM_WDSel;
    wire [31:0] EX_MEM_WD;

    EX U_EX(
        .clk(clk),
        .rst(reset),
        .ALU_A(ID_EX_ALU_A),
        .ALU_B(ID_EX_ALU_B),
        .ALUOp(ID_EX_ALUOp),
        .PC_in(ID_EX_PC),
        .immout_in(ID_EX_immout),
        .NPCOp_in(ID_EX_NPCOp),
        .MemWrite_in(ID_EX_MemWrite),
        .dm_ctrl_in(ID_EX_dm_ctrl),
        .raw_Data_out(ID_EX_DataWrite),
        .RegWrite_in(ID_EX_RegWrite),
        .rd_in(ID_EX_rd),
        .WDSel_in(ID_EX_WDSel),

        .EX_MEM_Forward_Data(EX_MEM_Forward_Data),

        .PC(EX_MEM_PC),
        .flush(flush),
        .immout(EX_MEM_immout),
        .NPCOp(EX_MEM_NPCOp),
        .MemWrite(EX_MEM_MemWrite),
        .dm_ctrl(EX_MEM_dm_ctrl),
        .wea(EX_MEM_wea),
        .dm_Data_out(EX_MEM_DataWrite),
        .aluout(EX_MEM_aluout),
        .RegWrite(EX_MEM_RegWrite),
        .rd(EX_MEM_rd),
        .WDSel(EX_MEM_WDSel),
        .WD(EX_MEM_WD)      
    );

    NPC U_NPC(
        .PC(EX_MEM_PC),
        .NPCOp(EX_MEM_NPCOp),
        .IMM(EX_MEM_immout),
        .aluout(EX_MEM_aluout),

        .NPC(MEM_NPC)
    );

    wire MEM_WB_RegWrite;
    wire [4:0] MEM_WB_rd;
    wire [31:0] MEM_WB_WD;
    wire [31:0] MEM_WB_PC;

    MEM U_MEM(
        .clk(clk), 
        .rst(reset),

        .MEM_WB_Forward_Data(MEM_WB_Forward_Data),

        .raw_Data_in(Data_in),
        .dm_ctrl(EX_MEM_dm_ctrl),
        .bias(EX_MEM_aluout[1:0]),

        .RegWrite_in(EX_MEM_RegWrite),
        .rd_in(EX_MEM_rd),
        .WDSel_in(EX_MEM_WDSel),
        .WD_in(EX_MEM_WD),

        .RegWrite(MEM_WB_RegWrite),
        .rd(MEM_WB_rd),
        .WD(MEM_WB_WD)
    );

    assign mem_w = EX_MEM_MemWrite;
    assign Addr_out = EX_MEM_aluout;
    assign wea = EX_MEM_wea;
    assign Data_out = EX_MEM_DataWrite;
    assign dm_ctrl = EX_MEM_dm_ctrl;
endmodule