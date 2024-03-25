

module shk_lfsr(
  input wire                  clk,
  input wire                  rst_n,
  input wire                  s_shk,                                                      // start trigger
  input wire    [15:0]        curr_lfsr,
  output reg                  shk_end,
  output reg    [15:0]        shk_lfsr
);

  localparam                  LP_RAM_DATA_RESERVED          = 26'd0;

  logic                       lt_trg;
  logic         [15:0]        shk_timer;
  logic                       not_allzero;

// latch trigger until shaking end.
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              lt_trg                        <= 1'b0;
    else  if(not_allzero)
                              lt_trg                        <= 1'b0;
    else  if(s_shk)
                              lt_trg                        <= 1'b1;
  end

// 
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              shk_timer                     <= 16'd0;
    else
                              shk_timer                     <= shk_timer + 16'd1;
  end

// 
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              shk_lfsr                      <= 16'd0;
    else if(not_allzero)
                              shk_lfsr                      <= curr_lfsr ^ shk_timer;
    else
                              shk_lfsr                      <= shk_lfsr;

  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              shk_end                       <= 1'b0;
    else if(s_shk && not_allzero)
                              shk_end                       <= 1'b1;
    else
                              shk_end                       <= 1'b0;
  end
  
  assign                      not_allzero                   = |(shk_lfsr ^ shk_timer);

endmodule