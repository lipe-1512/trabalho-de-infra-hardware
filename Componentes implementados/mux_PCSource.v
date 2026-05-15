module mux_PCSource (
    input wire [31:0] zero, um, dois, tres, quatro, cinco,
    input wire [2:0] escolha,
    output wire [31:0] saida_PCSource
);
    assign saida_PCSource = (escolha == 3'b000) ? zero :
                            (escolha == 3'b001) ? um :
                            (escolha == 3'b010) ? dois :
                            (escolha == 3'b011) ? tres :
                            (escolha == 3'b100) ? quatro :
                            cinco;
endmodule