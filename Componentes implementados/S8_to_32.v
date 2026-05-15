module S8_to_32 (
    input wire [7:0] bit_8,
    output wire [31:0] bit_32
);
    assign bit_32 = {{24{1'b0}}, bit_8};
endmodule