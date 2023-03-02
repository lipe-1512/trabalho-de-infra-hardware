module div(input wire clk, reset, divStart, input wire [31:0] A, B, output reg DivZero, output reg [31:0] Hi, Lo);
   
    reg seletor = 1'b0;
    reg [5:0] nOfBits;

    reg [31:0] divisor; // Sinal B
    reg [31:0] dividendo; // Sinal A
    reg [31:0] resto; // Hi
    reg [31:0] resultado; // Lo

    reg sinalDividendo;
    reg sinalDivisor;

    always @(posedge clk) begin 

        if(reset == 1'b1)begin

            nOfBits = 6'd32;
            dividendo = A;
            divisor = B;
            resto = 32'b0;
            resultado = 32'b0;
            sinalDividendo = dividendo[31];
            sinalDivisor = divisor[31];
            Hi = 32'b0;
            Lo = 32'b0;

        end

        if(divStart == 1'b1)begin

            seletor = 1'b1;
            nOfBits = 6'd32;
            dividendo = A;
            divisor = B;
            resto = 32'b0;
            resultado = 32'b0;
            sinalDividendo = dividendo[31];
            sinalDivisor = divisor[31];
            Hi = 32'b0;
            Lo = 32'b0;
            
            if(divisor[31] == 1'b1)begin

                divisor = ~(divisor) + 1'b1; //complemento de dois do valor do divisor. Isso ocorre porque, em aritmética de complemento de dois, para negar um número, é necessário inverter todos os seus bits e, em seguida, adicionar 1 ao resultado.

            end 
 
            if(dividendo[31] == 1'b1)begin

                dividendo = ~(dividendo) + 1'b1; //complemento de dois do valor do dividendo. Isso ocorre porque, em aritmética de complemento de dois, para negar um número, é necessário inverter todos os seus bits e, em seguida, adicionar 1 ao resultado.

            end

        end

        if(seletor == 1'b1 && nOfBits != 0)begin

            if(B == 32'b0) begin

                DivZero = 1'b1;
                nOfBits = 6'b0;
                
            end else begin

                resto = resto << 1;
                resto[0] = dividendo[nOfBits - 1];

                if(resto >= divisor)begin

                    resto = resto - divisor;
                    resultado[nOfBits - 1] = 1'b1;

                end

                nOfBits = nOfBits - 1;

                if(nOfBits == 6'b000000)begin

                    if(sinalDividendo != sinalDivisor)begin

                        if(sinalDivisor == 1'b1)begin

                            Hi = ~resto + 1'b1; //complemento de dois do valor do resto. Isso ocorre porque, em aritmética de complemento de dois, para negar um número, é necessário inverter todos os seus bits e, em seguida, adicionar 1 ao resultado.


                        end else begin

                            Hi = resto;

                        end

                        Lo = ~resultado + 1'b1; //complemento de dois do valor do resultado. Isso ocorre porque, em aritmética de complemento de dois, para negar um número, é necessário inverter todos os seus bits e, em seguida, adicionar 1 ao resultado.


                    end else begin

                        if(sinalDivisor == 1'b1)begin

                            Hi = ~resto + 1'b1;

                        end else begin

                            Hi = resto;

                        end                    

                        Lo = resultado;

                    end

                end
            end
        end

    end

endmodule
