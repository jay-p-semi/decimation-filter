module half_band_filter #(
    parameter NUM_TAPS = 15,
    parameter TAP_SIZE = 16,
    parameter logic signed [TAP_SIZE-1:0] TAPS [(NUM_TAPS+1)/4] = '{-109, 1127, -4523, 19889}, 
    parameter logic signed [TAP_SIZE-1:0] C_TAP = 32768,
    parameter BIT_IN_WIDTH = 25,
    parameter REG_WIDTH = BIT_IN_WIDTH + TAP_SIZE + $clog2((NUM_TAPS+1)/4)
) (
    input wire clk,
    input wire rst_n,
    input wire signed [BIT_IN_WIDTH-1:0] data_in, //24:0
    input wire en,
    output wire [BIT_IN_WIDTH:0] data_out //25:0
);

logic signed [BIT_IN_WIDTH-1:0] mem [NUM_TAPS]; //24:0 * 15
logic signed [BIT_IN_WIDTH:0] p_sum;  // 25:0 26 bits
logic signed [BIT_IN_WIDTH + TAP_SIZE : 0] p_result; //41:0 42 bits
logic signed [REG_WIDTH : 0] sum; //43:0 44 bits

int j;

always_ff @( posedge clk ) begin : storage
    if(!rst_n) begin
        for (j = 0; j < NUM_TAPS ; j++ ) begin
            mem[j] <= {BIT_IN_WIDTH{1'b0}};
        end
    end
    else begin
        mem[0] <= data_in;
        for (j = 1; j < NUM_TAPS ; j++ ) begin
            mem[j] <= mem[j-1];
        end
    end
end

always_comb begin : combinational_block
    sum = 0;
    for(j = 0; j < (NUM_TAPS+1)/4; j++) begin
        p_sum = mem[j*2] + mem[NUM_TAPS-1-2*j];
        p_result = TAPS[j]*p_sum;
        sum = sum + p_result;
    end
    sum = sum + C_TAP*mem[(NUM_TAPS)/2];
end

assign data_out = sum >>> (TAP_SIZE - 1); // 44 >>> 15 = 29
    
endmodule