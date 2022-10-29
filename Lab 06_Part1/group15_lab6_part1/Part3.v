`include "Part1.v"
`include "Part2.v"
`include "DataMemory.v"

// CPU module                                                                                   /*  */
module cpu(PC, INSTRUCTION, CLK, RESET, READ_SIGNAL, WRITE_SIGNAL, RESULT, OUT1, READ_DATA, BUSY_WAIT);
    
    output reg [31:0] PC;               //Register to hold the PC address
    input [31:0] INSTRUCTION;           //Fetching instruction to the cpu as a input
    input CLK, RESET;                   //Clok and the Reset to clear the cpu

                                                                                                /*  */
    output reg READ_SIGNAL, WRITE_SIGNAL; // Ouput going from the cpu to data memory
    input BUSY_WAIT;                       //Input come from the data memory
    output [7:0] RESULT , OUT1;             //Going output from the ALU and the register out as output
    input [7:0] READ_DATA;                  //Data value come from the memry


    wire [31:0] PC_Reg;                 // PC adder(To hold the current PC + 4)

    PC_Adder pc_adder (PC_Reg , PC);    //Insatance of a PC_Adder module to increase the Current PC by 4(PC = PC+4)

    wire [31:0] Extended_Val;   // Extended_Val is a 32 bit wire

    /* 
        Create a instance of EXTEND_BITS module
        We send Offset(INSTRUCTION[23:16]) as the input
    */
    EXTEND_BITS extend_bits_m(INSTRUCTION[23:16] , Extended_Val);
    
    wire [31:0] Jump_Target;   // Jump_Target is a 32 bit wire
    /* 
        Create a instance of JUMP_TARGET_ADDER module
    */
    JUMP_TARGET_ADDER jump_target_adder_m (PC_Reg , Extended_Val , Jump_Target);


    // MUX_ Selections(Registers to hold the value come from the two muxes in the cpu)
    reg [7:0] MUX_1_OUT;        //(MUX 1 :- To get the REGOUT2 value or the 2s complement of REGOUT2)
    reg [7:0] MUX_2_OUT ;       //(MUX 2 :- to get the Immediate value from the corresponding instruction or 
                                //get the output of MUX 1)


//===========================================================================================================================
    //always block for update the PC value(PC UPDATE) and if RESET signal given as 1 ,then to reset the cpu(Bring the PC to 0)
    always @(posedge CLK) 
    begin

        if (RESET == 1) begin
           #1 PC =  0;         //Set the PC value to 0 (begin) if RESET Signal is given
        end

                                                                                                            /*   */
        // -------------------------------------------------------------------------------
        else if(~BUSY_WAIT) begin
            if(SELECT3 == 0)begin
                #1 PC =  PC_Reg; 
            end                         //update the PC value According to the signals(SELECT3)
         
            else begin
                #1 PC =  Jump_Target;   //(update the PC to Calculated jump Target according to the relevant signal)
            end
        end
        // -------------------------------------------------------------------------------

    end


//============================================================================================================================  
    
    
    // Decode(To Decode and Identify the INSTRUCTION into parts [OPCODE],[RD/IMM],[RT],[RS/IMM])

    //Control signals of MUX 1 nad MUX 2
    wire SELECT1;            //Control signal Of MUX 1
    
    
    reg [2:0] SELECT;       //The signal of ALUOP (to get the corresponding operation's reslut)
    wire [7:0] RESULT;      //The Output of The ALU
    wire ZERO;                                                                                    

    /*

        | OP-CODE      |  RD / IMM      | RT            |  RS / IMM  |
        | (bits 31-24) |  (bits 23-16)  | (bits 15-8)   |  (bits7-0) |
        
    */
    

    //To check the OPCODE of the instruction word and update the SELECT,SELECT1 and SELECT2
    always @(INSTRUCTION) 
    begin
        case (INSTRUCTION[31:24]) //OPCODE part of the given Instruction
            8'b00000000:    // Loadi
                begin
                    SELECT <= #1 0;     //change the SELECT (ALUOP) to 000(FORWARD)
                end
                
            8'b00000001: // Mov
                begin
                    SELECT <= #1 0;     //Change the SELECT (ALOUP) to 000(FORWARD) 
                end
            
            8'b00000010: // Add
                begin
                    SELECT <= #1 1;     //change the SELECT (ALUOP) to 001(ADD)
                end
            
            8'b00000011: // Sub
                begin
                    SELECT <= #1 1;     //change the SELECT (ALUOP) to 001(ADD)
                end

            8'b00000100: // And
                begin
                    SELECT <= #1 2;     //change the SELECT (ALUOP) to 010(AND)
                end
            
            8'b00000101: // Or
                begin
                    SELECT <= #1 3;     //change the SELECT (ALUOP) to 011(OR)
                end
        
            8'b00000111: // Beq
                begin
                    SELECT <= #1 1;     //change the SELECT (ALUOP) to 011(OR)
                end


            // Adding some new instructions                                         /* */
            8'b00001000: // lwd
                begin
                    SELECT <= #1 0;    //change the SELECT (ALUOP) to 000(FORWARD)
                end
            
            8'b00001001: // lwi
                begin
                    SELECT <= #1 0;     //change the SELECT (ALUOP) to 000(FORWARD)
                end
            
            8'b00001010: // swd
                begin
                    SELECT <= #1 0;     //change the SELECT (ALUOP) to 000(FORWARD)
                end
            
            8'b00001011: // swi
                begin
                    SELECT <= #1 0;     //change the SELECT (ALUOP) to 000(FORWARD)
                end

        endcase


        /*
        SELECT     =>   Supported Instructions
        --------------------------------------
        FORWARD    =>   loadi,mov
        ADD        =>   add,sub
        AND        =>   and
        OR         =>   or
        --------------------------------------
        */
        
    
    end

    //(Update the SELECT1 and SELECT2)

    // Complement or not
    assign #1 SELECT1 = INSTRUCTION[31:24] == 3 || INSTRUCTION[31:24] == 7 ? 1'b1  : 1'b0; //Update the Select 1 to 1 if 
                                                                                           //INSTRUCTION is beq or sub


    


    wire isJump , isBeq , temp1 , SELECT3;
    
    assign isJump = (INSTRUCTION[31:24] == 6);                      //Update isJump signal to 1 if the INSTRUCTION is jump
    assign isBeq = (INSTRUCTION[31:24] == 7);                       //Update isJump signal to 1 if the INSTRUCTION is beq

    //Get the value generate from the control unit (isJump ,isBeq)

    and(temp1 , isBeq , ZERO);                  // Then the OUTPUT signal(ZERO) and isBeq values going through and gate
    or(SELECT3 , temp1 , isJump);              // Then that output and isJump are going through a or gate and generate SELECT3





    always @(posedge CLK) 
    begin

        #1 WRITE = 0;
        #4 WRITE = ~(isBeq || isJump || INSTRUCTION[31:24] == 10 || INSTRUCTION[31:24] == 11);
    end


    // REGISTER READ

    // Register file instance
    wire [7:0] IN;               // IN is a 8 bit register
    reg WRITE;                  // WRITE is a register
    wire [7:0] OUT1 , OUT2;     // OUT1 , OUT2 are 8 bit wires
    
    // create instance of the reg_file module
    reg_file reg_f (IN,OUT1,OUT2,INSTRUCTION[18:16],INSTRUCTION[10:8],INSTRUCTION[2:0], WRITE, CLK, RESET, BUSY_WAIT);
    /* 
    
    *This take the relevant part of the Instruction as READREG1,READREG2 and  WRITEREG(Also with the WRITE,CLK,and RESET)
    *Then read the values from the corresponding registers and put them into OUT1 and OUT2
    *Also at the write time the RESULT (IN) of the ALU write to the Correspondung register

    */
    
    // 2'S COMPLEMENT INSTANCE
    wire [7:0] COMP_OUTPUT;
    TWO_COMP two_comp (OUT2 , COMP_OUTPUT); 

    
    // MUX_1 Selection
    always @(OUT2 , COMP_OUTPUT,SELECT1) begin
        if(SELECT1 == 0)begin
            MUX_1_OUT = OUT2;               //If the SELECT1 = 0 then set MUX_1_OUT as REGOUT2
        end
        else begin
            MUX_1_OUT = COMP_OUTPUT;        //Otherwise Set the MUX_1_OUT as 2's compliment of REGOUT2
        end
    end

    // MUX_2 Selection(To get the output of the MUX2)
    always @(MUX_1_OUT , INSTRUCTION[7:0] , SELECT2) begin
        if(SELECT2 == 0)begin
            MUX_2_OUT = INSTRUCTION[7:0];   //If SELECT2 == 0 then the corresponding value send through the mux 2(IMM value)
        end
        else begin
            MUX_2_OUT = MUX_1_OUT;          //Otherwise send the output of the MUX1
        end
    end



    //Create instance of the alu
    alu alu_(OUT1, MUX_2_OUT, RESULT, SELECT , ZERO);
    /*
        *ALU get OUT1(REGOUT1 from the register file) as [OPERAND 1] and MUX_2OUT(Output of the MUX2) as the o[OPERAND 2]
        *SELECT signal is updated to the correponding value by control unit.Therefor ALU Produce the RESULT and give it 
        to the IN(IN of the register file)

    */ 



                                                                                                             /* */
    //Clear the value of READ_SIGNAL AND WRITE_SIGNAL when BUSY_WAIT change from 1 to 0
    always @(negedge BUSY_WAIT) begin
            READ_SIGNAL = 0;            //clear the read signal
            WRITE_SIGNAL = 0;           //Clear the write signal
    end

    //Decode the value of READ_SIGNAL AND WRITE_SIGNAL when the instruction change
    always @(INSTRUCTION) begin
            if(INSTRUCTION[31:24] == 8 || INSTRUCTION[31:24] == 9)begin //lwd/lwi change the READ_SIGNAL
                READ_SIGNAL = 1;
            end
            else begin
                READ_SIGNAL = 0;
            end

            if(INSTRUCTION[31:24] == 10 || INSTRUCTION[31:24] == 11)begin//swd/swi change the WRITE_SIGNAL
                WRITE_SIGNAL = 1;
            end
            else begin
                WRITE_SIGNAL = 0;
            end
    end

    

    wire SELECT2;          
    wire SELECT4;

    // To get immediate value or register value
    // If the INSTRUCTION is Forward or lwi , swi set SELECT@ as 0
    assign #1 SELECT2 = INSTRUCTION[31:24] == 0 || INSTRUCTION[31:24] == 9 || INSTRUCTION[31:24] == 11 ? 1'b0 : 1'b1;      //Set the SELECT2 target

    // To get ALU RESULT or value reading from the memory
    // If the INSTRUCTION is lwi or lwd set SELECT4 as 1
    assign #1 SELECT4 = INSTRUCTION[31:24] == 8 || INSTRUCTION[31:24] == 9 ? 1'b1 : 1'b0; 

    //According to the SELECT4 value set IN (Write data to Register file)
    assign IN = SELECT4 ? READ_DATA : RESULT; 


    



endmodule 

//Adder for update the value of current pc  value

module PC_Adder(PC_Reg , PC);
    output reg [31:0] PC_Reg;       //To old the value of PC = PC +4
    input [31:0] PC;                //Take the current PC value as the INPUT
    always @(PC) 
    begin
        PC_Reg = #1 PC + 4;         //UPDATE the pc to PC +4 
    end
endmodule


//Module to get the 2's compliment of a given 8 bit value
module TWO_COMP (COMP_INPUT , COMP_OUTPUT);
    input [7:0] COMP_INPUT;         //Input(8 bit number)
    output [7:0] COMP_OUTPUT;       //Output(2's compliment of the given  number)

    assign #1 COMP_OUTPUT = ~ COMP_INPUT + 8'b00000001; //Turn the given value to its 2's compliment
endmodule



//This is the JUMP/BEQ Adder
//Get the PC_Reg(PC+4) and the EXtended 32 bits from the instruction
module JUMP_TARGET_ADDER (PC_Reg , Extended_Val , Jump_Target); 
    input [31:0] PC_Reg;        
    input [31:0] Extended_Val;        
    output [31:0] Jump_Target;       

    //Do the relevant calculation 
    assign #2 Jump_Target = PC_Reg + Extended_Val;
endmodule


//MODULE for EXTEND the 8 bit
module EXTEND_BITS (Offset , Extended_Val);         //This takes the offset part from the INSTRUCRION
    input [7:0] Offset;        
    output reg [31:0] Extended_Val;        
      
    always @(Offset) begin
       Extended_Val[1:0] = 2'b00;                   //Set the last two bits to zeros(shifting by wiring)
       Extended_Val[9:2] = Offset[7:0];             //Get the offset value to 32 bit word
       
       //This part is for sign extension
       if(Offset[7] == 0)begin
           Extended_Val[31:10] = 22'b0000000000000000000000; //If a positive
       end
           
       else begin
           Extended_Val[31:10] = 22'b1111111111111111111111;//if Negative
       end
           
    end
endmodule
// ------------------------------------------------------------------------------------------------





module cpu_tb;
    
    reg CLK, RESET;
    wire [31:0] PC , INSTRUCTION;

    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg [7:0] instr_mem [1023:0];

    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)

    assign #2 INSTRUCTION = {instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1],instr_mem[PC+0]};
    
    initial
    begin
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
                                                                            /*  */
    /*                                                                         
    -----
     CPU
    -----
    */
    
    wire READ_SIGNAL , WRITE_SIGNAL , BUSY_WAIT;
    wire [7:0] OUT1 , READ_DATA , RESULT;
    
    cpu mycpu(PC, INSTRUCTION, CLK, RESET, READ_SIGNAL, WRITE_SIGNAL, RESULT, OUT1, READ_DATA, BUSY_WAIT);


                                                                            /*  */
    /*                                                                      
    ---------------
     DATA MEMORY
    ---------------
    */
    data_memory d_memory(CLK,RESET,READ_SIGNAL, WRITE_SIGNAL, RESULT, OUT1, READ_DATA, BUSY_WAIT);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, mycpu);
        
        // finish simulation after some time
        #500
        $finish;
        
    end

    initial
    begin
        CLK = 1'b0;
        RESET = 1'b1;
        #10
        RESET = 1'b0;
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
    
endmodule