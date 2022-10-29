// alu module
// Add new output(ZERO) to the alu module                                                   /* */                                                
module alu(DATA1, DATA2, RESULT, SELECT , ZERO);                               
input [7:0] DATA1 , DATA2; // set data1 and data2 as 8 bit inputs
input [2:0] SELECT; // set select as 3 bit input
output reg [7:0] RESULT; // set result as 8 bit output register
output ZERO; // set ZERO as a output                                                        /* */

// Initialize 8 bit wires for storing outputs of the functional modules. 
wire  [7:0] forward_o , add_o , and_o , or_o;


// create instances of each functional modules.
FORWARD forward (DATA2, forward_o); 
ADD add_ (DATA1 , DATA2, add_o); 
AND and_ (DATA1 , DATA2, and_o); 
OR or_ (DATA1 , DATA2, or_o);   

/* 
    Create a instance of the  ZERO_MODULE                       
    RESULT : OUTPUT of the ALU
*/
ZERO_MODULE zero_m(RESULT , ZERO);                                                          /* */                           

/* always block                                                     
   If output of any functional module instance changed (forward_o , add_o , and_o , or_o)
   this block will be executed.
*/      
always @ (forward_o , add_o , and_o , or_o , SELECT)            
    begin
        case (SELECT)
            3'b000: // If SELECT == 0
                begin
                    RESULT =  forward_o; // assign value of forward_o to RESULT
                end
                
            3'b001: // If SELECT == 1
                begin
                    RESULT =  add_o; // assign value of add_o to RESULT
                end
                
            3'b010: // If SELECT == 2
                begin
                    RESULT = and_o; // assign value of and_o to RESULT
                end
                
            3'b011: // If SELECT == 3
                begin
                    RESULT = or_o; // assign value of or_o to RESULT
                end
                
        endcase
    end
endmodule  


// FORWARD funtional module
module FORWARD(DATA2, RESULT);
input [7:0] DATA2 ; // set data2 as 8 bit input
output [7:0] RESULT; // set result as 8 bit output

assign #1 RESULT = DATA2;
endmodule  


// ADD funtional module
module ADD(DATA1, DATA2, RESULT);
input [7:0] DATA1 , DATA2; // set data1 and data2 as 8 bit inputs
output [7:0] RESULT; // set result as 8 bit output

assign #2 RESULT = DATA1 + DATA2;
endmodule 


// AND funtional module
module AND(DATA1, DATA2, RESULT);
input [7:0] DATA1 , DATA2; // set data1 and data2 as 8 bit inputs
output [7:0] RESULT; // set result as 8 bit output

assign #1 RESULT = DATA1 & DATA2;
endmodule 

// OR funtional module
module OR(DATA1, DATA2, RESULT);
input [7:0] DATA1 , DATA2; // set data1 and data2 as 8 bit inputs
output [7:0] RESULT; // set result as 8 bit output

assign #1 RESULT = DATA1 | DATA2;
endmodule 


/*
    ZERO_MODULE
    It checks the OUTPUT of the ALU. If it is 0 set ZERO as 1. Otherwise set ZERO as 0.
*/
module ZERO_MODULE(RESULT , ZERO);                                                          /* */
    input [7:0] RESULT; // set RESULT as a 8 bit input
    output ZERO; // set ZERO as a output
    wire a,b,c,d,e,f; // Declare some wires

    /*
        RESULT contains 8 wires.
        We use set of OR gates and one NOR gate to check whether the RESULT is 0 or not.
    */
    or(a , RESULT[0] , RESULT[1]);
    or(b , a , RESULT[2]);
    or(c , b , RESULT[3]);
    or(d , c , RESULT[4]);
    or(e , d , RESULT[5]);
    or(f , e , RESULT[6]);
    nor(ZERO , f , RESULT[7]);

endmodule 

// // Test bench module for testing purposes
// module Testbench; 
//     /* data1 , data2 , select are registers. 
//        They are used to give inputs for the alu module.
//     */
//     reg [7:0] data1 , data2; 
//     reg [2:0] select; 

//     // result is a 8 bit wire. This is used as the output of the alu module.
//     wire [7:0] result;
//     wire zero; 
    
//     // create instance of the alu module.
//     alu alu_t (data1 , data2 , result , select , zero); 
    
//     /* Initail block
//        This is used to change values of the input ports.
//     */
//     initial 
//     begin
//         // t = 0    data1 = 0   data2 = 0   select = 0 (FORWARD)
//         data1 = 8'b00000000 ; data2 = 8'b00000000 ; select = 3'b000; 


//         #5 
//         // t = 5    data1 = 4   data2 = 6   select = 0 (FORWARD)
//         data1 = 8'b00000100 ; data2 = 8'b00000110 ; select = 3'b000;

//         #5 
//         // t = 10    data1 = 4   data2 = 5   select = 1 (ADD)
//         data1 = 8'b00000100 ; data2 = 8'b00000101 ; select = 3'b001;

//         #5 
//         // t = 15    data1 = 5   data2 = 2   select = 2 (AND)
//         data1 = 8'b00000101 ; data2 = 8'b00000010 ; select = 3'b010;

//         #5 
//         // t = 20    data1 = 6   data2 = 6   select = 3 (OR)
//         data2 = 8'b00000110 ; data1 = 8'b00000110 ; select = 3'b011;
//     end 
    

//     /* Initial block
//        This is used for monitoring purposes.
//     */
//     initial  
//     begin
//         $monitor("%d,\t%b,\t%b,\t%b,\t%b,\t%b",$time, data1,data2,select,result,zero); 
//         // $monitor("%d,\t%d,\t%d,\t%d,\t%d",$time, data1,data2,select,result); 
//         $dumpfile ("simple_processor.vcd"); 
//         $dumpvars; 
//     end 
        
// endmodule