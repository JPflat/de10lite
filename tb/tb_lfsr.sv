`timescale 1ns / 1ps

module tb_lfsr;
  // テストベンチのモジュールにはポートリストはない

  parameter STEP = 20; // 10ナノ秒：100MHz
  parameter TICKS = 1000;

  reg TEST_CLK;
  reg TEST_RESET;
  reg [1:0] KEY;
  wire [31:0] TEST_COUNT;


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
  parameter                   GP_LFSR_SEED                  = 16'd1;

  wire          [15:0]        lfsr;
  reg rgen_trg;

  initial begin
    rgen_trg = 0;
    #(1001);
    #(STEP);
        rgen_trg = 1;
    #(STEP);
        rgen_trg = 0;

  end

  // counter_1 という名前で counter モジュールをインスタンス化
  lfsr_top #(.GP_LFSR_SEED(GP_LFSR_SEED))
    dut    (
    .clk(TEST_CLK),
    .rst_n(TEST_RESET),
    .gen_en(1'b1),
    .rgen_trg(rgen_trg),
    .lfsr(lfsr)
  );


endmodule