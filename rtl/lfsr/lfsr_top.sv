

module lfsr_top #(
  parameter                   GP_LFSR_SEED                  = 16'd1
)
(
  input wire                  clk,
  input wire                  rst_n,
  input wire                  gen_en,                                                     // start trigger
  input wire                  rgen_trg,                                                   // start trigger
  output wire   [15:0]        lfsr
);


  logic                       shk_end;
  logic         [15:0]        shk_lfsr;


  shk_lfsr	shk_lfsr_inst (
                              .clk                          ( clk ),
                              .rst_n                        ( rst_n ),
                              .s_shk                        ( rgen_trg ),
                              .curr_lfsr                    ( lfsr ),
                              .shk_end                      ( shk_end ),
                              .shk_lfsr                     ( shk_lfsr )
  );

  gen_lfsr	#(.GP_LFSR_SEED(GP_LFSR_SEED))
    gen_lfsr_inst (
                              .clk                          ( clk ),
                              .rst_n                        ( rst_n ),
                              .gen_en                       ( gen_en ),
                              .rgen_lfsr                    ( shk_lfsr ),
                              .rgen_en                      ( shk_end ),
                              .lfsr                         ( lfsr )
  );


endmodule