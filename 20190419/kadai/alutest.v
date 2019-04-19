module  alutest;
reg	[7:0]	A, B;
reg	[3:0]	CTR;
reg	ck;
wire	[7:0] O;
initial begin
	ck=0;
	$dumpfile("alu.vcd");
	$dumpvars;
	$monitor( "%t\tA=%b, B=%b, CTR=%b, OUT=%b", $time, A, B, CTR, O );
	#40 CTR <= 'b0000; A <= 11; B <= 2;
	#40 CTR <= 'b0001; A <= 11; B <= 2;
	#40 CTR <= 'b1000; A <= 'b10010110; B <= 'b00001111;
	#40 CTR <= 'b1001; A <= 'b10010110; B <= 'b00001111;
	#40 CTR <= 'b1010; A <= 'b10010110; B <= 'b00001111;
	#40 CTR <= 'b1011; A <= 'b10010110; B <= 0;
	#40 CTR <= 'b1100; A <= 'b10010110; B <= 0;
	#40 CTR <= 'b1101; A <= 'b10010110; B <= 0;
	#40 CTR <= 'b1110; A <= 'b10010110; B <= 0;
	#40 CTR <= 'b1111; A <= 'b10010110; B <= 0;
	#40 CTR <= 'b1101; A <= 'b01100011; B <= 0;
	#150  $finish;
end
alu	ALU(A , B , O , CTR , ck);
always	#10	ck = ~ck;
endmodule
