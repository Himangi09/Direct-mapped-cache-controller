module tag_comparator #(
    parameter int TAG_BITS = 26
)(
    input  logic [TAG_BITS-1:0] requested_tag,
    input  logic [TAG_BITS-1:0] stored_tag,

    output logic tag_match
);

    assign tag_match = (requested_tag == stored_tag);

endmodule