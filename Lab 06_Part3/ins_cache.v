`timescale  1ns/100ps

// Instruction Cache Module
module ins_cache(clock,PC,reset,busy_wait,cache_Instruction,imem_address,imem_read,imem_read_data,imem_busy_wait);

input clock,reset;
input [31:0] PC;
output reg busy_wait;

// Declare inputs and outputs
input imem_busy_wait;
input [127:0] imem_read_data;
output reg [5:0] imem_address;
output reg imem_read;
output reg [31:0] cache_Instruction;

/* 
	Define some registers
*/
reg valid,read_access;
reg [1:0] offset,state,nextstate;
reg [2:0] index;
reg [4:0] tag;
reg [127:0] cache_block;
reg [127:0] cache_mem [7:0]; 

reg [4:0] cache_tag [7:0];
reg cache_valid[7:0];
reg  [31:0] instruction;

/*
	Using tag and valid bit generate the hit signal
*/
wire hit;
assign #0.9 hit = (tag == PC[11:7] && valid);




always @(cache_block[31:0],cache_block[63:32],cache_block[95:64],cache_block[127:96],offset)begin
	#1	
	// Mux to select the correct instructions
	case(offset)
		0:
            instruction = cache_block[31:0];
		    
        1:
            instruction = cache_block[63:32];
		    
        2:
            instruction = cache_block[95:64];
		    
        3:
            instruction = cache_block[127:96];
		
	endcase
	
	
	/*
	Above mux take the cache block and break that into seperate parts

	Then it give the the correct instruction is fetched to the cpu
	*/
	if(PC == -4)begin
		instruction = 32'dx;
	end
end

	/*
	This is the parameteres to identifying states
	IDLE = 0
	MEM_READ = 1
	ALLOCATE = 2
	*/
parameter IDLE = 2'b00,MEM_READ = 2'b01,ALLOCATE = 2'b10;


always @(*)begin

	case(state)
		//To handle the idle cases
		IDLE		:	
						if(hit) 			//To check hit and handle the idle
							nextstate = IDLE;
						else
							nextstate = MEM_READ;	//Set next sate to the ME_READ to read the instruction
		MEM_READ	:
						if(imem_busy_wait)		//To handle the MEM_READ 
							nextstate = MEM_READ;
						else
							nextstate = ALLOCATE;	
		ALLOCATE	:
						nextstate = IDLE;	 //State that allocate the instruction to the cache block
	
	endcase
	
	//enable memory read_access for a instruction miss

	if(hit == 1'b0 && nextstate == MEM_READ) imem_read =1'b1;
	
end


//Handle the states with the parameters
always @(*)begin

	case(state)
		
		IDLE		:	begin
					//Set the mem_read to 0 because there is no read in that case
						imem_read = 1'd0;
						////Also set the the addres to x sinsce there is no reading part in this stte
						imem_address = 6'dx;
						end
		
		MEM_READ	:	begin
					//Set the rlevant addres that get it from the pc value
					//And read the relevanta block from the instruction memeory
						imem_address = PC[9:4];
						end
						
		ALLOCATE :	begin
						//Set the read signal to zero because there is no reading 
						imem_read = 1'b0;
						#1
						//Fetch the relevant block to the cache 
						cache_mem[index][127:0] = imem_read_data;	

						//Set the tag
						cache_tag[index] = PC[11:7];
						//Set the valid bit is to high 
						cache_valid[index] = 1;
						#1.9 
						//Set the busy_wait to 0
						busy_wait =0;


						end
	
	endcase
end


//Extract the tag,valid and the instruction block 
always @(*)begin

	if(read_access == 1'b1)begin
	
		#1
		//Get the relevant cache block from the cache memory
		cache_block = cache_mem[ PC[6:4]][127:0]; 
		//Set the tag bits
		tag = cache_tag[ PC [6:4]];
		//Set the valid bit
		valid = cache_valid[PC[6:4]];	

		//index of the cache_mem entry
		index = PC[6:4];
		//offset				
		offset = PC[3:2];				
		

	end

end


always @(instruction)begin
	
	//To handle the hit
	if(hit == 1'b1)begin
		//Set the cahce_instruction to the relevant instruction that hold
		cache_Instruction = instruction;
		//After that set the red signal to low
		read_access = 1'b0;
	
	end
		

end

	integer i;
    always @(posedge clock, reset)
    begin
		//Handle the reset
        if(reset)begin
			//Set the default state as the idle when reset is given
            state = IDLE;
			//Set the busy wait to zero
			busy_wait = 1'b0;
			
			
			#1
			//reset the instructin cache into zero
			for (i=0;i<=7;i=i+1)begin
				cache_mem[i] = 0;  
				//Alos valid bit and the tags
				cache_valid[i] = 0;
				cache_tag[i] = 0; 
			end 			

			
			
			
		end
        else begin
			//change the state of FSM in a positive clock edge
            state = nextstate;
		end
    end

/*
Every state transition happen when there is a positive clock edge
Idle state is used to handle the default(normal) cases
MEM_READ state is to handle the reading part that reads the instruction block from the instruction memry
Allocate is used to handle the fetching part(instruction that read from the instruction memory is fetched to the instruction cache block
)


*/
//To handle the hit
always @(posedge clock)begin
	//When there is a hit or the begining of the pc(just after reset) the busy_wait is xero
	if(hit == 1'b1 || PC == -4)begin
		busy_wait = 1'b0;
	
	end
	else begin
		//Or  wehn thre is a miss set that busy wait to 1
		busy_wait = 1'b1;
	
	end

end
//To handle the read access
always @(PC)begin
	//Change the readacces to 1 when the pc is changed
	read_access = 1'b1;
	
	if(PC == -4)begin
		//If the pc is on the reset state set the busy_wait and the read accces to zero
	 	busy_wait = 1'b0;
	 	read_access = 1'b0;
	
	end

end

endmodule