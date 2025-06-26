module RAM(
    input clk, writeEnable,
    input [31:0] address, writeData,
    output reg [31:0] readData
);

    // Define the 64 entry memory array
    reg [31:0] memory [0:63]; 

    // Define the sequential behavior for writing to memory
    always @(posedge clk) begin
        if (writeEnable) begin
            memory[address[31:2]] <= writeData; // Write data to the specified word address
        end
    end

    // Define the combinational behavior for reading from memory
    always @(*) begin
        readData = memory[address[31:2]]; // Read data from the specified word address
    end

endmodule