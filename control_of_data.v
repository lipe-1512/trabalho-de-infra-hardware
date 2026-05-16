module control_of_data (
    input wire [31:0] saida_PCSource, 
    input wire [31:0] mem_reg_data, 
    input wire [31:0] B_out,
    input wire [4:0] rs, 
    input wire [4:0] rt,
    input wire [15:0] imediato,
    output wire [3:0] PC_1,
    output wire [4:0] rd, 
    output wire [4:0] shamt, 
    output wire [4:0] B_out_5bits, 
    output wire [4:0] mem_reg_out_5bits,
    output wire [25:0] jump_instruc,
    output wire [31:0] sh_out, 
    output wire [31:0] s_out, 
    output wire [31:0] sb_out
);
    wire [15:0] SH_B_in;
    wire [15:0] SH_mem_in;
    wire [7:0]  SB_B_in;
    wire [23:0] SB_mem_in;

    assign PC_1 = saida_PCSource[31:28];
    assign rd = imediato[15:11];
    assign B_out_5bits = B_out[4:0];
    assign mem_reg_out_5bits = mem_reg_data[4:0];
    assign shamt = imediato[10:6];
    assign jump_instruc = {rs, rt, imediato};
    
    // Preparação para stores (SH/SB)
    assign SH_B_in = B_out[15:0];
    assign SH_mem_in = mem_reg_data[31:16];
    assign SB_B_in = B_out[7:0];
    assign SB_mem_in = mem_reg_data[31:8];
    
    assign sh_out = {SH_mem_in, SH_B_in};
    assign sb_out = {SB_mem_in, SB_B_in};
    assign s_out = B_out;
endmodule