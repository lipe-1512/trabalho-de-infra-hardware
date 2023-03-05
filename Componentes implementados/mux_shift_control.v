module mux_shift_control (
    input wire [31:0] zero, um,
    input wire escolha,
    output wire saida_mux_shift_contol
);
    assign saida_mux_shift_contol = (escolha == 1'b0) ? zero : um;
endmodule