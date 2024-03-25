`include "../include/vga_conf.h"

module top_de10lite (
  input wire                  i_clk,
//  input wire                  i_rst_n,

// LEDs
  output wire   [9:0]         o_led,
// 7SEGs
  output wire   [7:0]         HEX0,
  output wire   [7:0]         HEX1,
  output wire   [7:0]         HEX2,
  output wire   [7:0]         HEX3,
  output wire   [7:0]         HEX4,
  output wire   [7:0]         HEX5,
// SW
  input wire    [9:0]         SW,
// KEY
  input wire    [1:0]         KEY,
// LED
  output wire   [9:0]         LEDR,
// GSENSOR  
  output wire                 CS_N,
  output wire                 scl,
  inout wire                  sda,
  output wire                 txd,
  input wire                  rxd,

// VGA
  output wire                 o_vga_hsync,
  output wire                 o_vga_vsync,
  output wire   [3:0]         o_vga_anr,
  output wire   [3:0]         o_vga_ang,
  output wire   [3:0]         o_vga_anb
);
  `include                    "../include/sync_params.h"

  localparam                  LP_POR_MAX                    = 16'd65535;

  wire                        clk50m;
  wire                        locked;

  wire                        reset_n;
  reg                         por_n;
  reg           [15:0]        por_count;

  logic         [12:0]        vram_wr_adr;
  logic                       vram_wr_en;
  logic                       vram_wr_dt;

  logic                       vga_end;

  logic         [15:0]        key0_cnt;
  logic         [1:0]         key0_ff;
  logic         [15:0]        key1_cnt;
  logic         [1:0]         key1_ff;

  logic         [7:0]         seg7_cnt_01;
  logic         [7:0]         seg7_cnt_23;
  logic         [7:0]         seg7_cnt_45;
  logic         [25:0]        sec_cnt;

  logic         [23:0]        gnrt;

  logic         [9:0]         key_lt;

  logic         [15:0]        dly;
  logic         [15:0]        lfgm_dly;

  logic                       rd_data_en;
  logic         [31:0]        rd_data;


  // assign                      o_led                         = mode;
  assign                      o_led                         = {7'd0, pwm_cnt[18], pwm_cnt[19], pwm_cnt[17]};
  assign                       CS_N                           = 1'b1;
  assign                       txd                          = 1'b0;

  // PLLs
  PLL	PLL_inst (
                              .inclk0                       ( i_clk  ),
                              .c0                           ( clk50m ),
                              .locked                       ( locked )
  );

//----------------------------------------------------------------------------------------
// generate internl reset
//----------------------------------------------------------------------------------------
  always @(posedge clk50m) begin
    if(por_count != LP_POR_MAX) begin
                              por_n                         <= 1'b0;
                              por_count                     <= por_count + 16'h0001;
    end
    else begin
                              por_n                         <= 1'b1;
                              por_count                     <= por_count;
    end
  end
  assign                      reset_n                       = locked & por_n;
//----------------------------------------------------------------------------------------
  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              key0_ff                       <= 2'b11;
    else
                              key0_ff                       <= {key0_ff[0], KEY[0]};
  end

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              // key0_cnt                      <= 16'd65535;
                              key0_cnt                      <= 16'd100;
    else if(key0_ff[1] && ~key0_ff[0])
                              key0_cnt                      <= 16'd0;
    else if(KEY[0])
                              // key0_cnt                      <= 16'd65535;
                              key0_cnt                      <= 16'd100;
    else if(key0_cnt == 16'd65535)
                              key0_cnt                      <= key0_cnt;
    else
                              key0_cnt                      <= key0_cnt + 16'd1;
  end
//----------------------------------------------------------------------------------------
  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              sec_cnt                       <= 26'd0;
    else if(sec_cnt == 26'd49999999)
                              sec_cnt                       <= 26'd0;
    else
                              sec_cnt                       <= sec_cnt + 26'd1;
  end

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              seg7_cnt_01                   <= 8'd0;
    else if(key0_cnt == 16'd65534)
                              seg7_cnt_01                   <= seg7_cnt_01 + 8'd1;
    else
                              seg7_cnt_01                   <= seg7_cnt_01;
  end

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              seg7_cnt_23                   <= 8'd0;
    else if(1'b0)
                              seg7_cnt_23                   <= seg7_cnt_23 + 8'd1;
    else
                              seg7_cnt_23                   <= seg7_cnt_23;
  end

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              seg7_cnt_45                   <= 8'd0;
    else if(sec_cnt == 26'd49999999)
                              seg7_cnt_45                   <= seg7_cnt_45 + 8'd1;
    else
                              seg7_cnt_45                   <= seg7_cnt_45;
  end

  seg7_dcd seg7_dcd_inst0(
                              .in                           ( delcht_cnt[3:0] ),
                              .out                          ( HEX0 )
  );

  seg7_dcd seg7_dcd_inst1(
                              .in                           ( delcht_cnt[7:4] ),
                              .out                          ( HEX1 )
  );

  seg7_dcd seg7_dcd_inst2(
                              .in                           ( delcht_cnt[11:8] ),
                              .out                          ( HEX2 )
  );

  seg7_dcd seg7_dcd_inst3(
                              .in                           ( delcht_cnt[12] ),
                              .out                          ( HEX3 )
  );

  seg7_dcd seg7_dcd_inst4(
                              .in                           ( rd_data[27:24] ),
                              .out                          ( HEX4 )
  );

  seg7_dcd seg7_dcd_inst5(
                              .in                           ( rd_data[31:28] ),
                              .out                          ( HEX5 )
  );

 /* ---------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------- */
  logic         [12:0]        delcht_cnt;
  logic         [9:0]         sw_lt_1; 
  logic         [9:0]         sw_lt_2; 
  logic         [9:0]         mode; 
  logic                       m_dbg;                        // debug mode     
  logic                       m_lfgm;                       // life game
  logic                       m_oth;                        // other
 always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n) begin
                              sw_lt_1                       <= 10'd0;
                              sw_lt_2                       <= 10'd0;
    end
    else begin
                              sw_lt_2                       <= sw_lt_1;
                              sw_lt_1                       <= SW;
    end
  end

 always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              delcht_cnt                    <= '1;
    else if(sw_lt_2 != sw_lt_1)
                              delcht_cnt                    <= '0;
    else if(delcht_cnt == '1)
                              delcht_cnt                    <= delcht_cnt;
    else
                              delcht_cnt                    <= delcht_cnt + 13'd1;
  end

 always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              mode                          <= 10'd0;
    else if(delcht_cnt == 13'd8190)
                              mode                          <= SW;
    else
                              mode                          <= mode;
  end

  assign                      m_dbg                         = (mode == 10'b00_0000_0000);
  assign                      m_lfgm                        = (mode == 10'b00_0000_0001);
  assign                      m_oth                         = (mode == 10'b00_0000_0000);

/* ---------------------------------------------------------------------------------------------------------------------
 LIFE GAME
--------------------------------------------------------------------------------------------------------------------- */
  logic         [10:0]         dummy_cnt;
  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              dummy_cnt                     <= '0;
    else
                              dummy_cnt                     <= dummy_cnt + 1'b1;
  end
  
  lfgm_top lfgm_top_inst(
                              .clk                        ( clk50m  ),
                              .rst_n                      ( reset_n ),
                              // .start_trg                    (key0_cnt == 16'd65534),
                              // .start_trg                    (key0_cnt == 16'd99),
                            //  .start_trg                    ((dummy_cnt==11'd1200)),
                              .start_trg                    (vga_end),
                              .rgen_trg                     (key0_cnt == 16'd65534),
                              .gnrt                         (gnrt),
                              .disp_rd_adr                  (vram_wr_adr),
                              .disp_rd_en                   (vram_wr_en),
                              .disp_wr_dt                   (vlfgm_ram_wr_dt),
                              .dly                          (lfgm_dly)
  );

/* ---------------------------------------------------------------------------------------------------------------------
 VGA controller
--------------------------------------------------------------------------------------------------------------------- */   
  logic         [15:0]        lfsr;

  always_comb begin
    if(mode  == 10'b00_0000_0001) begin
                              // vram_wr_dt                    = lfsr[15];
                              vram_wr_dt                    = vlfgm_ram_wr_dt;
                              dly                           = lfgm_dly;
    end
    else begin
                              vram_wr_dt                    = 1'b0;
                              dly                           = 16'd0;
    end
  end



  vga_ctrl #(
                              .P_HSYNC_ACTIVE_VIDEO         (P_HSYNC_ACTIVE_VIDEO),
                              .P_HSYNC_FRONT_PORCH          (P_HSYNC_FRONT_PORCH),
                              .P_HSYNC_SYNC_PULSE           (P_HSYNC_SYNC_PULSE),
                              .P_HSYNC_BACK_PORCH           (P_HSYNC_BACK_PORCH),
                              .P_VSYNC_ACTIVE_VIDEO         (P_VSYNC_ACTIVE_VIDEO),
                              .P_VSYNC_FRONT_PORCH          (P_VSYNC_FRONT_PORCH),
                              .P_VSYNC_SYNC_PULSE           (P_VSYNC_SYNC_PULSE),
                              .P_VSYNC_BACK_PORCH           (P_VSYNC_BACK_PORCH),
                              .P_HSYNC_CNT_BIT              (LP_HSYNC_CNT_BIT),
                              .P_VSYNC_CNT_BIT              (LP_VSYNC_CNT_BIT),
                              .P_VSYNC_BACK_PORCH_BITS      (LP_VSYNC_BACK_PORCH_BITS)
  )
    vga_ctrl_inst (
                              .i_clk                        ( clk50m  ),
                              .i_rst_n                      ( reset_n ),
                              .o_vga_hsync                  ,
                              .o_vga_vsync                  ,

                              .vram_wr_adr                  (vram_wr_adr),
                              .vram_wr_en                   (vram_wr_en),
                              .vram_wr_dt                   (vram_wr_dt),
                              .dly                          (dly),
                              .dbg_m                        (m_lfgm),

                              .o_vga_anr                    ,
                              .o_vga_ang                    ,
                              .o_vga_anb                    ,
                              .o_vga_end                    (vga_end),
                              .o_vga_act                    (  )
  );
  
  //
 i2c_ap i2c_ap_inst(
                              .clk                        ( clk50m  ),
                              .rstb                      ( reset_n ),
                              // .start_trg                    (key0_cnt == 16'd65534),
                              // .start_trg                    (key0_cnt == 16'd99),
                            //  .start_trg                    ((dummy_cnt==11'd1200)),
                              .led_0                        (led_0),
                              .scl                          (scl),
                              .sda                          (sda),
                              .txd                          (),
                              .rxd                          (),
                              .rd_data_en                   (rd_data_en),
                              .rd_data                      (rd_data)
  );

  reg [19:0]    pwm_cnt;
  reg           pwm_led0;
  reg           pwm_led1;
  reg           pwm_led2;
  reg           pwm_led3;
  reg           pwm_led4;

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              pwm_cnt                       <= '1;
    else
                              pwm_cnt                       <= pwm_cnt + 20'd1;
  end


  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              pwm_led0                      <= '0;
    else if(pwm_cnt >= 23'd4790000)
                              pwm_led0                      <= '1;
    else
                              pwm_led0                      <= pwm_led0;
  end

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              pwm_led1                      <= '0;
    else if(pwm_cnt >= 23'd4790000)
                              pwm_led1                      <= '1;
    else if(pwm_cnt == 23'd4099999)
                              pwm_led1                      <= '0;
    else
                              pwm_led1                      <= pwm_led1;
  end

  always_ff @( posedge clk50m, negedge reset_n ) begin
    if(~reset_n)
                              pwm_led2                      <= '0;
    else if(pwm_cnt >= 23'd4790000)
                              pwm_led2                      <= '1;
    else if(pwm_cnt == 23'd1199999)
                              pwm_led2                      <= '0;
    else
                              pwm_led2                      <= pwm_led2;
  end
endmodule