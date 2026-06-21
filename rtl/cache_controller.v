module cache_controller #(

    parameter int ADDR_WIDTH  = 32,
    parameter int DATA_WIDTH  = 32,
    parameter int CACHE_LINES = 16,
    parameter int BLOCK_SIZE  = 4,

    parameter int INDEX_BITS  = $clog2(CACHE_LINES),
    parameter int OFFSET_BITS = $clog2(BLOCK_SIZE),
    parameter int TAG_BITS    = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS

)(
    input  logic clk,
    input  logic rst,

    input  logic cpu_req,
    input  logic [ADDR_WIDTH-1:0] cpu_addr,

    output logic cpu_ready,
    output logic [DATA_WIDTH-1:0] cpu_data,
    output logic hit
);

    // ==================================================
    // FSM
    // ==================================================

    typedef enum logic [1:0] {
        IDLE,
        CHECK,
        REFILL
    } state_t;

    state_t state, next_state;

    // ==================================================
    // Decoder Signals
    // ==================================================

    logic [TAG_BITS-1:0] req_tag;
    logic [INDEX_BITS-1:0] index;
    logic [OFFSET_BITS-1:0] offset;

    // ==================================================
    // Cache Signals
    // ==================================================

    logic [TAG_BITS-1:0] cache_tag;
    logic [DATA_WIDTH-1:0] cache_data;
    logic cache_valid;

    logic write_en;

    // ==================================================
    // Comparator Signals
    // ==================================================

    logic tag_match;

    // ==================================================
    // Memory Signals
    // ==================================================

    logic [DATA_WIDTH-1:0] mem_data;

    // ==================================================
    // Address Decoder
    // ==================================================

    address_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .CACHE_LINES(CACHE_LINES),
        .BLOCK_SIZE(BLOCK_SIZE)
    ) decoder (
        .addr(cpu_addr),
        .tag(req_tag),
        .index(index),
        .offset(offset)
    );

    // ==================================================
    // Cache Storage
    // ==================================================

    cache_storage #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .CACHE_LINES(CACHE_LINES),
        .BLOCK_SIZE(BLOCK_SIZE)
    ) cache (

        .clk(clk),

        .write_en(write_en),

        .write_index(index),
        .write_tag(req_tag),
        .write_data(mem_data),

        .read_index(index),

        .read_tag(cache_tag),
        .read_data(cache_data),
        .read_valid(cache_valid)
    );

    // ==================================================
    // Comparator
    // ==================================================

    tag_comparator #(
        .TAG_BITS(TAG_BITS)
    ) comparator (
        .requested_tag(req_tag),
        .stored_tag(cache_tag),
        .tag_match(tag_match)
    );

    // ==================================================
    // Hit Detector
    // ==================================================

    hit_detector hit_det (
        .valid_bit(cache_valid),
        .tag_match(tag_match),
        .hit(hit)
    );

    // ==================================================
    // Main Memory
    // ==================================================

    main_memory memory (
        .addr(cpu_addr[7:0]),
        .data_out(mem_data)
    );

    // ==================================================
    // State Register
    // ==================================================

    always_ff @(posedge clk or posedge rst)
    begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // ==================================================
    // Next State Logic
    // ==================================================

    always_comb
    begin

        next_state = state;

        case(state)

            IDLE:
            begin
                if(cpu_req)
                    next_state = CHECK;
            end

            CHECK:
            begin
                if(hit)
                    next_state = IDLE;
                else
                    next_state = REFILL;
            end

            REFILL:
            begin
                next_state = IDLE;
            end

        endcase

    end

    // ==================================================
    // Output Logic
    // ==================================================

    always_comb
    begin

        cpu_ready = 1'b0;
        cpu_data  = '0;
        write_en  = 1'b0;

        case(state)

            CHECK:
            begin

                if(hit)
                begin
                    cpu_data  = cache_data;
                    cpu_ready = 1'b1;
                end

            end

            REFILL:
            begin

                cpu_data  = mem_data;
                cpu_ready = 1'b1;

                write_en  = 1'b1;

            end

        endcase

    end

endmodule