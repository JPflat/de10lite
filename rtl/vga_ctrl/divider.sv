module divider #(
  parameter P_DIV_NUM = 2
) (
  input wire clk,
  input wire rst_n,

  output wire o_div
);
  localparam LP_DIV_BIT = $clog2(P_DIV_NUM);

  logic [LP_DIV_BIT-1:0] dreg;

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      dreg <= '0;
    else
      dreg <= dreg + {{LP_DIV_BIT-1{1'b0}}, 1'b1};    
  end

  assign o_div = dreg[LP_DIV_BIT-1];
endmodule