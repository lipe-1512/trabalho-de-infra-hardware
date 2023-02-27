module mux_PCSource (
    wire input [31:0] zero, um, dois tres, quatro, cinco,
    wire input [2:0] escolha,
    wire output [31:0] saida_PCSource
);
    assign saida_PCSource = (saida_PCSource == 3'b000) ? zero:
                            (saida_PCSource == 3'b001) ? um:
                            (saida_PCSource == 3'b010) ? dois:
                            (saida_PCSource == 3'b011) ? tres:
                            (saida_PCSource == 3'b100) ? quatro:
                            cinco;
endmodule