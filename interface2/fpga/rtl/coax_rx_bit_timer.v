// Copyright (c) 2020, Andrew Kay
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

`default_nettype none

module coax_rx_bit_timer (
    input clk,
    input rx,
    input reset,
    output reg sample,
    output reg synchronized
);
    parameter CLOCKS_PER_BIT = 8;

    localparam IDLE = 0;
    localparam SYNCHRONIZED = 1;
    localparam UNSYNCHRONIZED = 2;

    reg [1:0] state = IDLE;
    reg [1:0] next_state;

    reg previous_rx;

    reg [$clog2(CLOCKS_PER_BIT*2):0] transition_counter = 0;
    reg [$clog2(CLOCKS_PER_BIT*2):0] next_transition_counter;
    reg [$clog2(CLOCKS_PER_BIT):0] bit_counter = 0;
    reg [$clog2(CLOCKS_PER_BIT):0] next_bit_counter;

    always @(*)
    begin
        next_state = state;

        sample = 0;
        synchronized = 0;

        next_transition_counter = transition_counter;
        next_bit_counter = bit_counter;

        case (state)
            IDLE:
            begin
                if (rx != previous_rx)
                begin
                    next_transition_counter = 0;
                    next_bit_counter = CLOCKS_PER_BIT / 2;

                    next_state = SYNCHRONIZED;
                end
            end

            SYNCHRONIZED:
            begin
                if (transition_counter < (CLOCKS_PER_BIT + (CLOCKS_PER_BIT / 4)))
                    next_transition_counter = transition_counter + 1;
                else
                    next_state = UNSYNCHRONIZED;

                synchronized = 1;

                if (bit_counter < CLOCKS_PER_BIT)
                    next_bit_counter = bit_counter + 1;
                else
                    next_bit_counter = 0;

                if (rx != previous_rx && transition_counter > (CLOCKS_PER_BIT / 2))
                begin
                    next_transition_counter = 0;
                    next_bit_counter = CLOCKS_PER_BIT / 2;
                end

                if (bit_counter == ((CLOCKS_PER_BIT / 4) * 3))
                    sample = 1;
            end

            UNSYNCHRONIZED:
            begin
                if (bit_counter < CLOCKS_PER_BIT)
                    next_bit_counter = bit_counter + 1;
                else
                    next_bit_counter = 0;

                if (bit_counter == ((CLOCKS_PER_BIT / 4) * 3))
                    sample = 1;
            end
        endcase
    end

    always @(posedge clk)
    begin
        state <= next_state;

        transition_counter <= next_transition_counter;
        bit_counter <= next_bit_counter;

        if (reset)
            state <= IDLE;

        previous_rx <= rx;
    end
endmodule
