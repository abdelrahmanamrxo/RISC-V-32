module PC(
    input clk, areset, load, PCsrc,
    input signed [31:0] target,
    output reg [31:0] PC
);

    // PC Update Logic (combinational portion)

    reg [31:0] nextPC;

    always @(*) begin
        if (PCsrc) begin
            nextPC = $signed(PC) + target; // Use target address if PCsrc is high
        end else begin
            nextPC = PC + 4; // Increment PC by 4 for sequential execution
        end
    end


    // Main PC Register (sequential portion)

    always @(posedge clk or negedge areset) begin
        if (!areset) begin
            PC <= 32'h00000000; // Reset PC to 0 (active low)
        end else if (load) begin
            PC <= nextPC; // Load next PC value
        end else begin
            PC <= PC; // Keep current PC value in case of a halt (no load)
        end
    end

endmodule