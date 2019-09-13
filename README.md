# CORDIC-Design-Project
Design of a CORDIC FSM based calculator for 4th year VLSI course

<p align="center">
  <img width="458" height="229" src="https://raw.githubusercontent.com/KyleCathers/CORDIC-Design-Project/master/FPGA.png">
</p>

# Project Description
The objective of the project is to implement an iterative CORDIC processor in hardware using VHDL code programmed onto the Basys 3's on-board FPGA. Upon completion the Basys 3 will be able to perform rotation and vectoring calculations through simple shifting and addition operations. The Xilinx Vivado environment was used throughout the project for its simplicity and ability to simulate VHDL code.

The finished design must be able to convert from predetermined fixed point 16-bit input data, perform iterative calculations based on said input, and display the result to a 7-segment HEX display on the Basys 3 board. The input data is formatted to represent specific data ranges (0 ≤ x ≤ 1, 0 ≤ y ≤ 1, 0 ≤ z ≤ 2 radians).

The project will use start and reset inputs (debounced pushbuttons) for state control, and a number of switches for input and display data selection. The project includes a number of sub components within the CORDIC processor component: an ALU, a storage module, and a lookup table. The controller for the CORDIC is built into the processor component, running a finite state machine to control processor operation (e.g. iteration control and signal assignment to sub components).
