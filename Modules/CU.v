module CU(
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7, zeroFlag, signFlag,
    output reg PCSrc,
    output wire ResultSrc, MemWrite, ALUSrc, RegWrite,
    output wire [1:0] ImmSrc, 
    output wire [2:0] ALUControl
);

    // Internal signals
    wire branch;
    wire [1:0] ALUOp;
    
    // Instantiate the main decoder
    main_decoder main_dec (
        .opcode(opcode),
        .branch(branch),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc)
    );

    // Define branch control logic
    always @(*) begin
        if (branch) begin
            case (funct3)
                3'b000: PCSrc = zeroFlag; // BEQ
                3'b001: PCSrc = ~zeroFlag; // BNE
                3'b100: PCSrc = signFlag; // BLT
                default: PCSrc = 0; // Default case, no branch taken
            endcase
        end else begin
            PCSrc = 0; // No branch if not a branch instruction
        end
    end

    // Instantiate the ALU decoder
    ALU_decoder alu_dec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .opcode_5(opcode[5]),
        .ALUControl(ALUControl)
    );

endmodule