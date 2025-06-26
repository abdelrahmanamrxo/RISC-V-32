module RAM_tb;

// Declare inputs and outputs
reg clk;
reg writeEnable;
reg [31:0] address;
reg [31:0] writeData;
wire [31:0] readData;

// Instantiate the RAM module
RAM RAM_DUT (
    .clk(clk),
    .writeEnable(writeEnable),
    .address(address),
    .writeData(writeData),
    .readData(readData)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // Toggle clock every 5 time units
end

// Define local memory for testing
reg [31:0] local_memory [0:63];
initial begin
    $readmemh("test_data.txt", local_memory); // Load test data from a file
end
// Begin testing

integer i;
integer error_count=0;

initial begin
    // Write to the RAM
    writeEnable = 1;
    for (i = 0; i < 64; i = i + 1) begin
        @(negedge clk); 
        address = i;
        writeData = local_memory[i];
        @(negedge clk); 
        if (RAM_DUT.memory[i] !== local_memory[i]) begin
            $display("Error: Write failed at address %d. Expected %h, got %h", i, local_memory[i], RAM_DUT.memory[i]);
            error_count = error_count + 1;
        end else begin
            $display("Write successful at address %d: %h", i, local_memory[i]);
        end
    end

    // Read from the RAM
    writeEnable = 0;
    for (i = 0; i < 64; i = i + 1) begin
        @(negedge clk); 
        address = i;
        @(negedge clk); 
        if (readData !== local_memory[i]) begin
            $display("Error: Read failed at address %d. Expected %h, got %h", i, local_memory[i], readData);
            error_count = error_count + 1;
        end else begin
            $display("Read successful at address %d: %h", i, readData);
        end
    end

    // Final report
    if (error_count == 0) begin
        $display("All tests passed successfully!");
    end else begin
        $display("Total errors: %d", error_count);
    end

    $stop;
end

endmodule