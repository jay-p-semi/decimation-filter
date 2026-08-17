module decimation #(
    parameter ORDER = 4,
    parameter D_RATIO = 64,
    parameter D_DELAY = 1,
    parameter BIT_IN_WIDTH = 1,
    parameter REG_WIDTH = BIT_IN_WIDTH + ORDER*$clog2(D_DELAY*D_RATIO);
) (
    input wire clk,
    input wire rst_n,
    input wire [BIT_IN_WIDTH - 1 : 0] data_in,
    input wire valid_in,
    output reg [REG_WIDTH -1 : 0] data_out,
    output reg valid_out
); 
    generate
        genvar i = 0;
        for ( i = 0; i < ORDER ; i++) begin
            
        end
    endgenerate

endmodule