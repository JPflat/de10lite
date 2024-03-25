
/*
  9 clocks delay from start to end.
*/
module lfgm_jdg (
  input wire                  clk,
  input wire                  rst_n,
  input wire                  start_jdg,
  input wire                  jdg_en,
  input wire                  t_cell,
  input wire    [7:0]         ad_cells,
  input wire    [4:0]         state,
  output reg                  end_jdge,
  output wire                 nxt_gen_cell,
  output reg    [1:0]         nxt_gen_cell_state
);

  `include                    "../include/lifegame_rules.v"

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
  
  logic         [3:0]         alive_cnt;

  assign                      nxt_gen_cell                  = (nxt_gen_cell_state == LP_GN_LIVE) ? 1'b1 : 1'b0;

/* ---------------------------------------------------------------------------------------
 alive cell counter
--------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              alive_cnt                     <= 4'd0;
    else if(state == LP_SHIFTIN_AND_START_JDG)
                              alive_cnt                     <= 4'd0;
    else
      case(state)
        LP_CHK_UPPERLEFT:     alive_cnt                     <= alive_cnt + ad_cells[7];
        LP_CHK_UPPER:         alive_cnt                     <= alive_cnt + ad_cells[6];
        LP_CHK_UPPERRIGHT:    alive_cnt                     <= alive_cnt + ad_cells[5];
        LP_CHK_LEFT:          alive_cnt                     <= alive_cnt + ad_cells[4];
        LP_CHK_RIGHT:         alive_cnt                     <= alive_cnt + ad_cells[3];
        LP_CHK_LOWERLEFT:     alive_cnt                     <= alive_cnt + ad_cells[2];
        LP_CHK_LOWER:         alive_cnt                     <= alive_cnt + ad_cells[1];
        LP_CHK_LOWERRIGHT:    alive_cnt                     <= alive_cnt + ad_cells[0];
        default:              alive_cnt                     <= alive_cnt;
      endcase
  end

/* ---------------------------------------------------------------------------------------
  Life and death judgement
--------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              nxt_gen_cell_state            <= LP_GN_DEAD;
    else if(state == LP_JDG_LIFE_OR_DEATH && jdg_en)
      if(t_cell == LP_CELL_DEAD)
        if(alive_cnt == LP_RULE_BORN)
                              nxt_gen_cell_state            <= LP_GN_LIVE;
        else
                              nxt_gen_cell_state            <= LP_GN_DEAD;              // keep death
      else
        if((alive_cnt == LP_RULE_LIVE_1) || (alive_cnt == LP_RULE_LIVE_2))
                              nxt_gen_cell_state            <= LP_GN_LIVE;
        else if(alive_cnt <= LP_RULE_DEPOP_MAX)
                              nxt_gen_cell_state            <= LP_GN_DEPOP;
        else
                              nxt_gen_cell_state            <= LP_GN_OVER;              // over
    else
                              nxt_gen_cell_state            <= LP_GN_DEAD;                // not judge; through
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              end_jdge                      <= 1'b0;
    else if(start_jdg)
                              end_jdge                      <= 1'b0;
    else if(state == LP_JDG_LIFE_OR_DEATH)
                              end_jdge                      <= 1'b1;
    else
                              end_jdge                      <= 1'b0;
  end



endmodule