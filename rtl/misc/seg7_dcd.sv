module seg7_dcd (
  input wire [3:0] in,
  output wire [7:0] out
);

  localparam P_7SEG_DECODE_0 = 8'b11000000;
  localparam P_7SEG_DECODE_1 = 8'b11111001;
  localparam P_7SEG_DECODE_2 = 8'b10100100;
  localparam P_7SEG_DECODE_3 = 8'b10110000;
  localparam P_7SEG_DECODE_4 = 8'b10011001;
  localparam P_7SEG_DECODE_5 = 8'b10010010;
  localparam P_7SEG_DECODE_6 = 8'b10000010;
  localparam P_7SEG_DECODE_7 = 8'b11011000;
  localparam P_7SEG_DECODE_8 = 8'b10000000;
  localparam P_7SEG_DECODE_9 = 8'b10011000;
  localparam P_7SEG_DECODE_A = 8'b00100000;
  localparam P_7SEG_DECODE_B = 8'b00000011;
  localparam P_7SEG_DECODE_C = 8'b00100111;
  localparam P_7SEG_DECODE_D = 8'b00100001;
  localparam P_7SEG_DECODE_E = 8'b00000100;
  localparam P_7SEG_DECODE_F = 8'b00001110;

  assign out = (in == 4'h0) ? P_7SEG_DECODE_0 :
                 (in == 4'h1) ? P_7SEG_DECODE_1 :
                 (in == 4'h2) ? P_7SEG_DECODE_2 :
                 (in == 4'h3) ? P_7SEG_DECODE_3 :
                 (in == 4'h4) ? P_7SEG_DECODE_4 :
                 (in == 4'h5) ? P_7SEG_DECODE_5 :
                 (in == 4'h6) ? P_7SEG_DECODE_6 :
                 (in == 4'h7) ? P_7SEG_DECODE_7 :
                 (in == 4'h8) ? P_7SEG_DECODE_8 :
                 (in == 4'h9) ? P_7SEG_DECODE_9 :
                 (in == 4'ha) ? P_7SEG_DECODE_A :
                 (in == 4'hb) ? P_7SEG_DECODE_B :
                 (in == 4'hc) ? P_7SEG_DECODE_C :
                 (in == 4'hd) ? P_7SEG_DECODE_D :
                 (in == 4'he) ? P_7SEG_DECODE_E : P_7SEG_DECODE_F;

endmodule