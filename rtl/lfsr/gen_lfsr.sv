

module gen_lfsr #(
  parameter                   GP_LFSR_SEED                  = 16'd1
)(
  input wire                  clk,
  input wire                  rst_n,
  input wire                  gen_en,                                                      // start trigger
  input wire    [15:0]        rgen_lfsr,
  input wire                  rgen_en,
  output reg    [15:0]        lfsr
);

  logic                       c;

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              lfsr                          <= GP_LFSR_SEED;
    else if(rgen_en)
                              lfsr                          <= rgen_lfsr;
    else if(gen_en)
                              lfsr                          <= {lfsr[14:0], c} ;
    else
                              lfsr                          <= lfsr;
  end

  assign                      c                             = lfsr[15] ^ lfsr[13] ^
                                                              lfsr[12] ^ lfsr[ 3] ;   

endmodule