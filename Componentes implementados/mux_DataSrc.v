module mux_DataSrc (
    input wire [31:0] zero, um, dois, tres, quatro, cinco, seis, sete, oito, nove, dez,
    input wire [3:0] escolha,
    output wire [31:0] saida_DataSrc
);
    assign saida_DataSrc = (escolha == 4'b0000) ? zero :
                           (escolha == 4'b0001) ? um :
                           (escolha == 4'b0010) ? dois :
                           (escolha == 4'b0011) ? tres :
                           (escolha == 4'b0100) ? quatro :
                           (escolha == 4'b0101) ? cinco :
                           (escolha == 4'b0110) ? seis :
                           (escolha == 4'b0111) ? sete :
                           (escolha == 4'b1000) ? oito :
                           (escolha == 4'b1001) ? nove :
                           dez;
endmodule