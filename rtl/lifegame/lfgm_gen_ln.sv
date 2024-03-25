module lfgm_gen_ln (
  input wire                  clk,
  input wire                  rst_n,
  input wire    [4:0]         state,
  input wire                  rgen_en,
  input wire                  wcf,
  input wire    [107:0]       rd_data,
  output reg    [81:0]        next_cell_dt
);

  localparam                  LP_MODULE_NUM                 = 80;
  localparam                  LP_WALL_DATA                  = 1'b0;

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

  logic         [1:0]         sftin_prd_1;
  logic         [1:0]         sftin_rd;
// shift register
  logic         [81:0]        buff [0:2];        

  logic         [79:0]        cln;                                                        // 1 line of cell data 
  logic         [79:0]        rgln;                                                       // 1 line of re generate 

  logic         [15:0]        lfsr; 
/*
  assign                      sftin_prd_1                   = (state == LP_PRE_READ_1);
  assign                      sftin_prd_2                   = (state == LP_PRE_READ_2);
  assign                      sftin_rd                      = (state == LP_READ);
*/
/* ---------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------- */
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              sftin_prd_1                   <= 2'b00;
                              sftin_rd                      <= 2'b00;
    end
    else begin
                              sftin_prd_1                   <= {sftin_prd_1[0], (state == LP_PRE_READ_1)};
                              sftin_rd                      <= {sftin_rd[0],    (state == LP_READ      )};
    end
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
                              buff[2][81:0]             <= 82'd0;
                              buff[1][81:0]             <= 82'd0;
                              buff[0][81:0]             <= 82'd0;
    end
    else if(state == LP_PRE_READ_1) begin
                              buff[2][81:0]             <= 82'd0;
                              buff[1][81:0]             <= 82'd0;
                              buff[0][81:0]             <= 82'd0;
    end
    else if(sftin_prd_1[1] || sftin_rd[1]) begin
                              buff[2][81:0]             <= buff[1][81:0];
                              buff[1][81:0]             <= buff[0][81:0];
                              buff[0][81:0]             <= rd_data[81:0];
    end
    else begin
                              buff[2][81:0]             <= buff[2][81:0];
                              buff[1][81:0]             <= buff[1][81:0];
                              buff[0][81:0]             <= buff[0][81:0];
    end
  end

/* ---------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------- */
  lfsr_top #(.GP_LFSR_SEED(16'd3568))
    lfsr_top  (
                              .clk                          ( clk  ),
                              .rst_n                        ( rst_n ),
                              .gen_en                       (1'b1  ),
                              .rgen_trg                     (1'b0),
                              // .rgen_trg                     (lfsr[15]),
                              .lfsr                         (lfsr)
  );

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              rgln                          <= 80'd0;
    else
                              rgln                          <= {rgln[78:0], lfsr[15]};
  end
/* ---------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------- */
  genvar i;
  generate
      for(i = 0; i < LP_MODULE_NUM; i = i + 1) begin: jdg_block
        lfgm_jdg	lfgm_jdg_inst (
                              .clk                          ( clk ),
                              .rst_n                        ( rst_n ),
                              .state                        ( state ),
                              .jdg_en                       ( wcf ),
                              .t_cell                       ( buff[1][i+1] ),
                              .ad_cells                     ( {buff[2][i+2], buff[2][i+1], buff[2][i], 
                                                               buff[1][i+2],               buff[1][i], 
                                                               buff[0][i+2], buff[0][i+1], buff[0][i]} ),
                              .nxt_gen_cell                 ( cln[i] ),
                              .nxt_gen_cell_state           (  )
        );
      end
  endgenerate

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              next_cell_dt                  <= 82'd0;
    else if(state == LP_DLT)
      if(rgen_en)
                              next_cell_dt                  <= {LP_WALL_DATA, (rgln ^ cln), LP_WALL_DATA};
      else
                              next_cell_dt                  <= {LP_WALL_DATA, cln, LP_WALL_DATA};
    else
                              next_cell_dt                  <= next_cell_dt;
  end

endmodule