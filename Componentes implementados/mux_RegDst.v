module mux_RegDst (
    input wire [4:0] zero, um, dois, tres, quatro, cinco,
    input wire [2:0] escolha,
    output wire [4:0] saida_RegDst
);
    assign saida_RegDst = (escolha == 3'b000) ? zero :
                          (escolha == 3'b001) ? um :
                          (escolha == 3'b010) ? dois :
                          (escolha == 3'b011) ? tres :
                          (escolha == 3'b100) ? quatro :
                          cinco;
endmodule