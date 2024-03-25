//
// Range checker
//
module rng_chk #(
  parameter                   GP_RANGE_MIN                  = 0,
  parameter                   GP_RANGE_MAX                  = 0,
  parameter                   GP_OUTPUT_VALUE               = 0

)(
  input wire                                                clk,
  input wire                                                rst_n,
  input wire    [$clog2(GP_RANGE_MAX+1) - 1:0]              in,
  input wire                                                ien,
  output reg    [$clog2(GP_OUTPUT_VALUE+1) - 1:0]           out,
  output reg                                                oen,
);

  logic                       rin;                                                        // range in
  assign                      rin                           = (GP_RANGE_MIN <= in) && 
                                                              (in <= GP_RANGE_MAX);

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              out                           <= '0;
    else if(ien && rin)
                              out                           <= GP_OUTPUT_VALUE;
    else
                              out                           <= out;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              oen                           <= 1'b0;
    else if(rin)
                              oen                           <= 1'b1;
    else
                              oen                           <= 1'b0;
  end

endmodule