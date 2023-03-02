module S_16_to_32 (
    input wire[15:0] multX2,
    output wire[31:0] out_32
);
assign out_32 = {16{multX2[15]}{multX2}};
endmodule