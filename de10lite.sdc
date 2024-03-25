create_clock -name CLOCK -period 20.833 [get_ports {i_clk}]
#create_clock -name CLOCK -period 3.5 [get_ports {clk48m}]
derive_pll_clocks
derive_clock_uncertainty

#create_generated_clock -name vga_clk -source [get_pins {PLL_inst|altpll_component|auto_generated|pll1|clk[0]}] -divide_by 2 [get_pins {vga_ctrl_inst|timgen|div2_pls|d}]
#create_clock -name CLK_25M_vr -period 40.000

#set_output_delay -max -clock CLK_25M_vr  0.3 [get_ports {o_vga_anr* o_vga_ang* o_vga_anb* o_vga_hsync o_vga_vsync}]
#set_output_delay -min -clock CLK_25M_vr -1.6 [get_ports {o_vga_anr* o_vga_ang* o_vga_anb* o_vga_hsync o_vga_vsync}]