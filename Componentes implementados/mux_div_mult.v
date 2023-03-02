module mux_div_mult (
    wire input [31:0] zero, um, dois,
    wire input[1:0] escolha,
    wire output[31:0] out_mux_div_mult
);
assign out_mux_div_mult = (escolha == 2'b00) ? zero:
                          (escolha == 2'b01) ? um:
                          dois;
endmodule