

module vga_ctrl #(
  parameter                   P_HSYNC_ACTIVE_VIDEO          = 643,
  parameter                   P_HSYNC_FRONT_PORCH           = 659,
  parameter                   P_HSYNC_SYNC_PULSE            = 755,
  parameter                   P_HSYNC_BACK_PORCH            = 803,
  parameter                   P_VSYNC_ACTIVE_VIDEO          = 483,
  parameter                   P_VSYNC_FRONT_PORCH           = 493,
  parameter                   P_VSYNC_SYNC_PULSE            = 495,
  parameter                   P_VSYNC_BACK_PORCH            = 528,
  parameter                   P_HSYNC_CNT_BIT               = 0,
  parameter                   P_VSYNC_CNT_BIT               = 0,
  parameter                   P_VSYNC_BACK_PORCH_BITS       = 0
)
(
  input wire                  i_clk,
  input wire                  i_rst_n,

  output wire   [12:0]        vram_wr_adr,
  output wire                 vram_wr_en,
  input wire                  vram_wr_dt,
  input wire    [15:0]        dly,
  input wire                  dbg_m,

  output wire                 o_vga_hsync,
  output wire                 o_vga_vsync,
  output wire    [3:0]        o_vga_anr,
  output wire    [3:0]        o_vga_ang,
  output wire    [3:0]        o_vga_anb,
  output wire                 o_vga_end,
  output wire                 o_vga_act
);


  
  logic vga_clk_en;

  logic                       rgb_on;
  //logic                       end_disp;
  logic         [7:0]         rd_data_line;
  logic         [3:0]         rd_col_rd;
  logic         [3:0]         rd_col_gr;
  logic         [3:0]         rd_col_bl;

  logic         [P_HSYNC_CNT_BIT-1:0] hsync_cnt;
  logic         [P_VSYNC_CNT_BIT-1:0] vsync_cnt;

  assign                      o_vga_anr[3]                 = rgb_on & rd_data_line[7] & rd_col_rd[3];
  assign                      o_vga_anr[2]                 = rgb_on & rd_data_line[7] & rd_col_rd[2];
  assign                      o_vga_anr[1]                 = rgb_on & rd_data_line[7] & rd_col_rd[1];
  assign                      o_vga_anr[0]                 = rgb_on & rd_data_line[7] & rd_col_rd[0];
  assign                      o_vga_ang[3]                 = rgb_on & rd_data_line[7] & rd_col_gr[3];
  assign                      o_vga_ang[2]                 = rgb_on & rd_data_line[7] & rd_col_gr[2];
  assign                      o_vga_ang[1]                 = rgb_on & rd_data_line[7] & rd_col_gr[1];
  assign                      o_vga_ang[0]                 = rgb_on & rd_data_line[7] & rd_col_gr[0];
  assign                      o_vga_anb[3]                 = rgb_on & rd_data_line[7] & rd_col_bl[3];
  assign                      o_vga_anb[2]                 = rgb_on & rd_data_line[7] & rd_col_bl[2];
  assign                      o_vga_anb[1]                 = rgb_on & rd_data_line[7] & rd_col_bl[1];
  assign                      o_vga_anb[0]                 = rgb_on & rd_data_line[7] & rd_col_bl[0];



  timgen timgen(
                              .clk                          (i_clk),
                              .rst_n                        (i_rst_n),
                              .o_tim_0                      (vga_clk_en)
  );

  syncgen #(
                              .P_HSYNC_ACTIVE_VIDEO         (P_HSYNC_ACTIVE_VIDEO),
                              .P_HSYNC_FRONT_PORCH          (P_HSYNC_FRONT_PORCH),
                              .P_HSYNC_SYNC_PULSE           (P_HSYNC_SYNC_PULSE),
                              .P_HSYNC_BACK_PORCH           (P_HSYNC_BACK_PORCH),
                              .P_VSYNC_ACTIVE_VIDEO         (P_VSYNC_ACTIVE_VIDEO),
                              .P_VSYNC_FRONT_PORCH          (P_VSYNC_FRONT_PORCH),
                              .P_VSYNC_SYNC_PULSE           (P_VSYNC_SYNC_PULSE),
                              .P_VSYNC_BACK_PORCH           (P_VSYNC_BACK_PORCH),
                              .P_HSYNC_CNT_BIT              (P_HSYNC_CNT_BIT),
                              .P_VSYNC_CNT_BIT              (P_VSYNC_CNT_BIT),
                              .P_VSYNC_BACK_PORCH_BITS      (P_VSYNC_BACK_PORCH_BITS)
    )
    syncgen(
                              .clk                          (i_clk),
                              .rst_n                        (i_rst_n),
                              .vga_clk_en                   ,
                              .o_rgb_on                     (rgb_on),
                              .o_hsync                      (o_vga_hsync),
                              .o_vsync                      (o_vga_vsync),
                              .o_end_disp                   (o_vga_end),
                              .o_hsync_cnt                  (hsync_cnt),
                              .o_vsync_cnt                  (vsync_cnt),
                              .o_vga_act                    ()
  );

  vram_ctrl #(
                              .P_HSYNC_CNT_BIT              (P_HSYNC_CNT_BIT),
                              .P_VSYNC_CNT_BIT              (P_VSYNC_CNT_BIT)
    )
    vram_ctrl_inst(
                              .clk                          (i_clk),
                              .rst_n                        (i_rst_n),
                              .vga_clk_en                   ,
                              .rgb_on                       (rgb_on),
                              .end_disp                     (o_vga_end),
                              .hsync_cnt                    (hsync_cnt),
                              .vsync_cnt                    (vsync_cnt),
                              .chr_8b                       (),
                              .col_rd                       (),
                              .col_gr                       (),
                              .col_bl                       (),

                              .vram_wr_adr                  (vram_wr_adr),
                              .vram_wr_en                   (vram_wr_en),
                              .vram_wr_dt                   (vram_wr_dt),
                              .dly                          (dly),
                              .dbg_m                        (dbg_m),

                              .o_rd_data_line               (rd_data_line),
                              .o_rd_col_rd                  (rd_col_rd),
                              .o_rd_col_gr                  (rd_col_gr),
                              .o_rd_col_bl                  (rd_col_bl)
  );
endmodule