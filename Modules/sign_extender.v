module sign_extender(
    input [31:0] instruction,
    input [1:0] ImmSrc,
    output reg [31:0] ImmExt
);

    always @(*) begin
        case (ImmSrc)
            2'b00: 
                ImmExt = {{20{instruction[31]}}, instruction[31:20]}; // I-type
            2'b01: 
                ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-type
            2'b10: 
                ImmExt = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B-type
            default: 
                ImmExt = 32'b0; // Default case, no extension
        endcase
    end

endmodule
