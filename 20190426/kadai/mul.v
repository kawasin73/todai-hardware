module mul(A, B, O, ck, start, fin);
    input [7:0] A, B;
    input ck, start;
    output [16:0] O;
    output fin;

    reg [7:0] INA, INB;
    reg [16:0] y, OUT;
    reg [3:0] st;
    reg FIN;

    initial begin
        FIN <= 0;
        st <= 8;
        OUT <= 0;
    end

    always @(posedge ck) begin
        if (start == 1) begin
            INA <= A;
            INB <= B;
            st <= 7;
            y <= 0;
            OUT <= 0;
        end
        else if (FIN == 1) begin
            FIN <= 0;
            OUT <= 0;
        end
        else if (st == 0) begin
            OUT <= (y << 1) + (INB[st] == 1 ? INA : 0);
            FIN <= 1;
            // when st is 0 then underflows and change to 8
            st <= st - 1;
        end
        else if (st != 8) begin
            y <= (y << 1) + (INB[st] == 1 ? INA : 0);
            st <= st - 1;
        end
    end

    assign fin = FIN;
    assign O = OUT;
endmodule
