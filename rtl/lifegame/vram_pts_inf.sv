//
// interface with VRAM
//
module vram_pts_inf (
  input wire                  clk,
  input wire                  rst_n,
  input wire    [12:0]        adr,
  input wire                  adr_en,
  input wire    [107:0]       rd_dt,
  output reg    [5:0]         rd_adr,
  output reg                  rd_en,
  output wire                 pts_rd_dt
);

  localparam                  LP_MODULE_NUM                 = 60;

  logic         [3:0]         sft_en;
  logic         [12:0]        sft_adr;

  logic         [59:0]        adr_rng_chk;
//  logic                       ill_rng;


  logic        [5:0]          rd_adr_r;
  logic        [5:0]          rd_adr_lt;

  logic         [1:0]         sft_rd_en;
  logic         [79:0]        lt_rd_dt;


  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              sft_adr                       <= 12'd0;
    else
                              sft_adr                       <= adr;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              sft_en                        <= 1'b0;
    else
                              sft_en                        <= {sft_en[2:0], adr_en};
  end

/* ---------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------- */
  genvar i;
  generate
  for(i = 0; i < LP_MODULE_NUM; i = i + 1) begin: a
    assign                    adr_rng_chk[59-i]             = (sft_adr >= i*80) && (sft_adr <= ((i+1)*80)-1);
  end
  endgenerate

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              rd_adr_r                        <= 6'd1;
    else if(sft_en[0] || (~sft_en[0] & &sft_en[3:1]))
      case(adr_rng_chk)
      // 1-4
        60'h000000000000001:  rd_adr_r                        <= 6'd60;                           
        60'h000000000000002:  rd_adr_r                        <= 6'd59;
        60'h000000000000004:  rd_adr_r                        <= 6'd58;
        60'h000000000000008:  rd_adr_r                        <= 6'd57;
      // 5-8
        60'h000000000000010:  rd_adr_r                        <= 6'd56;                            
        60'h000000000000020:  rd_adr_r                        <= 6'd55;
        60'h000000000000040:  rd_adr_r                        <= 6'd54;
        60'h000000000000080:  rd_adr_r                        <= 6'd53;        
      // 9-12
        60'h000000000000100:  rd_adr_r                        <= 6'd52;  
        60'h000000000000200:  rd_adr_r                        <= 6'd51;
        60'h000000000000400:  rd_adr_r                        <= 6'd50;
        60'h000000000000800:  rd_adr_r                        <= 6'd49;
      // 13-16
        60'h000000000001000:  rd_adr_r                        <= 6'd48;
        60'h000000000002000:  rd_adr_r                        <= 6'd47;
        60'h000000000004000:  rd_adr_r                        <= 6'd46;
        60'h000000000008000:  rd_adr_r                        <= 6'd45;
      // 17-20
        60'h000000000010000:  rd_adr_r                        <= 6'd44;
        60'h000000000020000:  rd_adr_r                        <= 6'd43;
        60'h000000000040000:  rd_adr_r                        <= 6'd42;
        60'h000000000080000:  rd_adr_r                        <= 6'd41;
      // 21-24
        60'h000000000100000:  rd_adr_r                        <= 6'd40;
        60'h000000000200000:  rd_adr_r                        <= 6'd39;
        60'h000000000400000:  rd_adr_r                        <= 6'd38;
        60'h000000000800000:  rd_adr_r                        <= 6'd37;
      // 25-28
        60'h000000001000000:  rd_adr_r                        <= 6'd36;
        60'h000000002000000:  rd_adr_r                        <= 6'd35;
        60'h000000004000000:  rd_adr_r                        <= 6'd34;
        60'h000000008000000:  rd_adr_r                        <= 6'd33;
      // 29-32
        60'h000000010000000:  rd_adr_r                        <= 6'd32;
        60'h000000020000000:  rd_adr_r                        <= 6'd31;
        60'h000000040000000:  rd_adr_r                        <= 6'd30;
        60'h000000080000000:  rd_adr_r                        <= 6'd29;
      // 33-36
        60'h000000100000000:  rd_adr_r                        <= 6'd28;
        60'h000000200000000:  rd_adr_r                        <= 6'd27;
        60'h000000400000000:  rd_adr_r                        <= 6'd26;
        60'h000000800000000:  rd_adr_r                        <= 6'd25;
      // 37-40
        60'h000001000000000:  rd_adr_r                        <= 6'd24;
        60'h000002000000000:  rd_adr_r                        <= 6'd23;
        60'h000004000000000:  rd_adr_r                        <= 6'd22;
        60'h000008000000000:  rd_adr_r                        <= 6'd21;
      // 41-44
        60'h000010000000000:  rd_adr_r                        <= 6'd20;
        60'h000020000000000:  rd_adr_r                        <= 6'd19;
        60'h000040000000000:  rd_adr_r                        <= 6'd18;
        60'h000080000000000:  rd_adr_r                        <= 6'd17;
      // 45-48
        60'h000100000000000:  rd_adr_r                        <= 6'd16;
        60'h000200000000000:  rd_adr_r                        <= 6'd15;
        60'h000400000000000:  rd_adr_r                        <= 6'd14;
        60'h000800000000000:  rd_adr_r                        <= 6'd13;
      // 49-52
        60'h001000000000000:  rd_adr_r                        <= 6'd12;
        60'h002000000000000:  rd_adr_r                        <= 6'd11;
        60'h004000000000000:  rd_adr_r                        <= 6'd10;
        60'h008000000000000:  rd_adr_r                        <= 6'd9;       
      // 53-56
        60'h010000000000000:  rd_adr_r                        <= 6'd8;
        60'h020000000000000:  rd_adr_r                        <= 6'd7;
        60'h040000000000000:  rd_adr_r                        <= 6'd6;
        60'h080000000000000:  rd_adr_r                        <= 6'd5; 
      // 57-60
        60'h100000000000000:  rd_adr_r                        <= 6'd4;
        60'h200000000000000:  rd_adr_r                        <= 6'd3;
        60'h400000000000000:  rd_adr_r                        <= 6'd2;
        60'h800000000000000:  rd_adr_r                        <= 6'd1;                                          
        default            :  rd_adr_r                        <= 6'd63;
      endcase
    else
                              rd_adr_r                        <= rd_adr_r;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              rd_adr_lt                     <= 6'd1;
    else
                              rd_adr_lt                     <= rd_adr_r;
  end

  assign        rd_en                                       = rd_adr_r != rd_adr_lt;
  // assign        rd_adr                                      = rd_adr_lt;
  assign        rd_adr                                      = rd_adr_r;
  assign        pts_rd_dt                                   = lt_rd_dt[79];

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              sft_rd_en                     <= 2'b00;
    else
                              sft_rd_en                     <= {sft_rd_en[0], rd_en};
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              lt_rd_dt                      <= 80'd0;
    else if(sft_rd_en[1])
                              lt_rd_dt                      <= rd_dt[80:1];
    else
                              lt_rd_dt                      <= {lt_rd_dt[78:0], 1'b0};
  end





endmodule


 /*
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              bfcnt                         <= 7'd60;
    else if(sft_en[1] && (bfcnt == 7'd60))
                              bfcnt                         <= 7'd0;
    else if(bfcnt == 7'd60)
                              bfcnt                         <= bfcnt;
    else if(sft_en[2])
                              bfcnt                         <= bfcnt + 7'd1;
  end

  assign                      bfram_wr_adr                  = bfcnt;
  assign                      bfram_wr_en                   = sft_en[2];

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              bfcnt                         <= 7'd80;
    else if(sft_en[1] && (bfcnt == 7'd80))
                              bfcnt                         <= 7'd0;
    else if(bfcnt == 7'd80)
                              bfcnt                         <= bfcnt;
    else if(sft_en[2])
                              bfcnt                         <= bfcnt + 7'd1;
  end

// read pointer
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              rdpt                         <= 7'd80;
    else if(sft_en[3])
                              rdpt                         <= 7'd0;
    else if(rdpt == 7'd80)
                              rdpt                         <= rdpt;
    else
                              rdpt                         <= rdpt + 7'd1;
  end


  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
                              ill_rng                       <= 1'b0;
    else if(rd_adr == 6'd63)
                              ill_rng                       <= 1'b1;
    else
                              ill_rng                       <= ill_rng;
  end
*/