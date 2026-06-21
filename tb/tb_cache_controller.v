module tb_cache_controller;

    parameter int ADDR_WIDTH  = 32;
    parameter int DATA_WIDTH  = 32;
    parameter int CACHE_LINES = 16;
    parameter int BLOCK_SIZE  = 4;

    logic clk;
    logic rst;

    logic cpu_req;
    logic [ADDR_WIDTH-1:0] cpu_addr;

    logic cpu_ready;
    logic [DATA_WIDTH-1:0] cpu_data;
    logic hit;

    // DUT

    cache_controller #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .CACHE_LINES(CACHE_LINES),
        .BLOCK_SIZE (BLOCK_SIZE)
    ) dut (
        .clk(clk),
        .rst(rst),

        .cpu_req(cpu_req),
        .cpu_addr(cpu_addr),

        .cpu_ready(cpu_ready),
        .cpu_data(cpu_data),
        .hit(hit)
    );

    // Clock Generation

    always #5 clk = ~clk;

    initial begin

        clk      = 0;
        rst      = 1;
        cpu_req  = 0;
        cpu_addr = 0;

        // Reset

        #20;
        rst = 0;

        //------------------------------------------------
        // TC1 : First Access (Expected MISS)
        //------------------------------------------------

        $display("\n===== TC1 =====");

        cpu_addr = 32'd20;
        cpu_req  = 1;

        wait(cpu_ready);

        cpu_req = 0;

        if (cpu_data == 32'd20)
            $display("TC1 DATA PASS");
        else
            $error("TC1 DATA FAIL");

        if (hit == 0)
            $display("TC1 MISS PASS");
        else
            $error("TC1 MISS FAIL");

        //------------------------------------------------
        // TC2 : Same Address Again (Expected HIT)
        //------------------------------------------------

        #20;

        $display("\n===== TC2 =====");

        cpu_addr = 32'd20;
        cpu_req  = 1;

        wait(cpu_ready);

        cpu_req = 0;

        if (cpu_data == 32'd20)
            $display("TC2 DATA PASS");
        else
            $error("TC2 DATA FAIL");

        if (hit == 1)
            $display("TC2 HIT PASS");
        else
            $error("TC2 HIT FAIL");

        //------------------------------------------------
        // TC3 : Different Address (Expected MISS)
        //------------------------------------------------

        #20;

        $display("\n===== TC3 =====");

        cpu_addr = 32'd50;
        cpu_req  = 1;

        wait(cpu_ready);

        cpu_req = 0;

        if (cpu_data == 32'd50)
            $display("TC3 DATA PASS");
        else
            $error("TC3 DATA FAIL");

        if (hit == 0)
            $display("TC3 MISS PASS");
        else
            $error("TC3 MISS FAIL");

        //------------------------------------------------
        // TC4 : Conflict Miss / Replacement Test
        // Address 84 maps to same cache index as 20
        //------------------------------------------------

        #20;

        $display("\n===== TC4 =====");

        cpu_addr = 32'd84;
        cpu_req  = 1;

        @(posedge cpu_ready);

        cpu_req = 0;

        #1;

        if (cpu_data == 32'd84)
            $display("TC4 DATA PASS");
        else
            $error("TC4 DATA FAIL");

        if (hit == 0)
            $display("TC4 MISS PASS");
        else
            $error("TC4 MISS FAIL");

        //------------------------------------------------
        // TC5 : Access 20 Again
        // Expected MISS because 84 replaced it
        //------------------------------------------------

        #20;

        $display("\n===== TC5 =====");

        cpu_addr = 32'd20;
        cpu_req  = 1;

        @(posedge cpu_ready);

        cpu_req = 0;

        #1;

        if (cpu_data == 32'd20)
            $display("TC5 DATA PASS");
        else
            $error("TC5 DATA FAIL");

        if (hit == 0)
            $display("TC5 REPLACEMENT PASS");
        else
            $error("TC5 REPLACEMENT FAIL");

        //------------------------------------------------

        #20;

        $display("\nSimulation Completed Successfully");
        $finish;

    end

endmodule