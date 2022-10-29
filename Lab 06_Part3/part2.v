`timescale  1ns/100ps



module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);

reg [7:0] registers [7:0];	//defining the registor file

input [7:0] IN; // set IN as 8 bit input
input [2:0] INADDRESS , OUT1ADDRESS , OUT2ADDRESS; // set INADDRESS , OUT1ADDRESS , OUT2ADDRESS as 3 bit inputs
input WRITE , CLK , RESET; // set WRITE , CLK , RESET as inputs
output reg [7:0] OUT1 , OUT2; // set OUT1 , OUT2 as 8 bit output registers

reg [7:0] interOUT1,interOUT2;	//declearing output as reg type

reg finishWrite = 1'b0;	//this register is used to check whether write/reset is done

integer idx;
initial begin
    $dumpfile("cpu_wavedata.vcd");
    //$monitor("%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d",$time,registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]); 
     for (idx = 0; idx < 8; idx = idx + 1) 
        $dumpvars(0, registers[idx]);
end





integer i; // Initialize a integer variable for loop

always @ (posedge CLK)
begin
    if(RESET)begin // If RESET = 1
        /* all the registers will be set as 0
           This is a non blocking statement. So all the registers will be set as 0
           at same time (after 1 time unit).
        */
        for (i=0;i<=7;i=i+1)begin
            registers[i] <=  #1 0;   
        end 
		 finishWrite=~finishWrite;
    end

    // If RESET == 0 and WRITE == 1
    if(!RESET & WRITE)begin
        /* store given value in the given register.
           IN contains the value and INADDRESS used to identify the register.
        */
        #1 registers[INADDRESS] =  IN;
        finishWrite =~ finishWrite; 
    end  
end



// end
/* always block
   This block will be executed when OUT1 or OUT2 or RESET or WRITE changed
*/
always @ (OUT1ADDRESS , OUT2ADDRESS , RESET , WRITE)
begin
    if(!WRITE)begin // If WRITE == 0
        OUT1 <= #2 registers[OUT1ADDRESS]; // set OUT1 as the value in OUT1ADDRESS register
        OUT2 <= #2 registers[OUT2ADDRESS]; // set OUT2 as the value in OUT2ADDRESS register
    end
    
end


//afret a resetting or writing,updating the output registors
always @(finishWrite)begin

	//add time delay for outputing register values
	//calculating the output registor addresses and outputing the corresponding register values
	interOUT1 = registers[ OUT1ADDRESS ];
	interOUT2 = registers[ OUT2ADDRESS ];
	#2
	OUT1 = interOUT1;
	OUT2 = interOUT2;
end




always @(*)begin

	$monitor("%d , %d , %d , %d , %d , %d , %d , %d , %d",$time, registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]);
	

end


endmodule