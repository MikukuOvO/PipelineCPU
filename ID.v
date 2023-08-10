`include "EXT.v"
`include "ctrl.v"

module ID(
    input clk,
    input rst,
    input flush,
    input [31:0] PC_in,
    input [31:0] inst_in,

    // 读取寄存器堆中的数据
    input [31:0] RD1,         
    input [31:0] RD2,         

    // 数据冒险
    input ID_EX_RegWrite,
    input [4:0] ID_EX_rd,
    input EX_MEM_RegWrite,
    input [4:0] EX_MEM_rd,

    // 数据冒险的旁路
    input [1:0] ID_EX_WDSel,
    input [31:0] EX_MEM_Forward_Data,
    input [31:0] MEM_WB_Forward_Data,

    output stall,                               // 检测阻塞
    output [4:0] rs1,                           // 从寄存器堆中读取的寄存器编号
    output [4:0] rs2,                           // 从寄存器堆中读取的寄存器编号

    // EX 阶段使用的内容
    output reg [31:0] ALU_A,                    // ALU 的输入
    output reg [31:0] ALU_B,                    // ALU 的输入
    output reg [4:0] ALUOp,                     // ALU 控制信号

    // MEM 阶段使用的内容
    output reg [31:0] PC,
    output reg [31:0] immout,
    output reg [2:0] NPCOp,
    output reg MemWrite,
    output reg [2:0] dm_ctrl, 
    output reg [31:0] DataWrite,

    // WB 阶段使用的内容
    output reg RegWrite, 
    output reg [4:0] rd,                        // 写入寄存器的编号
    output reg [1:0] WDSel                      // 写入寄存器的数据来源
    );

    // 处理立即数的阶段
    wire [4:0] iimm_shamt;
    wire [11:0] iimm, simm, bimm;
    wire [19:0] uimm, jimm;

    assign iimm_shamt=inst_in[24:20];
    assign iimm=inst_in[31:20];
    assign simm={inst_in[31:25], inst_in[11:7]};
    assign bimm={inst_in[31], inst_in[7], inst_in[30:25], inst_in[11:8]};
    assign uimm=inst_in[31:12];
    assign jimm={inst_in[31], inst_in[19:12], inst_in[20], inst_in[30:21]};

    // 输出的定义
    wire [31:0] immout_w;

    EXT U_EXT(
        // 输入
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), 
        // 输出
        .immout(immout_w)
    );

    // 处理信号的阶段
    // 输入的定义以及处理
    wire [6:0] Op;
    wire [6:0] Funct7;
    wire [2:0] Funct3;

    assign Op=inst_in[6:0];           
    assign Funct7=inst_in[31:25];     
    assign Funct3=inst_in[14:12];   
    assign rs1=inst_in[19:15];
    assign rs2=inst_in[24:20];
    assign rd_w=inst_in[11:7];

    // 输出的定义
    wire [4:0] rd_w;
    wire RegWrite_w;
    wire MemWrite_w;
    wire [5:0] EXTOp;
    wire [4:0] ALUOp_w;
    wire [2:0] NPCOp_w;
    wire ALUSrc;
    wire [1:0] GPRSel;
    wire [1:0] WDSel_w;
    wire [2:0] dm_ctrl_w;

    wire use_rs1, use_rs2;                              // 寄存器是否被使用

    ctrl U_ctrl(
        .Op(Op), .Funct7(Funct7), .Funct3(Funct3),
        .RegWrite(RegWrite_w), .MemWrite(MemWrite_w),
        .EXTOp(EXTOp), .ALUOp(ALUOp_w), .NPCOp(NPCOp_w), 
        .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel_w), .dm_ctrl(dm_ctrl_w),
        .use_rs1(use_rs1), .use_rs2(use_rs2)
    );

    wire Rs1Legal=use_rs1&(rs1!=5'b0);
    wire Rs2Legal=use_rs2&(rs2!=5'b0);
    wire type_l=ID_EX_WDSel[0];

    // 可以大致将冒险分为三类，其中一类与 ld 类型有关的冒险需要通过阻塞进行解决
    // 剩下的两类冒险分为 EX 冒险和 MEM 冒险，我们在下面进行了处理

    // 冒险的检测
    // 注意这里我们用到的 ID_EX_rd 为 EX_MEM 阶段的输入值，所以相当于书中的 EX_MEM_rd
    wire DataHazardA1=ID_EX_RegWrite&Rs1Legal&(ID_EX_rd==rs1);
    wire DataHazardA2=ID_EX_RegWrite&Rs2Legal&(ID_EX_rd==rs2);
    wire DataHazardB1=(!DataHazardA1)&EX_MEM_RegWrite&Rs1Legal&(EX_MEM_rd==rs1);    
    wire DataHazardB2=(!DataHazardA2)&EX_MEM_RegWrite&Rs2Legal&(EX_MEM_rd==rs2);    

    // 是否选择旁路
    wire ForwardA1=DataHazardA1&(~type_l);          // 排除 load 类型的指令
    wire ForwardA2=DataHazardA2&(~type_l);          // 排除 load 类型的指令
    wire ForwardB1=DataHazardB1;
    wire ForwardB2=DataHazardB2;

    // load 类型的指令进行一个周期的阻塞，阻塞一个周期后相当于 MEM 冒险
    assign stall=(~flush)&((DataHazardA1&type_l)|(DataHazardA2&type_l));

    // 考虑数据的来源，分为三种：EX/MEM 旁路，MEM/WB 旁路，以及原始数据，注意优先级的顺序
    wire [31:0] NewRD1, NewRD2;
    assign NewRD1=ForwardA1?EX_MEM_Forward_Data:(ForwardB1?MEM_WB_Forward_Data:RD1);
    assign NewRD2=ForwardA2?EX_MEM_Forward_Data:(ForwardB2?MEM_WB_Forward_Data:RD2);

    // 开始进行数据的选择

    always @(posedge clk, posedge rst) begin
        if (rst||flush) begin
            ALU_A<=32'b0;
            ALU_B<=32'b0;
            ALUOp<=5'b0;

            PC<=32'b0;
            immout<=32'b0;
            NPCOp<=3'b0;

            MemWrite<=1'b0;
            dm_ctrl<=3'b0;

            RegWrite<=1'b0;
            rd<=5'b0;
            WDSel<=2'b0;
        end
        else begin
            ALU_A<=NewRD1;
            ALU_B<=(ALUSrc)?immout_w:NewRD2;
            ALUOp<=ALUOp_w;

            PC<=PC_in;
            immout<=immout_w;
            NPCOp<=(stall)?3'b0:NPCOp_w;

            MemWrite<=(stall)?1'b0:MemWrite_w;
            dm_ctrl<=dm_ctrl_w;
            DataWrite<=NewRD2;

            RegWrite<=(stall)?1'b0:RegWrite_w;
            rd<=rd_w;
            WDSel<=WDSel_w;
        end
    end
endmodule
