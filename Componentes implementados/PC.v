module PC (
    input clk, reset
);
    //DATA WIRES
    wire [5:0] OpCode;
    wire OpCode404;
    wire [4:0] rs, rt, rd, shamt, mux_reg_dst_out, shift_n_control_out, B_out_5bits, mem_reg_out_5bits;
    wire [15:0] imediato;
    wire [31:0] Imediato_32bits, imediato_branch, mux_mem_reg_out, pc_out, EPC_out, cause_control_out, IorDout, mem_out;
    wire [31:0] branch_A, branch_B, A_out, mux_res_A, mux_res_B, mux_res, Alu_res, mem_reg_out, Load_out, store_out;
    wire [31:0] s_out, sh_out, sb_out, shift_input_control_out, reg_deslo_out, PC_source_res, 
    
    //MULT E DIV
    wire [31:0] Mult_div_hi, Mult_div_lo, Mult_hi_out, Mult_lo_out, Div_hi_out, Div_lo_out, High_out, Low_out;

    //JUMP
    wire [31:0] jump;
    wire [27:0] jump_shift;
    wire [25:0] jump_instruction;

    //ALU
    wire zero, neg, lt, gt, et, O;
    wire [31:0] Lt_extend;

    //CONTROL SIGNAL
    wire[2:0] IorD,
    wire mem_wr,
    wire[1:0] cause_control,
    wire ir_wr,
    wire reg_wr,
    wire wr_A,
    wire wr_B,
    wire [2:0] mem_reg,
    wire [1:0] reg_dst,
    wire [1:0] Alu_Src_A,
    wire [2:0] Alu_Src_B,
    wire [2:0] Alu_Op,
    wire Alu_out_wr,
    wire [2:0] PC_Source,
    wire PC_wr,
    wire EPC_wr,  
    wire [1:0] load_control,
    wire [1:0] store_control,
    wire mult_start,
    wire div_start,
    wire Mult_div_lo,
    wire Mult_div_hi,
    wire Lo_wr,
    wire Hi_wr,
    wire reset_out,
    wire [1:0] shift_control_in,
    wire [2:0] shift_control,
    wire [1:0] shift_n

    parameter sp = 5'b11101;
    parameter ra = 5'b11111;

    RegDesloc regDeslc(
        clk, reset, Shift_control, shift_n_control_out, shift_input_control_out, reg_deslo_out
    );

    Memoria mem(
        IorDOut, clk, mem_wr, store_out, mem_out
    );

    control_of_data c_o_d(
        pc_out, imediato, mem_reg_out, RS, RT, B_out,
        PC_1, RD, shamt, jump_instruction, B_out_5bits, 
        mem_reg_out_5bits, sh_out, sb_out, s_out
    );

    Banco_reg BR(
        clk, reset, reg_wr, RS, RT, mux_reg_dst_out, mux_mem_reg_out, branch_A, branch_B
    );

    Instr_Reg IR(
        clk, reset, ir_wr, mem_out, OpCode, RS, RT, imediato
    );

    ula32 ALU(
        mux_res_A, mux_res_B, Alu_Op, mux_res, O, neg, zero, et, gt, lt 
    );

    //REGs

    Registrador PC(
        clk, reset, PC_wr, PC_source_res, pc_out
    );

    Registrador A(
        clk, reset, wr_A, branch_A, A_out
    );

    Registrador B(
        clk, reset, wr_B, branch_B, B_out
    );

    Registrador AluOut(
        clk, reset, Alu_out_wr, mux_res, Alu_res
    );

    Registrador MemDataRegister(
        clk, reset, Mem_wr, mem_out, mem_reg_out
    );

    Registrador EPC(
        clk, reset, EPC_wr, mux_res, EPC_out
    );

    Registrador HI(
        clk, reset, Hi_wr, mult_div_hi_out, High_out 
    );

    Registrador LO(
        clk, reset, Lo_wr, mult_div_lo_out, Low_out
    );

    //MUXS

    muxpcsource muxpcsource(
        {{24{1'b0}}, mem_out[7:0]}, A_out, mux_res, {pc_out[31:28], jump_shift}, Alu_res, EPC_out, PC_Source, PC_source_res
    );

    muxcausecontrol cc(
        32'b00000000000000000000000011111101, 32'b00000000000000000000000011111110, 32'b00000000000000000000000011111111, cause_control, cause_control_out
    );
    
    muxiord iord(
        pc_out, cause_control_out, A_out, B_out, Alu_res, IorD, IorDOut
    );

    muxregdst regdst(
        RT, RD, ra, sp, reg_dst, mux_reg_dst_out
    );

    muxalusrcA muxalusrca(
        pc_out, mem_out, A_out, 32'b00000000000000000000000000011101, Alu_Src_A, mux_res_A
    );

    muxalusrcB muxalusrcb(
        B_out, 32'b00000000000000000000000000000100, Imediato_32bits,
        mem_reg_out, imediato_branch, Alu_Src_B, mux_res_B
    );

    muxmemtoreg muxmemtoreg(
        High_out, Low_out, Load_out, Alu_res, Lt_extend, reg_deslo_out, Imediato_32bits, 32'b00000000000000000000000011100011, mem_reg, mux_mem_reg_out
    );

    muxload load(
        {{16{1'b0}}, mem_reg_out[15:0]}, {{24{1'b0}}, mem_reg_out[7:0]}, mem_reg_out, Load_control, Load_out
    );

    muxStore store(
        sh_out, sb_out, s_out, Store_control, store_out
    );

    muxShiftInput si(
        A_out, Imediato_32bits, B_out, Shift_control_in, shift_input_control_out
    );

    muxshiftN sn(
        B_out_5bits, 5'b10000, shamt, mem_reg_out_5bits, Shift_n, shift_n_control_out 
    );

    muxmultordiv multOrDivHI(
        Mult_hi_out, Div_hi_out, Mult_div_hi, mult_div_hi_out
    );

    muxmultordiv MultOrDivLO(
        Mult_lo_out, Div_lo_out, Mult_div_lo, mult_div_lo_out
    );


    //Signal Extend

    signext16_32 imediatoExtender(
        imediato, Imediato_32bits
    );

    signext1_32 LTExtender(
        lt, Lt_extend
    );


    //Shift Left 2

    shiftleft2_32_32 imediatoShifter(
        Imediato_32bits, imediato_branch
    );

    shiftleft2_26_28 jumpShifter(
        jump_instruction, jump_shift
    );


    //Mult e Div

    Mult multiplication(
        clk, reset, mult_start, A_out, B_out, Mult_hi_out, Mult_lo_out  
    );

    Div division(
        clk, reset, div_start, A_out, B_out, div_zero, Div_hi_out, Div_lo_out
    );

    //control_unit

    ControlUnit UnitOfControl(
        clk, reset, O, OpCode404, imediato[5:0], div_zero, OpCode, zero, lt, et, gt, neg, IorD, cause_control, mem_wr, ir_wr, 
        reg_dst, mem_reg, reg_wr, wr_A, wr_B, Alu_Src_A, Alu_Src_B,
        Alu_Op, Alu_out_wr, PC_Source, PC_wr, EPC_wr,
        Mem_wr, Load_control, Store_control, 
        Mult_div_lo, Mult_div_hi, Lo_wr, hi_wr,
        Shift_control_in, Shift_n, Shift_control, mult_start, div_start,reset 
    );




endmodule