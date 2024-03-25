module timer (
  input wire clk,
  input wire rst_n,
  input wire vga_clk_en,
  input wire cnt_up_pls,
  output wire [22:0] o_time
);

  logic [3:0] min_cnt_1, min_cnt_2;
  logic [3:0] sec_cnt_1, sec_cnt_2;
  logic [3:0] point_cnt_1;
  logic [2:0] point_cnt_2;

  logic co_p1;
  logic co_p2;
  logic co_s1;
  logic co_s2;
  logic co_m1;
  
  assign co_p1 = (point_cnt_1 == 4'd9) ? 1'b1 : 1'b0;
  assign co_p2 = (point_cnt_2 == 3'd6) ? 1'b1 : 1'b0;
  assign co_s1 = (sec_cnt_1 == 4'd9)   ? 1'b1 : 1'b0;
  assign co_s2 = (sec_cnt_2 == 4'd5)   ? 1'b1 : 1'b0;
  assign co_m1 = (min_cnt_1 == 4'd9)   ? 1'b1 : 1'b0;

  assign o_time = {min_cnt_2, min_cnt_1,
                   sec_cnt_2, sec_cnt_1,
                   point_cnt_2, point_cnt_1};

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      point_cnt_1 <= '0;
    else if(vga_clk_en && cnt_up_pls)
      if(point_cnt_1 == 4'd9)
        point_cnt_1 <= '0;
      else
        point_cnt_1 <= point_cnt_1 + 4'd1;
    else
        point_cnt_1 <= point_cnt_1;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      point_cnt_2 <= '0;
    else if(vga_clk_en && cnt_up_pls && co_p1)
      if(point_cnt_2 == 3'd6)
        point_cnt_2 <= '0;
      else
        point_cnt_2 <= point_cnt_2 + 3'd1;
    else
        point_cnt_2 <= point_cnt_2;
  end


  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      sec_cnt_1 <= '0;
    else if(vga_clk_en && cnt_up_pls && co_p1 && co_p2 )
      if(sec_cnt_1 == 4'd9)
        sec_cnt_1 <= '0;
      else
        sec_cnt_1 <= sec_cnt_1 + 4'd1;
    else
        sec_cnt_1 <= sec_cnt_1;
  end


  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      sec_cnt_2 <= '0;
    else if(vga_clk_en && cnt_up_pls && co_p1 && co_p2 && co_s1 )
      if((sec_cnt_2 == 4'd5))
        sec_cnt_2 <= '0;
      else
        sec_cnt_2 <= sec_cnt_2 + 4'd1;
    else
        sec_cnt_2 <= sec_cnt_2;
  end


  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      min_cnt_1 <= '0;
    else if(vga_clk_en && cnt_up_pls && co_p1 && co_p2 && co_s1 && co_s2)
      if((min_cnt_1 == 4'd9))
        min_cnt_1 <= '0;
      else
        min_cnt_1 <= min_cnt_1 + 4'd1;
    else
        min_cnt_1 <= min_cnt_1;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      min_cnt_2 <= '0;
    else if(vga_clk_en && cnt_up_pls && co_p1 && co_p2 && co_s1 && co_s2 && co_m1)
      if((min_cnt_2 == 4'd5))
        min_cnt_2 <= '0;
      else
        min_cnt_2 <= min_cnt_2 + 4'd1;
    else
        min_cnt_2 <= min_cnt_2;
  end
endmodule
