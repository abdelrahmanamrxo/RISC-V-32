module RISC_32(
    input clk, global_reset
);

    // Define the internal signals

    wire [31:0] instruction;
    wire [31:0] PC;
    wire load, PCsrc;
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire funct7;
    wire zeroFlag, signFlag;
    wire ResultSrc, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ImmSrc;
    wire [2:0] ALUControl;
    wire [31:0] SrcA, SrcB, ImmExt, readData1, readData2, ALUResult, RAM_Data, result; 

    // Assignments for the internal signals

    assign result = (ResultSrc) ? RAM_Data : ALUResult; // Select result based on ResultSrc
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[30];
    assign load = ~(instruction == 0); // Load PC only if instruction is not zero
    assign SrcA = readData1;
    assign SrcB = (ALUSrc) ? ImmExt : readData2; // Use immediate value if ALUSrc is set

    // Instantiate the PC
    PC pc_inst (
        .clk(clk),
        .areset(global_reset),
        .load(load),
        .PCsrc(PCsrc),
        .target(ImmExt),
        .PC(PC)
    );

    // Instantiate the instruction memory
    ROM instruction_memory (
        .address(PC),
        .instruction(instruction)
    );

    // Instantiate the Control Unit
    CU control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zeroFlag(zeroFlag),
        .signFlag(signFlag),
        .PCSrc(PCsrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    // Instantiate the ALU
    ALU alu_inst (
        .ALUControl(ALUControl),
        .A(SrcA),
        .B(SrcB),
        .zeroFlag(zeroFlag),
        .signFlag(signFlag),
        .ALUResult(ALUResult)
    );

    // Instantiate the sign extender
    sign_extender sign_extender_inst (
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    // Instantiate the RAM for data memory
    RAM data_memory (
        .clk(clk),
        .writeEnable(MemWrite),
        .address(ALUResult),
        .writeData(readData2),
        .readData(RAM_Data)
    );


    // Instantiate the register file
    RF reg_file (
        .readData1(readData1),
        .readData2(readData2),
        .clk(clk),
        .areset(global_reset),
        .writeEnable(RegWrite),
        .readReg1(instruction[19:15]), // rs1
        .readReg2(instruction[24:20]), // rs2
        .writeReg(instruction[11:7]),  // rd
        .writeData(result)
    );


endmodule