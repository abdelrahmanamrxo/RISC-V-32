module PC_tb;

// Define inputs and outputs for the PC
reg clk, areset, load, PCsrc;
reg signed [31:0] target;
wire [31:0] PC;

// Instantiate the PC module
PC PC_dut (
    .clk(clk),
    .areset(areset),
    .load(load),
    .PCsrc(PCsrc),
    .target(target),
    .PC(PC)
);

// Define clock generation

initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock period of 10 time units
end

// Write used tasks for the testbench
integer error_count = 0;
integer previous_PC;
task validate_outputs;
    begin
        if (!areset) begin
            if (PC !== 32'h00000000) begin
                $display("[%0t] Reset failed: Expected PC = 0, got %h", $time, PC);
                error_count = error_count + 1;
            end
        end else if (load) begin
            if (PCsrc) begin
                if (PC !== $signed(previous_PC) + target) begin
                    $display("[%0t] Load with PCsrc failed: Expected PC = %h, got %h", $time, $signed(previous_PC) + target, PC);
                    error_count = error_count + 1;
                end
            end else begin
                if (PC !== previous_PC + 4) begin // Assuming initial PC was 0 and incremented by 4
                    $display("[%0t] Load without PCsrc failed: Expected PC = %h, got %h", $time, previous_PC + 4, PC);
                    error_count = error_count + 1;
                end
            end
        end else begin
            if (PC !== previous_PC) begin // If not loading, PC should remain the same
                $display("[%0t] No load failed: Expected PC to remain the same, got %h", $time, PC);
                error_count = error_count + 1;
            end
        end
    end
endtask

// Write the test sequence

initial begin
   
    // Reset module
    @(negedge clk);
    areset = 0;
    load = 0;
    PCsrc = 0;
    target = 16; // Set positive target

    @(negedge clk);
    previous_PC = PC; // Store initial PC value
    areset = 1; 
    load = 1;
    PCsrc = 0;

    @(negedge clk);
    validate_outputs(); // Validate outputs after reset
    previous_PC = PC; // Update previous PC

    @(negedge clk);
    validate_outputs(); // Validate outputs after first load
    previous_PC = PC; // Update previous PC 

    @(negedge clk);
    validate_outputs(); // Validate outputs after second load
    previous_PC = PC; // Update previous PC 

    @(negedge clk);
    validate_outputs(); // Validate outputs after second load
    previous_PC = PC; // Update previous PC 

    @(negedge clk);
    load = 0; // Stop loading
    previous_PC = PC; // Update previous PC

    @(negedge clk);
    validate_outputs(); // Validate outputs after stopping load
    previous_PC = PC; // Update previous PC

    @(negedge clk);
    validate_outputs(); // Validate outputs after starting load with PCsrc
    previous_PC = PC; // Update previous PC
    load =1; // Start loading again
    PCsrc = 1; // Set PCsrc to true
    

    @(negedge clk);
    validate_outputs(); // Validate outputs after loading with negative target
    previous_PC = PC; // Update previous PC

    if (error_count == 0) begin
        $display("All tests passed successfully!");
    end else begin
        $display("Test completed with %d errors.", error_count);
    end

    $stop; // Stop the simulation
end

endmodule