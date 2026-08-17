module cic_filter #(
    parameter ORDER = 4,
    parameter D_RATIO = 64,
    parameter D_DELAY = 1,
    parameter BIT_IN_WIDTH = 1,
    parameter BIT_DROP = 5,
    parameter REG_WIDTH = BIT_IN_WIDTH + ORDER*$clog2(D_DELAY*D_RATIO)
) (
    input wire clk_f,
    input wire clk_s,
    input wire rst_n,
    input wire [BIT_IN_WIDTH - 1 : 0] data_in,
    input wire en,
    output wire signed [REG_WIDTH -1 : 0] data_out,
    // output reg valid_out
);

    logic signed [REG_WIDTH - 1: 0] int_out [ORDER];
    logic signed [REG_WIDTH - 1: 0] comb_out [ORDER];
    logic signed [REG_WIDTH - 1: 0] comb_delay [ORDER][D_DELAY];
    logic signed [REG_WIDTH - 1: 0] int_last;

    genvar i, j;
    // integrators 
    generate
        for (i = 0; i < ORDER; i++ ) begin
            always_ff @( posedge clk_f ) begin : integrators
                if(!rst_n) begin
                    int_out[i] <= {REG_WIDTH{1'b0}};
                end
                else begin
                    if(en) begin
                        if(i == 0)
                            int_out[i] <= $signed(int_out[i]) + $signed(data_in);
                        else
                            int_out[i] <= $signed(int_out[i]) + $signed(int_out[i - 1]);
                    end
                end
            end : integrators
        end
    endgenerate

    assign int_last = int_out[ORDER - 1];

    // comb
    generate
        for (i = 0; i < ORDER ; i++ ) begin
            always_ff @( posedge clk_s ) begin : comb
                if(!rst_n) begin
                    comb_out[i] <= {REG_WIDTH{1'b0}};
                    for (j = 0; j < D_DELAY; j++) begin
                        comb_delay[i][j] <= {REG_WIDTH{1'b0}};
                    end
                end
                else begin
                    if (en) begin
                        for (j = 1; j < D_DELAY ; j++ ) begin
                            comb_delay[i][j] <= comb_delay[i][j-1];
                        end
                        if(i == 0) begin
                            comb_delay[i][0] <= $signed(int_last);
                            comb_out[i] <= $signed(int_last) - $signed(comb_delay[i][D_DELAY - 1]);
                        end
                        else begin
                            comb_delay[i][0] <= $signed(comb_out[i-1]);
                            comb_out[i] <= $signed(comb_out[i - 1]) - $signed(comb_delay[i][D_DELAY - 1]);
                        end
                    end
                end
            end : comb
        end
    endgenerate

    assign data_out = comb_out[ORDER - 1];
endmodule