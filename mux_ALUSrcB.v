module mux_ALUSrcB (
    input wire [31:0] zero, um, dois, tres, quatro,
    input wire [2:0] controle,
    output wire [31:0] saida_ALUSrcB
);
    assign saida_ALUSrcB = (controle == 3'b000) ? zero :
                           (controle == 3'b001) ? um :
                           (controle == 3'b010) ? dois :
                           (controle == 3'b011) ? tres :
                           quatro;
endmodule