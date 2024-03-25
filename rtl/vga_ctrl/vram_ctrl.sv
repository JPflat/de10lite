module vram_ctrl #(
  parameter                   P_HSYNC_CNT_BIT               = 0,
  parameter                   P_VSYNC_CNT_BIT               = 0
)(
  input wire                  clk,
  input wire                  rst_n,
  input wire                  vga_clk_en,
  input wire                  rgb_on,
  input wire                  end_disp,
  input wire    [P_HSYNC_CNT_BIT-1:0] hsync_cnt,
  input wire    [P_VSYNC_CNT_BIT-1:0] vsync_cnt,
  input wire    [7:0]         chr_8b,
  input wire    [3:0]         col_rd,
  input wire    [3:0]         col_gr,
  input wire    [3:0]         col_bl,

  output reg    [12:0]        vram_wr_adr,
  output reg                  vram_wr_en,
  input wire                  vram_wr_dt,
  input wire    [15:0]        dly,
  input wire                  dbg_m,
  
  output wire   [7:0]         o_rd_data_line,
  output wire   [3:0]         o_rd_col_rd,
  output wire   [3:0]         o_rd_col_gr,
  output wire   [3:0]         o_rd_col_bl
);
  `include                    "../include/chara_params.v"
  `include                    "../include/color_params.h"
  `include                    "../include/ascii.h"


  logic         [75:0]        enc;
  logic         [22:0]        o_time;

  logic         [12:0]        vram_rd_adr; // VRAM read address 
  logic         [12:0]        vram_rd_adr_lt; // VRAM read address 
  logic         [63:0]        vram_rd_data_1; //
  logic         [63:0]        vram_rd_data_2; //
  logic         [7:0]         rd_data_line; //
  logic                       vram_wr_en_1;
  logic                       vram_wr_en_2;
  logic         [63:0]        vram_wr_data; //
  logic         [11:0]        vram_wr_col; //
  logic         [11:0]        vram_rd_col_1; //
  logic         [11:0]        vram_rd_col_2; //
  logic                       lat_vram_dat_line;
  logic                       lat_vram_dat_line_1;
  logic         [3:0]         rd_col_rd;
  logic         [3:0]         rd_col_gr;
  logic         [3:0]         rd_col_bl;

  logic         [63:0]        lfgm_dcd;
  logic                       end_disp_ff;
  logic                       end_disp_dx;


  assign        o_rd_data_line                              = rd_data_line;
  assign        o_rd_col_rd                                 = rd_col_rd  ;
  assign        o_rd_col_gr                                 = rd_col_gr  ;
  assign        o_rd_col_bl                                 = rd_col_bl  ;


// VRAM
  assign                      lat_vram_dat_line             = (vram_rd_adr != vram_rd_adr_lt) ? 1'b1 : 1'b0;
  assign                      vram_wr_data                  = enc[63:0];
//  assign                      vram_wr_data                  = vram_wr_dt;
  assign                      vram_wr_col                   = enc[75:64];

  assign                      lfgm_dcd                      = (vram_wr_dt) ? ~P_CHR_wndw :
                                                                              P_CHR_emp;
                                                              

// 8bit to 64bit encoder
  function [63:0] venc;
    input [3:0] din;
    begin
      case(din)
                4'd0:         venc                          = P_CHR_0;
                4'd1:         venc                          = P_CHR_1;
                4'd2:         venc                          = P_CHR_2;
                4'd3:         venc                          = P_CHR_3;
                4'd4:         venc                          = P_CHR_4;
                4'd5:         venc                          = P_CHR_5;
                4'd6:         venc                          = P_CHR_6;
                4'd7:         venc                          = P_CHR_7;
                4'd8:         venc                          = P_CHR_8;
                4'd9:         venc                          = P_CHR_9;
                //8'da:         venc                          = P_CHR_9;
                default:      venc                          = P_CHR_unkn;
      endcase
    end
  endfunction

// vram write data selecter
// {<RED>, <GREEN>, <BLUE>, <DATA>}
//    <RED>, <GREEN>, <BLUE>: 4bit
//    <DATA>: 64bit
  always_comb begin
    case(vram_wr_adr)
      13'd0: enc = {P_COL_LV10, P_COL_LV00, P_COL_LV00, P_CHR_emp};                       // left top
      13'd1: enc = {P_COL_LV05, P_COL_LV05, P_COL_LV01, P_CHR_a};
      13'd2: enc = {P_COL_LV05, P_COL_LV05, P_COL_LV01, P_CHR_b};
      13'd3: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_c};
      12'd4: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_d};
      13'd5: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_e};
      13'd6: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_f};
      13'd7: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_g};
      13'd8: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_h};
      13'd9: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_i};
      13'd10: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_j};
      13'd11: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_k};
      13'd12: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_l};
      13'd13: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_m};
      13'd14: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_n};
      13'd15: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_o};
      13'd16: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_p};
      13'd17: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_q};
      13'd18: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_r};
      13'd19: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_s};
      13'd20: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_t};
      13'd21: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_u};
      13'd22: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_v};
      13'd23: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_w};
      13'd24: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_x};
      13'd25: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_y};
      13'd26: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_z};
      13'd27: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_cln};
      13'd28: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_scln};
      13'd29: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_excl};
      13'd30: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_qstn};
      13'd31: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h0)};
      13'd32: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h1)};
      13'd33: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h2)};
      13'd34: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h3)};
      13'd35: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h4)};
      13'd36: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h5)};
      13'd37: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h6)};
      13'd38: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h7)};
      13'd39: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h8)};
      13'd40: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(4'h9)};
      13'd79: enc = {P_COL_LV10, P_COL_LV00, P_COL_LV00, P_CHR_emp};                      // right top

      13'd4720: enc = {P_COL_LV10, P_COL_LV00, P_COL_LV00, P_CHR_emp};                    // left bottom
      13'd4786: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, ~P_CHR_t};
      13'd4787: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_i};
      13'd4788: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_m};
      13'd4789: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_e};
      13'd4790: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_r};
      13'd4791: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_fill};
      13'd4792: enc = {P_COL_LV10, P_COL_LV15, P_COL_LV01, venc(o_time[22:19])}; 
      13'd4793: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(o_time[18:15])}; 
      13'd4794: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_cln};
      13'd4795: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(o_time[14:11])}; 
      13'd4796: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(o_time[10:7])}; 
      13'd4797: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, P_CHR_cln};
      13'd4798: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(o_time[6:4])};
      13'd4799: enc = {P_COL_LV15, P_COL_LV15, P_COL_LV15, venc(o_time[3:0])};
//      13'd4799: enc = {P_VGA_COLOR_BK_RD, 64'hFF818181818181FF};
      default enc = {P_COL_LV15, P_COL_LV15, P_COL_LV05, P_CHR_wndw}; 
    endcase
  end

// end disp differential
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              end_disp_ff                   <= '0;
    else 
                              end_disp_ff                   <= end_disp;
  end

  assign                      end_disp_dx                   = ~end_disp_ff & end_disp;

/* -----------------------------------------------------------------
 VRAM address control
-------------------------------------------------------------------- */
// write
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              vram_wr_adr                   <= '0;
    else if(end_disp_dx) 
                              vram_wr_adr                   <= '0;
    else if(vram_wr_adr >= (13'd4800 + dly[12:0])) 
                              vram_wr_adr                   <= vram_wr_adr;
    else 
                              vram_wr_adr                   <= vram_wr_adr + 13'd1;
  end

// output enable
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              vram_wr_en                    <= 1'b1;
    else if(end_disp_dx) 
                              vram_wr_en                    <= 1'b1;
    else if(vram_wr_adr >= (13'd4800 + dly[12:0])) 
                              vram_wr_en                    <= 1'b0;
    else
                              vram_wr_en                    <= vram_wr_en;
  end

// internal enable
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              vram_wr_en_1                  <= 1'b1;
    else if(end_disp_dx) 
                              vram_wr_en_1                  <= 1'b1;
    else if(vram_wr_adr == (10'd1023 + dly[12:0])) 
                              vram_wr_en_1                  <= 1'b0;
    else
                              vram_wr_en_1                  <= vram_wr_en_1;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) 
                              vram_wr_en_2                  <= 1'b0;
    else if(end_disp_dx) 
                              vram_wr_en_2                  <= 1'b0;
    else if(vram_wr_adr >= (13'd4800 + dly[12:0])) 
                              vram_wr_en_2                  <= 1'b0;
    else if(vram_wr_adr == (10'd1023 + dly[12:0])) 
                              vram_wr_en_2                  <= 1'b1;
    else 
                              vram_wr_en_2                  <= vram_wr_en_2;
  end

// read
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              vram_rd_adr                   <= '0;
                              vram_rd_adr_lt                <= '0;
    end
    else if(vga_clk_en) begin
      if(end_disp) begin
                              vram_rd_adr                   <= '0;
                              vram_rd_adr_lt                <= vram_rd_adr;
      end
      else if((vsync_cnt[8:3] <= 6'd59) && (hsync_cnt[9:3] <= 7'd79)) begin
                              vram_rd_adr                   <= (vsync_cnt[8:3] * 7'd80) + hsync_cnt[9:3];
                              vram_rd_adr_lt                <= vram_rd_adr; 
      end
      else begin
                              vram_rd_adr                   <= vram_rd_adr;
                              vram_rd_adr_lt                <= vram_rd_adr; 
      end
    end
    else begin
                              vram_rd_adr                   <= vram_rd_adr;
                              vram_rd_adr_lt                <= vram_rd_adr_lt;
    end
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      lat_vram_dat_line_1 <= '0;
    else if(vga_clk_en)
        lat_vram_dat_line_1 <= lat_vram_dat_line;
    else
        lat_vram_dat_line_1 <= lat_vram_dat_line_1;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      rd_data_line <= vram_rd_data_1[63:56 ];
    else if(vga_clk_en)
      if(lat_vram_dat_line_1)
        if(vram_rd_adr <= 13'd1023)
          case (vsync_cnt[2:0])
                3'd0 :        rd_data_line             <= vram_rd_data_1[63:56];
                3'd1 :        rd_data_line             <= vram_rd_data_1[55:48];
                3'd2 :        rd_data_line             <= vram_rd_data_1[47:40];
                3'd3 :        rd_data_line             <= vram_rd_data_1[39:32];
                3'd4 :        rd_data_line             <= vram_rd_data_1[31:24];
                3'd5 :        rd_data_line             <= vram_rd_data_1[23:16];
                3'd6 :        rd_data_line             <= vram_rd_data_1[15:8 ];
                3'd7 :        rd_data_line             <= vram_rd_data_1[7:0  ];
                default:      rd_data_line             <= vram_rd_data_1[63:56];
          endcase
        else
          case (vsync_cnt[2:0])
                3'd0 :        rd_data_line             <= vram_rd_data_2[63:56];
                3'd1 :        rd_data_line             <= vram_rd_data_2[55:48];
                3'd2 :        rd_data_line             <= vram_rd_data_2[47:40];
                3'd3 :        rd_data_line             <= vram_rd_data_2[39:32];
                3'd4 :        rd_data_line             <= vram_rd_data_2[31:24];
                3'd5 :        rd_data_line             <= vram_rd_data_2[23:16];
                3'd6 :        rd_data_line             <= vram_rd_data_2[15:8 ];
                3'd7 :        rd_data_line             <= vram_rd_data_2[7:0  ];
                default:      rd_data_line             <= vram_rd_data_2[63:56];
          endcase
      else if(rgb_on)
        rd_data_line <= {rd_data_line[6:0], rd_data_line[7]};
      else
        rd_data_line <= rd_data_line;
    else
        rd_data_line <= rd_data_line;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              rd_col_rd                     <= 4'd0;
                              rd_col_gr                     <= 4'd0;
                              rd_col_bl                     <= 4'd0;
    end
    else if(vga_clk_en && lat_vram_dat_line_1) begin
      if(vram_rd_adr <= 13'd1023) begin
                              rd_col_rd                     <= vram_rd_col_1[11:8];
                              rd_col_gr                     <= vram_rd_col_1[7:4];
                              rd_col_bl                     <= vram_rd_col_1[3:0];
      end
      else begin
                              rd_col_rd                     <= vram_rd_col_2[11:8];
                              rd_col_gr                     <= vram_rd_col_2[7:4];
                              rd_col_bl                     <= vram_rd_col_2[3:0];
      end
    end
    else begin
                              rd_col_rd                     <= rd_col_rd;
                              rd_col_gr                     <= rd_col_gr;
                              rd_col_bl                     <= rd_col_bl;
    end
  end

/* -----------------------------------------------------------------
 IP
-------------------------------------------------------------------- */
  reg           [11:0]        clr_rbar; 
  reg           [11:0]        clr_gbar; 
  reg           [11:0]        clr_bbar; 
  reg           [3:0]         tlt;
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              clr_rbar                       <= 12'b0000_0000_1111;      
                              clr_gbar                       <= 12'b0000_0111_1000;      
                              clr_bbar                       <= 12'b0011_1100_0000;      
    end
    else if(o_time[10:7] != tlt) begin
                              clr_rbar                       <= {clr_rbar[10:0], clr_rbar[11]};
                              clr_gbar                       <= {clr_gbar[10:0], clr_gbar[11]};
                              clr_bbar                       <= {clr_bbar[10:0], clr_bbar[11]};
    end
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              tlt                           <= 4'h0;      
    else
                              tlt                           <= o_time[10:7];
  end

  vram_64bx1024w	data_1st_inst (
                              .clock                        ( clk ),
                              // .data                         ( vram_wr_data),
                              // .data                         ( lfgm_dcd),
                              .data                         ( dbg_m ? lfgm_dcd : vram_wr_data),
                              .rdaddress                    ( vram_rd_adr[9:0] ),
                              // .wraddress                    ( vram_wr_adr ),
                              .wraddress                    ( vram_wr_adr - dly[12:0]),
                              .wren                         ( vram_wr_en_1 ),
                              .q                            ( vram_rd_data_1 )
  );

  vram_64bx4096w	data_2nd_inst (
                              .clock                        ( clk ),
                              // .data                         ( lfgm_dcd ),
                              .data                         ( dbg_m ? lfgm_dcd : vram_wr_data ),
                              .rdaddress                    ( vram_rd_adr - 13'd1024 ),
                              // .wraddress                    ( vram_wr_adr - 13'd1024 ),
                              .wraddress                    ( vram_wr_adr - 13'd1024 - dly[12:0]),
                              .wren                         ( vram_wr_en_2 ),
                              .q                            ( vram_rd_data_2 )
  );

  vram_16bx1024w	color_1st_inst (
                              .clock                        ( clk ),
                              // .data                         ( {4'd0, vram_wr_col} ),
                              .data                         ( {clr_bbar, clr_gbar, clr_rbar} ),
                              .rdaddress                    ( vram_rd_adr[9:0] ),
                              .wraddress                    ( vram_wr_adr - dly[12:0]),
                              .wren                         ( vram_wr_en_1 ),
                              .q                            ( vram_rd_col_1 )
  );

  vram_16bx4096w	color_2nd_inst (
                              .clock                        ( clk ),
                              // .data                         ( {4'd0, vram_wr_col} ),
                              .data                         ( {clr_bbar, clr_gbar, clr_rbar} ),
                              .rdaddress                    ( vram_rd_adr - 13'd1024 ),
                              .wraddress                    ( vram_wr_adr - 13'd1024 - dly[12:0] ),
                              .wren                         ( vram_wr_en_2 ),
                              .q                            ( vram_rd_col_2 )
  );

  timer timer(
                              .clk,
                              .rst_n,
                              .vga_clk_en,
                              .cnt_up_pls                   (end_disp),
                              .o_time                       (o_time)
  );
/*
  function [7:0] bin_to_ascii;
    input [3:0] din;
    begin
      case(din)
                4'd0:         bin_to_ascii                  = P_ASCII_0;
                4'd1:         bin_to_ascii                  = P_ASCII_1;
                4'd2:         bin_to_ascii                  = P_ASCII_2;
                4'd3:         bin_to_ascii                  = P_ASCII_3;
                4'd4:         bin_to_ascii                  = P_ASCII_4;
                4'd5:         bin_to_ascii                  = P_ASCII_5;
                4'd6:         bin_to_ascii                  = P_ASCII_6;
                4'd7:         bin_to_ascii                  = P_ASCII_7;
                4'd8:         bin_to_ascii                  = P_ASCII_8;
                4'd9:         bin_to_ascii                  = P_ASCII_9;
                default:      bin_to_ascii                  = 8'h00;
      endcase
    end
  endfunction
  */
  endmodule