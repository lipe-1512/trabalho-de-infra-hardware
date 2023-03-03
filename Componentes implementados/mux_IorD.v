module mux_IorD (
    wire input [31:0] zero, um, dois, tres, quatro, //possíveis saída do mux
    wire input [1:0] escolha, // selecionar a saída correta
    wire output [31:0] saida_IorD //saída após a seleção
);
    assign saida_IorD = (saida_IorD == 2'b00) ? zero:
                        (saida_IorD == 2'b01) ? um:
                        (saida_IorD == 2'b10) ? dois:
                        (saida_IorD == 2'b11) ? tres:
                        quatro; // no caso de não está nos valores anteriores
endmodule