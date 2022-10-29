`include "part3.v"
`include "memory.v"
`include "cache.v"
`include "ins_memory.v"
`include "ins_cache.v"

`timescale  1ns/100ps

module testbench4;



reg CLK,RESET;

wire [127:0] insmreaddata;
wire [31:0] PC; 
wire [31:0] MWRITEDATA,MREADDATA,INSTRUCTION;	
wire MEMREAD,MEMWRITE,BUSY_WAIT,READ_SIGNAL,WRITE_SIGNAL,MEMBUSYWAIT,INS_BUSYWAIT,insmread,insmbusywait;
wire [7:0] RESULT,OUT1,READDATA;
wire [5:0] MADDRESS,insmaddress;




cpu mycpu(PC, INSTRUCTION, CLK, RESET,READ_SIGNAL,WRITE_SIGNAL,RESULT,OUT1,READDATA,BUSY_WAIT,INS_BUSYWAIT); 

dcache mydcache(CLK,RESET,READ_SIGNAL,WRITE_SIGNAL,RESULT,OUT1,READDATA,BUSY_WAIT,MEMREAD,MEMWRITE,MADDRESS,MWRITEDATA,MREADDATA,MEMBUSYWAIT);	//initailzing the cache


data_memory mydata_memory(CLK,RESET,MEMREAD,MEMWRITE,MADDRESS,MWRITEDATA,MREADDATA,MEMBUSYWAIT);


ins_cache myins_cache(CLK,PC,RESET,INS_BUSYWAIT,INSTRUCTION,insmaddress,insmread,insmreaddata,insmbusywait);

ins_memory myins_memory(CLK,insmread,insmaddress,insmreaddata,insmbusywait);

initial begin





//dumping wavedata
$dumpfile("testbench.vcd");
$dumpvars(0,testbench4);

CLK = 1'b0;
RESET = 1'b1;

#5

RESET = 1'b0;

#3500 $finish;

end

always

	#4 CLK = ~CLK;


endmodule







