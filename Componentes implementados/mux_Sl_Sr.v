module mux_Sl_Sr(
    input wire[31:0] zero, um, dois, tres, quatro, cinco, seis,
    input wire[2:0] escolha,
    output wire[31:0] out_mux_Sl_Sr
);
    assign out_mux_Sl_Sr = (escolha == 3'b000) ? zero:
                           (escolha == 3'b001) ? um:
                           (escolha == 3'b010) ? dois:
                           (escolha == 3'b011) ? tres:
                           (escolha == 3'b100) ? quatro:
                           (escolha == 3'b101) ? cinco:
                           seis;
endmodule