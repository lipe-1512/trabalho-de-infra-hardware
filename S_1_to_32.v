module S_1_to_32 (
    input wire bit,
    output wire [31:0] bits32
);
    assign bits32 = {32{bit}};
endmodule