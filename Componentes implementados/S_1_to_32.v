module S_1_to_32 (
    wire input bit, // bit de entrada de 1 bit
    wire output bits32 // bit de saída de 32 bits
);
    assign bits32 = {32{bit}}; //repetir o bit de entrada 32 vezes
endmodule