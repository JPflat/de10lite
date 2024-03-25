module lfgm_ctrl (
  input wire                  clk,
  input wire                  rst_n,
  input wire                  start_trg,
  input wire                  rgen_trg,
  output reg    [4:0]         state_cnt,
  output reg    [23:0]        gnrt_cnt,
  output reg                  rgen_en,

  output reg    [5:0]         adr,
  output reg                  wr_en,
  output reg                  rd_en,
  output reg                  wcf,                                                        // wall or cell flag
  output reg                  ram_face                                                    // 
);



  localparam                  LP_WAIT                       = 5'd17;
  localparam                  LP_PRE_READ_1                 = 5'd0;
//  localparam                  LP_PRE_READ_2                 = 5'd1;
  localparam                  LP_READ                       = 5'd1;
  localparam                  LP_SHIFTIN_AND_START_JDG      = 5'd5;
  localparam                  LP_CHK_UPPERLEFT              = 5'd6;
  localparam                  LP_CHK_UPPER                  = 5'd7;
  localparam                  LP_CHK_UPPERRIGHT             = 5'd8;
  localparam                  LP_CHK_LEFT                   = 5'd9;
  localparam                  LP_CHK_RIGHT                  = 5'd10;
  localparam                  LP_CHK_LOWERLEFT              = 5'd11;
  localparam                  LP_CHK_LOWER                  = 5'd12;
  localparam                  LP_CHK_LOWERRIGHT             = 5'd13;
  localparam                  LP_JDG_LIFE_OR_DEATH          = 5'd14;
  localparam                  LP_DLT                        = 5'd15;                      // latch 80bit cell data
  localparam                  LP_WRITE                      = 5'd16;

  logic         [1:0]         trg_sft;
  logic         [6:0]         trg_cnt;
  logic                       start_next_gen;

  logic         [5:0]         wr_adr;
  logic         [5:0]         rd_adr;

  logic                       lt_rgen_trg;

/* ---------------------------------------------------------------------------------------
 start trigger control
--------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              trg_sft                       <= 2'b00;
    else
                              trg_sft                       <= {trg_sft[0], start_trg};
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              trg_cnt                       <= 7'd0;
    else if(trg_sft[1] && ~trg_sft[0])
     if(trg_cnt == 7'd5)
      // if(trg_cnt == 7'd0)
                              trg_cnt                       <= 7'd0;
      else
                              trg_cnt                       <= trg_cnt + 7'd1;
    else
                              trg_cnt                       <= trg_cnt;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              gnrt_cnt                      <= 24'd0;
    else if(trg_sft[1] && ~trg_sft[0])
     if(trg_cnt == 7'd5)
                              gnrt_cnt                       <= gnrt_cnt + 24'd1;
    else
                              gnrt_cnt                       <= gnrt_cnt;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              start_next_gen                <= 1'b0;
    else if(trg_sft[1] && ~trg_sft[0])
     if(trg_cnt == 7'd5)
      // if(trg_cnt == 7'd0)
                              start_next_gen                <= 1'b1;
      else
                              start_next_gen                <= 1'b0;
    else
                              start_next_gen                <= 1'b0;
  end

/* ---------------------------------------------------------------------------------------
 state machine
--------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              state_cnt                     <= LP_WAIT;
    else if(start_next_gen)
                              state_cnt                     <= LP_PRE_READ_1;
    else if(state_cnt == LP_WAIT)
      if(wr_adr >= 6'd62)
                              state_cnt                     <= LP_WAIT;
      else
                              state_cnt                     <= LP_READ;
    else
                              state_cnt                     <= state_cnt + 4'd1;
  end

/* ---------------------------------------------------------------------------------------
 re generate
--------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              lt_rgen_trg                   <= 1'b0;
    else if(rgen_trg)
                              lt_rgen_trg                   <= 1'b1;
    else if(start_next_gen)
                              lt_rgen_trg                   <= 1'b0;
    else
                              lt_rgen_trg                   <= lt_rgen_trg;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              rgen_en                       <= 1'b0;
    else if(start_next_gen)
      if(lt_rgen_trg)
                              rgen_en                       <= 1'b1;
      else
                              rgen_en                       <= 1'b0;
    else
                              rgen_en                       <= rgen_en;
  end

/* ---------------------------------------------------------------------------------------
 RAM read count
   0, 61: wall data
   other: cell data
--------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              wr_adr                       <= 6'd63;
    else if(start_next_gen)
                              wr_adr                       <= 6'd0;
    else if(wr_adr >= 6'd62)
                              wr_adr                       <= wr_adr;
    else if(wr_en)
                              wr_adr                       <= wr_adr + 6'd1;
    else
                              wr_adr                       <= wr_adr;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              rd_adr                        <= 6'd63;
    else if(start_next_gen)
                              rd_adr                        <= 6'd0;
    else if(rd_adr >= 6'd62)
                              rd_adr                        <= rd_adr;
    else if(rd_en)
                              rd_adr                        <= rd_adr + 6'd1;
    else
                              rd_adr                        <= rd_adr;
  end

  always_comb begin
    if(state_cnt == LP_WRITE)
                              adr                           = wr_adr;
    else
                              adr                           = rd_adr;
  end


  always_comb begin
    if(state_cnt == LP_WRITE)
                              wr_en                         <= 1'b1;
    else
                              wr_en                         <= 1'b0;
  end

  always_comb begin
    if((state_cnt == LP_PRE_READ_1) || (state_cnt == LP_READ))
                              rd_en                         <= 1'b1;
    else
                              rd_en                         <= 1'b0;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              wcf                           <= 1'b0;
    else if(start_next_gen)
                              wcf                           <= 1'b0;
    else if((state_cnt == LP_WRITE) && (wr_adr == 6'd60))
                              wcf                           <= 1'b0;
    else if((state_cnt == LP_WRITE) && (wr_adr == 6'd0))
                              wcf                           <= 1'b1;
    else
                              wcf                           <= wcf;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              ram_face                      <= 1'b0;
    else if(start_next_gen)
                              ram_face                      <= ~ram_face;
    else
                              ram_face                      <= ram_face;
  end
endmodule