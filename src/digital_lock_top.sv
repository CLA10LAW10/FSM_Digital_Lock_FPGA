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
  logic [3:0] led_reg;
  logic [3:0] led_lock;
  logic [3:0] led_toggle1;
  logic [3:0] led_toggle2;
  logic [2:0] rgb_reg;
  logic [2:0] rgb_lock;
  logic [2:0] rgb_toggle1;
  logic [2:0] rgb_toggle2;
  logic pulse_25Hz;

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
                              pls_inst_1 (.clk(clk), .rst(rst), .input_signal(btn_db[j]), .output_pulse(btn_pulse[j]));
      end
    endgenerate

     pulse_gen pulse_25 (.clk(clk), .rst(rst), .pulse(pulse_25Hz));

  digital_lock lock_uut(.clk(clk), .rst(rst), .password(password), .re_enter(re_enter), .exit(exit),.is_a_key_pressed(is_a_key_pressed), .btn(btn_pulse), .led(led_lock), .rgb(rgb_lock));

always_ff @ (posedge clk, posedge rst) begin
    if (rst) begin
        led_reg <= 4'b0000;
        rgb_reg <= 4'b0000;
        led_toggle1 <= 4'b1010;
        led_toggle2 <= 4'b1111;
        rgb_toggle1 <= 3'b001;
        rgb_toggle2 <= 3'b010;
    end else begin
        if (pulse_25Hz) begin
            if (led_lock == 4'b0101) begin
                led_toggle1 <= ~led_toggle1;
                led_reg <= led_toggle1;
            end 
            else if (led_lock == 4'b1111) begin
                led_toggle2 <= ~led_toggle2;
                led_reg <= led_toggle2;
            end
            else begin
                led_reg <= led_lock;
            end

            if (rgb_lock == 3'b001) begin
                rgb_toggle1 <= {~rgb_toggle1[2],rgb_toggle1[1],~rgb_toggle1[0]};
                rgb_reg <= rgb_toggle1;
            end 
            else if (rgb_lock == 3'b010) begin
                rgb_toggle2 <= {rgb_toggle2[2],~rgb_toggle2[1],rgb_toggle2[0]};
                rgb_reg <= rgb_toggle2;
            end
            else begin
                rgb_reg <= rgb_lock;
            end

        end else begin
            led_reg <= led_reg;
            rgb_reg <= rgb_reg;
        end
    end
end

  assign is_a_key_pressed = btn_pulse[3] | btn_pulse[2] | btn_pulse[1] | btn_pulse[0];
  assign password = 16'b0100_0001_0010_0001;
  assign re_enter = 4'b0010;
  assign exit = 8'b0001_0010;

  assign rst = sw[0];
  assign led = led_reg;
  assign rgb = rgb_reg;

endmodule