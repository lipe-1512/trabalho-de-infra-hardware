module moduleName (
    wire input [7:0] bit_8, // bits de entrada para ser extendido
    wire output [31:0] bit_32  // valor de saída de 32 bits
);
    assign bit_32 = {24{1'b0},bit_8}; // extende o valor acrescentando zero
endmodule