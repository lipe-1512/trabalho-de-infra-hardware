module S_1_to_32 (
    wire input bit,
    wire output bits32
);
    assign bits32 = {32{bit}};
endmodule