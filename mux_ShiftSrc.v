module mux_ShiftSrc (
    input wire [4:0] zero, um, dois,
    input wire escolha,
    output wire [4:0] saida_ShiftSrc
);
    assign saida_ShiftSrc = (escolha == 1'b0) ? zero :
                            (escolha == 1'b1) ? um :
                            dois;
endmodule