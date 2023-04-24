`timescale 1ns / 1ps

module digital_lock(
    input clk,
    input rst,
    input [15:0] password,
    input [3:0] re_enter,
    input [7:0] exit,
    input is_a_key_pressed,
    input [3:0] btn,
    output [3:0] led,
    output [2:0] rgb
  );

  // FSM state type
  typedef enum {reset, lock, s1, s2, s3, unlock, w1, w2, w3, alarm, a1, r1, r2, r3} state_type;
  state_type state_reg, state_next;

  //   logic [15:0] password;
  //   logic [3:0] re_enter;
  //   logic [7:0] exit;

  //   assign password = 16'b0100_0001_0010_0001;
  //   assign re_enter = 4'b0010;
  //   assign exit = 8'b0001_0010;

  logic [3:0] led_reg;
  logic [2:0] rgb_reg;


  always_ff @ (posedge clk or posedge rst)
  begin
    if (rst == 1)
    begin
      state_reg <= reset;
    end
    else
    begin
      state_reg <= state_next;
    end // End of clk else
  end // End of always_ff

  // Button presses, N S E W
  always_ff @ (posedge clk)
  begin
    // if (is_a_key_pressed) begin
    // end else begin
    //     state_next = state_next;
    // end
    // case (state_reg)
    // reset :
    // begin
    //   state_next = lock;
    // end // End Reset state
    if (state_reg == reset)
    begin
      state_next = lock;
    end
    else if (is_a_key_pressed)
    begin
      case (state_reg)
        lock :
        begin
          if (btn == password[15:12])
          begin
            state_next = s1;
          end
          else if (btn == re_enter)
          begin
            state_next = r1;
          end
          else
          begin
            state_next = w1;
          end
        end // End Lock state

        s1 :
        begin
          if (btn == password[11:8])
          begin
            state_next = s2;
          end
          else if (btn == re_enter)
          begin
            state_next = r2;
          end
          else
          begin
            state_next = w2;
          end
        end // End S1 state

        s2 :
        begin
          if (btn == password[7:4])
          begin
            state_next = s3;
          end
          else
          begin
            state_next = w3;
          end
        end // End S2 state

        s3 :
        begin
          if (btn == password[3:0])
          begin
            state_next = unlock;
          end
          else if (btn == re_enter)
          begin
            state_next = reset;
          end
          else
          begin
            state_next = alarm;
          end
        end // End S3 state

        unlock :
        begin
          if (btn != 4'b0000)
          begin
            state_next = lock;
          end
        end // End unlock state

        w1 :
        begin
          if (btn == re_enter)
          begin
            state_next = r2;
          end
          else
          begin
            state_next = w2;
          end
        end // End w1 state

        w2 :
        begin
          if (btn == re_enter)
          begin
            state_next = r3;
          end
          else
          begin
            state_next = w3;
          end
        end // End w2 state

        w3 :
        begin
          if (btn != 4'b0000)
          begin
            state_next = alarm;
          end
        end // End w3 state

        alarm :
        begin
          if (btn == exit[7:4])
          begin
            state_next = a1;
          end
          else
          begin
            state_next = alarm;
          end
        end // End alarm state

        a1 :
        begin
          if (btn == exit[3:0])
          begin
            state_next = reset;
          end
          else
          begin
            state_next = alarm;
          end
        end // End a1 state

        r1 :
        begin
          if (btn == re_enter)
          begin
            state_next = reset;
          end
          else
          begin
            state_next = w2;
          end
        end // End r1 state

        r2 :
        begin
          if (btn == re_enter)
          begin
            state_next = reset;
          end
          else
          begin
            state_next = w3;
          end
        end // End r2 state

        r3 :
        begin
          if (btn == re_enter)
          begin
            state_next = reset;
          end
          else
          begin
            state_next = alarm;
          end
        end // End r1 state

        default:
          state_next = reset;
      endcase
    end
    else
    begin
      state_next = state_next;
    end

  end // End of always combiantion

  always_comb
  begin
    case (state_reg)

      reset :
      begin
        led_reg = 4'b0000;
        rgb_reg = 3'b000;
      end // End Reset state

      lock :
        led_reg = 4'b0000;

      s1 :
        led_reg = 4'b1000;

      s2 :
        led_reg = 4'b1100;

      s3 :
        led_reg = 4'b1110;

      unlock :
      begin
        led_reg = 4'b1111;
        rgb_reg = 3'b010;
      end // End unlock state

      w1 :
        led_reg = 4'b1000;

      w2 :
        led_reg = 4'b1100;

      w3 :
        led_reg = 4'b1110;


      alarm :
      begin
        led_reg = 4'b0101;
        rgb_reg = 3'b101;
      end // End alarm state

      a1 :
      begin
        led_reg = led_reg;
        rgb_reg = rgb_reg;
      end // End a1 state

      r1 :
        led_reg = 4'b1000;

      r2 :
        led_reg = 4'b1100;

      r3 :
        led_reg = 4'b1110;

      default:
      begin
        led_reg = 4'b0000;
        rgb_reg = 3'b000;
      end
    endcase
  end // End of always combination, LEDs

  assign led = led_reg;
  assign rgb = rgb_reg;

endmodule
