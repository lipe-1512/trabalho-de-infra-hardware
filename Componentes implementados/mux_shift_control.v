module mux_shift_control (
    input wire [31:0] zero, um,
    input wire escolha,
    output wire [31:0] saida_mux_shift_control // Changed to 32 bits
);
    assign saida_mux_shift_control = (escolha == 1'b0) ? zero : um;
endmodule