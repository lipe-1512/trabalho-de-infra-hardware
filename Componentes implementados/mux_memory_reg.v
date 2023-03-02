module mux_memory_reg (
    wire input[31:0] zero, um, dois,tres,quatro,cinco, seis, sete, oito,
    wire input [3:0] escolha,
    wire output [31:0] data_out
);
assign data_out = (escolha == 4'b0000) ? zero:
                  (escolha == 4'b0001) ? um:
                  (escolha == 4'b0010) ? dois:
                  (escolha == 4'b0011) ? tres:
                  (escolha == 4'b0100) ? quatro:
                  (escolha == 4'b0101) ? cinco:
                  (escolha == 4'b0110) ? seis:
                  (escolha == 4'b0111) ? sete:
                  oito;
endmodule