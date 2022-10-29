// reg_file module
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);
input [7:0] IN; // set IN as 8 bit input
input [2:0] INADDRESS , OUT1ADDRESS , OUT2ADDRESS; // set INADDRESS , OUT1ADDRESS , OUT2ADDRESS as 3 bit inputs
input WRITE , CLK , RESET; // set WRITE , CLK , RESET as inputs
output reg [7:0] OUT1 , OUT2; // set OUT1 , OUT2 as 8 bit output registers

reg [7:0] registers [7:0]; // Create 8 , 8 bit registers to store values.

integer i; // Initialize a integer variable for loop

/* always block
   This block will be executed when rising edge of CLK occurs.
*/
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
    end

    // If RESET == 0 and WRITE == 1
    if(!RESET & WRITE)begin
        /* store given value in the given register.
           IN contains the value and INADDRESS used to identify the register.
        */
        registers[INADDRESS] <= #1 IN; 
    end  
end


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
endmodule  


// Testbench module for testing purposes
module Testbench; 

    /* Following wires and registers are used to create instance of the reg_file module.
    */
    reg [7:0] IN; // IN is a 8 bit register
    reg [2:0] INADDRESS , OUT1ADDRESS , OUT2ADDRESS; // INADDRESS , OUT1ADDRESS , OUT2ADDRESS are 3 bit registers
    reg WRITE , CLK , RESET; // WRITE , CLK , RESET are registers
    wire [7:0] OUT1 , OUT2; // OUT1 , OUT2 are 8 bit wires

    // create instance of the reg_file module
    reg_file reg_f (IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);
    
    initial 
    begin
        
        // t = 5
        #5 RESET = 1; CLK = 0; CLK = 1; RESET = 0; // Reset
        // t = 10
        #5 WRITE = 1; CLK = 0; CLK = 1; IN = 10; INADDRESS = 0; // register0 value = 10
        // t = 15
        #5 CLK = 0; CLK = 1; IN = 20; INADDRESS = 1; // register1 value = 20
        // t = 20
        #5 CLK = 0; CLK = 1; IN = 30; INADDRESS = 2; // register2 value = 30
        // t = 25
        #5 CLK = 0; CLK = 1; IN = 40; INADDRESS = 3; // register4 value = 10
        // t = 30
        #5 CLK = 0; CLK = 1; IN = 50; INADDRESS = 4; // register5 value = 10
        // t = 35
        #5 CLK = 0; CLK = 1; IN = 60; INADDRESS = 5; // register6 value = 10
        // t = 40
        #5 CLK = 0; CLK = 1; IN = 70; INADDRESS = 6; // register7 value = 10
        // t = 45
        #5 CLK = 0; CLK = 1; IN = 80; INADDRESS = 7; // register8 value = 10


        // t = 50
        #5 WRITE = 0; OUT1ADDRESS = 0; OUT2ADDRESS = 1; // get register1 and register2 value
        // t = 55
        #5 OUT1ADDRESS = 2; OUT2ADDRESS = 3; // get register3 and register4 value
        // t = 60
        #5 OUT1ADDRESS = 4; OUT2ADDRESS = 5; // get register5 and register6 value
        // t = 65
        #5 OUT1ADDRESS = 6; OUT2ADDRESS = 7; // get register7 and register8 value


        // t = 70
        #5 WRITE = 1; RESET = 1; CLK = 0; CLK = 1; // reset
        // t = 75
        #5 RESET = 0; WRITE = 0; OUT1ADDRESS = 0; OUT2ADDRESS = 1;
    end 


    /* Initial block
       This is used for monitoring purposes.
    */
    initial  
    begin
        $monitor("%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d",$time, IN,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK, RESET,OUT1,OUT2); 
        // $monitor("%d,\t%d,\t%d",$time,OUT1,OUT2); 
        $dumpfile ("register_file.vcd"); 
        $dumpvars; 
    end 
    
endmodule
                          