/*
    This module implements the PC unit
*/
module PC(
    input clk,
    input rst,
    input stall,
    input [2:0] NPCOP,
    input [31:0] NPC,
    output reg [31:0] PC
);

    wire [31:0] PCPLUS4;
    assign PCPLUS4 = PC + 4; // For normal instruction execution with no jump, we will put PC + 4

    always @(posedge clk, posedge rst)
        if (rst)
            PC <= 32'h0000_0000; // Reset the PC
        else begin
            if (stall == 1) PC <= PC;
            else if (NPCOP != 3'b000) PC <= NPC;
            else PC <= PCPLUS4;
        end
endmodule