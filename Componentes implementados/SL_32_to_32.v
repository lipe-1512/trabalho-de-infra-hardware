module SL_32_to_32(
    input wire[31:0] local, //valor que será deslocado para esquerda
    output wire[31:0] out_Sl // valor de saída após o deslocamento
);
    assign out_Sl = local << 2; // realizar o deslocamento para esquerda
endmodule