module shift_register #(parameter WIDTH = 8)
(
                        input clk,
                        input rst,
                        input en,
                        input direction,
                        input in,
                        input [WIDTH - 1:0]parallel_in,
                        input load,
                        output reg out,
                        output reg [WIDTH - 1:0] parallel_out
);

always@(*)
    begin
        if(direction) begin
             out = parallel_out[WIDTH - 1];
        end else begin
             out = parallel_out[0];
        end
    end //end of always block

always@ (posedge clk)
    begin
        if(rst) begin
            parallel_out <= {(WIDTH){1'b0}};
        end else if (en) begin
            if(load) begin
                parallel_out <= parallel_in;
            end else if(direction) begin
                parallel_out <= {parallel_out[WIDTH - 2:0], in};
            end else begin
                parallel_out <= {in, parallel_out[WIDTH - 1:1]};
            end
        end
    end //end of always block
endmodule //shift_module
