module ROM(
    input [31:0] address,
    output reg [31:0] instruction
);

// Define the 64 entry memory array
reg [31:0] memory [0:63]; 

// Initialize the memory with some test instructions
initial begin
    $readmemh("program.txt", memory); // Load instructions from a file
end

// Define the combinational behavior for reading from memory
always @(*) begin
    instruction = memory[address]; 
end

endmodule