module mux_div_mult (
    input wire [31:0] zero, um, dois,
    input wire [1:0] escolha,
    output wire [31:0] out_mux_div_mult
);
    assign out_mux_div_mult = (escolha == 2'b00) ? zero :
                              (escolha == 2'b01) ? um :
                              dois;
endmodule