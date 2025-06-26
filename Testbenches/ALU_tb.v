module ALU_tb();

// Define inputs and outputs for the ALU

reg [31:0] A, B;
reg [2:0] ALUControl;
wire [31:0] ALUResult;
wire Zero, signFlag;

// Instantiate the ALU module

ALU ALU_dut (
    .A(A),
    .B(B),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero),
    .signFlag(signFlag)
);

// Write used tasks for the testbench

task reset_inputs;
    begin
        A = 32'h00000000;
        B = 32'h00000000;
        ALUControl = 3'b000;
    end
endtask

integer error_count=0;

task validate_outputs();
    begin
        case(ALUControl)
            3'b000: begin // ADD
                if (ALUResult !== A + B) begin
                    $display("ADD failed: Expected %h, got %h", A + B, ALUResult);
                    error_count = error_count + 1;
                end
                if (Zero !== (ALUResult == 32'h00000000)) begin
                    $display("Zero flag failed for ADD");
                    error_count = error_count + 1;
                end
                if (signFlag !== ALUResult[31]) begin
                    $display("Sign flag failed for ADD");
                    error_count = error_count + 1;
                end
            end
            3'b001: begin // SLL
                if (ALUResult !== (A << B[4:0])) begin
                    $display("SLL failed: Expected %h, got %h", A << B[4:0], ALUResult);
                    error_count = error_count + 1;
                end
            end
            3'b010: begin // SUB
                if (ALUResult !== (A - B)) begin
                    $display("SUB failed: Expected %h, got %h", A - B, ALUResult);
                    error_count = error_count + 1;
                end
                if (Zero !== (ALUResult == 32'h00000000)) begin
                    $display("Zero flag failed for SUB");
                    error_count = error_count + 1;
                end
                if (signFlag !== ALUResult[31]) begin
                    $display("Sign flag failed for SUB");
                    error_count = error_count + 1;
                end
            end
            3'b011: begin // Output should be zero (unused operation)
                if (ALUResult !== 32'h00000000) begin
                    $display("ALUControl 011 failed: Expected 00000000, got %h", ALUResult);
                    error_count = error_count + 1;
                end
            end
            3'b100: begin // XOR
                if (ALUResult !== (A ^ B)) begin
                    $display("XOR failed: Expected %h, got %h", A ^ B, ALUResult);
                    error_count = error_count + 1;
                end
            end
            3'b101: begin // SRL
                if (ALUResult !== (A >> B[4:0])) begin
                    $display("SRL failed: Expected %h, got %h", A >> B[4:0], ALUResult);
                    error_count = error_count + 1;
                end
            end
            3'b110: begin // OR
                if (ALUResult !== (A | B)) begin
                    $display("OR failed: Expected %h, got %h", A | B, ALUResult);
                    error_count = error_count + 1;
                end
            end
            3'b111: begin // AND
                if (ALUResult !== (A & B)) begin
                    $display("AND failed: Expected %h, got %h", A & B, ALUResult);
                    error_count = error_count + 1;
                end
            end
            default: begin
                $display("Invalid ALUControl value");
                error_count = error_count + 1;
            end
        endcase
    end
endtask

// Begin testing

integer i;
initial begin
    
    // Test each operation using known values
    $display("Testing using known values...");
    
    for(i=0; i < 8; i = i + 1) begin
        reset_inputs();
        ALUControl = i[2:0];
        
        // Set test values for A and B
        A = 32'h00000001;
        B = 32'h00000002;

        // Wait for ALU to compute
        #10;

        // Validate outputs
        validate_outputs();
    end

    $display("Testing with known values completed with %d errors.", error_count);
    error_count = 0;

    // Test with random values
    $display("Testing with random values...");
    repeat(100) begin
        reset_inputs();
        
        // Generate random values for A and B
        A = $random;
        B = $random;
        
        // Randomly select ALUControl
        ALUControl = $random % 8;

        // Wait for ALU to compute
        #10;

        // Validate outputs
        validate_outputs();
    end
    $display("Testing with random values completed with %d errors.", error_count);
    
    // Finish testbench

    if (error_count == 0)
        $display("All tests passed successfully!");
    $stop;
end

endmodule
