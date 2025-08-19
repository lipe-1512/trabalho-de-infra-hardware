module mux_ShiftAmt (
    wire input [4:0] zero, um, dois, //possíveis saída do mux
    wire input [1:0] escolha, // selecionar a saída correta
    wire output [4:0] saida_ShiftSrc //saída após a seleção
);
    assign saida_ShiftSrc = (saida_ShiftSrc == 1'b00) ? zero:
                            (saida_ShiftSrc == 1'b01) ? um:
                            dois; // no caso de não está nos valores anteriores
endmodule