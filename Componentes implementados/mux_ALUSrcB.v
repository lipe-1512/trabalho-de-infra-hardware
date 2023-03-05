module mux_ALUSrcB (
    input wire [31:0] zero, um, dois, tres, quatro, //possíveis saída do mux/
    input wire [1:0] controle, // selecionar a saída correta
    output wire [31:0] saida_USrcAB //saída após a seleção
);
    assign saida_USrcAB = (saida_USrcAB == 2'b00) ? zero:
                          (saida_USrcAB == 2'b01) ? um:
                          (saida_USrcAB == 2'b10) ? dois:
                          (saida_USrcAB == 2'b11) ? tres:
                          quatro; // no caso de não está nos valores anteriores
endmodule