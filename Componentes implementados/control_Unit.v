module control_Unit (
    input wire clk, reset,
    input wire O, div_zero,
    input wire [5:0] OpCode, Funct,
    input wire zero, neg, lt, gt, et,
    output reg [2:0] IorD,
    output reg mem_wr,
    output reg [1:0] cause_control,
    output reg ir_wr,
    output reg reg_wr,
    output reg wr_A,
    output reg wr_B,
    output reg [3:0] mem_reg,       // Changed from [2:0] to [3:0]
    output reg [2:0] reg_dst,       // Changed from [1:0] to [2:0]
    output reg [1:0] Alu_Src_A,
    output reg [2:0] Alu_Src_B,     // Changed from [1:0] to [2:0]
    output reg [2:0] Alu_Op,
    output reg Alu_out_wr,
    output reg [2:0] PC_Source,
    output reg PC_wr,
    output reg EPC_wr,
    output reg [3:0] load_control,  // Changed from [1:0] to [3:0]
    output reg [3:0] store_control, // Changed from [1:0] to [3:0]
    output reg mult_start,
    output reg div_start,
    output reg [1:0] mult_div_sel_lo,
    output reg [1:0] mult_div_sel_hi,
    output reg Lo_wr,
    output reg Hi_wr,
    output reg reset_out,
    output reg [1:0] shift_control_in,
    output reg [2:0] shift_control,
    output reg [1:0] shift_n
);
    reg [5:0] counter;
    reg [5:0] state;

    // Estados da FSM
    parameter RESET_START    = 6'b111111;
    parameter FETCH          = 6'b000001;
    parameter DECODE         = 6'b000010;
    parameter EXC_OPCODE     = 6'b000011;
    parameter EXC_OVERFLOW   = 6'b000100;
    parameter EXC_DIVZERO    = 6'b000101;
    
    // Instruções Formato R
    parameter ADD    = 6'b000110; parameter AND    = 6'b000111;
    parameter DIV    = 6'b001000; parameter MULT   = 6'b001001;
    parameter JR     = 6'b001010; parameter MFHI   = 6'b001011;
    parameter MFLO   = 6'b001100; parameter SLL    = 6'b001101;
    parameter SLLV   = 6'b001111; parameter SLT    = 6'b010000;
    parameter SRA    = 6'b010001; parameter SRAV   = 6'b010010;
    parameter SRL    = 6'b010011; parameter SUB    = 6'b010100;
    parameter BREAK  = 6'b010101; parameter RTE    = 6'b010110;
    
    // Instruções Formato I
    parameter ADDI   = 6'b011000; parameter ADDIU  = 6'b011001;
    parameter BEQ    = 6'b011010; parameter BNE    = 6'b011011;
    parameter BLE    = 6'b011100; parameter BGT    = 6'b011101;
    parameter LB     = 6'b011111; parameter LH     = 6'b100000;
    parameter LUI    = 6'b100001; parameter LW     = 6'b100010;
    parameter SB     = 6'b100011; parameter SH     = 6'b100100;
    parameter SLTI   = 6'b100101; parameter SW     = 6'b100111;
    
    // Instruções Formato J
    parameter J      = 6'b101000; parameter JAL    = 6'b101001;

    // Opcodes e Funct codes
    parameter OPCODE_R   = 6'b000000;
    parameter FUNCT_ADD  = 6'b100000; parameter FUNCT_AND = 6'b100100;
    parameter FUNCT_DIV  = 6'b011010; parameter FUNCT_MULT= 6'b011000;
    parameter FUNCT_JR   = 6'b001000; parameter FUNCT_MFHI= 6'b010000;
    parameter FUNCT_MFLO = 6'b010010; parameter FUNCT_SLL = 6'b000000;
    parameter FUNCT_SLLV = 6'b000100; parameter FUNCT_SLT = 6'b101010;
    parameter FUNCT_SRA  = 6'b000011; parameter FUNCT_SRAV= 6'b000111;
    parameter FUNCT_SRL  = 6'b000010; parameter FUNCT_SUB = 6'b100010;
    parameter FUNCT_BREAK= 6'b001101; parameter FUNCT_RTE = 6'b010011;

    parameter OPCODE_ADDI = 6'b001000; parameter OPCODE_ADDIU= 6'b001001;
    parameter OPCODE_BEQ  = 6'b000100; parameter OPCODE_BNE  = 6'b000101;
    parameter OPCODE_BLE  = 6'b000110; parameter OPCODE_BGT  = 6'b000111;
    parameter OPCODE_LB   = 6'b100000; parameter OPCODE_LH   = 6'b100001;
    parameter OPCODE_LW   = 6'b100011; parameter OPCODE_SB   = 6'b101000;
    parameter OPCODE_SH   = 6'b101001; parameter OPCODE_SW   = 6'b101011;
    parameter OPCODE_SLTI = 6'b001010; parameter OPCODE_LUI  = 6'b001111;
    parameter OPCODE_J    = 6'b000010; parameter OPCODE_JAL  = 6'b000011;

    initial begin
        reset_out = 1'b1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            state <= RESET_START;
            counter <= 6'b000000;
            IorD <= 3'b000; cause_control <= 2'b00; mem_wr <= 1'b0; ir_wr <= 1'b0;
            reg_dst <= 3'b000; mem_reg <= 4'b0000; reg_wr <= 1'b0; wr_A <= 1'b0; wr_B <= 1'b0;
            Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; Alu_out_wr <= 1'b0;
            PC_Source <= 3'b000; PC_wr <= 1'b0; EPC_wr <= 1'b0;
            load_control <= 4'b0000; store_control <= 4'b0000; 
            mult_div_sel_lo <= 2'b00; mult_div_sel_hi <= 2'b00;
            Lo_wr <= 1'b0; Hi_wr <= 1'b0; 
            shift_control_in <= 2'b00; shift_n <= 2'b00; shift_control <= 3'b000; 
            mult_start <= 1'b0; div_start <= 1'b0; 
            reset_out <= 1'b1;
        end else begin
            case (state)
                RESET_START: begin
                    reset_out <= 1'b1;
                    reg_dst <= 3'b011; mem_reg <= 4'b0111; reg_wr <= 1'b1; // SP initialization
                    if (counter == 6'b000000) begin
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH;
                        counter <= 6'b000000;
                        reset_out <= 1'b0;
                    end
                end
                
                FETCH: begin
                    if (counter != 6'b000011) begin
                        IorD <= 3'b000; mem_wr <= 1'b0; 
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b001; Alu_Op <= 3'b001; 
                        PC_Source <= 3'b010; PC_wr <= 1'b0; ir_wr <= 1'b0;
                        counter <= counter + 1;
                    end else begin
                        ir_wr <= 1'b1; PC_wr <= 1'b1; 
                        state <= DECODE; 
                        counter <= 6'b000000;
                    end
                end
                
                DECODE: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b100; Alu_Op <= 3'b001;
                        reg_wr <= 1'b0; Alu_out_wr <= 1'b1; 
                        wr_A <= 1'b1; wr_B <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        counter <= 6'b000000;
                        case (OpCode)
                            OPCODE_R: begin
                                case (Funct)
                                    FUNCT_ADD:  state <= ADD;
                                    FUNCT_AND:  state <= AND;
                                    FUNCT_DIV:  state <= DIV;
                                    FUNCT_MULT: state <= MULT;
                                    FUNCT_JR:   state <= JR;
                                    FUNCT_MFHI: state <= MFHI;
                                    FUNCT_MFLO: state <= MFLO;
                                    FUNCT_SLL:  state <= SLL;
                                    FUNCT_SLLV: state <= SLLV;
                                    FUNCT_SLT:  state <= SLT;
                                    FUNCT_SRA:  state <= SRA;
                                    FUNCT_SRAV: state <= SRAV;
                                    FUNCT_SRL:  state <= SRL;
                                    FUNCT_SUB:  state <= SUB;
                                    FUNCT_BREAK:state <= BREAK;
                                    FUNCT_RTE:  state <= RTE;
                                    default:    state <= EXC_OPCODE;
                                endcase
                            end
                            OPCODE_ADDI:  state <= ADDI;
                            OPCODE_ADDIU: state <= ADDIU;
                            OPCODE_BEQ:   state <= BEQ;
                            OPCODE_BNE:   state <= BNE;
                            OPCODE_BLE:   state <= BLE;
                            OPCODE_BGT:   state <= BGT;
                            OPCODE_LB:    state <= LB;
                            OPCODE_LH:    state <= LH;
                            OPCODE_LW:    state <= LW;
                            OPCODE_SB:    state <= SB;
                            OPCODE_SH:    state <= SH;
                            OPCODE_SW:    state <= SW;
                            OPCODE_SLTI:  state <= SLTI;
                            OPCODE_LUI:   state <= LUI;
                            OPCODE_J:     state <= J;
                            OPCODE_JAL:   state <= JAL;
                            default: state <= EXC_OPCODE;
                        endcase
                    end
                end
                
                // ========== INSTRUÇÕES ARITMÉTICAS ==========
                ADD: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b000; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        if (O == 1'b1) begin
                            state <= EXC_OVERFLOW; 
                            counter <= 6'b000000;
                        end else begin
                            mem_reg <= 4'b0011; reg_dst <= 3'b001; reg_wr <= 1'b1; 
                            counter <= counter + 1;
                        end
                    end else begin
                        if (O == 1'b1) begin
                            state <= EXC_OVERFLOW; 
                            counter <= 6'b000000;
                        end else begin
                            state <= FETCH; 
                            counter <= 6'b000000;
                        end
                    end
                end
                
                ADDI: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        if (O == 1'b1) begin
                            state <= EXC_OVERFLOW; 
                            counter <= 6'b000000;
                        end else begin
                            mem_reg <= 4'b0011; reg_dst <= 3'b000; reg_wr <= 1'b1; 
                            counter <= counter + 1;
                        end
                    end else begin
                        if (O == 1'b1) begin
                            state <= EXC_OVERFLOW; 
                            counter <= 6'b000000;
                        end else begin
                            state <= FETCH; 
                            counter <= 6'b000000;
                        end
                    end
                end
                
                SUB: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b000; Alu_Op <= 3'b010; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        if (O == 1'b1) begin
                            state <= EXC_OVERFLOW; 
                            counter <= 6'b000000;
                        end else begin
                            mem_reg <= 4'b0011; reg_dst <= 3'b001; reg_wr <= 1'b1; 
                            counter <= counter + 1;
                        end
                    end else begin
                        if (O == 1'b1) begin
                            state <= EXC_OVERFLOW; 
                            counter <= 6'b000000;
                        end else begin
                            state <= FETCH; 
                            counter <= 6'b000000;
                        end
                    end
                end
                
                AND: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b000; Alu_Op <= 3'b011; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        mem_reg <= 4'b0011; reg_dst <= 3'b001; reg_wr <= 1'b1; 
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; 
                        counter <= 6'b000000;
                    end
                end
                
                // ========== INSTRUÇÕES DE DESLOCAMENTO ==========
                SLL: begin
                    if (counter == 6'b000000) begin
                        shift_control <= 3'b001; shift_control_in <= 2'b10; 
                        shift_n <= 2'b10;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        shift_control <= 3'b010;
                        counter <= counter + 1;
                    end else if (counter == 6'b000010) begin
                        shift_control <= 3'b000; shift_control_in <= 2'b00; shift_n <= 2'b00;
                        mem_reg <= 4'b0101; reg_dst <= 3'b001; reg_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                SRA: begin
                    if (counter == 6'b000000) begin
                        shift_control <= 3'b001; shift_control_in <= 2'b10; 
                        shift_n <= 2'b10;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        shift_control <= 3'b100;
                        counter <= counter + 1;
                    end else if (counter == 6'b000010) begin
                        shift_control <= 3'b000; shift_control_in <= 2'b00; shift_n <= 2'b00;
                        mem_reg <= 4'b0101; reg_dst <= 3'b001; reg_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                // ========== INSTRUÇÕES DE MEMÓRIA ==========
                LW: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001 || counter == 6'b000010) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b0;
                        IorD <= 3'b100; mem_wr <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter == 6'b000011) begin
                        mem_wr <= 1'b1; IorD <= 3'b000;
                        counter <= counter + 1;
                    end else if (counter == 6'b000100) begin
                        mem_wr <= 1'b0; load_control <= 4'b0010; // LW -> 4'b0010 (dois)
                        mem_reg <= 4'b0010; reg_dst <= 3'b000; reg_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                LH: begin
                     if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001 || counter == 6'b000010) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b0;
                        IorD <= 3'b100; mem_wr <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter == 6'b000011) begin
                        mem_wr <= 1'b1; IorD <= 3'b000;
                        counter <= counter + 1;
                    end else if (counter == 6'b000100) begin
                        mem_wr <= 1'b0; load_control <= 4'b0000; // LH -> 4'b0000 (zero)
                        mem_reg <= 4'b0010; reg_dst <= 3'b000; reg_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end

                LB: begin
                     if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001 || counter == 6'b000010) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b0;
                        IorD <= 3'b100; mem_wr <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter == 6'b000011) begin
                        mem_wr <= 1'b1; IorD <= 3'b000;
                        counter <= counter + 1;
                    end else if (counter == 6'b000100) begin
                        mem_wr <= 1'b0; load_control <= 4'b0001; // LB -> 4'b0001 (um)
                        mem_reg <= 4'b0010; reg_dst <= 3'b000; reg_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                SW: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001 || counter == 6'b000010) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b0;
                        IorD <= 3'b000; mem_wr <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter == 6'b000011) begin
                        mem_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000100) begin
                        mem_wr <= 1'b0; store_control <= 4'b0010; // SW -> 4'b0010 (dois)
                        counter <= counter + 1;
                    end else if (counter == 6'b000101) begin
                        IorD <= 3'b100; mem_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                SH: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001 || counter == 6'b000010) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b0;
                        IorD <= 3'b000; mem_wr <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter == 6'b000011) begin
                        mem_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000100) begin
                        mem_wr <= 1'b0; store_control <= 4'b0000; // SH -> 4'b0000 (zero)
                        counter <= counter + 1;
                    end else if (counter == 6'b000101) begin
                        IorD <= 3'b100; mem_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                SB: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b010; Alu_Op <= 3'b001; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001 || counter == 6'b000010) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b000; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b0;
                        store_control <= 4'b0001; // SB -> 4'b0001 (um)
                        IorD <= 3'b000; mem_wr <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter == 6'b000011) begin
                        mem_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        IorD <= 3'b100; mem_wr <= 1'b1;
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                LUI: begin
                    if (counter == 6'b000000) begin
                        shift_n <= 2'b01; shift_control <= 3'b001; 
                        shift_control_in <= 2'b01;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        shift_control <= 3'b010;
                        counter <= counter + 1;
                    end else if (counter == 6'b000010) begin
                        mem_reg <= 4'b0101; reg_dst <= 3'b000; reg_wr <= 1'b1;
                        shift_n <= 2'b00; shift_control <= 3'b000; 
                        shift_control_in <= 2'b00;
                        counter <= counter + 1;
                    end else begin
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                // ========== DESVIOS ==========
                BEQ: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b10; Alu_Src_B <= 3'b000; Alu_Op <= 3'b111;
                        counter <= counter + 1;
                    end else if (counter == 6'b000001) begin
                        if (et == 1'b1) begin
                            PC_Source <= 3'b100; PC_wr <= 1'b1;
                        end
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                JR: begin
                    PC_Source <= 3'b001; PC_wr <= 1'b1;
                    state <= FETCH; counter <= 6'b000000;
                end
                
                J: begin
                    PC_Source <= 3'b011; PC_wr <= 1'b1;
                    state <= FETCH; counter <= 6'b000000;
                end
                
                JAL: begin
                    if (counter == 6'b000000) begin
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b001; Alu_Op <= 3'b000; 
                        Alu_out_wr <= 1'b1;
                        counter <= counter + 1;
                    end else begin
                        reg_dst <= 3'b010; mem_reg <= 4'b0011; PC_Source <= 3'b011;
                        reg_wr <= 1'b1; PC_wr <= 1'b1;
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                // ========== MULT/DIV ==========
                MULT: begin
                    if (counter == 6'b000000) begin
                        mult_start <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b100001) begin
                        Lo_wr <= 1'b1; Hi_wr <= 1'b1;
                        state <= FETCH; counter <= 6'b000000;
                    end else begin
                        mult_start <= 1'b0;
                        counter <= counter + 1;
                    end
                end
                
                DIV: begin
                    if (counter == 6'b000000) begin
                        div_start <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter == 6'b100001) begin
                        Lo_wr <= 1'b1; Hi_wr <= 1'b1;
                        state <= FETCH; counter <= 6'b000000;
                    end else begin
                        if (div_zero == 1'b1) begin
                            state <= EXC_DIVZERO; counter <= 6'b000000;
                        end else begin
                            div_start <= 1'b0;
                            counter <= counter + 1;
                        end
                    end
                end
                
                MFHI: begin
                    mem_reg <= 4'b0000; reg_dst <= 3'b001; reg_wr <= 1'b1;
                    state <= FETCH; counter <= 6'b000000;
                end
                
                MFLO: begin
                    mem_reg <= 4'b0001; reg_dst <= 3'b001; reg_wr <= 1'b1;
                    state <= FETCH; counter <= 6'b000000;
                end
                
                // ========== EXCEÇÕES ==========
                EXC_OPCODE, EXC_OVERFLOW, EXC_DIVZERO: begin
                    if (counter < 6'b000010) begin
                        cause_control <= (state == EXC_OVERFLOW) ? 2'b01 : 
                                        (state == EXC_OPCODE) ? 2'b00 : 2'b10;
                        IorD <= 3'b001; mem_wr <= 1'b0; 
                        Alu_Src_A <= 2'b00; Alu_Src_B <= 3'b001; Alu_Op <= 3'b010;
                        counter <= counter + 1;
                    end else begin
                        EPC_wr <= 1'b1; PC_wr <= 1'b1; 
                        state <= FETCH; counter <= 6'b000000;
                    end
                end
                
                RTE: begin
                    PC_Source <= 3'b101; PC_wr <= 1'b1;
                    state <= FETCH; counter <= 6'b000000;
                end
                
                default: begin
                    state <= FETCH; counter <= 6'b000000;
                end
            endcase
        end
    end
endmodule