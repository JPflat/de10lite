`timescale 1ns / 1ps

module tb_vga_ctrl;
  // テストベンチのモジュールにはポートリストはない

  parameter STEP = 20; // 10ナノ秒：100MHz
  parameter TICKS = 1000;

  reg TEST_CLK;
  reg TEST_RESET;
  reg [1:0] KEY;
  wire [31:0] TEST_COUNT;


  logic o_vga_hsync;
  logic o_vga_vsync;
  logic [3:0] o_vga_anr;
  logic  [3:0] o_vga_ang;
  logic  [3:0] o_vga_anb;
  // 各 initial ブロックは並列に実行される

  // シミュレーション設定
  initial
    begin
      // wave.vcd という名前で波形データファイルを出力
      //$dumpfile("tb_seg7_top.vcd");
      // counter_1 に含まれる全てのポートを波形データに含める
      //$dumpvars(0, dut);
      // シミュレータ実行時に counter_1 のポート COUNT を     
      // モニタする（値が変化した時に表示）
      //$monitor("COUNT: %d", counter_1.COUNT);
      #(90000);
      $finish();
    end

  // クロックを生成
  initial
    begin
      TEST_CLK = 1'b1;
      forever
        begin
          // #数値 で指定時間遅延させる
          // ~ でビット反転
          #(STEP / 2) TEST_CLK = ~TEST_CLK;
        end
    end

  // 同期リセット信号を生成
  initial
    begin
      TEST_RESET = 1'b0;
      // 2クロックの間リセット
      #(35);
      TEST_RESET = 1'b1;
    end
/*
  initial
    begin
      repeat (TICKS) @(posedge TEST_CLK);
      $finish;
    end
*/
  logic [7:0] shift;

  initial
    begin
      KEY[0] = 1'b1;
      KEY[1] = 1'b1;
      #(489);
      KEY[0] = 1'b0;
      #(3000);
      KEY[0] = 1'b1;

      #(30000);
      KEY[0] = 1'b0;
      #(3000);
      KEY[0] = 1'b1;
    end
    
  // counter_1 という名前で counter モジュールをインスタンス化
  top_de10lite
    dut    (
    .i_clk(TEST_CLK),
//    .i_rst_n(TEST_RESET),
    .KEY(KEY),
    .o_vga_hsync,
    .o_vga_vsync,
    .o_vga_anr,
    .o_vga_ang,
    .o_vga_anb
  );


endmodule