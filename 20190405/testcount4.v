module testcount4r;
  wire		[3:0] out;
  reg		ck;
  initial begin
	$monitor( "%t %b %b", $time, ck, out);
	ck<=0;
	#350
	$finish;
  end
  always #10  ck <= ~ck;
  count4  cnt ( out, ck );
endmodule
