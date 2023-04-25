`timescale 1ns / 1ps

module digital_lock_top_tb();

  logic clk;
  //   logic rst;
  logic [3:0] btn;
  logic [3:0] sw;
  logic [3:0] led;
  logic [2:0] rgb;

  parameter CP = 8;
  parameter clk_freq = 125_000_000;
  parameter stable_time = 1;

  digital_lock_top  #(.clk_freq(clk_freq), .stable_time(stable_time)) digital_lock_uut (.*);

  // Process made to toggle the clock every 5ns.
  always
  begin
    clk <= 1'b1;
    #(CP/2);
    clk <= 1'b0;
    #(CP/2);
  end

  // Simulation inputs.
  initial
  begin
    // Set initial values
    #CP;
    btn = 4'b0000;
    sw = 4'b0001;
    #CP;
    sw = 4'b0000;
    #CP;

    // Button presses, N S E W
    // N = 4'b1000;
    // S = 4'b0100;
    // E = 4'b0010;
    // W = 4'b0001

    // Unlock Digital Lock
    btn = 4'b0100; // South
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0001; // West
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0010; // East
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0001; // West
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    // Reset
    btn = 4'b1000; // North, back to lock
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    // Re-enter attempt
    btn = 4'b0001; // West
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0010; // East
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    // Second East, back to reset
    btn = 4'b0010; // East, back to lock
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    // Wrong guess
    btn = 4'b0100; // South
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0001; // West
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0010; // East
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b1000; // North, Alarm State
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0001; // West
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

    btn = 4'b0010; // East, back to lock
    #(CP*200_000);
    btn = 4'b0000;
    #(CP*200_000);

     $finish;
  end

endmodule;
