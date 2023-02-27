module mux_ExceCtrl (
    wire input [31:0] zero, um, dois, tres
    wire input [1:0] escolha,
    wire output [31:0] saida_ExceCtrl
);
    assign saida_ExceCtrl = (saida_ExceCtrl == 2'b00) ? zero:
                            (saida_ExceCtrl == 2'b01) ? um:
                            (saida_ExceCtrl == 2'b10) ? dois:
                            tres;

endmodule