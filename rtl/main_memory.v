module main_memory(

    input  logic [7:0] addr,
    output logic [31:0] data_out

);

    logic [31:0] memory [0:255];

    integer i;

    initial begin

        for(i=0;i<256;i=i+1)
            memory[i] = i;

    end

    assign data_out = memory[addr];

endmodule