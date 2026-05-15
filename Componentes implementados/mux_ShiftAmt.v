module mux_ShiftAmt (
    input wire [4:0] zero, um, dois,
    input wire [1:0] escolha,
    output wire [4:0] saida_ShiftAmt
);
    assign saida_ShiftAmt = (escolha == 2'b00) ? zero :
                            (escolha == 2'b01) ? um :
                            dois;
endmodule