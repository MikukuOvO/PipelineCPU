module NPC(                  // next pc module
    input  [31:0] PC,        // pc
    input  [2:0]  NPCOp,     // next pc operation
    input  [31:0] IMM,       // immediate
    input  [31:0] aluout,
    output reg [31:0] NPC    // next pc
);
    always @(*) begin
        case (NPCOp)
            `NPC_BRANCH: NPC = PC+IMM;
            `NPC_JUMP:   NPC = PC+IMM;
            `NPC_JALR:   NPC = aluout;
        endcase
    end
endmodule