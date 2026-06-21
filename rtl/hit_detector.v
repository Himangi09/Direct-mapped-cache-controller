module hit_detector(
    input  logic valid_bit,
    input  logic tag_match,

    output logic hit
);

    assign hit = valid_bit & tag_match;

endmodule