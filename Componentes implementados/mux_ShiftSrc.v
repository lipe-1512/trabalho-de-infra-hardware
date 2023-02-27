module mux_ShiftSrc (
    wire input [4:0] zero, um, dois,
    wire input [0] escolha,
    wire output [4:0] saida_ShiftSrc
);
    assign saida_ShiftSrc = (saida_ShiftSrc == 1'b0) ? zero:
                            (saida_ShiftSrc == 1'b1) ? um:
                            dois;
endmodule