module mux_IorD (
    input wire [31:0] zero, um, dois, tres, quatro,
    input wire [2:0] escolha,
    output wire [31:0] saida_IorD
);
    assign saida_IorD = (escolha == 3'b000) ? zero :
                        (escolha == 3'b001) ? um :
                        (escolha == 3'b010) ? dois :
                        (escolha == 3'b011) ? tres :
                        quatro;
endmodule