module RF(
    input clk, areset, writeEnable,
    input [4:0] readReg1, readReg2, writeReg,
    input [31:0] writeData,
    output reg [31:0] readData1, readData2
);

// Define the 32*32 register file
reg [31:0] registers [0:31];

// Reset and Writing Logic (synchronous)
integer i;

always @(posedge clk or negedge areset) begin
    if (!areset) begin
        // Reset all registers to 0
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'h00000000;
        end
    end else if (writeEnable) begin
        // Write data to the specified register (including register 0)
        registers[writeReg] <= writeData;
    end
end

// Asynchronous Read Logic
always @(*) begin
    readData1 = registers[readReg1];
    readData2 = registers[readReg2];
end

endmodule