

module lfgm_top (
  input wire                  clk,
  input wire                  rst_n,
  input wire                  start_trg,
  input wire                  rgen_trg,

// vram interface
  output wire   [23:0]        gnrt,                
  input wire    [12:0]        disp_rd_adr,
  input wire                  disp_rd_en,
  output wire                 disp_wr_dt,
  output wire   [15:0]        dly
);

  localparam                  LP_RAM_DATA_RESERVED          = 26'd0;

  logic         [4:0]         state;
  logic         [5:0]         adr_cnt;

// 
  logic         [7:0]         cnt_refrate;                                                // count 1/60 pulse
  logic                       next_gen;                                                   // start next generation
      
  logic                       end_disp;

// dpram
  logic                       ram_face;                                                   // ram surface
  logic         [5:0]         cram_adr;            
  logic         [5:0]         wr_adr;            
  logic         [5:0]         rd_adr;            
  logic         [107:0]       wr_data;            
  logic         [5:0]         lf_rd_adr;     

  logic         [107:0]       crama_rd_dta;    
  logic         [107:0]       crama_rd_dtb;    
  logic         [107:0]       cramb_rd_dta;    
  logic         [107:0]       cramb_rd_dtb;    
  logic         [107:0]       rd_data;    

  logic         [81:0]        next_cell_dt;     

  logic                       rd_en;

  logic                       wcf;   



  logic                       rgen_en;

//  assign                      end_disp                      = end_hbpor & end_vbpor;
  assign                      dly                           = 16'd5;

  lfgm_ctrl	lfgm_ctrl_inst (
                              .clk                          ( clk ),
                              .rst_n                        ( rst_n ),
                              .start_trg                    ( start_trg ),
                              .rgen_trg                     ( rgen_trg ),
                              .state_cnt                    ( state ),
                              .gnrt_cnt                     ( gnrt ),
                              .rgen_en                      ( rgen_en ),
                              .adr                          ( cram_adr ),
                              .wr_en                        ( wr_en ),
                              .rd_en                        ( rd_en ),
                              .wcf                          ( wcf ),
                              .ram_face                     ( ram_face )
  );

  lfgm_gen_ln	lfgm_gen_ln_inst (
                              .clk                          ( clk ),
                              .rst_n                        ( rst_n ),
                              .state                        ( state ),
                              .rgen_en                      ( rgen_en ),
                              .wcf                          ( wcf ),
                              .rd_data                      ( rd_data ),
                              .next_cell_dt                 ( next_cell_dt )
  );

/* ---------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------- */
  assign                      rd_data                       = ram_face ? crama_rd_dta : cramb_rd_dta;
  assign                      rd_adr                        = ram_face ? crama_rd_dta : cramb_rd_dta;


/* ---------------------------------------------------------------------------------------
  vga controller interface
--------------------------------------------------------------------------------------- */
  logic         [5:0]         d_rd_adr;
  logic                       d_rd_en;
  logic         [107:0]       d_rd_dt;
//  assign                      d_rd_adr                      = disp_rd_adr / 80;
  assign                      d_rd_dt                       = ram_face ? crama_rd_dtb : cramb_rd_dtb;

/* ---------------------------------------------------------------------------------------
 IPs
--------------------------------------------------------------------------------------- */
  vram_pts_inf	vram_pts_inf_inst  (
	                            .clk                          ( clk ),
	                            .rst_n                        ( rst_n ),
	                            .adr                          ( disp_rd_adr ),
	                            .adr_en                       ( disp_rd_en ),
                              .rd_dt                        ( d_rd_dt ),

	                            .rd_adr                       ( d_rd_adr ),
                              .rd_en                        ( d_rd_en  ),
	                            .pts_rd_dt                    ( disp_wr_dt )
	);

  dpram_108bx64w	cell_ram_a  (
	                            .clock                        ( clk ),
                // port A: 
	                            .address_a                    ( cram_adr ),
	                            .data_a                       ( {LP_RAM_DATA_RESERVED, next_cell_dt} ),
	                            .wren_a                       ( ~ram_face & wr_en),
                              .rden_a                       ( rd_en ),
	                            .q_a                          ( crama_rd_dta ),
	              // port B:
                              .address_b                    ( d_rd_adr ),
	                            .data_b                       ( 108'd0 ), // not use
	                            .wren_b                       ( 1'b0),  // not use
                              .rden_b                       ( d_rd_en ),
	                            .q_b                          ( crama_rd_dtb )
	);

  dpram_108bx64w	cell_ram_b  (
	                            .clock                        ( clk ),
                // port A: 
	                            .address_a                    ( cram_adr ),
	                            .data_a                       ( {LP_RAM_DATA_RESERVED, next_cell_dt} ),
	                            .wren_a                       ( ram_face & wr_en),
                              .rden_a                       ( rd_en ),
	                            .q_a                          ( cramb_rd_dta ),
	              // port B:
                              .address_b                    ( d_rd_adr ),
	                            .data_b                       ( 108'd0 ), // not use
	                            .wren_b                       ( 1'b0),  // not use
                              .rden_b                       ( d_rd_en ),
	                            .q_b                          ( cramb_rd_dtb )
	);
endmodule