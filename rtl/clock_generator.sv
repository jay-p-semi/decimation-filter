module clock_generator #(
    parameter STAGES = 3,
    parameter RATIOS [STAGES] = '{64, 4, 2};
) (
    input wire clk,
    input wire rst_n,
    output reg clk_out[STAGES]
);

    generate
        genvar i;
        for(i =0 ; i< STAGES; i++) begin
            logic [$clog2(RATIOS[i]/2)-1:0] counter;
            always_ff @( posedge clk ) begin : clk_div
                if(!rst_n) begin
                    clk_out[i] <= 1'b0;
                    counter <= '0;
                end
                else begin
                    counter <= counter + 1;
                    if (counter == 0) begin
                        clk_out[i] <= ~clk_out[i];
                    end
                end                
            end
        end
    endgenerate
endmodule