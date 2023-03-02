module mux_IorD (
    wire input [31:0] zero, um, dois, tres, quatro,
    wire input [1:0] escolha,
    wire output [31:0] saida_IorD
);
    assign saida_IorD = (saida_IorD == 2'b00) ? zero:
                        (saida_IorD == 2'b01) ? um:
                        (saida_IorD == 2'b10) ? dois:
                        (saida_IorD == 2'b11) ? tres:
                        quatro;
endmodule