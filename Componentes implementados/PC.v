module PC (
    input clk, reset
);
    //DATA WIRES
    wire [5:0] OpCode;
    wire OpCode404;
    wire [4:0] rs, rt, rd, shamt, MuxRegDstOut, ShiftNControlOut;
    wire [15:0] imediato;
    wire [31:0] ImediatoExtendido32bits, ImediatoToBrench, MuxMemToRegOut, PCOut, EPCOut, CauseControlOut, IorDout, MemOut;
    wire [31:0] BRoutA, BRoutB, AOut, MuxResultA, MuxResultB, AluResult, AluOutResult, MemDataRegisterOut, LoadOut, StoreOut;
    wire [31:0] SOut, SHOut, SBOut, ShiftInputControlOut, RegDeslocOut, PCSourceResult, 
    
    //MULT E DIV
    wire [31:0] Mult_div_hi, Mult_div_lo, MultHiOut, MultLoOut, DivHiOut, DivLoOut, HighOut, LowOut;

    //JUMP
    wire [31:0] JumpAddress;
    wire [27:0] JumpShifted;
    wire [25:0] jumpFromInstruction;

    //ALU
    wire zero, neg, lt, gt, et, O;
    wire [31:0] LTExtended;

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
        clk, reset, Shift_control, ShiftNControlOut, ShiftInputControlOut, RegDeslocOut
    );

    Memoria mem(
        IorDOut, clk, mem_wr, StoreOut, MemOut
    );

    control_of_data c_o_d(
        PCOut, imediato, MemDataRegisterOut, RS, RT, BOut,
        PCAux, RD, SHAMT, JumpFromInstruction, BOut5bits, 
        MemDataRegisterOut5bits, SHOut, SBOut, SOut
    );

    Banco_reg BR(
        clk, reset, reg_wr, RS, RT, MuxRegDstOut, MuxMemToRegOut, BRoutA, BRoutB
    );

    Instr_Reg IR(
        clk, reset, ir_wr, MemOut, OpCode, RS, RT, imediato
    );

    ula32 ALU(
        MuxResultA, MuxResultB, Alu_Op, AluResult, O, neg, zero, et, gt, lt 
    );

    //REGs

    Registrador PC(
        clk, reset, PC_wr, PCSourceResult, PCOut
    );

    Registrador A(
        clk, reset, wr_A, BRoutA, AOut
    );

    Registrador B(
        clk, reset, wr_B, BRoutB, BOut
    );

    Registrador AluOut(
        clk, reset, Alu_out_wr, AluResult, AluOutResult
    );

    Registrador MemDataRegister(
        clk, reset, Mem_wr, MemOut, MemDataRegisterOut
    );

    Registrador EPC(
        clk, reset, EPC_wr, AluResult, EPCOut
    );

    Registrador HI(
        clk, reset, Hi_wr, MultOrDivHighOut, HighOut 
    );

    Registrador LO(
        clk, reset, Lo_wr, MultOrDivLowOut, LowOut
    );

    //MUXS

    muxpcsource muxpcsource(
        {{24{1'b0}}, MemOut[7:0]}, AOut, AluResult, {PCOut[31:28], JumpShifted}, AluOutResult, EPCOut, PC_Source, PCSourceResult
    );

    muxcausecontrol cc(
        32'b00000000000000000000000011111101, 32'b00000000000000000000000011111110, 32'b00000000000000000000000011111111, cause_control, CauseControlOut
    );
    
    muxiord iord(
        PCOut, CauseControlOut, AOut, BOut, AluOutResult, IorD, IorDOut
    );

    muxregdst regdst(
        RT, RD, ra, sp, reg_dst, MuxRegDstOut
    );

    muxalusrcA muxalusrca(
        PCOut, MemOut, AOut, 32'b00000000000000000000000000011101, Alu_Src_A, MuxResultA
    );

    muxalusrcB muxalusrcb(
        BOut, 32'b00000000000000000000000000000100, ImediatoExtendido32bits,
        MemDataRegisterOut, ImediatoToBrench, Alu_Src_B, MuxResultB
    );

    muxmemtoreg muxmemtoreg(
        HighOut, LowOut, LoadOut, AluOutResult, LTExtended, RegDeslocOut, ImediatoExtendido32bits, 32'b00000000000000000000000011100011, mem_reg, MuxMemToRegOut
    );

    muxload load(
        {{16{1'b0}}, MemDataRegisterOut[15:0]}, {{24{1'b0}}, MemDataRegisterOut[7:0]}, MemDataRegisterOut, Load_control, LoadOut
    );

    muxStore store(
        SHOut, SBOut, SOut, Store_control, StoreOut
    );

    muxShiftInput si(
        AOut, ImediatoExtendido32bits, BOut, Shift_control_in, ShiftInputControlOut
    );

    muxshiftN sn(
        BOut5bits, 5'b10000, SHAMT, MemDataRegisterOut5bits, Shift_n, ShiftNControlOut 
    );

    muxmultordiv multOrDivHI(
        MultHiOut, DivHiOut, Mult_div_hi, MultOrDivHighOut
    );

    muxmultordiv MultOrDivLO(
        MultLoOut, DivLoOut, Mult_div_lo, MultOrDivLowOut
    );


    //Signal Extend

    signext16_32 imediatoExtender(
        imediato, ImediatoExtendido32bits
    );

    signext1_32 LTExtender(
        lt, LTExtended
    );


    //Shift Left 2

    shiftleft2_32_32 imediatoShifter(
        ImediatoExtendido32bits, ImediatoToBrench
    );

    shiftleft2_26_28 jumpShifter(
        JumpFromInstruction, JumpShifted
    );


    //Mult e Div

    Mult multiplication(
        clk, reset, mult_start, AOut, BOut, MultHiOut, MultLoOut  
    );

    Div division(
        clk, reset, div_start, AOut, BOut, div_zero, DivHiOut, DivLoOut
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