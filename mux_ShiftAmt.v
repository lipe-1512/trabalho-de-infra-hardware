module mux_ShiftAmt (
    wire input [4:0] zero, um, dois,
    wire input [1:0] escolha,
    wire output [4:0] saida_ShiftSrc
);
    assign saida_ShiftSrc = (saida_ShiftSrc == 1'b00) ? zero:
                            (saida_ShiftSrc == 1'b01) ? um:
                            dois;
endmodule