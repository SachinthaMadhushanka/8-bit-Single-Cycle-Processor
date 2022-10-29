`timescale  1ns/100ps

/*
Program	: 256x8-bit data memory (16-Byte blocks)
Author	: Isuru Nawinne
Date	: 10/06/2020

Description	:

This program presents a primitive instruction memory module for CO224 Lab 6 - Part 3
This memory allows instructions to be read as 16-Byte blocks
*/

module ins_memory(
    clock,
    read,
    address,
    readdata,
    busywait
);
input               clock;
input               read;
input[5:0]          address;
output reg [127:0]  readdata;
output reg          busywait;

reg readaccess;

//Declare memory array 1024x8-bits 
reg [7:0] memory_array [1023:0];

//Initialize instruction memory
initial
begin
    busywait = 0;
    readaccess = 0;

	
	{memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}  = 32'b00000101000000000000000000001001; 
    {memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}  = 32'b00000101000000010000000000000001; 
    {memory_array[10'd11], memory_array[10'd10], memory_array[10'd9],  memory_array[10'd8]}  = 32'b00001010000000000000000000000001; 
    {memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} = 32'b00001011000000000000000100000000; 

    {memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} = 32'b00001000000000100000000000000001;
    {memory_array[10'd23], memory_array[10'd22], memory_array[10'd21], memory_array[10'd20]} = 32'b00001000000000110000000000000001; 
	
    {memory_array[10'd27], memory_array[10'd26], memory_array[10'd25], memory_array[10'd24]} = 32'b00000001000001000000000000000001;
	
	
    {memory_array[10'd31], memory_array[10'd30], memory_array[10'd29], memory_array[10'd28]} = 32'b00001011000000000000010000000010; 

    {memory_array[10'd35], memory_array[10'd34], memory_array[10'd33], memory_array[10'd32]} = 32'b00001001000001010000000000000010;

    {memory_array[10'd39], memory_array[10'd38], memory_array[10'd37], memory_array[10'd36]} = 32'b00001011000000000000010000100000;

	{memory_array[10'd43], memory_array[10'd42], memory_array[10'd41], memory_array[10'd40]} = 32'b00001001000001100000000000100000;
	
end

//Detecting an incoming memory access
always @(read)
begin
    busywait = (read)? 1 : 0;
    readaccess = (read)? 1 : 0;
end

//Reading
always @(posedge clock)
begin
    if(readaccess)
    begin
		#40
        readdata[7:0]     =  memory_array[{address,4'b0000}];
        readdata[15:8]    = #40 memory_array[{address,4'b0001}];
        readdata[23:16]   = #40 memory_array[{address,4'b0010}];
        readdata[31:24]   = #40 memory_array[{address,4'b0011}];
        readdata[39:32]   = #40 memory_array[{address,4'b0100}];
        readdata[47:40]   = #40 memory_array[{address,4'b0101}];
        readdata[55:48]   = #40 memory_array[{address,4'b0110}];
        readdata[63:56]   = #40 memory_array[{address,4'b0111}];
        readdata[71:64]   = #40 memory_array[{address,4'b1000}];
        readdata[79:72]   = #40 memory_array[{address,4'b1001}];
        readdata[87:80]   = #40 memory_array[{address,4'b1010}];
        readdata[95:88]   = #40 memory_array[{address,4'b1011}];
        readdata[103:96]  = #40 memory_array[{address,4'b1100}];
        readdata[111:104] = #40 memory_array[{address,4'b1101}];
        readdata[119:112] = #40 memory_array[{address,4'b1110}];
        readdata[127:120] = #40 memory_array[{address,4'b1111}];
        #1 busywait = 0;
        readaccess = 0;
    end
end
 
endmodule