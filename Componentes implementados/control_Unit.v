module control_unit (
    input wire clk, reset,
    input wire O, OpCode404, div_zero,
    input wire [5:0] OpCode, Funct,
    input wire zero, neg, lt, gt, et,

    output reg[2:0] IorD,
    output reg mem_wr,
    output reg[1:0] cause_control,
    output reg ir_wr,
    output reg reg_wr,
    output reg wr_A,
    output reg wr_B,
    output reg [2:0] mem_reg,
    output reg[1:0] reg_dst,
    output reg[1:0] Alu_Src_A,
    output reg[2:0] Alu_Src_B,
    output reg[2:0] Alu_Op,
    output reg Alu_out_wr,
    output reg[2:0] PC_Source,
    output reg PC_wr,
    output reg EPC_wr,  
    output reg [1:0] load_control,
    output reg [1:0] store_control,
    output reg mult_start,
    output reg div_start,
    output reg Mult_div_lo,
    output reg Mult_div_hi,
    output reg Lo_wr,
    output reg hi_wr,
    output reg reset_out,
    output reg [1:0] shift_control_in,
    output reg [2:0] shift_control,
    output reg [1:0] shift_n
);
    // variáveis para determinar o ciclo
    reg [5:0] counter;
    reg [5:0] state;

    //Estados
    parameter reset_start = 6'b111111;
    parameter fetch = 6'b000001;
    parameter  decode = 6'b000010;
    parameter OpCode404 = 6'b000011;
    parameter overflow = 6'b000100;
    parameter zero_div_start = 6'b000101;

    //Instruções 

    parameter ADD = 6'b000110;
    parameter AND = 6'b000111;
    parameter DIV = 6'b001000;
    parameter MULT = 6'b001001;
    parameter JR = 6'b001010;
    parameter MFHI = 6'b001011;
    parameter MFLO = 6'b001100;
    parameter SLL = 6'b001101;
    parameter SLLV = 6'b001111;
    parameter SLT = 6'b010000;
    parameter SRA = 6'b010001;
    parameter SRAV = 6'b010010;
    parameter SRL = 6'b010011;
    parameter SUB = 6'b010100;
    parameter BREAK = 6'b010101;
    parameter RTE = 6'b010110;
    parameter ADDI = 6'b011000;
    parameter ADDIU = 6'b011001;
    parameter BEQ = 6'b011010;
    parameter BNE = 6'b011011;
    parameter BLE = 6'b011100;
    parameter BGT = 6'b011101;
    parameter LB = 6'b011111;
    parameter LH = 6'b100000;
    parameter LUI = 6'b100001;
    parameter LW = 6'b100010;
    parameter SB = 6'b100011;
    parameter SH = 6'b100100;
    parameter SLTI = 6'b100101;
    parameter SW = 6'b100111;
    parameter J = 6'b101000;
    parameter JAL = 6'b101001;

    // instruções R
    parameter opcodeR = 6'b000000;
    
    parameter ADDFunct = 6'b100000;
    parameter ANDFunct = 6'b100100;
    parameter DIVFunct = 6'b011010;
    parameter MULTFunct = 6'b011000;
    parameter JRFunct = 6'b001000;
    parameter MFHIFunct = 6'b010000;
    parameter MFLOFunct = 6'b010010;
    parameter SLLFunct = 6'b000000;
    parameter SLLVFunct = 6'b000100;
    parameter SLTFunct = 6'b101010;
    parameter SRAFunct = 6'b000011;
    parameter SRAVFunct = 6'b000111;
    parameter SRLFunct = 6'b000010;
    parameter SUBFunct = 6'b100010;
    parameter BREAKFunct = 6'b001101;
    parameter RTEFunct = 6'b010011;
    parameter ADDMFunct = 6'b000101;

    //instruções I

    parameter ADDIop = 6'b001000;
    parameter ADDIUop = 6'b001001;
    parameter BEQop = 6'b000100;
    parameter BNEop = 6'b000101;
    parameter BLEop = 6'b000110;
    parameter BGTop = 6'b000111;
    parameter SLLMop = 6'b000001;
    parameter LBop = 6'b100000;
    parameter LHop = 6'b100001;
    parameter LWop = 6'b100011;
    parameter SBop = 6'b101000;
    parameter SHop = 6'b101001;
    parameter SWop = 6'b101011;
    parameter SLTIop = 6'b001010;
    parameter LUIop = 6'b001111;

    //instruções J 

    parameter Jop = 6'b000010;
    parameter JALop = 6'b000011;

    initial begin
        reset_out = 1'b1;
    end

    always @(posedge clk) begin
        if(reset == 1'b1)begin
            if(state != reset_start)begin

                state = reset_start; //*

                //Setando todos os outputs para 0

                IorD = 3'b000;
                cause_control = 2'b00;
                mem_wr = 1'b0;
                ir_wr = 1'b0;
                //reg_dst = 2'b00;
                //mem_reg = 3'b000;
                //reg_wr = 1'b0;
                wr_A = 1'b0;
                wr_B = 1'b0;
                Alu_Src_A = 2'b00;
                Alu_Src_B = 3'b000;
                Alu_Op = 3'b000;
                Alu_out_wr = 1'b0;
                PC_Source = 3'b000;
                PC_wr = 1'b0;
                EPC_wr = 1'b0;  
                mem_wrmDataWrite = 1'b0;
                load_control = 1'b0;
                store_control = 2'b00;
                Mult_div_lo = 1'b0;
                Mult_div_hi = 1'b0;
                Lo_wr = 1'b0;
                Hi_wr = 1'b0;
                shift_control_in = 2'b00;
                shift_n = 2'b00;
                shift_control = 3'b000;
                mult_start = 1'b0;
                div_start = 1'b0;

                reset_out = 1'b1;


                //Resetando a pilha
                reg_dst = 2'b11;
                mem_reg = 3'b111;
                reg_wr = 1'b1;

                counter = 6'b000000;
 
            end else begin
                
                state = fetch; //*

                //Setando todos os outputs para 0

                IorD = 3'b000;
                cause_control = 2'b00;
                mem_wr = 1'b0;
                ir_wr = 1'b0;
                //reg_dst = 2'b00;
                //mem_reg = 3'b000;
                //reg_wr = 1'b0;
                wr_A = 1'b0;
                wr_B = 1'b0;
                Alu_Src_A = 2'b00;
                Alu_Src_B = 3'b000;
                Alu_Op = 3'b000;
                Alu_out_wr = 1'b0;
                PC_Source = 3'b000;
                PC_wr = 1'b0;
                EPC_wr = 1'b0;  
                mem_wrmDataWrite = 1'b0;
                load_control = 1'b0;
                store_control = 2'b00;
                Mult_div_lo = 1'b0;
                Mult_div_hi = 1'b0;
                Lo_wr = 1'b0;
                Hi_wr = 1'b0;
                shift_control_in = 2'b00;
                shift_n = 2'b00;
                shift_control = 3'b000;
                mult_start = 1'b0;
                div_start = 1'b0;

                reset_out = 1'b0; //*

                //Resetando a pilha
                reg_dst = 2'b11;
                mem_reg = 3'b111;
                reg_wr = 1'b1;                

                counter = 6'b000000;

            end

        end else begin
        
            case (state)
                fetch: begin
                    if(counter != 6'b000011)begin

                        state = fetch;

                        cause_control = 2'b00;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;
    
                        reset_out = 1'b0;

                        IorD = 3'b000;
                        mem_wr = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b001;
                        PC_Source = 3'b010;

                        counter = counter + 1;

                    end else begin

                        ir_wr = 1'b1;
                        PC_wr = 1'b1;
                        PC_Source = 3'b010;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b001;
                        counter = 6'b000000;
                        state = decode;

                    end

                end

                decode: begin
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;
    
                        reset_out = 1'b0;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b100;
                        Alu_Op = 3'b001;
                        reg_wr = 1'b0;
                        Alu_out_wr = 1'b1;
                        wr_A = 1'b1;
                        wr_B = 1'b1;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000001) begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b100;
                        Alu_Op = 3'b001;
                        reg_wr = 1'b0;
                        Alu_out_wr = 1'b1;
                        wr_A = 1'b1;
                        wr_B = 1'b1;                        

                        counter = 6'b000000;

                        case(OpCode)
                            opcodeR: begin
                                case(Funct)
                                    ADDFunct: begin
                                         state = ADD;
                                        end
                                    ANDFunct: begin
                                         state =  AND;
                                        end
                                    DIVFunct: begin
                                         state =  DIV;
                                        end
                                    MULTFunct: begin
                                         state =  MULT;
                                        end
                                    JRFunct: begin
                                         state =  JR;
                                        end
                                    MFHIFunct: begin
                                         state =  MFHI;
                                        end
                                    MFLOFunct: begin
                                         state =  MFLO;
                                        end
                                    SLLFunct: begin
                                         state =  SLL;
                                        end
                                    SLLVFunct: begin
                                         state =  SLLV;
                                        end
                                    SLTFunct: begin
                                         state =  SLT;
                                        end
                                    SRAFunct: begin
                                         state =  SRA;
                                        end
                                    SRAVFunct: begin
                                         state =  SRAV;
                                        end
                                    SRLFunct: begin
                                         state =  SRL;
                                        end
                                    SUBFunct: begin
                                         state =  SUB;
                                        end
                                    BREAKFunct: begin
                                         state =  BREAK;
                                        end
                                    RTEFunct: begin
                                         state =  RTE;
                                        end
                                endcase
                            end
                                
                            ADDIop: begin
                                 state = ADDI;
                                end
                            ADDIUop: begin
                                 state = ADDIU;
                                end
                            BEQop: begin
                                 state = BEQ;
                                end
                            BNEop: begin
                                 state = BNE;
                                end
                            BLEop: begin
                                 state = BLE;
                                end
                            BGTop: begin
                                 state = BGT;
                                end
                            LBop: begin
                                 state = LB;
                                end
                            LHop: begin
                                 state = LH;
                                end
                            LWop: begin
                                 state = LW;
                                end
                            SBop: begin
                                 state = SB;
                                end
                            SHop: begin
                                 state = SH;
                                end
                            SWop: begin
                                 state = SW;
                                end
                            SLTIop: begin
                                 state = SLTI;
                                end
                            LUIop: begin
                                 state = LUI;
                                end

                            Jop: begin
                                 state = J;
                                end
                            JALop: begin
                                 state = JAL;
                                end
                            default: state = op404;
                        endcase

                    end
                end

                ADD: begin
                    
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;
    

                        reset_out = 1'b0;

                        Alu_Src_A = 10;
                        Alu_Src_B = 000;
                        Alu_Op = 001;
                        Alu_out_wr = 1;

                        
                        counter = counter + 1;
                    
                    end else if(counter == 6'b000001)begin

                        if(O == 1)begin

                            IorD = 3'b000;
                            cause_control = 2'b00;
                            mem_wr = 1'b0;
                            ir_wr = 1'b0;
                            reg_dst = 2'b00;
                            mem_reg = 3'b000;
                            reg_wr = 1'b0;
                            wr_A = 1'b0;
                            wr_B = 1'b0;
                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;
                            Alu_out_wr = 1'b0;
                            PC_Source = 3'b000;
                            PC_wr = 1'b0;
                            EPC_wr = 1'b0;  
                            mem_wrmDataWrite = 1'b0;
                            load_control = 1'b0;
                            store_control = 2'b00;
                            Mult_div_lo = 1'b0;
                            Mult_div_hi = 1'b0;
                            Lo_wr = 1'b0;
                            Hi_wr = 1'b0;
                            shift_control_in = 2'b00;
                            shift_n = 2'b00;
                            shift_control = 3'b000;
                            mult_start = 1'b0;
                            div_start = 1'b0;
        

                            reset_out = 1'b0;

                            counter = 6'b000000;
                            state = overflow;
                        end

                        else begin
                            

                            mem_reg = 011;
                            reg_dst = 01;
                            reg_wr = 1;

                            Alu_Src_A = 00;
                            Alu_Src_B = 000;
                            Alu_Op = 000;
                            Alu_out_wr = 0;

                            counter = counter + 1;
                        end
                    

                    end else if(counter == 6'b000010)begin
                            if(O == 1)begin

                                IorD = 3'b000;
                                cause_control = 2'b00;
                                mem_wr = 1'b0;
                                ir_wr = 1'b0;
                                reg_dst = 2'b00;
                                mem_reg = 3'b000;
                                reg_wr = 1'b0;
                                wr_A = 1'b0;
                                wr_B = 1'b0;
                                Alu_Src_A = 2'b00;
                                Alu_Src_B = 3'b000;
                                Alu_Op = 3'b000;
                                Alu_out_wr = 1'b0;
                                PC_Source = 3'b000;
                                PC_wr = 1'b0;
                                EPC_wr = 1'b0;  
                                mem_wrmDataWrite = 1'b0;
                                load_control = 1'b0;
                                store_control = 2'b00;
                                Mult_div_lo = 1'b0;
                                Mult_div_hi = 1'b0;
                                Lo_wr = 1'b0;
                                Hi_wr = 1'b0;
                                shift_control_in = 2'b00;
                                shift_n = 2'b00;
                                shift_control = 3'b000;
                                mult_start = 1'b0;
                                div_start = 1'b0;
            

                                reset_out = 1'b0;
                                counter = 6'b000000;
                                state = overflow;
                        end

                        else begin

                            reset_out = 1'b0;
                            mem_reg = 011;
                            reg_dst = 01;
                            reg_wr = 1;

                            counter = 6'b000000;
                            state = fetch;
                        end
                    end


                end

                ADDI: begin

                    if(counter == 6'b000000)begin 

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;    

                        reset_out = 1'b0;

                        Alu_Src_A = 10;
                        Alu_Src_B = 010;
                        Alu_Op = 001;
                        Alu_out_wr = 1;

                        counter = counter + 1;


                    end else if (counter == 6'b000001) begin

                        if(O == 1) begin

                            IorD = 3'b000;
                            cause_control = 2'b00;
                            mem_wr = 1'b0;
                            ir_wr = 1'b0;
                            reg_dst = 2'b00;
                            mem_reg = 3'b000;
                            reg_wr = 1'b0;
                            wr_A = 1'b0;
                            wr_B = 1'b0;
                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;
                            Alu_out_wr = 1'b0;
                            PC_Source = 3'b000;
                            PC_wr = 1'b0;
                            EPC_wr = 1'b0;  
                            mem_wrmDataWrite = 1'b0;
                            load_control = 1'b0;
                            store_control = 2'b00;
                            Mult_div_lo = 1'b0;
                            Mult_div_hi = 1'b0;
                            Lo_wr = 1'b0;
                            Hi_wr = 1'b0;
                            shift_control_in = 2'b00;
                            shift_n = 2'b00;
                            shift_control = 3'b000;
                            mult_start = 1'b0;
                            div_start = 1'b0;            

                            reset_out = 1'b0;
                            counter = 6'b000000;
                            state = overflow;

                        end else begin

                        mem_reg = 3'b011;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;

                        Alu_Src_A = 00;
                        Alu_Src_B = 000;
                        Alu_Op = 000;
                        Alu_out_wr = 0;

                        counter = counter + 1;
                        end

                    end else if (counter == 6'b000010) begin

                        if (O == 1) begin

                            IorD = 3'b000;
                            cause_control = 2'b00;
                            mem_wr = 1'b0;
                            ir_wr = 1'b0;
                            reg_dst = 2'b00;
                            mem_reg = 3'b000;
                            reg_wr = 1'b0;
                            wr_A = 1'b0;
                            wr_B = 1'b0;
                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;
                            Alu_out_wr = 1'b0;
                            PC_Source = 3'b000;
                            PC_wr = 1'b0;
                            EPC_wr = 1'b0;  
                            mem_wrmDataWrite = 1'b0;
                            load_control = 1'b0;
                            store_control = 2'b00;
                            Mult_div_lo = 1'b0;
                            Mult_div_hi = 1'b0;
                            Lo_wr = 1'b0;
                            Hi_wr = 1'b0;
                            shift_control_in = 2'b00;
                            shift_n = 2'b00;
                            shift_control = 3'b000;
                            mult_start = 1'b0;
                            div_start = 1'b0;            

                            reset_out = 1'b0;
                            counter = 6'b000000;
                            state = overflow;

                        end else begin
                        
                        state = fetch;

                        mem_reg = 3'b011;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;

                        counter = 6'b000000;

                        end                        

                    end


                end

                ADDIU: begin
                    
                    if(counter == 6'b000000)begin 

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;    

                        reset_out = 1'b1;

                        Alu_Src_A = 10;
                        Alu_Src_B = 010;
                        Alu_Op = 001;
                        Alu_out_wr = 1;

                        counter = counter + 1;


                    end else if (counter == 6'b000001) begin

                        mem_reg = 3'b011;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;

                        Alu_Src_A = 00;
                        Alu_Src_B = 000;
                        Alu_Op = 000;
                        Alu_out_wr = 0;

                        counter = counter + 1;

                    end else if (counter == 6'b000010) begin
                        
                        state = fetch;

                        mem_reg = 3'b011;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;

                        counter = 6'b000000;                        

                    end               

                end

                AND : begin
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 10;
                        Alu_Src_B = 000;
                        Alu_Op = 011;
                        Alu_out_wr = 1;

                        
                        counter = counter + 1;
                    
                    end else if(counter == 6'b000001)begin                          

                            mem_reg = 011;
                            reg_dst = 01;
                            reg_wr = 1;

                            Alu_Src_A = 00;
                            Alu_Src_B = 000;
                            Alu_Op = 000;
                            Alu_out_wr = 0;

                            counter = counter + 1;

                    end else if(counter == 6'b000010)begin
       
                            reset_out = 1'b0;
                            mem_reg = 011;
                            reg_dst = 01;
                            reg_wr = 1;

                            counter = 6'b000000;
                            state = fetch;
                    end                    

                end

                SUB: begin 

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 10;
                        Alu_Src_B = 000;
                        Alu_Op = 010;
                        Alu_out_wr = 1;

                        counter = counter + 1;
                    
                    end else if(counter == 6'b000001)begin

                        if(O == 1)begin

                            IorD = 3'b000;
                            cause_control = 2'b00;
                            mem_wr = 1'b0;
                            ir_wr = 1'b0;
                            reg_dst = 2'b00;
                            mem_reg = 3'b000;
                            reg_wr = 1'b0;
                            wr_A = 1'b0;
                            wr_B = 1'b0;
                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;
                            Alu_out_wr = 1'b0;
                            PC_Source = 3'b000;
                            PC_wr = 1'b0;
                            EPC_wr = 1'b0;  
                            mem_wrmDataWrite = 1'b0;
                            load_control = 1'b0;
                            store_control = 2'b00;
                            Mult_div_lo = 1'b0;
                            Mult_div_hi = 1'b0;
                            Lo_wr = 1'b0;
                            Hi_wr = 1'b0;
                            shift_control_in = 2'b00;
                            shift_n = 2'b00;
                            shift_control = 3'b000;
                            mult_start = 1'b0;
                            div_start = 1'b0;

                            reset_out = 1'b0;

                            counter = 6'b000000;
                            state = overflow;
                        end

                        else begin
                            
                            mem_reg = 011;
                            reg_dst = 01;
                            reg_wr = 1;

                            Alu_Src_A = 00;
                            Alu_Src_B = 000;
                            Alu_Op = 000;
                            Alu_out_wr = 0;

                            counter = counter + 1;
                        end
                    

                    end else if(counter == 6'b000010)begin
                        
                        if(O == 1)begin

                            IorD = 3'b000;
                            cause_control = 2'b00;
                            mem_wr = 1'b0;
                            ir_wr = 1'b0;
                            reg_dst = 2'b00;
                            mem_reg = 3'b000;
                            reg_wr = 1'b0;
                            wr_A = 1'b0;
                            wr_B = 1'b0;
                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;
                            Alu_out_wr = 1'b0;
                            PC_Source = 3'b000;
                            PC_wr = 1'b0;
                            EPC_wr = 1'b0;  
                            mem_wrmDataWrite = 1'b0;
                            load_control = 1'b0;
                            store_control = 2'b00;
                            Mult_div_lo = 1'b0;
                            Mult_div_hi = 1'b0;
                            Lo_wr = 1'b0;
                            Hi_wr = 1'b0;
                            shift_control_in = 2'b00;
                            shift_n = 2'b00;
                            shift_control = 3'b000;
                            mult_start = 1'b0;
                            div_start = 1'b0;
        

                            reset_out = 1'b0;
                            counter = 6'b000000;
                            state = overflow;
                        end

                        else begin

                            reset_out = 1'b0;
                            mem_reg = 011;
                            reg_dst = 01;
                            reg_wr = 1;

                            counter = 6'b000000;
                            state = fetch;

                        end
                    end

                end
                
                reset_start: begin

                    if(counter == 6'b000000)begin

                            state = reset_start; //*

                            //Setando todos os outputs para 0
                            IorD = 3'b000;
                            cause_control = 2'b00;
                            mem_wr = 1'b0;
                            ir_wr = 1'b0;
                            reg_dst = 2'b00;
                            mem_reg = 3'b000;
                            reg_wr = 1'b0;
                            wr_A = 1'b0;
                            wr_B = 1'b0;
                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;
                            Alu_out_wr = 1'b0;
                            PC_Source = 3'b000;
                            PC_wr = 1'b0;
                            EPC_wr = 1'b0;  
                            mem_wrmDataWrite = 1'b0;
                            load_control = 1'b0;
                            store_control = 2'b00;
                            Mult_div_lo = 1'b0;
                            Mult_div_hi = 1'b0;
                            Lo_wr = 1'b0;
                            Hi_wr = 1'b0;
                            shift_control_in = 2'b00;
                            shift_n = 2'b00;
                            shift_control = 3'b000;
                            mult_start = 1'b0;
                            div_start = 1'b0;
        

                            reset_out = 1'b1;

                    end

                end

                overflow : begin

                    if(counter != 5'b00010) begin

                        ir_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        mem_reg = 3'b000;
                        reg_dst = 2'b00;
                        reg_wr = 1'b0;
                        reset_out = 1'b0;

                        cause_control = 2'b01;
                        IorD = 3'b001;
                        mem_wr = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b010;

                        counter = counter + 1;

                    end else begin

                        EPC_wr = 1'b1;
                        PC_Source = 3'b000;
                        PC_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end


                end

                op404 : begin

                    if(counter == 6'b00000)begin

                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        cause_control = 2'b00;
                        IorD = 3'b001;
                        mem_wr = 1'b0;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000001) begin

                        cause_control = 2'b00;
                        IorD = 3'b001;
                        mem_wr = 1'b0;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b010;

                        counter = counter + 1;

                    end else begin

                        EPC_wr = 1'b1;
                        PC_Source = 3'b000;
                        PC_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                zero_div_start: begin

                    if(counter == 6'b00000)begin

                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        cause_control = 2'b10;
                        IorD = 3'b001;
                        mem_wr = 1'b0;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000001) begin

                        cause_control = 2'b00;
                        IorD = 3'b001;
                        mem_wr = 1'b0;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b010;

                        counter = counter + 1;

                    end else begin

                        EPC_wr = 1'b1;
                        PC_Source = 3'b000;
                        PC_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end                    

                end

                LUI: begin
                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0; 
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        cause_control = 2'b00;
                        IorD = 3'b000;
                        mem_wr = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        shift_n = 2'b01;
                        shift_control = 3'b001;
                        shift_control_in = 2'b01;
                        

                        counter = counter + 1;
                    
                    end else if (counter == 6'b000001) begin

                        shift_control = 3'b010;

                        counter = counter + 1;

                    end else if (counter == 6'b000010) begin

                        mem_reg = 3'b101;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;

                        reset_out = 1'b0;

                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        shift_control_in = 2'b00;

                        counter = counter + 1;

                    end else if (counter == 6'b000011) begin

                        state = fetch;

                        mem_reg = 3'b101;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;

                        counter = 6'b000000;

                    end
                end

                SLL : begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;    

                        reset_out = 1'b0;

                        shift_control = 3'b001;
                        shift_control_in = 2'b10;
                        shift_n = 2'b10;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        shift_control = 3'b010;

                        counter = counter + 1;

                    end else if (counter == 6'b00010)begin

                        shift_control = 3'b000;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end


                end

                SLLV: begin

                    if(counter == 6'b000000)begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    reg_dst = 2'b00;
                    mem_reg = 3'b000;
                    reg_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    Alu_Src_A = 2'b00;
                    Alu_Src_B = 3'b000;
                    Alu_Op = 3'b000;
                    Alu_out_wr = 1'b0;
                    PC_Source = 3'b000;
                    PC_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0;

                    shift_control = 3'b001;
                    counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        shift_control = 3'b010;
                        shift_n = 2'b00;
                        shift_control_in = 2'b00;
                        
                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        shift_control = 3'b000;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                SRA : begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        shift_control = 3'b001;
                        shift_control_in = 2'b10;
                        shift_n = 2'b10;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        shift_control = 3'b100;

                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        shift_control = 3'b000;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                SRAV: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        shift_control = 3'b001;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        shift_control = 3'b100;

                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        shift_control = 3'b000;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                SRL: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        shift_control = 3'b001;
                        shift_control_in = 2'b10;
                        shift_n = 2'b10;
                        counter = counter + 1;


                    end else if (counter == 6'b000001)begin

                        shift_control = 3'b011;

                        counter = counter + 1;

                    end else if (counter == 6'b000010)begin

                        shift_control = 3'b000;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        mem_reg = 3'b101;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;

                        state = fetch;
                        counter = 6'b000000;

                    end

                end

                RTE: begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    reg_dst = 2'b00;
                    mem_reg = 3'b000;
                    reg_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    Alu_Src_A = 2'b00;
                    Alu_Src_B = 3'b000;
                    Alu_Op = 3'b000;
                    Alu_out_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0;

                    PC_Source = 3'b101;
                    PC_wr = 1'b1;

                    counter = 6'b000000;
                    state = fetch;


                end

                LW: begin

                    if(counter == 6'b000000) begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    reg_dst = 2'b00;
                    mem_reg = 3'b000;
                    reg_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    PC_Source = 3'b000;
                    PC_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0; 

                    Alu_Src_A = 2'b10;
                    Alu_Src_B = 3'b010;
                    Alu_Op = 3'b001;
                    Alu_out_wr = 1'b1;

                    counter = counter + 1;

                    end else if(counter == 6'b000001 || counter == 6'b000010) begin

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;

                        IorD = 3'b100;
                        mem_wr = 0;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000011) begin

                        mem_wrmDataWrite = 1'b1;
                        IorD = 3'b000;

                        counter = counter + 1;

                    end else if(counter == 6'b000100) begin

                        mem_wrmDataWrite = 1'b0;
                        load_control = 2'b10;
                        mem_reg = 3'b010;
                        reg_dst = 00;
                        reg_wr = 1;

                        counter = counter + 1;

                    end else begin

                        mem_wrmDataWrite = 1'b0;
                        load_control = 2'b10;
                        mem_reg = 3'b010;
                        reg_dst = 00;
                        reg_wr = 1;

                        state = fetch;
                        counter = 6'b000000;                        

                    end                 

                end

                LH: begin

                    if(counter == 6'b000000) begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    reg_dst = 2'b00;
                    mem_reg = 3'b000;
                    reg_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    PC_Source = 3'b000;
                    PC_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0; 

                    Alu_Src_A = 2'b10;
                    Alu_Src_B = 3'b010;
                    Alu_Op = 3'b001;
                    Alu_out_wr = 1'b1;

                    counter = counter + 1;

                    end else if(counter == 6'b000001 || counter == 6'b000010) begin

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;

                        IorD = 3'b100;
                        mem_wr = 0;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000011) begin

                        mem_wrmDataWrite = 1'b1;
                        IorD = 3'b000;

                        counter = counter + 1;

                    end else if(counter == 6'b000100) begin

                        mem_wrmDataWrite = 1'b0;
                        load_control = 2'b00;
                        mem_reg = 3'b010;
                        reg_dst = 00;
                        reg_wr = 1;

                        counter = counter + 1;

                    end else begin

                        mem_wrmDataWrite = 1'b0;
                        load_control = 2'b00;
                        mem_reg = 3'b010;
                        reg_dst = 00;
                        reg_wr = 1;

                        state = fetch;
                        counter = 6'b000000;                        

                    end                      

                end

                LB: begin

                    if(counter == 6'b000000) begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    reg_dst = 2'b00;
                    mem_reg = 3'b000;
                    reg_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    PC_Source = 3'b000;
                    PC_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0; 

                    Alu_Src_A = 2'b10;
                    Alu_Src_B = 3'b010;
                    Alu_Op = 3'b001;
                    Alu_out_wr = 1'b1;

                    counter = counter + 1;

                    end else if(counter == 6'b000001 || counter == 6'b000010) begin

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;

                        IorD = 3'b100;
                        mem_wr = 0;
                        
                        counter = counter + 1;

                    end else if(counter == 6'b000011) begin

                        mem_wrmDataWrite = 1'b1;
                        IorD = 3'b000;

                        counter = counter + 1;

                    end else if(counter == 6'b000100) begin

                        mem_wrmDataWrite = 1'b0;
                        load_control = 2'b01;
                        mem_reg = 3'b010;
                        reg_dst = 00;
                        reg_wr = 1;

                        counter = counter + 1;

                    end else begin

                        mem_wrmDataWrite = 1'b0;
                        load_control = 2'b01;
                        mem_reg = 3'b010;
                        reg_dst = 00;
                        reg_wr = 1;

                        state = fetch;
                        counter = 6'b000000;                        

                    end  

                end
                
                SW: begin

                    if (counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b010;
                        Alu_Op = 3'b001;
                        Alu_out_wr = 1'b1;

                        counter = counter + 1;

                    end else if(counter == 6'b000001 || counter == 6'b000010)begin

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;

                        IorD = 3'b000;
                        mem_wr = 1'b0;

                        counter = counter + 1;

                    end else if(counter == 6'b000011)begin
                        
                        mem_wrmDataWrite = 1'b1;

                        counter = counter + 1;

                    end else if(counter == 6'b000100)begin

                        mem_wrmDataWrite = 1'b0;
                        store_control = 2'b10;
                        counter = counter + 1;

                    end else if(counter == 6'b000101) begin

                        IorD = 3'b100;
                        mem_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        IorD = 3'b100;
                        mem_wr = 1'b1;

                        counter = 6'b000000;
                        state = fetch;

                    end
                    
                end  

                SH: begin

                    if (counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b010;
                        Alu_Op = 3'b001;
                        Alu_out_wr = 1'b1;

                        counter = counter + 1;

                    end else if(counter == 6'b000001 || counter == 6'b000010)begin

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;

                        IorD = 3'b000;
                        mem_wr = 1'b0;

                        counter = counter + 1;

                    end else if(counter == 6'b000011)begin
                        
                        mem_wrmDataWrite = 1'b1;

                        counter = counter + 1;

                    end else if(counter == 6'b000100)begin

                        mem_wrmDataWrite = 1'b0;
                        store_control = 2'b00;
                        counter = counter + 1;

                    end else if(counter == 6'b000101) begin

                        IorD = 3'b100;
                        mem_wr = 1'b1;

                        counter = counter + 1;

                    end else begin

                        IorD = 3'b100;
                        mem_wr = 1'b1;

                        counter = 6'b000000;
                        state = fetch;

                    end                    

                end  

                SB: begin

                    if (counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b010;
                        Alu_Op = 3'b001;
                        Alu_out_wr = 1'b1;

                        counter = counter + 1;

                    end else if(counter == 6'b000001 || counter == 6'b000010)begin

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        store_control = 2'b01;

                        IorD = 3'b000;
                        mem_wr = 1'b0;

                        counter = counter + 1;

                    end else if(counter == 6'b000011)begin
                        
                        mem_wrmDataWrite = 1'b1;

                        counter = counter + 1;

                    end else begin

                        IorD = 3'b100;
                        mem_wr = 1'b1;

                        counter = 6'b000000;
                        state = fetch;

                    end                 

                end

                SLTI: begin
                    if(counter == 6'b000000)begin

                        ir_wr = 1'b0; 
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 1'b0;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        cause_control = 2'b00;
                        IorD = 3'b000;
                        mem_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;
    
                        reset_out = 1'b0;

                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        shift_control_in = 2'b00;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b010;
                        Alu_Op = 3'b111;

                        counter = counter + 1;

                    end else if (counter == 6'b000001) begin
                        
                        state = fetch;

                        mem_reg = 3'b100;
                        reg_dst = 2'b00;
                        reg_wr = 1'b1;
                        
                        
                        counter = 6'b000000;

                    end
                end

                SLT: begin 

                    if(counter == 6'b000000)begin

                        ir_wr = 1'b0; 
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 1'b0;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        cause_control = 2'b00;
                        IorD = 3'b000;
                        mem_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;
    
                        reset_out = 1'b0;

                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        shift_control_in = 2'b00;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b111;

                        counter = counter + 1;

                    end else if (counter == 6'b000001) begin 

                        state = fetch;

                        mem_reg = 3'b100;
                        reg_dst = 2'b01;
                        reg_wr = 1'b1;
                        
                        
                        counter = 6'b000000;

                    end

                end

                BREAK: begin 

                    if(counter == 6'b000000)begin

                        ir_wr = 1'b0; 
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 1'b0;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        cause_control = 2'b00;
                        IorD = 3'b000;
                        mem_wr = 1'b0;
                        mult_start = 1'b0;
                        div_start = 1'b0;
    
                        reset_out = 1'b0;

                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        shift_control_in = 2'b00;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b010;
                        PC_Source = 3'b010;
                        PC_wr = 1'b1;

                        counter = 6'b000000;
                        state = fetch;

                    end
                end   

                BEQ: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(et == 1'b1)begin

                            PC_Source = 3'b100;
                            PC_wr = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end
                    
                end  

                BNE: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(et == 1'b0)begin

                            PC_Source = 3'b100;
                            PC_wr = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end

                end

                BLE: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(et == 1'b1 || lt == 1'b1)begin

                            PC_Source = 3'b100;
                            PC_wr = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end                    

                end

                BGT: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_out_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b10;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b111;

                        counter  = counter + 1;

                    end else if(counter == 6'b000001)begin

                        if(gt == 1'b1)begin

                            PC_Source = 3'b100;
                            PC_wr = 1'b1;

                            counter = 6'b000000;
                            state = fetch;

                        end else begin

                            Alu_Src_A = 2'b00;
                            Alu_Src_B = 3'b000;
                            Alu_Op = 3'b000;

                            counter = 6'b000000;
                            state = fetch;

                        end

                    end                    

                end
                
                JR: begin

                    ir_wr = 1'b0; 
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    Alu_out_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 1'b0;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    cause_control = 2'b00;
                    IorD = 3'b000;
                    mem_wr = 1'b0;
                    Alu_Src_A = 2'b00;
                    Alu_Src_B = 3'b000;
                    Alu_Op = 3'b000;
                    reset_out = 1'b0;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    shift_control_in = 2'b00;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    mem_reg = 3'b000;
                    reg_dst = 2'b00;
                    reg_wr = 1'b0;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0;

                    PC_Source = 3'b001;
                    PC_wr = 1'b1;

                    state = fetch;

                    counter = 6'b000000;

                end

                J: begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    reg_dst = 2'b00;
                    mem_reg = 3'b000;
                    reg_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    Alu_Src_A = 2'b00;
                    Alu_Src_B = 3'b000;
                    Alu_Op = 3'b000;
                    Alu_out_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0;

                    PC_Source = 3'b011;
                    PC_wr = 1'b1;

                    counter = 6'b000000;
                    state = fetch;                    

                end

                JAL: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;   
                        mult_start = 1'b0;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b001;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b1;                        

                        counter = counter + 1;
                        
                    end else begin

                        reg_dst = 2'b10;
                        mem_reg = 3'b011;
                        PC_Source = 3'b011;
                        reg_wr =  1'b1;
                        PC_wr = 1'b1;

                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;

                        counter = 6'b000000;
                        state = fetch; 

                    end

                end
                MFHI: begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    Alu_Src_A = 2'b00;
                    Alu_Src_B = 3'b000;
                    Alu_Op = 3'b000;
                    Alu_out_wr = 1'b0;
                    PC_Source = 3'b000;
                    PC_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b1;

                    mem_reg = 3'b000;
                    reg_dst = 2'b01;
                    reg_wr = 1'b1;

                    state = fetch;

                    counter = 6'b000000;

                end

                MFLO: begin

                    IorD = 3'b000;
                    cause_control = 2'b00;
                    mem_wr = 1'b0;
                    ir_wr = 1'b0;
                    wr_A = 1'b0;
                    wr_B = 1'b0;
                    Alu_Src_A = 2'b00;
                    Alu_Src_B = 3'b000;
                    Alu_Op = 3'b000;
                    Alu_out_wr = 1'b0;
                    PC_Source = 3'b000;
                    PC_wr = 1'b0;
                    EPC_wr = 1'b0;  
                    mem_wrmDataWrite = 1'b0;
                    load_control = 1'b0;
                    store_control = 2'b00;
                    Mult_div_lo = 1'b0;
                    Mult_div_hi = 1'b0;
                    Lo_wr = 1'b0;
                    Hi_wr = 1'b0;
                    shift_control_in = 2'b00;
                    shift_n = 2'b00;
                    shift_control = 3'b000;
                    mult_start = 1'b0;
                    div_start = 1'b0;

                    reset_out = 1'b0;

                    mem_reg = 3'b001;
                    reg_dst = 2'b01;
                    reg_wr = 1'b1;

                    state = fetch;

                    counter = 6'b000000;

                end

                MULT: begin

                    if(counter == 6'b000000) begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        div_start = 1'b0;

                        reset_out = 1'b0;

                        mult_start = 1'b1;
                        Mult_div_hi = 1'b0;
                        Mult_div_lo = 1'b0;

                        counter = counter + 1;

                    end else if(counter == 6'b100001) begin
                        
                        Lo_wr = 1'b1;
                        Hi_wr = 1'b1;

                        counter = 6'b000000;
                        state = fetch;

                    end else begin
                        
                        mult_start = 1'b0;
                        Mult_div_hi = 1'b0;
                        Mult_div_lo = 1'b0;

                        counter = counter + 1;

                    end                    

                end

                DIV: begin

                    if(counter == 6'b000000)begin

                        IorD = 3'b000;
                        cause_control = 2'b00;
                        mem_wr = 1'b0;
                        ir_wr = 1'b0;
                        reg_dst = 2'b00;
                        mem_reg = 3'b000;
                        reg_wr = 1'b0;
                        wr_A = 1'b0;
                        wr_B = 1'b0;
                        Alu_Src_A = 2'b00;
                        Alu_Src_B = 3'b000;
                        Alu_Op = 3'b000;
                        Alu_out_wr = 1'b0;
                        PC_Source = 3'b000;
                        PC_wr = 1'b0;
                        EPC_wr = 1'b0;  
                        mem_wrmDataWrite = 1'b0;
                        load_control = 1'b0;
                        store_control = 2'b00;
                        Mult_div_lo = 1'b0;
                        Mult_div_hi = 1'b0;
                        Lo_wr = 1'b0;
                        Hi_wr = 1'b0;
                        shift_control_in = 2'b00;
                        shift_n = 2'b00;
                        shift_control = 3'b000;
                        mult_start = 1'b0;

                        reset_out = 1'b0;

                        div_start = 1'b1;
                        Mult_div_hi = 1'b1;
                        Mult_div_lo = 1'b1;

                        counter = counter + 1;

                    end else if(counter == 6'b100001) begin

                        Lo_wr = 1'b1;
                        Hi_wr = 1'b1;

                        counter = 6'b000000;
                        state = fetch;                        

                    end else begin

                            if(div_zero == 1'b1)begin

                                IorD = 3'b000;
                                cause_control = 2'b00;
                                mem_wr = 1'b0;
                                ir_wr = 1'b0;
                                reg_dst = 2'b00;
                                mem_reg = 3'b000;
                                reg_wr = 1'b0;
                                wr_A = 1'b0;
                                wr_B = 1'b0;
                                Alu_Src_A = 2'b00;
                                Alu_Src_B = 3'b000;
                                Alu_Op = 3'b000;
                                Alu_out_wr = 1'b0;
                                PC_Source = 3'b000;
                                PC_wr = 1'b0;
                                EPC_wr = 1'b0;  
                                mem_wrmDataWrite = 1'b0;
                                load_control = 1'b0;
                                store_control = 2'b00;
                                Mult_div_lo = 1'b0;
                                Mult_div_hi = 1'b0;
                                Lo_wr = 1'b0;
                                Hi_wr = 1'b0;
                                shift_control_in = 2'b00;
                                shift_n = 2'b00;
                                shift_control = 3'b000;
                                mult_start = 1'b0;
                                div_start = 1'b0;
                                
                                reset_out = 1'b0;

                                state = zero_div_start;
                                counter = 6'b000000;
                            end else begin
                                div_start = 1'b0;
                                Mult_div_hi = 1'b1;
                                Mult_div_lo = 1'b1;

                                counter = counter + 1;
                            end
                    end

                end

            endcase

        end

    end
endmodule