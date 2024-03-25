module timgen (
  input wire clk,
  input wire rst_n,

  output wire o_tim_0

);
  logic div2_pls;

  divider #(.P_DIV_NUM(2))
    div2(
      .clk,
      .rst_n,
      .o_div()
    );

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      div2_pls <= 1'b0;
    else
      div2_pls <= ~div2_pls;
  end
  assign o_tim_0 = div2_pls;
  
endmodule