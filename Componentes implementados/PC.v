module PC (
    input wire clk, reset
);
    // Declaração explícita de todos os fios
    wire [5:0] OpCode;
    wire [4:0] rs, rt, rd, shamt, mux_reg_dst_out, shift_n_control_out, B_out_5bits, mem_reg_out_5bits;
    wire [15:0] imediato;
    wire [31:0] Imediato_32bits, imediato_branch, mux_mem_reg_out, pc_out, EPC_out, cause_control_out, IorDout, mem_out;
    wire [31:0] branch_A, branch_B, A_out, mux_res_A, mux_res_B, Alu_res, mem_reg_out, Load_out, store_out;
    wire [31:0] s_out, sh_out, sb_out, shift_input_control_out, reg_deslo_out, PC_source_res;
    wire [31:0] Mult_div_hi, Mult_div_lo, Mult_hi_out, Mult_lo_out, Div_hi_out, Div_lo_out, High_out, Low_out;
    wire [31:0] jump;
    wire [27:0] jump_shift;
    wire [25:0] jump_instruction;
    wire zero, neg, lt, gt, et, O;
    wire [31:0] Lt_extend;
    wire [2:0] IorD, Alu_Op, PC_Source, shift_control, mem_reg;
    wire mem_wr, ir_wr, reg_wr, wr_A, wr_B, Alu_out_wr, PC_wr, EPC_wr, mult_start, div_start, reset_out;
    wire [1:0] cause_control, reg_dst, Alu_Src_A, Alu_Src_B, load_control, store_control, Mult_div_lo, Mult_div_hi, Lo_wr, Hi_wr, shift_control_in, shift_n;
    wire [31:0] PC_1, rd_out, shamt_out, B_out_5bits_wire, mem_reg_out_5bits_wire, jump_instruc;

    parameter sp = 5'b11101;
    parameter ra = 5'b11111;

    // Instanciações com mapeamento nomeado para compatibilidade com VHDL
    RegDesloc regDeslc(
        .Clk(clk), .Reset(reset), .Shift(shift_control), .N(shift_n_control_out), 
        .Entrada(shift_input_control_out), .Saida(reg_deslo_out)
    );
    
    Memoria mem(
        .Address(IorDout), .Clock(clk), .Wr(mem_wr), .Datain(store_out), .Dataout(mem_out)
    );
    
    control_of_data c_o_d(
        .saida_PCSource(PC_source_res), .mem_reg_data(mux_mem_reg_out), .B_out(B_out),
        .rs(rs), .rt(rt), .imediato(imediato), .PC_1(PC_1), .rd(rd_out), .shamt(shamt_out),
        .jump_instruc(jump_instruction), .B_out_5bits(B_out_5bits_wire),
        .mem_reg_out_5bits(mem_reg_out_5bits_wire), .sh_out(sh_out), .sb_out(sb_out), .s_out(s_out)
    );
    
    Banco_reg BR(
        .Clk(clk), .Reset(reset), .RegWrite(reg_wr), .ReadReg1(rs), .ReadReg2(rt), 
        .WriteReg(mux_reg_dst_out), .WriteData(mux_mem_reg_out), .ReadData1(branch_A), .ReadData2(branch_B)
    );
    
    Instr_Reg IR(
        .Clk(clk), .Reset(reset), .Load_ir(ir_wr), .Entrada(mem_out), 
        .Instr31_26(OpCode), .Instr25_21(rs), .Instr20_16(rt), .Instr15_0(imediato)
    );
    
    ula32 ALU(
        .A(mux_res_A), .B(mux_res_B), .Seletor(Alu_Op), .S(Alu_res), 
        .Overflow(O), .Negativo(neg), .z(zero), .Igual(et), .Maior(gt), .Menor(lt)
    );
    
    // Registradores VHDL
    Registrador PC_reg(.Clk(clk), .Reset(reset), .Load(PC_wr), .Entrada(PC_source_res), .Saida(pc_out));
    Registrador A_reg(.Clk(clk), .Reset(reset), .Load(wr_A), .Entrada(branch_A), .Saida(A_out));
    Registrador B_reg(.Clk(clk), .Reset(reset), .Load(wr_B), .Entrada(branch_B), .Saida(B_out));
    Registrador AluOut_reg(.Clk(clk), .Reset(reset), .Load(Alu_out_wr), .Entrada(Alu_res), .Saida(Alu_res)); // Nota: Saida nomeada como Alu_res no original
    Registrador MemDataRegister(.Clk(clk), .Reset(reset), .Load(mem_wr), .Entrada(mem_out), .Saida(mem_reg_out));
    Registrador EPC_reg(.Clk(clk), .Reset(reset), .Load(EPC_wr), .Entrada(Alu_res), .Saida(EPC_out));
    Registrador HI_reg(.Clk(clk), .Reset(reset), .Load(Hi_wr), .Entrada(Mult_div_hi), .Saida(High_out));
    Registrador LO_reg(.Clk(clk), .Reset(reset), .Load(Lo_wr), .Entrada(Mult_div_lo), .Saida(Low_out));

    // Multiplexadores
    mux_PCSource muxpcsource(.zero({{24{1'b0}}, mem_out[7:0]}), .um(A_out), .dois(Alu_res), .tres({pc_out[31:28], jump_shift}), .quatro(Alu_res), .cinco(EPC_out), .escolha(PC_Source), .saida_PCSource(PC_source_res));
    mux_div_mult cc(.zero(32'hFD), .um(32'hFE), .dois(32'hFF), .escolha(cause_control), .out_mux_div_mult(cause_control_out));
    mux_IorD iord(.zero(pc_out), .um(cause_control_out), .dois(A_out), .tres(B_out), .quatro(Alu_res), .escolha(IorD), .saida_IorD(IorDout));
    mux_RegDst regdst(.zero(rt), .um(rd_out), .dois(ra), .tres(sp), .escolha(reg_dst), .saida_RegDst(mux_reg_dst_out));
    mux_ALUSrcA muxalusrca(.zero(pc_out), .um(mem_out), .dois(A_out), .tres(32'h1D), .controle(Alu_Src_A), .saida_ALUSrcA(mux_res_A));
    mux_ALUSrcB muxalusrcb(.zero(B_out), .um(32'h04), .dois(Imediato_32bits), .tres(mem_reg_out), .quatro(imediato_branch), .controle(Alu_Src_B), .saida_ALUSrcB(mux_res_B));
    mux_memory_reg muxmemtoreg(.zero(High_out), .um(Low_out), .dois(Load_out), .tres(Alu_res), .quatro(Lt_extend), .cinco(reg_deslo_out), .seis(Imediato_32bits), .sete(32'hE3), .escolha(mem_reg), .memory_reg_out(mux_mem_reg_out));
    mux_DataSrc load(.zero({{16{1'b0}}, mem_reg_out[15:0]}), .um({{24{1'b0}}, mem_reg_out[7:0]}), .dois(mem_reg_out), .escolha(load_control), .saida_DataSrc(Load_out));
    mux_DataSrc store(.zero(sh_out), .um(sb_out), .dois(s_out), .escolha(store_control), .saida_DataSrc(store_out));
    mux_shift_control si(.zero(A_out), .um(Imediato_32bits), .escolha(shift_control_in), .saida_mux_shift_control(shift_input_control_out));
    mux_ShiftAmt sn(.zero(B_out_5bits_wire), .um(5'b10000), .dois(shamt_out), .escolha(shift_n), .saida_ShiftAmt(shift_n_control_out));
    mux_div_mult multOrDivHI(.zero(Mult_hi_out), .um(Div_hi_out), .dois(Mult_div_hi), .escolha(Hi_wr), .out_mux_div_mult(Mult_div_hi));
    mux_div_mult MultOrDivLO(.zero(Mult_lo_out), .um(Div_lo_out), .dois(Mult_div_lo), .escolha(Lo_wr), .out_mux_div_mult(Mult_div_lo));

    // Extensão e Deslocamento
    S_16_to_32 imediatoExtender(.multX2(imediato), .out_32(Imediato_32bits));
    S_1_to_32 LTExtender(.bit(lt), .bits32(Lt_extend));
    SL_32_to_32 imediatoShifter(.local(Imediato_32bits), .out_Sl(imediato_branch));
    SL_32_to_32 jumpShifter(.local({jump_instruction, 2'b00}), .out_Sl(jump_shift)); // Ajuste para 28 bits

    // Divisor e Multiplicador (Assumindo componentes VHDL/Verilog existentes)
    // Mult multiplication(.clk(clk), .reset(reset), .mult_start(mult_start), .A(A_out), .B(B_out), .Hi(Mult_hi_out), .Lo(Mult_lo_out));
    Div division(.clk(clk), .reset(reset), .div_start(div_start), .A(A_out), .B(B_out), .div_zero(), .Hi(Div_hi_out), .Lo(Div_lo_out));

    // Unidade de Controle
    control_Unit UnitOfControl(
        .clk(clk), .reset(reset), .O(O), .OpCode404(OpCode404), .div_zero(), .OpCode(OpCode), .Funct(), 
        .zero(zero), .neg(neg), .lt(lt), .gt(gt), .et(et), .IorD(IorD), .mem_wr(mem_wr), 
        .cause_control(cause_control), .ir_wr(ir_wr), .reg_wr(reg_wr), .wr_A(wr_A), .wr_B(wr_B), 
        .mem_reg(mem_reg), .reg_dst(reg_dst), .Alu_Src_A(Alu_Src_A), .Alu_Src_B(Alu_Src_B), 
        .Alu_Op(Alu_Op), .Alu_out_wr(Alu_out_wr), .PC_Source(PC_Source), .PC_wr(PC_wr), .EPC_wr(EPC_wr), 
        .load_control(load_control), .store_control(store_control), .Mult_div_lo(Mult_div_lo), 
        .Mult_div_hi(Mult_div_hi), .Lo_wr(Lo_wr), .hi_wr(Hi_wr), .reset_out(reset_out), 
        .shift_control_in(shift_control_in), .shift_n(shift_n), .shift_control(shift_control), 
        .mult_start(mult_start), .div_start(div_start)
    );
endmodule