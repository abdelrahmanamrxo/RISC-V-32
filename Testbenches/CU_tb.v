module CU_tb;
    // Inputs
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg funct7;
    reg zeroFlag;
    reg signFlag;

    // Outputs
    wire PCSrc;
    wire ResultSrc;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    wire [1:0] ImmSrc;
    wire [2:0] ALUControl;

    // Error counter
    integer error_count;

    // Instantiate the Control Unit
    CU uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zeroFlag(zeroFlag),
        .signFlag(signFlag),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    // Task to check and display results, increment error_count on mismatch
    task check;
        input [8*50:1] test_name;
        input exp_PCSrc, exp_ResultSrc, exp_MemWrite, exp_ALUSrc, exp_RegWrite;
        input [1:0] exp_ImmSrc;
        input [2:0] exp_ALUControl;
        reg mismatch;
        begin
            #1; // wait for outputs to settle
            mismatch = ((exp_PCSrc !== 1'bx) && (PCSrc !== exp_PCSrc)) || ((exp_ResultSrc !== 1'bx) && (ResultSrc !== exp_ResultSrc)) ||
                       ((exp_MemWrite !== 1'bx) && (MemWrite !== exp_MemWrite)) || ((exp_ALUSrc !== 1'bx) && (ALUSrc !== exp_ALUSrc)) ||
                       ((exp_RegWrite !== 1'bx) && (RegWrite !== exp_RegWrite)) || ((exp_ImmSrc !== 2'bxx) && (ImmSrc !== exp_ImmSrc)) ||
                       ((exp_ALUControl !== 3'bxxx) && (ALUControl !== exp_ALUControl));
            $display("%s: opcode=%b funct3=%b funct7=%b zero=%b sign=%b | PCSrc=%b (exp %b), ResultSrc=%b (exp %b), MemWrite=%b (exp %b), ALUSrc=%b (exp %b), RegWrite=%b (exp %b), ImmSrc=%b (exp %b), ALUControl=%b (exp %b) %s", 
                     test_name, opcode, funct3, funct7, zeroFlag, signFlag,
                     PCSrc, exp_PCSrc, ResultSrc, exp_ResultSrc, MemWrite, exp_MemWrite,
                     ALUSrc, exp_ALUSrc, RegWrite, exp_RegWrite,
                     ImmSrc, exp_ImmSrc, ALUControl, exp_ALUControl,
                     (mismatch ? "ERROR" : "OK"));
            if (mismatch) error_count = error_count + 1;
        end
    endtask

    initial begin
        error_count = 0;
        // LOAD Word (opcode 0000011)
        opcode = 7'b0000011; funct3 = 3'b000; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        check("LOAD", 0, 1, 0, 1, 1, 2'b00, 3'b000);

        // STORE Word (0100011)
        opcode = 7'b0100011; funct3 = 3'b000; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ResultSrc is don't-care for stores: use 'bx
        check("STORE", 0, 1'bx, 1, 1, 0, 2'b01, 3'b000);

        // R-Type: ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-ADD", 0, 0, 0, 0, 1, 2'bxx, 3'b000);

        // R-Type: SUB
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 1'b1; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-SUB", 0, 0, 0, 0, 1, 2'bxx, 3'b010);

        // R-Type: SHL
        opcode = 7'b0110011; funct3 = 3'b001; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-SHL", 0, 0, 0, 0, 1, 2'bxx, 3'b001);

        // R-Type: XOR
        opcode = 7'b0110011; funct3 = 3'b100; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-XOR", 0, 0, 0, 0, 1, 2'bxx, 3'b100);

        // R-Type: SHR
        opcode = 7'b0110011; funct3 = 3'b101; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-SHR", 0, 0, 0, 0, 1, 2'bxx, 3'b101);

        // R-Type: OR
        opcode = 7'b0110011; funct3 = 3'b110; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-OR", 0, 0, 0, 0, 1, 2'bxx, 3'b110);

        // R-Type: AND
        opcode = 7'b0110011; funct3 = 3'b111; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        // ImmSrc is don't-care for R-type
        check("R-AND", 0, 0, 0, 0, 1, 2'bxx, 3'b111);

        // I-Type (ADDI)
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 1'b0;
        check("I-ADDI", 0, 0, 0, 1, 1, 2'b00, 3'b000);

        // Branch BEQ taken
        opcode = 7'b1100011; funct3 = 3'b000; zeroFlag = 1; signFlag = 0;
        check("BEQ-TAKEN", 1, 0, 0, 0, 0, 2'b10, 3'b010);

        // Branch BEQ not taken
        zeroFlag = 0;
        check("BEQ-NOT", 0, 0, 0, 0, 0, 2'b10, 3'b010);

        // Branch BNE taken
        funct3 = 3'b001; zeroFlag = 0;
        check("BNE-TAKEN", 1, 0, 0, 0, 0, 2'b10, 3'b010);

        // Branch BLT taken
        funct3 = 3'b100; signFlag = 1;
        check("BLT-TAKEN", 1, 0, 0, 0, 0, 2'b10, 3'b010);

        // Default case
        opcode = 7'b1111111; funct3 = 3'b000; funct7 = 1'b0; zeroFlag = 0; signFlag = 0;
        check("DEFAULT", 0, 0, 0, 0, 0, 2'b00, 3'b000);

        if (error_count == 0)
            $display("\nNo errors have occurred, testing completed successfully!");
        else
            $display("\nTotal errors: %0d", error_count);
        $stop;
    end
endmodule
