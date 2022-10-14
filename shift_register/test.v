`timescale 1 ns / 100 ps

module test();

localparam         WIDTH       = 8;
localparam         TOTAL_TESTS = 4;

reg                clk;
reg                rst;
reg                en;
reg                direction;
reg  [WIDTH - 1:0] parallel_in;
reg                in;
reg                load;
wire [WIDTH - 1:0] parallel_out;
wire               out;

integer            passed_tests_count;
integer            failed_tests_count;
integer            skipped_tests_count;
integer            index;
realtime           start_capture;
realtime           end_capture;
realtime           all_tests_end;

initial
begin
    clk                 <= 1'b0;
    parallel_in         <= $random;
    passed_tests_count  <= 0;
    failed_tests_count  <= 0;
    skipped_tests_count <= 0;
end

always
begin
    #5 clk = ~clk;
end

task check_load_enabled;
begin
    $display("\nTest check_load_enabled started. (Testing if 'output register' and 'parallel_in' are equal).");
    @(posedge clk);
    start_capture = $realtime;
    rst = 1'b1;
    index = 8'd0;

    repeat(20)@(posedge clk);
    rst = 1'b0;

    en = 1'b1;
    direction = 1'b0;
    in = 1'b1;
    load = 1'b1;

    repeat(1)@(posedge clk);
    #1;
    load = 1'b0;

    if(parallel_out == parallel_in)
    begin
        $display("Test check_load_enabled PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end else begin
        $display("Test check_load_enabled FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end

    $display("Test check_load_enabled ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_load_enabled

task check_reset_enabled;
begin
    $display("\nTest check_reset_enabled started. (Testing if 'output register' is reset).");
    @(posedge clk);
    start_capture = $realtime;
    rst = 1'b1;
    index = 8'd0;
    en = 1'b1;
    direction = 1'b0;
    in = 1'b1;
    load = 1'b0;

    repeat(20)@(posedge clk);
    if(parallel_out == 8'b00000000)
    begin
        $display("Test check_reset_enabled PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end else begin
        $display("Test check_reset_enabled FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end

    $display("Test check_reset_enabled ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_reset_enabled

task check_direction_is_one;
begin
    $display("\nTest check_direction_is_one started. (Testing if new bit added from the right).");
    @(posedge clk);
    start_capture = $realtime;
    rst = 1'b1;
    index = 8'd0;
    en = 1'b1;
    direction = 1'b1;
    in = 1'b1;
    load = 1'b0;

    repeat(20)@(posedge clk);
    rst = 1'b0;

    repeat(20)@(posedge clk);
    if(parallel_out[WIDTH - 1] == in)
    begin
        $display("Test check_direction_is_one PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end else begin
        $display("Test check_direction_is_one FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end

    $display("Test check_direction_is_one ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_direction_is_one

task check_direction_is_zero;
begin
    $display("\nTest check_direction_is_zero started. (Testing if new bit added from the left).");
    @(posedge clk);
    start_capture = $realtime;
    rst = 1'b1;
    index = 8'd0;
    en = 1'b1;
    direction = 1'b0;
    in = 1'b1;
    load = 1'b0;

    repeat(20)@(posedge clk);
    rst = 1'b0;

    repeat(20)@(posedge clk);
    if(parallel_out[0] == in)
    begin
        $display("Test check_direction_is_zero PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end else begin
        $display("Test check_direction_is_zero FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end

    $display("Test check_direction_is_one ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_direction_is_zero

initial
begin
    $dumpvars;
    $timeformat(-9, 3, " ns", 10);
    $display("");
    $display("Starting tests...");

    check_load_enabled;
    check_reset_enabled;
    check_direction_is_one;
    check_direction_is_zero;

    if(passed_tests_count + failed_tests_count != TOTAL_TESTS)
    begin
        skipped_tests_count = TOTAL_TESTS - (passed_tests_count + failed_tests_count);
    end

    all_tests_end = $realtime;

    $display("");
    $display("TOTAL TESTS: %0d, PASSED: %0d, FAILED: %0d, SKIPPED: %0d.",
                TOTAL_TESTS, passed_tests_count, failed_tests_count, skipped_tests_count);
    $display("Time elapsed for all tests: %0t", all_tests_end);
    $display("");

    #1000 $finish;
end //end of initial block

//instantiation of module 'shift_register'
shift_register #(.WIDTH(WIDTH))
    shift_register
    (.clk(clk),
    .rst(rst),
    .en(en),
    .in(in),
    .parallel_in(parallel_in),
    .load(load),
    .direction(direction),
    .out(out),
    .parallel_out(parallel_out));

endmodule //test
