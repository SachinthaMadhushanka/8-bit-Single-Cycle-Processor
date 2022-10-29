`timescale  1ns/100ps
`include "part1.v"
`include "part2.v"

module cu(PC,INSTRUCTION, CLK, RESET,OUT1ADDRESS,OUT2ADDRESS,IMM,IN,WRITEENABLE,SELECT,SELECT1,SELECT2,JUMP,B_TARGET,is_Decode,mem_read,mem_write,WRITESELECT,BUSYWAIT);

//INPUTS
input [31:0] INSTRUCTION,PC;	// Get the input INSTRUCTION AND PC VALUE AS inputs 

input RESET,CLK,BUSYWAIT;		// To hold the RESET.CLOCKM AND THE busy wait signals

output reg B_TARGET;			// To hold the brach target
output reg [31:0] JUMP;			// Hold the jump value of PC

output reg [2:0] OUT1ADDRESS,OUT2ADDRESS,IN,SELECT; //To keep the OUT1ADDRESS and OUT2ADDRESS. Also IN(write data) and the ALOUP(SELECT)

//Below part is to take write signal(when we want to write values in to registers),
/*
	SELECT1 : FOR MUX1
	SELECT2 : FOR MUX2
*/
output WRITEENABLE,SELECT1,SELECT2,WRITESELECT,mem_read,mem_write;

// To hold the IMMEDIATE values
output reg [7:0] IMM;





//To hold the temporary pc value when calculating PC VAL
reg [31:0] inter_PC;


reg SELECT1,SELECT2,WRITESELECT,mem_read,mem_write; 


reg WRITEENABLE = 0;
output reg is_Decode 	= 0;

//Hnadle the cprresponding signals when the beq and jump instruction involve
always @(PC)begin

	if(PC ==-4)begin
	
		SELECT2 = 1'b1;			
		B_TARGET = 1'b0;
	
	end



end

// DECODE THE COMING INSTRUCTION

integer i;
always @(INSTRUCTION)begin 

	//Hold the (read) registers 
	OUT1ADDRESS = INSTRUCTION[15:8]; 
	OUT2ADDRESS = INSTRUCTION[7:0];
	
	//Take the data from register or immediate		
	IN = INSTRUCTION[23:16];		
	IMM = INSTRUCTION[7:0];			
	JUMP[1:0] = 1'd0;
	
	

	
	
	//Extract the jump address from the instruction
	JUMP[8:2] = INSTRUCTION[23:16];
	
	
	for(i = 9;i<32 ;i = i +1)begin
		
		JUMP[i] = INSTRUCTION[23] ;
	
	end
	
	
	
	#1
	//Take care of the mem_read and the mem_write
	mem_read = 1'b0;
	mem_write = 1'b0;
	 
	
	
	case(INSTRUCTION[31:24])

		8'b00000000:  
			SELECT = 3'b001;			//opcode for add instruction
		
		8'b00000001:
		   	SELECT = 3'b001;			//opcode for sub instruction
		
		8'b00000010:
		   	SELECT = 3'b010;			//opcode for and instruction
		
		8'b00000011:
		   	SELECT = 3'b011;			//opcode for or instruction
		
		8'b00000100:
		   	SELECT = 3'b000;			//opcode for mov instruction
		
		8'b00000101:
		   	SELECT = 3'b000;			//opcode for loadi instruction
		
		8'b00000110:
		   	SELECT = 3'b001;			//opcode for beq instruction
		
		8'b00000111:
		   	SELECT = 3'b000;			//opcode for jump instruction
		
		8'b00001000:
		   	SELECT = 3'b000;			//opcode for lwd instruction
		
		8'b00001001:
		   	SELECT = 3'b000;			//opcode for lwi instruction
		
		8'b00001010:
		   	SELECT = 3'b000;			//opcode for swd instruction
		
		8'b00001011:
		   	SELECT = 3'b000;			//opcode for swi instruction
	
	endcase
	

	B_TARGET  	= (INSTRUCTION[31:24] == 6  || INSTRUCTION[31:24] == 7);
	mem_read 	= (INSTRUCTION[31:24] == 8 || INSTRUCTION[31:24] == 9);
	mem_write 	= (INSTRUCTION[31:24] == 10 || INSTRUCTION[31:24] == 11);
	WRITESELECT	= ~(INSTRUCTION[31:24] == 8 || INSTRUCTION[31:24] == 9);
	SELECT1		= ~(INSTRUCTION[31:24] == 1 || INSTRUCTION[31:24] == 6);
	SELECT2 	= (INSTRUCTION[31:24] == 5 || INSTRUCTION[31:24] == 7 || INSTRUCTION[31:24] == 9 || INSTRUCTION[31:24] == 11);
	WRITEENABLE	= ~(INSTRUCTION[31:24] == 6 || INSTRUCTION[31:24] == 7 || INSTRUCTION[31:24] == 10 || INSTRUCTION[31:24] == 11);
	
	is_Decode = ~ is_Decode;
		
end



endmodule



//CREATE THE CPU MODULE


module cpu(PC, INSTRUCTION, CLK, RESET,mem_read,mem_write,RESULT,OUT1,mem_readdata,BUSYWAIT,INS_BUSYWAIT);

//Input take to clock , Busywait, and the another busywait come from the instruction cache
input CLK,RESET,BUSYWAIT,INS_BUSYWAIT;

// The data tha write to the memory
input [7:0] mem_readdata;

//Relevant instruction and the PC value 
input [31:0] INSTRUCTION;
output reg [31:0] PC;

//Signals to handle the read access and the write access of the memory cache
output mem_read,mem_write;

// Values of the reg out and the RESULT
output [7:0] RESULT,OUT1;

// To take the address of the two registers and the destinationteg adress and the aloup signal
wire [2:0] OUT1ADDRESS,OUT2ADDRESS,IN,ALUOP;

//To get the immediate value,out put of the regouut two and the data that write to rhe mem cache
wire [7:0] IMMEDIATE,OUT2,mem_readdata;
wire [31:0] OFFSET;
/*
	mux_select1 ,mux_select2 are the control signals of the mux 1 and the mux 2 respectively
	Zero signal is to hanlde the additional mux s select value
*/
wire WRITEENABLE,mux_select1,mux_select2,BRANCH,ZERO,is_Decode,BUSYWAIT,WRITESELECT;

//Updated pc values
reg [31:0] updated_PC;

//To hold the value that come in intermidiate calculation
reg [31:0] inter_PC,BRANCHTARGET;

//Relevant output of mux1 and mux2 
reg[7:0] mux2out,mux1out,WRITEDATA,M_data;

//To hold the signal when decide the next pc value
reg getPC;





//CU Module
cu mycu(PC,INSTRUCTION, CLK, RESET,OUT1ADDRESS,OUT2ADDRESS,IMMEDIATE,IN,WRITEENABLE,ALUOP,mux_select1,mux_select2,OFFSET,BRANCH,is_Decode,mem_read,mem_write,WRITESELECT,BUSYWAIT);

//Regfile 
reg_file myregfile(WRITEDATA, OUT1, OUT2, IN, OUT1ADDRESS, OUT2ADDRESS, WRITEENABLE, CLK, RESET);




// Implementation of the mux 1 and the mux 2
always @(mux1out,IMMEDIATE,mux_select2)begin

	if(mux_select2 == 1'b0) begin

		mux2out = mux1out;

	end
	else begin

		mux2out = IMMEDIATE;

	end
end

//This two modules take the relevant signaland decide the correponging output and send them as outputs of a mux
always @(M_data,OUT2,mux_select1)begin

	if(mux_select1 == 1'b0) begin

		mux1out = M_data;

	end
	else begin

		mux1out = OUT2;

	end
end



//Handle the data value thats deal with the mem cache and the reg files

always @(mem_readdata,RESULT,WRITESELECT)begin

	if(WRITESELECT == 1'b0) begin

		WRITEDATA = mem_readdata;

	end
	else begin

		WRITEDATA = RESULT;

	end
end



//ALU module
alu myalu(OUT1,mux2out, RESULT, ALUOP,ZERO); 





always @(RESET)begin//writing to PC is sensitive for the positive clock edge

	//updating the pc value
	
	if(RESET == 1'b1)begin
	#1//PC write delay
		PC = -32'd4;
		
	end
	
end
//write to the PC
always @(posedge CLK)begin

	//updating the pc value
	//PC write delay
	#1
	if(!RESET  && !BUSYWAIT && !INS_BUSYWAIT )begin
	
	
		PC = updated_PC;
		
	end

end


always @(inter_PC,BRANCHTARGET,getPC)begin

	if(getPC == 1'b0) begin

		updated_PC = inter_PC;

	end
	else begin

		updated_PC = BRANCHTARGET;

	end
end
//increasing the PC value by four
always @(PC)begin //updating pc value is sensitive to the PC

	#1 //adding delay four to PC value
	if(BUSYWAIT == 1'b0 && INS_BUSYWAIT == 1'b0)begin
		inter_PC = PC + 32'd4;
	end

end 


//Hnadle the jump and beq

always @(is_Decode)begin

	#1	
	if(BUSYWAIT == 1'b0)begin
		BRANCHTARGET = OFFSET + inter_PC; //SEt the target value depends on the offset (pc +4 offset)
	end
	
end


always @(BRANCH,ZERO)begin
	
	if(BUSYWAIT == 1'b0)begin
	
		//Handle when the pc on reset
		if(PC == -4)begin
		
			getPC = 1'b0;
		
		end
	
		else begin
		
			getPC = BRANCH & ZERO;		//for the instructions except bne instruction
		
		end
	
	end

end
 

//Handle the 2's cpmpliment and the original val module

always @(OUT2)begin

	#1	
	if(BUSYWAIT == 1'b0)begin
	
		M_data = ~OUT2 + 8'b00000001;	//Get the compliment of the value
		
	end
	
end




endmodule



