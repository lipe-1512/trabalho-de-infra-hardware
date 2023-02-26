module mux_ALUSrcA (
    input wire [31:0] zero, um, dois, tres,
    input wire [1:0] controle,
    output wire [31:0] saida_USrcAB
);
    assign saida_USrcA = (saida_USrcAB == 2'b00) ? zero:
                         (saida_USrcAB == 2'b01) ? um:
                         (saida_USrcAB == 2'b10) ? dois:
                         tres;
endmodule