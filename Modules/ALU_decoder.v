module ALU_decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7,
    input opcode_5,
    output reg [2:0] ALUControl
);

    // Create an intermediate signal to combine funct7 and opcode_5
    wire [1:0] intermediate_control;
    assign intermediate_control = {opcode_5, funct7};

    // Control logic for ALU operations
    always @(*) begin
        case(ALUOp)
            
            // Load/Store operations
            2'b00: begin
                ALUControl = 3'b000; 
            end

            // Branch operations
            2'b01: begin
                case(funct3)
                    3'b000: ALUControl = 3'b010; // BEQ
                    3'b001: ALUControl = 3'b010; // BNQ
                    3'b100: ALUControl = 3'b010; // BLT
                    default: ALUControl = 3'b000; // Default case
                endcase
            end

            // Other R-Type/Immediate operations
            2'b10: begin
                case(funct3)
                    // Add/Subtract operations
                    3'b000: begin
                        if (intermediate_control == 2'b11) begin
                            ALUControl = 3'b010; // SUB
                        end else begin
                            ALUControl = 3'b000; // ADD
                        end
                    end

                    // Rest of the ALU operations
                    3'b001: ALUControl = 3'b001; // SLL
                    3'b100: ALUControl = 3'b100; // XOR 
                    3'b101: ALUControl = 3'b101; // SRL
                    3'b110: ALUControl = 3'b110; // OR
                    3'b111: ALUControl = 3'b111; // AND

                    // Default case for unsupported funct3
                    default: begin
                        ALUControl = 3'b000; // Default case
                    end
                endcase
            end
        endcase
    end
endmodule