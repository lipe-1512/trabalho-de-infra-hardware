module mux_RegDst (
    wire input [4:0] zero, um, dois, tres, quatro, cinco, //possíveis saída do mux
    wire input [2:0] escolha, // selecionar a saída correta
    wire output [4:0] saida_RegDst //saída após a seleção
);
assign saida_RegDst = (saida_RegDst == 3'b000) ? zero:
                      (saida_RegDst == 3'b001) ? um:
                      (saida_RegDst == 3'b010) ? dois:
                      (saida_RegDst == 3'b011) ? tres:
                      (saida_RegDst == 3'b100) ? quatro:
                      cinco; // no caso de não está nos valores anteriores
endmodule