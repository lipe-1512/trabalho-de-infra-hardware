module mux_div_mult (
    wire input [31:0] zero, um, dois, //possíveis saída do mux
    wire input[1:0] escolha, // selecionar a saída correta
    wire output[31:0] out_mux_div_mult //saída após a seleção
);
assign out_mux_div_mult = (escolha == 2'b00) ? zero:
                          (escolha == 2'b01) ? um:
                          dois; // no caso de não está nos valores anteriores
endmodule