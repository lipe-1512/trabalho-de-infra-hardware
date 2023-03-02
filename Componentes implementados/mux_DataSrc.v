module mux_DataSrc (
    wire input [31:0] zero, um, dois, tres, quatro, cinco, seis, sete, oito, nove, dez
    wire input [3:0] escolha,
    wire output [31:0] saida_DataSrc
);
    assign saida_DataSrc = (saida_DataSrc == 4'b0000) ? zero:
                           (saida_DataSrc == 4'b0001) ? um:
                           (saida_DataSrc == 4'b0010) ? dois:
                           (saida_DataSrc == 4'b0011) ? tres:
                           (saida_DataSrc == 4'b0100) ? quatro:
                           (saida_DataSrc == 4'b0101) ? cinco:
                           (saida_DataSrc == 4'b0110) ? seis:
                           (saida_DataSrc == 4'b0111) ? sete:
                           (saida_DataSrc == 4'b1000) ? oito:
                           (saida_DataSrc == 4'b1001) ? nove:
                           dez;
endmodule