`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Author:        Victor Espinoza
// Email:         victor.alfonso94@gmail.com
// Project #:     Project 3 - Transmit Engine plus PicoBlaze
// Course:        CECS 460
//
// Create Date:   11:04:58 10/08/2015 
// 
// Module Name:   proj3_TransmitEngine 
// File Name:     proj3_TransmitEngine.v
//  
// Description:   This top_level module basically ties in all of the other  
//                modules that I made and connects them together. It takes the 
//                primary inputs of clk, rstb, bit8, parity_en, odd_n_even, and
//                baud_val[3:0]. This project has one output called tx. This tx
//                output goes to P9, which is a port that connects to the RS-232
//                serial connector that connects to a UART terminal on a 
//                computer via a serial cable. The clk input comes from the 
//                clock on the Nexys 2 board, while the rstb input is a push
//                button. The bit8, parity_en, odd_n_even, and baud_val[3:0] 
//                inputs are all switches on the Nexys 2 board. The rstb input
//                is synchronized and distributed to all of the other modules in
//                this project. This synchronized rstb value (rstbs) is also
//                negated and then used as the reset input to the PicoBlaze
//                processor. Inside of the PicoBlaze, I read in the status of  
//                the transmit engine and wait until it is ready to transit 
//                another byte by subtracting this value by 02 (the location
//                of the TxRdy bit of the status register). Once the TxRdy
//                bit is set, I then know that the Transmit Engine is ready to
//                transmit another byte and I then output this value to the 
//                PicoBlaze. On the second clk cycle of the output instruction,
//                I decode the Write_Strobe value by using the Write_Strobe and
//                the Port_Id port of the picoblaze. I then put these values
//                into my write[255:0] register (because there are 2^8 registers
//                that can be written to the PicoBlaze: 00 - FF). For my design,
//                I output my values to the Port_ID of 01, so I needed to pass
//                my write[1] value into my transmit engine to let it know
//                that it should load in the appropriate data bits (Out_Port)
//                into the shift register. The baud_val[3:0] bits determine the
//                baud rate at which the Program is going to be transmitting 
//                characters. The bit8, parity_en and odd_n_even inputs 
//                determine the format of the data bits being transmitted (7N1,
//                7E1, 7O1, 8N1, 8O1, and 8E1). All of these inputs go into my
//                transmit engine where I update my shift register and baud
//                counter accordingly. Once I establish the desired baud rate
//                and data format, I then open a terminal window under the same
//                baud rate and data format and then I am ready to start 
//                transmitting characters to the UART terminal. In the PicoBlaze,
//                I continually output the values of "CSULB CECS 460<CR><LF>".
//                This results in the sequence of "CSULB CECS 460<CR><LF> being
//                continually transmitted to the UART Terminal.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module proj3_TransmitEngine(clk, rstb, bit8, parity_en, odd_n_even, baud_val, tx);

   //Input and Output Declarations
   input        clk, rstb, bit8, parity_en, odd_n_even;
   input [3:0]  baud_val;
   
   output wire  tx;
   //Local Declarations
   //wire rstsb, TxSet, TxRst, Done, sSet, sRst, ld, btu, shift;
   wire         rstsb, tx_out;
   wire [7:0]   in_port;
   wire         interrupt, read_strobe, write_strobe, interrupt_ack;
   wire [7:0]   out_port;
   wire [7:0]   port_id;
   reg  [255:0] write;

   
   assign tx = tx_out;
   
   //synch_reset module instantiation
   //module synch_reset(clk, rstb, rstsb);
   synch_reset Synchronizer_Circuit(
      .clk(clk), 
      .rstb(rstb),
      .rstsb(rstsb)
   );
   
   
   //instantiate the picoblaze
   embedded_kcpsm3 ekcp3(
      .port_id(port_id),
      .write_strobe(write_strobe),
      .read_strobe(read_strobe),
      .out_port(out_port),
      .in_port(in_port),
      .interrupt(interrupt),
      .interrupt_ack(interrupt_ack),
      .reset(!rstsb),
      .clk(clk)
   );
   
   assign interrupt = 0;
   //write strobe decode   
   always@(*)begin
      write = 0;
      write[port_id] = write_strobe;
   end   

   //transmit_engine module instantiation   
   //module transmit_engine(clk, rstb, bit8, parity_en, odd_n_even, baud_val,
   //txWrite, inData, tx, pico_data);

   transmit_engine transmit(
      .clk(clk), 
      .rstb(rstsb),
      .bit8(bit8),
      .parity_en(parity_en),
      .odd_n_even(odd_n_even),
      .baud_val(baud_val),
      .txWrite(write[1]),
      .inData(out_port),
      .tx(tx_out),
      .pico_data(in_port)
   );   
   

endmodule
