module mux_ExceCtrl (
    wire input [31:0] zero, um, dois, tres, //possíveis saída do mux
    wire input [1:0] escolha, // selecionar a saída correta
    wire output [31:0] saida_ExceCtrl //saída após a seleção
);
    assign saida_ExceCtrl = (saida_ExceCtrl == 2'b00) ? zero:
                            (saida_ExceCtrl == 2'b01) ? um:
                            (saida_ExceCtrl == 2'b10) ? dois:
                            tres; // no caso de não está nos valores anteriores

endmodule