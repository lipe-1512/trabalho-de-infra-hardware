module div (
    input wire clk, 
    input wire reset, 
    input wire div_start,
    input wire [31:0] A, 
    input wire [31:0] B,
    output reg div_zero,
    output reg [31:0] Hi, 
    output reg [31:0] Lo
);
    reg seletor;
    reg [5:0] nOfBits;
    reg [31:0] divisor;
    reg [31:0] dividendo;
    reg [31:0] resto;
    reg [31:0] resultado;
    reg sinalDividendo;
    reg sinalDivisor;

    always @(posedge clk) begin
        if (reset == 1'b1) begin
            seletor <= 1'b0;
            nOfBits <= 6'd32;
            dividendo <= 32'b0;
            divisor <= 32'b0;
            resto <= 32'b0;
            resultado <= 32'b0;
            sinalDividendo <= 1'b0;
            sinalDivisor <= 1'b0;
            Hi <= 32'b0;
            Lo <= 32'b0;
            div_zero <= 1'b0;
        end else if (div_start == 1'b1) begin
            seletor <= 1'b1;
            nOfBits <= 6'd32;
            dividendo <= A;
            divisor <= B;
            resto <= 32'b0;
            resultado <= 32'b0;
            sinalDividendo <= A[31];
            sinalDivisor <= B[31];
            Hi <= 32'b0;
            Lo <= 32'b0;
            div_zero <= 1'b0;
            
            if (B == 32'b0) begin
                div_zero <= 1'b1;
            end else begin
                if (B[31] == 1'b1) begin
                    divisor <= ~B + 1'b1;
                end else begin
                    divisor <= B;
                end
                if (A[31] == 1'b1) begin
                    dividendo <= ~A + 1'b1;
                end else begin
                    dividendo <= A;
                end
            end
        end else if (seletor == 1'b1 && nOfBits != 6'd0) begin
            if (B == 32'b0) begin
                div_zero <= 1'b1;
                nOfBits <= 6'b0;
            end else begin
                resto <= {resto[30:0], dividendo[nOfBits - 1]};
                if (resto >= divisor) begin
                    resto <= resto - divisor;
                    resultado[nOfBits - 1] <= 1'b1;
                end
                nOfBits <= nOfBits - 1;
                
                if (nOfBits == 6'b000000) begin
                    if (sinalDividendo != sinalDivisor) begin
                        Lo <= ~resultado + 1'b1;
                        if (sinalDivisor == 1'b1) begin
                            Hi <= ~resto + 1'b1;
                        end else begin
                            Hi <= resto;
                        end
                    end else begin
                        Lo <= resultado;
                        if (sinalDivisor == 1'b1) begin
                            Hi <= ~resto + 1'b1;
                        end else begin
                            Hi <= resto;
                        end
                    end
                    seletor <= 1'b0;
                end
            end
        end
    end
endmodule