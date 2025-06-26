module ALU(
    input [31:0] A, B,
    input [2:0] ALUControl,
    output reg [31:0] ALUResult,
    output reg zeroFlag, signFlag
);

    // Notice that the 011 operation is unused in this ALU design, so it will return zero.
    
    always @(*) begin
        case (ALUControl)
            3'b000: ALUResult = A + B;
            3'b001: ALUResult = A << B[4:0]; // Set a limit on shift amount to prevent undefined behavior
            3'b010: ALUResult = A - B;
            3'b100: ALUResult = A ^ B;
            3'b101: ALUResult = A >> B[4:0]; // Set a limit on shift amount to prevent undefined behavior
            3'b110: ALUResult = A | B;
            3'b111: ALUResult = A & B;
            default: ALUResult = 32'h00000000;
        endcase
        
        zeroFlag = (ALUResult == 32'h00000000);
        signFlag = ALUResult[31];
    end
endmodule