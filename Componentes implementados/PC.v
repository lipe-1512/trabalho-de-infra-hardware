module PC (
    input clk, reset
);
    //DATA WIRES
    wire [5:0] OpCode;
    wire OpCode404;
    wire [4:0] rs, rt, rd, shamt, MuxRegDstOut, ShiftNControlOut;
    wire [15:0] Imediato;
    wire [31:0] ImediatoExtendido32bits, ImediatoToBrench, MuxMemToRegOut, PCOut, EPCOut, CauseControlOut, IorDout, MemOut;
    wire [31:0] BRoutA, BRoutB, AOut, MuxResultA, MuxResultB, AluResult, AluOutResult, MemDataRegisterOut, LoadOut, StoreOut;
    wire [31:0] SOut, SHOut, SBOut, ShiftInputControlOut, RegDeslocOut, PCSourceResult, 
    
    //MULT E DIV
    wire [31:0] MultOrDivHigh, MultOrDivLow, MultHiOut, MultLoOut, DivHiOut, DivLoOut, HighOut, LowOut;

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
    wire multStart,
    wire divStart,
    wire MultOrDivLow,
    wire MultOrDivHigh,
    wire LOWrite,
    wire HIWrite,
    wire reset_out,
    wire [1:0] shift_control_in,
    wire [2:0] shift_control,
    wire [1:0] shift_n

    parameter sp = 5'b11101;
    parameter ra = 5'b11111;

    RegDesloc regDeslc(
        clk, reset, ShiftControl, ShiftNControlOut, ShiftInputControlOut, RegDeslocOut
    );

    Memoria mem(
        IorDOut, clk, mem_wr, StoreOut, MemOut
    );

    control_of_data c_o_d(
        PCOut, Imediato, MemDataRegisterOut, RS, RT, BOut,
        PCAux, RD, SHAMT, JumpFromInstruction, BOut5bits, 
        MemDataRegisterOut5bits, SHOut, SBOut, SOut
    );

    Banco_reg BR(
        clk, reset, reg_wr, RS, RT, MuxRegDstOut, MuxMemToRegOut, BRoutA, BRoutB
    );

    Instr_Reg IR(
        clk, reset, ir_wr, MemOut, OpCode, RS, RT, Imediato
    );

    ula32 ALU(
        MuxResultA, MuxResultB, AluOperation, AluResult, O, neg, zero, et, gt, lt 
    );

    //Registradores

    Registrador PC(
        clk, reset, PCWrite, PCSourceResult, PCOut
    );

    Registrador A(
        clk, reset, wr_A, BRoutA, AOut
    );

    Registrador B(
        clk, reset, wr_B, BRoutB, BOut
    );

    Registrador AluOut(
        clk, reset, AluOutWrite, AluResult, AluOutResult
    );

    Registrador MemDataRegister(
        clk, reset, MemDataWrite, MemOut, MemDataRegisterOut
    );

    Registrador EPC(
        clk, reset, EPCWrite, AluResult, EPCOut
    );

    Registrador HI(
        clk, reset, HIWrite, MultOrDivHighOut, HighOut 
    );

    Registrador LO(
        clk, reset, LOWrite, MultOrDivLowOut, LowOut
    );

    //MUXS

    muxpcsource muxpcsource(
        {{24{1'b0}}, MemOut[7:0]}, AOut, AluResult, {PCOut[31:28], JumpShifted}, AluOutResult, EPCOut, PCSource, PCSourceResult
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
        PCOut, MemOut, AOut, 32'b00000000000000000000000000011101, AluSrcA, MuxResultA
    );

    muxalusrcB muxalusrcb(
        BOut, 32'b00000000000000000000000000000100, ImediatoExtendido32bits,
        MemDataRegisterOut, ImediatoToBrench, AluSrcB, MuxResultB
    );

    muxmemtoreg muxmemtoreg(
        HighOut, LowOut, LoadOut, AluOutResult, LTExtended, RegDeslocOut, ImediatoExtendido32bits, 32'b00000000000000000000000011100011, mem_reg, MuxMemToRegOut
    );

    muxload load(
        {{16{1'b0}}, MemDataRegisterOut[15:0]}, {{24{1'b0}}, MemDataRegisterOut[7:0]}, MemDataRegisterOut, LoadControl, LoadOut
    );

    muxStore store(
        SHOut, SBOut, SOut, StoreControl, StoreOut
    );

    muxShiftInput si(
        AOut, ImediatoExtendido32bits, BOut, ShiftInputControl, ShiftInputControlOut
    );

    muxshiftN sn(
        BOut5bits, 5'b10000, SHAMT, MemDataRegisterOut5bits, ShiftNControl, ShiftNControlOut 
    );

    muxmultordiv multOrDivHI(
        MultHiOut, DivHiOut, MultOrDivHigh, MultOrDivHighOut
    );

    muxmultordiv MultOrDivLO(
        MultLoOut, DivLoOut, MultOrDivLow, MultOrDivLowOut
    );


    //Signal Extend

    signext16_32 imediatoExtender(
        Imediato, ImediatoExtendido32bits
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
        clk, reset, multStart, AOut, BOut, MultHiOut, MultLoOut  
    );

    Div division(
        clk, reset, divStart, AOut, BOut, div_zero, DivHiOut, DivLoOut
    );

    //Unidade de controle

    ControlUnit UnitOfControl(
        clk, reset, O, OpCode404, div_zero, OpCode, zero, lt, et, gt, neg, IorD, cause_control, mem_wr, ir_wr, 
        reg_dst, mem_reg, reg_wr, wr_A, wr_B, AluSrcA, AluSrcB,
        AluOperation, AluOutWrite, PCSource, PCWrite, EPCWrite,
        MemDataWrite, LoadControl, StoreControl, 
        MultOrDivLow, MultOrDivHigh, LOWrite, HIWrite,
        ShiftInputControl, ShiftNControl, ShiftControl, multStart, divStart,reset 
    );




endmodule