module moduleName (
    wire input [7:0] bit_8,
    wire output [31:0] bit_32
);
    assign bit_32 = {24{1'b0}bit_8};
endmodule