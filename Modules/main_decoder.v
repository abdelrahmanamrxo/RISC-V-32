module main_decoder(
    input [6:0] opcode,
    output reg branch, ResultSrc, MemWrite, ALUSrc, RegWrite,
    output reg [1:0] ALUOp, ImmSrc
);

    always @(*) begin
        case(opcode)
            // Load Word 
            7'b000_0011: begin
                RegWrite=1;
                ImmSrc=2'b00;
                ALUSrc=1;
                MemWrite=0;
                ResultSrc=1;
                branch=0;
                ALUOp=2'b00; 
            end

            // Store Word
            7'b010_0011: begin
                RegWrite=0;
                ImmSrc=2'b01;
                ALUSrc=1;
                MemWrite=1;
                //ResultSrc=0; // don't care
                branch=0;
                ALUOp=2'b00; 
            end

            // R-type instructions
            7'b011_0011: begin
                RegWrite=1;
                //ImmSrc=2'b00; // don't care
                ALUSrc=0;
                MemWrite=0;
                ResultSrc=0;
                branch=0;
                ALUOp=2'b10; 
            end

            // Immediate instructions
            7'b001_0011: begin
                RegWrite=1;
                ImmSrc=2'b00;
                ALUSrc=1;
                MemWrite=0;
                ResultSrc=0;
                branch=0;
                ALUOp=2'b10; 
            end

            // branch instructions
            7'b1100011: begin
                RegWrite=0;
                ImmSrc=2'b10;
                ALUSrc=0;
                MemWrite=0;
                //ResultSrc=0; // don't care
                branch=1;
                ALUOp=2'b01; 
            end

            // Default case
            default: begin
                RegWrite=0;
                ImmSrc=2'b00;
                ALUSrc=0;
                MemWrite=0;
                ResultSrc=0;
                branch=0;
                ALUOp=2'b00; 
            end
        endcase
    end
endmodule