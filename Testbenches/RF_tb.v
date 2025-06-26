module RF_tb;

// Define inputs and outputs for the RF
reg clk, areset, writeEnable;
reg [4:0] readReg1, readReg2, writeReg;
reg [31:0] writeData;
wire [31:0] readData1, readData2;

// Instantiate the RF module
RF RF_dut (
    .clk(clk),
    .areset(areset),
    .writeEnable(writeEnable),
    .readReg1(readReg1),
    .readReg2(readReg2),
    .writeReg(writeReg),
    .writeData(writeData),
    .readData1(readData1),
    .readData2(readData2)
);

// Define clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock period of 10 time units
end

// Define local memory for testing
reg [31:0] local_memory [0:31];
// Initialize local memory
initial begin
    $readmemh("RF_memory.txt", local_memory);
end

// Begin testing
integer error_count = 0;
integer i;

initial begin
    // Reset the RF
    @(negedge clk);
    areset = 0;
    writeEnable = 0;
    readReg1 = 5'd0;
    readReg2 = 5'd0;
    writeReg = 5'd0;
    writeData = 32'h00000000;

    // Test reset functionality
    @(negedge clk);
    areset = 1; // Deassert reset
    for (i = 0; i < 31; i = i + 1) begin
        readReg1 = i; 
        readReg2 = i+1;
        #10; // Wait for a short time to allow the read operation
        if(readData1 !== 32'h00000000 || readData2 !== 32'h00000000) begin
            $display("Error: Read data not zero after reset at readReg1=%d, readReg2=%d", readReg1, readReg2);
            error_count = error_count + 1;
        end
    end
    
    // Test writing to registers
    @(negedge clk);
    writeEnable = 1; // Enable writing
    for (i = 0; i < 32; i = i + 1) begin
        @(negedge clk);
        writeReg = i; // Select register to write
        writeData = local_memory[i]; // Use local memory for data
        @(negedge clk);
        if (RF_dut.registers[i] !== writeData) begin
            $display("Error: Write failed at register %d, expected %h, got %h", writeReg, writeData, RF_dut.registers[i]);
            error_count = error_count + 1;
        end
    end

    // Test reading from registers
    @(negedge clk);
    writeEnable = 0; // Disable writing
    for (i = 0; i < 31; i = i + 1) begin
        @(negedge clk);
        readReg1 = i; // Select register to read
        readReg2 = i + 1; // Read next register
        @(negedge clk);
        if (readData1 !== local_memory[i] || readData2 !== local_memory[i + 1]) begin
            $display("Error: Read failed at readReg1=%d, expected %h, got %h; readReg2=%d, expected %h, got %h", 
                     readReg1, local_memory[i], readData1, readReg2, local_memory[i + 1], readData2);
            error_count = error_count + 1;
        end
    end

    // Final report
    if (error_count == 0) begin
        $display("All tests passed successfully!");
    end else begin
        $display("Total errors: %d", error_count);
    end

    $stop; // Stop the simulation

end

endmodule