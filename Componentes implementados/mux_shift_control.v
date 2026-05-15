module mux_shift_control (
    input wire [31:0] zero, um,
    input wire escolha,
    output wire saida_mux_shift_control
);
    assign saida_mux_shift_control = (escolha == 1'b0) ? zero : um;
endmodule