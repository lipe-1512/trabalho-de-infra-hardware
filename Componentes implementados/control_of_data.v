module control_of_data (
    input wire [31:0] saida_PCSource, mem_reg_data, B_out,
    input wire [4:0] rs, rt,
    input wire [15:0] imediato,
   
    output wire [3:0] PC_1
    output wire [4:0] rd, shamt,
    output wire [25:0] jump_instruc,
    output wire [31:0] sh_out, s_out, sb_out
);

    //Stores
    wire [15:0] SH_B_in;
    wire [15:0] SH_mem_in;
    
    wire [7:0] SB_B_in;
    wire [23:0] SB_mem_in;

    assign SH_B_in = B_out[15:0];
    assign SH_mem_in = mem_reg_data[31:16];

    assign SB_B_in = B_out[7:0];
    assign SB_mem_in = mem_reg_data[31:8];

    assign PC_1 = saida_PCSource[31:28];
    assign rd = imediato[15:11];
    assign shamt =imediato[10:6];
    assign jump_instruc = {rs, rt, imediato};
    assign sh_out = {SH_mem_in, SH_B_in};
    assign sb_out = {SB_mem_in, SB_B_in};
    assign s_out = B_out
    
endmodule