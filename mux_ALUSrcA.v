module mux_ALUSrcA (
    input wire [31:0] zero, um, dois, tres,
    input wire [1:0] controle,
    output wire [31:0] saida_ALUSrcA
);
    assign saida_ALUSrcA = (controle == 2'b00) ? zero :
                           (controle == 2'b01) ? um :
                           (controle == 2'b10) ? dois :
                           tres;
endmodule