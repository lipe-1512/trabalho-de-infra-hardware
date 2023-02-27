module mux_RegDst (
    wire input [4:0] zero, um, dois, tres, quatro, cinco,
    wire input [2:0] escolha,
    wire output [4:0] saida_RegDst
);
assign saida_RegDst = (saida_RegDst == 3'b000) ? zero:
                      (saida_RegDst == 3'b001) ? um:
                      (saida_RegDst == 3'b010) ? dois:
                      (saida_RegDst == 3'b011) ? tres:
                      (saida_RegDst == 3'b100) ? quatro:
                      cinco;
    
endmodule