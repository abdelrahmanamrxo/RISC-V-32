module ROM_tb;

// Define inputs and outputs for the ROM
reg [31:0] address;
wire [31:0] instruction;

// Instantiate the ROM module
ROM ROM_dut (
    .address(address),
    .instruction(instruction)
);

// Start testing
integer i;
integer error_count = 0;

initial begin
    for (i = 0; i < 21; i = i + 1) begin
        address = i; // Set the address to read
        #10; // Wait for a short time to allow the instruction to be read
        if (instruction !== ROM_dut.memory[i]) begin
            $display("Error at address %0d: Expected %h, got %h", i, ROM_dut.memory[i], instruction);
            error_count = error_count + 1;
        end else begin
            $display("Address %0d: Instruction %h", i, instruction);
        end
    end

    if (error_count == 0) begin
        $display("All tests passed successfully!");
    end else begin
        $display("Total errors: %d", error_count);
    end
end
endmodule