Project Overview:    

Functional Universal Asynchronous Transmit Engine using Verilog.   
    
The purpose of this lab was to create the transmit engine logic and to include the PicoBlaze into our design. For this lab, I was supposed to continually transmit the sequence "CSULB CECS 460<CR><LF>" to the terminal.    
    
The purpose of the PicoBlaze in my design was to output the specified characters after the TxRdy bit was set in the Transmit Engine's status register. This was achieved by reading in the value of the status register by using an Input instruction and then subtracting that value by 2 (which would result in a zero value if the TxRdy bit was set).    
    
I would continually monitor the status register of the Transmit Engine and once the TxRdy bit was set, I would then output the appropriate character on the PicoBlaze's out_port using the Output instruction. I also had to decode the write_strobe and port_id value coming out of the PicoBlaze so that I could make sure that the Transmit Engine was getting the right write input.  
    
Within the Transmit Engine, I also had various R-S flops to control the TxRdy variable and the start variable. I also had a flop to store the data coming out of the PicoBlaze and a register that delayed the write input to the Transmit Engine by one clock cycle.     
    
I also had to implement a shift register, a baud-rate counter, and a bit counter to make sure that I was transmitting data at the appropriate bit time (1/Baud Rate) intervals and in the appropriate format (7N1, 7O1, 7E1, 8N1, 8O1, 8E1). This project was somewhat difficult to verify/implement, but I ended up with a successful program in the end.    
         
PicoBlaze Assembly Code:    
    
             ;UART Transmit
             ;
             ;================================================================
             ; data constants
             ;================================================================
             ;selected ASCII codes
             CONSTANT ASCII_C_U , 43               ; Uppercase C
             CONSTANT ASCII_S_U , 53               ; Uppercase S
             CONSTANT ASCII_U_U , 55               ; Uppercase U
             CONSTANT ASCII_L_U , 4C               ; Uppercase L
             CONSTANT ASCII_B_U , 42               ; Uppercase B
             CONSTANT ASCII_Space , 20             ; Space 
             CONSTANT ASCII_E_U , 45               ; Uppercase E
             CONSTANT ASCII_4 , 34                 ; number 4
             CONSTANT ASCII_6 , 36                 ; number 6
             CONSTANT ASCII_0 , 30                 ; number 0
             CONSTANT ASCII_CR , 0D                ; carriage return <CR>
             CONSTANT ASCII_LF , 0A                ; line feed <LF>

             ;================================================================
             ; port aliases
             ;================================================================
             ;____________________________input port definitions_____________________________________
              
             CONSTANT rd_flag_port, 00         ;status of transmit engine
             NAMEREG sd, tx_data               ;data to be tx by uart

             ;____________________________output port definitions____________________________________

             CONSTANT uart_tx_port, 01    ;outputs to register 1 (Write_Strobe[1])

             ;================================================================
             ; Main Program
             ;================================================================
             main_program: 

                    load tx_data , ASCII_C_U
                    call tx_one_byte                            ; transmit C

                    load tx_data , ASCII_S_U
                    call tx_one_byte                            ; transmit S

                    load tx_data , ASCII_U_U
                    call tx_one_byte                            ; transmit U

                    load tx_data , ASCII_L_U
                    call tx_one_byte                            ; transmit L

                    load tx_data , ASCII_B_U
                    call tx_one_byte                            ; transmit B

                    load tx_data , ASCII_Space 
                    call tx_one_byte                            ; transmit space

                    load tx_data , ASCII_C_U
                    call tx_one_byte                            ; transmit C

                    load tx_data , ASCII_E_U
                    call tx_one_byte                            ; transmit E

                    load tx_data , ASCII_C_U
                    call tx_one_byte                            ; transmit C

                    load tx_data , ASCII_S_U
                    call tx_one_byte                            ; transmit S

                    load tx_data , ASCII_Space 
                    call tx_one_byte                            ; transmit space

                    load tx_data , ASCII_4
                    call tx_one_byte                            ; transmit 4

                    load tx_data , ASCII_6
                    call tx_one_byte                            ; transmit 6

                    load tx_data , ASCII_0
                    call tx_one_byte                            ; transmit 0

                    load tx_data , ASCII_CR
                    call tx_one_byte                            ; transmit CR (Carriage Return)

                    load tx_data , ASCII_LF
                    call tx_one_byte                            ; transmit LF (Line Feed)

             JUMP main_program
   

             ;================================================================
             ; routine : tx_one_byte
             ;       function : Wait until uart TxRdy bit is set, which signifies that the UART is
             ;                         ready to transmit another byte. Then transmit another byte to
             ;                         the UART.
             ;       Input Register :   tx_data
             ;       Temp Register :   s6 - read port flags
             ;
             ;================================================================     
             tx_one_byte :
                    input s6, rd_flag_port                 ;read in status of the Transmit Engine
                    sub s6, 02                             ;check to see if TxRdy bit is set high
                    jump nz, tx_one_byte                   ;if it isn't, keep on waiting until it is set high
                    output tx_data, uart_tx_port           ;If it is set high, then transmit byte to uart
                    return



Project Block-Diagram:    
![ScreenShot](https://cloud.githubusercontent.com/assets/14812721/24985129/06beb7ce-1fa7-11e7-8371-076ce9c53143.jpg)
   
Dependencies:     
This project was created using the Xilinx ISE Project Navigator Version: 14.7.   
    
Project Verification:    
For this lab's verification I created a test bench module for both my top_level and my transmit_engine files.   
    
For the top_level test bench, all I did was initialize my inputs and set my baud-rate / data format to be 9600 / 8O1. I then ran the simulation and used the waveforms to verify that my Transmit Engine was storing/shifting the correct values out and that the PicoBlaze was outputting the character values at the appropriate times.    
     
The Transmit Engine test bench was a lot more involved than my top_level test bench. In the Transmit Engine test bench, I made sure to test out a variety of data values and I also made sure that I was able to successfully run at all of the different baud-rates specified for my project. I also made sure that each data format (7N1, 7O1, 7E1, 8N1, 8O1m 8E1) worked correctly as well.     
      
I verified this by making sure that each 12-bit packet was transmitted in the correct order and by making sure that the appropriate values were being loaded into my shift register I also compared the desired shift register values to the actual shift register values and outputted the result to the console in order to help me debug my shift register and make sure that it was working properly.     
     
For a more detailed version of each test bench and its verification, refer to the header section of each test bench module within the source code. It is there that I go into further detail about how I verified the completeness of my design.

