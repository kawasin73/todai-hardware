module simcpu;
reg CK, RST;
wire RW;
wire [15:0] IA, DA, DD;
reg [15:0] ID, DDi;
reg [15:0] IMEM [0:127], DMEM[0:127];

wire  [15:0]  DMEM00, DMEM01, DMEM02;
	CPU c(CK,RST,IA,ID,DA,DD,RW);

assign DMEM00 = DMEM[0];
assign DMEM01 = DMEM[1];
assign DMEM02 = DMEM[2];

   assign DD = ((RW == 1) ? DDi : 'b Z);

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars;
	CK = 0;
	RST = 0;
#5	RST = 1;
#100	RST = 0;
	
        #10000 $finish;
end

always @(negedge CK) begin
   if( DA == 2 && DD == 75 && RW == 0 ) begin
      $display( "OK" );
      $finish;
   end
end

always @(negedge CK) begin
	ID = IMEM[IA];
end

always @(negedge CK) begin
   if( RW == 1 ) DDi = DMEM[DA];
   else DMEM[DA] = DD;
end

initial begin
DMEM[0]= 5;
DMEM[1]= 15;
// D2 = D0 * D1
IMEM[ 0]='b 1100_0001_0000_0000; // IMM  R1, [0]     ; R1 = result
IMEM[ 1]='b 1100_0010_0000_0000; // IMM  R2, [0]     ; R2 = xxxxxxx not use
IMEM[ 2]='b 1100_0011_0000_0001; // IMM  R3, [1]     ; R3 = 1
IMEM[ 3]='b 1100_0100_0000_1000; // IMM  R4, [8]     ; R4 = loop count
IMEM[ 4]='b 1100_0101_0001_0101; // IMM  R5, [21]    ; R5 = finish addr
IMEM[ 5]='b 1100_0110_0000_1101; // IMM  R6, [13]    ; R6 = loop addr
IMEM[ 6]='b 1100_0111_0001_0000; // IMM  R7, [16]    ; R7 = skip addr
IMEM[ 7]='b 1100_1000_0000_0000; // IMM  R8, [0]     ; R8 = mem addr
IMEM[ 8]='b 1100_1001_0000_0001; // IMM  R9, [1]     ; R9 = bit mask
IMEM[ 9]='b 1011_1010_0000_1000; // LD  R10, [R8]    ; R10 = Data[0]
IMEM[10]='b 0000_1000_1000_0011; // ADD  R8, R8, R3
IMEM[11]='b 1011_1011_0000_1000; // LD  R11, [R8]    ; R11 = Data[1]
IMEM[12]='b 0000_1000_1000_0011; // ADD  R8, R8, R3
IMEM[13]='b 0101_1100_1011_1001; // AND R12, R11, R9 ; R12 = skip add or not
IMEM[14]='b 1001_0000_0000_0111; // BR  f=0, R7
IMEM[15]='b 0000_0001_0001_1010; // ADD  R1,  R1, R10
IMEM[16]='b 0011_1010_1010_0011; // LSH R10, R10, R3
IMEM[17]='b 0010_1011_1011_0011; // RSH R11, R11, R3
IMEM[18]='b 0001_0100_0100_0011; // SUB  R4,  R4, R3
IMEM[19]='b 1001_0000_0000_0101; // BR f=0, R5
IMEM[20]='b 1000_0000_0000_0110; // JMP R0, R6
IMEM[21]='b 1010_0000_0001_1000; // ST R1, R8
IMEM[22]='b 1000_0000_0000_0101; // JMP R0, R5
end

always #10 CK = ~CK;

endmodule
