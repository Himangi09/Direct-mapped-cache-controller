module cache_storage #(

    parameter int ADDR_WIDTH  = 32,
    parameter int DATA_WIDTH  = 32,
    parameter int CACHE_LINES = 16,
    parameter int BLOCK_SIZE  = 4,

    parameter int INDEX_BITS  = $clog2(CACHE_LINES),
    parameter int OFFSET_BITS = $clog2(BLOCK_SIZE),
    parameter int TAG_BITS    = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS

)(
    input  logic clk,

    input  logic write_en,

    input  logic [INDEX_BITS-1:0] write_index,
    input  logic [TAG_BITS-1:0]   write_tag,
    input  logic [DATA_WIDTH-1:0] write_data,

    input  logic [INDEX_BITS-1:0] read_index,

    output logic [TAG_BITS-1:0]   read_tag,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic                  read_valid
);

    logic [TAG_BITS-1:0]   tag_mem   [0:CACHE_LINES-1];
    logic [DATA_WIDTH-1:0] data_mem  [0:CACHE_LINES-1];
    logic                  valid_mem [0:CACHE_LINES-1];

    integer i;

    initial begin

        for(i=0;i<CACHE_LINES;i=i+1) begin
            tag_mem[i]   = '0;
            data_mem[i]  = '0;
            valid_mem[i] = 1'b0;
        end

    end

    // Write Port

    always_ff @(posedge clk) begin

        if(write_en) begin

            tag_mem[write_index]   <= write_tag;
            data_mem[write_index]  <= write_data;
            valid_mem[write_index] <= 1'b1;

        end

    end

    // Read Port

    assign read_tag   = tag_mem[read_index];
    assign read_data  = data_mem[read_index];
    assign read_valid = valid_mem[read_index];

endmodule