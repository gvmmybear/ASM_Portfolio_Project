# ASM_Portfolio_Project
A Low Level I/O Program Written in Assembly Language

Author: Christian Castro
Date: 01/09/2022

Program: Low Level I/O Using String Primitives and Macros
Language: Assembly Language for x86 Processors using MASM

Overview:
This project was our final portfolio project for Oregon State Univeristy CS course 271 (Computer Architecture and Assembly Language). The functionality of this program is quite simple, it takes 10 integers from user input and calculates the sum and truncated average of these numbers. After these calculations are complete, the program then prints out the entered numbers as well as the results for the sum and average. 

However, the requirements for this particular project restricted use of certain Irvine32 library procedures such as ReadInt/WriteInt, ReadDec, etc. Thus, the user's input is processed as string and converted to signed integer values so these simple calculations can be computed. Once these calculations are done, the process of converting from integer to string is also executed by use of Macros and string primitives and then displayed for the program user.  
