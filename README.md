# UART_Controller
This repository contains a full-duplex UART (Universal Asynchronous Receiver/Transmitter) controller implemented in Verilog. The design is modular, featuring a dedicated baud rate generator, a state-machine-driven transmitter, and a robust receiver that utilizes 16x oversampling for reliable data capture.


# Project Structure
## 1. Top Level (uart_top.v)
The top module acts as the glue logic for the entire system. It interconnects the Baud Rate Generator, the Sender, and the Receiver. It defines the external interface for the FPGA, providing status signals like busy (for transmission) and rdy (to signal new incoming data).

## 2. Baud Rate Generator (baud_rate_genrator.v)
This module handles the timing for the entire system.

It produces two enable pulses: enb_tx (pulsing once per bit period) and enb_rx (pulsing 16 times per bit period).

By using parameters for clk_freq and baud_rate, the timing can be adjusted for any hardware board without rewriting the logic.

## 3. UART Sender (uart_sender.v)
A four-state Finite State Machine (IDLE, START, DATA, STOP) handles the transmission logic.

Idle: The TX line is held high.

Start: Upon wr_en (write enable), it pulls the line low for one bit period.

Data: Shifts out 8 bits of data, LSB first.

Stop: Returns the line to high to signal the end of the frame.

## 4. UART Receiver (uart_reciever.v)
This is the most complex part of the design. It uses a 16x oversampling clock to ensure accuracy even if there is a slight clock mismatch between devices.

Noise Filtering: It waits for the middle of the start bit (sample 7) to verify the signal is still low, preventing false triggers from line noise.

Data Capture: It samples the RX line at the midpoint of every data bit (the 8th sample out of 16) to ensure maximum signal stability.

Ready Signal: Once the stop bit is confirmed, it moves the temporary shift register data to data_out and raises the rdy flag.

<img width="1905" height="649" alt="Screenshot 2026-01-05 221045" src="https://github.com/user-attachments/assets/10a6ac26-a48e-4adf-9837-519cd94b2524" />
