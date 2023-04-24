`timescale 1ns / 1ps

module digital_lock_top
  #(clk_freq = 125_000_000,
    stable_time = 10)
   (
     input clk,
     // input rst,
     input [3:0] btn,
     input [3:0] sw,
     output [3:0] led,
     output [2:0] rgb
   );

  logic rst;

  // Debounce and Pulse logic/parameters
  //   parameter clk_freq = 125_000_000;
  //   parameter stable_time = 10; // ms
  logic [3:0] btn_db;
  logic [3:0] btn_pulse;

  // Logic for digital lock
  logic [15:0] password;
  logic [3:0] re_enter;
  logic [7:0] exit;
  logic is_a_key_pressed;

    // The for-loop creates 16 assign statements
    genvar i;
    generate
      for (i=0; i < 4; i++)
      begin : debounce_generator
        debounce  #(.clk_freq(clk_freq), .stable_time(stable_time))
                  db_inst (.clk(clk), .rst(rst), .button(btn[i]), .result(btn_db[i]));
      end
    endgenerate

    genvar j;
    generate
      for (j=0; j < 4; j++)
      begin : pulse_generator
        single_pulse_detector #(.detect_type(2'b0))
                              pls_inst_1 (.clk(clk), .rst(rst), .input_signal(btn_db[i]), .output_pulse(btn_pulse[i]));
      end
    endgenerate

  digital_lock lock_uut(.clk(clk), .rst(rst), .password(password), .re_enter(re_enter), .exit(exit),.is_a_key_pressed(is_a_key_pressed), .btn(btn_pulse), .led(led), .rgb(rgb));
//   assign btn_pulse = btn;
  assign is_a_key_pressed = (btn_pulse == 4'b0000) ? 1'b0 : 1'b1;
  assign password = 16'b0100_0001_0010_0001;
  assign re_enter = 4'b0010;
  assign exit = 8'b0001_0010;

  assign rst = sw[0];

endmodule


//   debounce  #(.clk_freq(clk_freq), .stable_time(stable_time))
//     db_inst_1(.clk(clk), .rst(rst), .button(btn[1]), .result(btn1_debounce));

//   single_pulse_detector #(.detect_type(2'b0))
//                         pls_inst_1 (.clk(clk), .rst(rst), .input_signal(btn1_debounce), .output_pulse(btn1_pulse));
