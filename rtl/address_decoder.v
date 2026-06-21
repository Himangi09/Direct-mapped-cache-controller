module address_decoder #(
    parameter int ADDR_WIDTH  = 32,
    parameter int CACHE_LINES = 16,
    parameter int BLOCK_SIZE  = 4,

    parameter int INDEX_BITS  = $clog2(CACHE_LINES),
    parameter int OFFSET_BITS = $clog2(BLOCK_SIZE),
    parameter int TAG_BITS    = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS
)(
    input logic [ADDR_WIDTH-1:0] addr,

    output logic [TAG_BITS-1:0] tag,
    output logic [INDEX_BITS-1:0] index,
    output logic [OFFSET_BITS-1:0] offset
);

    assign tag    = addr[ADDR_WIDTH-1 : INDEX_BITS + OFFSET_BITS];

    assign index  = addr[INDEX_BITS + OFFSET_BITS - 1 :
                         OFFSET_BITS];

    assign offset = addr[OFFSET_BITS - 1 : 0];

endmodule