/*
  Format: 640 x 480, 60Hz
  Pixcel clock: 25.125MHz
*/
module syncgen #(
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
)(
  input wire                  clk,
  input wire                  rst_n,
  input wire                  vga_clk_en,

  output wire                 o_rgb_on,
  output reg                  o_hsync,
  output reg                  o_vsync,
  output wire                 o_end_disp,
  output wire   [P_HSYNC_CNT_BIT-1:0] o_hsync_cnt,
  output wire   [P_VSYNC_CNT_BIT-1:0] o_vsync_cnt,
  output reg                  o_vga_act
);

// state
  logic         [P_HSYNC_CNT_BIT-1:0] hsync_cnt;
  logic         [P_VSYNC_CNT_BIT-1:0] vsync_cnt;
// sync
  logic                       end_hbpor;
  logic                       end_vbpor;
  logic                       end_disp;
// vram


// encoder
// timer

  logic db_tri;

  assign                      o_hsync_cnt                   = hsync_cnt;
  assign                      o_vsync_cnt                   = vsync_cnt;

  assign o_vga_act = 1'd0;
  assign                      o_end_disp                    = end_disp;

// VGA RGB
  assign                      o_rgb_on                      = (hsync_cnt >= 10'd3 && hsync_cnt <= (P_HSYNC_ACTIVE_VIDEO - 10'd1)) && (vsync_cnt <= (P_VSYNC_ACTIVE_VIDEO - 10'd1));

// sync
  assign                      end_hfpor                     = (hsync_cnt == P_HSYNC_FRONT_PORCH - 10'd1) ? 1'b1 : 1'b0;
  assign                      end_hsync                     = (hsync_cnt == P_HSYNC_SYNC_PULSE - 10'd1)  ? 1'b1 : 1'b0;
  assign                      end_hbpor                     = (hsync_cnt >= P_HSYNC_BACK_PORCH - 10'd1)  ? 1'b1 : 1'b0;

  assign                      end_vfpor                     = (vsync_cnt == P_VSYNC_FRONT_PORCH - 10'd1) ? 1'b1 : 1'b0;
  assign                      end_vsync                     = (vsync_cnt == P_VSYNC_SYNC_PULSE - 10'd1)  ? 1'b1 : 1'b0;
  assign                      end_vbpor                     = (vsync_cnt >= P_VSYNC_BACK_PORCH - 10'd1)  ? 1'b1 : 1'b0;
  assign                      end_disp                      = end_hbpor & end_vbpor;



/* -----------------------------------------------------------------
 Horizon and Vertical sync control
-------------------------------------------------------------------- */
// horizon
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      hsync_cnt <= '0;
    else if(vga_clk_en)
      if(hsync_cnt >= (P_HSYNC_BACK_PORCH - 10'd1))
          hsync_cnt <= '0;
      else
        hsync_cnt <= hsync_cnt + 10'd1;
    else
      hsync_cnt <= hsync_cnt;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      o_hsync <= 1'b1;
    else if(vga_clk_en)
      if(end_hfpor)
        o_hsync <= 1'b0;
      else if(end_hsync)
        o_hsync <= 1'b1;
      else
        o_hsync <= o_hsync;
    else
      o_hsync <= o_hsync;
  end

// vertical
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      vsync_cnt <= '0;
    else if(vga_clk_en && (end_hbpor))
      if(end_vbpor) 
         vsync_cnt <= '0;
      else
        vsync_cnt <= vsync_cnt + {{P_VSYNC_BACK_PORCH_BITS-1{1'b0}}, 1'b1};
    else
      vsync_cnt <= vsync_cnt;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      o_vsync <= 1'b1; // TBD
    else if(vga_clk_en & end_hfpor)
      if(end_vfpor)
        o_vsync <= 1'b0;
      else if(end_vsync)
        o_vsync <= 1'b1;
      else
        o_vsync <= o_vsync;
    else
      o_vsync <= o_vsync;
  end






// debug trigger
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      db_tri <= 1'b0;
    else
        db_tri <= end_vbpor;

  end
endmodule