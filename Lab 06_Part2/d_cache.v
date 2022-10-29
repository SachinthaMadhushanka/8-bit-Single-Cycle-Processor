`timescale  1ns/100ps

// Data_cache Module
module data_cache (clock,reset,read,write,address,write_data,read_data,busy_wait,mem_read,mem_write,mem_address,mem_write_data,mem_read_data,mem_busy_wait);

	// Add cache memory to the wavedata file
	integer idx;
	initial begin
		$dumpfile("cpu_wavedata.vcd");
		for (idx = 0; idx < 8; idx = idx + 1) 
			$dumpvars(0, cache_mem[idx]);
	end

	// Declare inputs and outputs of the CPU module
	input clock,reset,read,write; 
	input [7:0] address,write_data;
	output reg busy_wait;
	output reg [7:0] read_data;

	// Declare inputs and outputs of the Data Memory module
	input mem_busy_wait;
	input [31:0] mem_read_data;
	output reg mem_read,mem_write;
	output reg [5:0] mem_address;
	output reg [31:0] mem_write_data;
	
	/* 
		Define some registers
		read_access and write_access for controlling read and write opretations in cache memory.
	*/
	reg read_access, write_access,valid,dirty;
	reg [1:0] offset; 
	reg [2:0] tag,index; 
	reg [31:0] cache_block; 

	reg [31:0] cache_mem[7:0];	
	reg [2:0] cache_tag[7:0];
	reg cache_dirty [7:0];
	reg cache_valid [7:0];
	

	/*
		Using tag and valid bit get the hit signal
	*/
	wire hit;
	assign #0.9 hit = tag == address[7:5] && valid;

	/* 
		4 to 1 MUX to get the read data from the cache block
		Using the offset get corresponding data from the block
	*/
	always @(cache_block[7:0],cache_block[15:8],cache_block[23:16],cache_block[31:24],offset)begin
	
		case(offset)
		
			0:	
				#1 read_data = cache_block[7:0];
			1:	
				#1 read_data = cache_block[15:8]; 
			2:	
				#1 read_data = cache_block[23:16]; 
			3:	
				#1 read_data = cache_block[31:24]; 
		
		endcase
	end


	/*
		This block will be executed at the positive edge of the clock
	*/
	always @(posedge clock)begin 
		/* 
			If read_access and hit signal is 1 => Read hit
			Set read_access and busy_wait to 0
		*/
		if(read_access && hit)begin 
			read_access = 0; 
			busy_wait = 0;
		end

		/* 
			If write_access and hit signal is 1 => Write hit
		*/
		else if(write_access && hit)begin
			busy_wait = 0; // Set busy_wait to 0
			
			/*
				Writing to the cache memory using offset
				Using the offset write data to corresponding place in the block.
			*/
			case(offset)
				0:	
					#1 cache_mem[index][7:0] = write_data; 
				1:	
					#1 cache_mem[index][15:8] = write_data;
				2:	
					#1 cache_mem[index][23:16] = write_data;
				3:	
					#1 cache_mem[index][31:24] = write_data;
		
			endcase
			cache_valid[index] = 1; // Set valid bit to 1
			cache_dirty[index] = 1; // Set dirty bit to 1
			write_access = 0; // Set write_access to 0
			
		 end
	end
	
	/*
		Read write signal control using seperate cicuit.
	*/
	always @(read, write)
	begin
		busy_wait = (read || write); 
		read_access = (read && !write);
		write_access = (!read && write);
	end
	
	always @(*)begin
		
		/*
			if read_access or write_access enabled
			set following signals
		*/
		if(read_access || write_access)begin
		
			index <= #1 address[4:2]; // Set index
			cache_block <= #1 cache_mem[ address[4:2] ];
			tag <= #1 cache_tag[address[4:2]];
			dirty <= #1 cache_dirty[address[4:2]];
			valid <= #1 cache_valid[address[4:2]];
			offset <= #1 address[1:0];
			
		end
	end
	



  /* Cache Controller FSM Start */

	//These are the STATES in our FSM
    parameter IDLE = 3'b000, MEM_WRITE = 3'b001 , MEM_READ = 3'b010 , ALLOCATE = 3'b011;
    /*
		IDLE 	  : State to handle cache
		MEM_WRITE : State to write data block to the main memory
		MEM_READ  : State to read the data block from main memory
		ALLOCATE  : State to deal with the cache (Data block coming from the data memory is fetched to the cache in this state )
	*/
	
	
	reg [2:0] state, next_state; //To hold the current state and next state values

    //To select the next states based on Current states parameters
    always @(*)
    begin
        case (state)
            IDLE:
                
				//To handle misses without the dirty bit
				if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;			// Set the next state to MEM_READ to read the relevant block from data memory
                
				
				//To handle misses with the dirty bit
				else if ((read || write) && dirty && !hit)	
                    next_state = MEM_WRITE;			// Set the next state to MEM_WRITE (Because the the existing cache block is inconsistent with
													//with data memory block)
                else
                    next_state = IDLE;              // If everything is perfect it stay on the currnt state
            
            MEM_READ:
				//To handle  next state when the mem_busy wait is low
                if (!mem_busy_wait)
                    next_state = ALLOCATE;			//We can set to that into ALLOCATE state (After reading is done we should fetched that block into cache)
                //To handle the next state when the mem_busywit is high
				else    
                    next_state = MEM_READ;			//If the reading is not done we should stay on the same state 
					
			MEM_WRITE:
				//To handle next state when the mem_busywait is low
                if (!mem_busy_wait)
                    next_state = MEM_READ;			//If the writing is done the block is read from the data memory 
                //To handle next state when the mem_busywait is low
				else    
                    next_state = MEM_WRITE;			//If the writing is not  done stay in the current state untill writnig is done 
					
			ALLOCATE:
                 
                    next_state = IDLE;				//After the read into cache complete set next state as IDLE
      
        endcase
    end

   
   
   
   //==========================================================================================================================================
    always @(*)
    begin
        case(state)
			//Handle the IDLE STATE
            IDLE:
            begin
				//Set mem_read and mem_write to 0 because we did not deal with the data memry in this STATE
                mem_read = 1'd0;	
                mem_write = 1'd0;

				//Also set the mem_addres and mem_write_data to x 
                mem_address = 6'dx;
                mem_write_data = 32'dx;

				//This state not deal with the data memrory. It use only cache memory. If misses happen next state will schange to rlevat state
    
            end
         
            MEM_READ: 
            begin
				//In this state we read data block from the data memory. Therefore the mem_read should high and mem_write should be low
                mem_read = 1'd1;
                mem_write = 1'd0;

				//Set the mem_address to relevant block address(To do that tag and the index that come from the cpu are used)
                mem_address = {tag, index};
                //Since this state do not write anything into the data memory se wet that address to x
				mem_write_data = 32'dx;
                
            end
			
			MEM_WRITE: 
            begin
				//This state writes the data block into the data memory. Therefore the mem_write is high and mem_read is low 
                mem_read = 1'd0;
                mem_write = 1'd1;

				//Set the data memory address into relevant block address by usimg tag and index
                mem_address = {tag, index};	
				
				//In this state we write data into data memory. cache_block holds the relevant data and that block is write to data mem
                mem_write_data = cache_block;
              
              
            end
			
			ALLOCATE: 
            begin
				//This state is to write (allocate) the data block that is read from the data memory, into the cache memory
               	//Since this only fetching the data block into cache the mem_read,mem_write should be zero  
			   	mem_read = 1'd0;
                mem_write = 1'd0;
				//Also the address and the mem_write_data should yo be x
                mem_address = 6'dx;
                mem_write_data = 32'dx;
				
				//After 1 time unit delay is start to fetching the data into cache memory
				#1
				// | VALID - 36 | DIRTY - 35 | TAG 34 - 32 | DATA BLOCK 31 - 0 | 		Structure of the cache memory
				
				cache_mem[index] 	= 	mem_read_data;			//Data block to the first 32 bits in cache memory
				cache_tag[index] = 	address[7:5];			//Then the tag bits
				cache_valid[index]	= 	1'd1;					//Set the dirty bit
				cache_dirty[index] 	= 	1'd0;					//Set the valid bit
			
            end
            
            
            
        endcase
    end

	
	
	integer i;
	//========================================================================================================================================

    always @(posedge clock, reset)
    begin
        if(reset)begin
            state = IDLE; 			//If reset the cache , the state should be in IDLE	
			
			//Set the busy_wait to be 0
			busy_wait = 0;		
			
			// Reset the entire cache memory
			for (i=0;i<=7;i=i+1)begin
				cache_mem[i] <=  #1 0;   
				cache_dirty[i] <=  #1 0;   
				cache_valid[i] <=  #1 0;   
			end 			
			
		end
        else begin
			//change the state of FSM in a positive clock edge
            state = next_state;
		end
    end
	
	

    /* Cache Controller FSM End */

endmodule