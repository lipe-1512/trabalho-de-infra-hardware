module SL_32_to_32 (
    input wire [31:0] local,
    output wire [31:0] out_Sl
);
    assign out_Sl = local << 2;
endmodule