
`timescale  1ns/100ps

module dcache (clock,reset,read,write,address,write_data,read_data,busy_wait,mem_read,mem_write,mem_address,mem_write_data,mem_read_data,mem_busy_wait);

		// Add cache memory to the wavedata file
	// integer idx;
	// initial begin
	// 	$dumpfile("cpu_wavedata.vcd");
	// 	for (idx = 0; idx < 8; idx = idx + 1) 
	// 		$dumpvars(0, cache_mem[idx]);
	// end

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


	/*
								 CACHE MEMORY
					   DATA			TAG			VALID		DIRTY 
					  32bits       3bits         1bit		 1bit     *  8
	*/
	reg [36:0] cache_mem[7:0];	
	

	/*
		Using tag and valid bit get the hit signal
	*/
	wire hit;
	
	//tag comparisan unit
	// xnor bit1cmp(cmpR1,tag[2],address[7]);
	// xnor bit1cmp(cmpR2,tag[1],address[6]);
	// xnor bit1cmp(cmpR3,tag[0],address[5]);
	
	// and #0.9 cmpResult(hit,cmpR1,cmpR2,cmpR3,valid); //deciding a hit or a miss 
	assign #0.9 hit = tag == address[7:5] && valid;
	
	//mux4to1 readData(cache_block[7:0],cache_block[15:8],cache_block[23:16],cache_block[31:24],offset,read_data); //select correct data word from the data cache_block
	// always @(cache_block[7:0],cache_block[15:8],cache_block[23:16],cache_block[31:24],offset)begin
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
	
		
		
	
	// end

	always @(posedge clock)begin 
	
		if(read_access == 1'b1 && hit == 1'b1)begin //read hit
			
			read_access = 1'b0;
			busy_wait = 1'b0;
		end
		else if(write_access == 1'b1 && hit == 1'b1)begin //write hit
			busy_wait = 1'b0;
			
			#1
			case(offset)
			
				//writing the data word to the cache
				0:	
					#1 cache_mem[index][7:0] = write_data; 
				1:	
					#1 cache_mem[index][15:8] = write_data;
				2:	
					#1 cache_mem[index][23:16] = write_data;
				3:	
					#1 cache_mem[index][31:24] = write_data;
		
			endcase
			cache_mem[index][35] = 1; // Set valid bit to 1
			cache_mem[index][36] = 1; // Set dirty bit to 1
			write_access = 0; // Set write_access to 0
			
		 
		 end
	end
	
	
	always @(read, write)
	begin
		//generating signals for the cache acccess
		busy_wait = (read || write)? 1 : 0;
		read_access = (read && !write)? 1 : 0;
		write_access = (!read && write)? 1 : 0;
	end
	
	always @(*)begin
		
		//reding the corresponding cache index
		/*
			if read_access or write_access enabled
			set following signals
		*/
		if(read_access || write_access)begin
		
			index <= #1 address[4:2]; // Set index
			cache_block <= #1 cache_mem[ address[4:2] ][31:0];
			tag <= #1 cache_mem[ address[4:2] ][34:32]; 
			dirty <= #1 cache_mem[ address[4:2] ][35];
			valid <= #1 cache_mem[ address[4:2] ][36];
			offset <= #1 address[1:0];
			
		end
	end
	
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_WRITE = 3'b001 , MEM_READ = 3'b010 , ALLOCATE = 3'b011;
    reg [2:0] state, next_state;

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

    // combinational output logic
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
                mem_address = address[7:2];
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
				
				cache_mem[index][31:0] 	= 	mem_read_data;			//Data block to the first 32 bits in cache memory
				cache_mem[index][34:32] = 	address[7:5];			//Then the tag bits
				cache_mem[index][35] 	= 	1'd0;					//Set the dirty bit
				cache_mem[index][36] 	= 	1'd1;					//Set the valid bit
			
            end
            
            
            
        endcase
    end

	integer i;
    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)begin
            state = IDLE; 			//If reset the cache , the state should be in IDLE	
			
			//Set the busy_wait to be 0
			busy_wait = 0;		
			
			// Reset the entire cache memory
			for (i=0;i<=7;i=i+1)begin
				cache_mem[i] <=  #1 0;   
			end 			
			
		end
        else begin
			//change the state of FSM in a positive clock edge
            state = next_state;
		end
    end
	
	

    /* Cache Controller FSM End */

endmodule