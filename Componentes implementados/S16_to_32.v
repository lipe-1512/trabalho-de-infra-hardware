module S_16_to_32 (
    input wire[15:0] multX2, // vetor de 16 bits que será estendido com o bit mais significativo
    output wire[31:0] out_32 // vetor saída de 32 bits 
);
assign out_32 = {16{multX2[15]},{multX2}}; // multiplica por 16 o mais significativo e soma 
endmodule