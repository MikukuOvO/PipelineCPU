/*
    This module implements the NPC unit
*/
module NPC(
    input [31:0] PC,
    input [2:0] NPCOp,
    input [31:0] IMM,
    input [31:0] aluout,
    output reg [31:0] NPC
);
    always @(*) begin
        case (NPCOp)
            `NPC_BRANCH: NPC = PC + IMM;
            `NPC_JUMP:   NPC = PC + IMM;
            `NPC_JALR:   NPC = aluout;
        endcase
    end
endmodule