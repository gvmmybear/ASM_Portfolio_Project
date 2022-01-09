TITLE Low Level I/O Using String Primitives & MACROS     (Project_6.asm)

; Author: Christian Castro
; Last Modified: 01/09/2022
; Email address: chj.castro@gmail.com
; Course number:  Oregon State University - CS271 Computer Architecture and Assembly Language
; Project Number: 6                
; Description: This program takes user input for 10 signed integers. Once the 
;		user enters these numbers as a string, these string values are converted
;		to numeric form and stored in an array in memory. Using these newly
;		converted numbers, the average and sum are calculated and also stored
;		in memory in numeric form. Upon completion of these calculations, these
;		numbers are then converted back into a string and then printed onto the
;		terminal screen. The only limiting condition is that the sum and average
;		as well as the numbers entered by the user must each be able to fit inside 
;		a 32-bit register (as an integer).

INCLUDE Irvine32.inc
; ==================
; MACRO DEFINITIONS
; ==================
; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Description: Reads user input as a string and then stores in memory.
;
; Preconditions: None
;
; Receives:
; prompt = prompt message, i.e. prints "Enter a signed integer: "
; output = array OFFSET
; count = BUFFER constant, used to limit the allowed number of char entered.
; bytesRead = number of bytes read by MACRO, i.e. number of digits entered by user.
;
; returns: output = stores input at array OFFSET 
; ---------------------------------------------------------------------------------
mGetString  MACRO prompt, output, count, bytesRead
; ...
; Saves used registers
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI

; Prints prompt message, then using ReadString, stores user input 
; to array in memory.
	MOV	EDX, prompt
	CALL	WriteString
	MOV	ECX, count
	MOV	EDX, output
	CALL	ReadString
	MOV	EDI, bytesRead
	MOV	[EDI], EAX

; Restores register values
	POP	EDI
	POP	EDX
	POP	ECX
ENDM	

; MACRO DEFINITIONS CONT.
; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description: Prints from string from memory
;
; Preconditions: None
;
; Receives:
; msg = display message, i.e. "The average is: " 
; string = array OFFSET of string to be printed
;
; returns: None
; ---------------------------------------------------------------------------------
mDisplayString MACRO msg, string
; ...
	LOCAL	_printNums, _end
; Saves register values	
	PUSHAD
	PUSH	ESI

; Prints display message before printing string.
	CALL	CrLf
	MOV	EDX, msg
	CALL	WriteString
	MOV	ESI, string
	CLD

; Iterates through array and prints each char using WriteChar.
_printNums:
	LODSB
	CMP	AL, NULL
	JE	_end
	CALL	WriteChar
	JMP	_printNums
_end:
	CALL	CrLf

; Restores registers
	POP	ESI
	POPAD
ENDM

; =====================
; CONSTANT DEFINITIONS
; =====================
; MAX_NUM is used as a buffer value, as well as the maximum number of numbers entered.
MAX_NUM	= 10

; Below, each of these constants are the ascii codes for what their name describes.
plusSign = 2Bh
minusSign = 2Dh
COMMA = 2Ch
SPACE = 20h
NULL = 00h
; ...

.data
; ====================
; VARIABLE DEFINITIONS
; ====================
intro1		BYTE	"Project 6: String Primitives and Macros",0Ah,
			"Author: Christian Castro",0Ah,0
intro2		BYTE	"Please enter 10 signed integers. Their total sum must be within the range of",0Ah,
			"-2,147,483,648 and 2,147,483,647. Once all 10 integers have been entered,",0Ah, 
			"they will be displayed as a list, along with their sum and truncated average.",0Ah,0
prompt1		BYTE	"Please enter a signed integer: ",0
error		BYTE	"Error! You did not enter a signed integer or your value was either too large or too small.",0
listMsg		BYTE	"Here are the numbers you entered:",0Ah,0
sumMsg		BYTE	"The total sum of these numbers is: ",0
aveMsg		BYTE	"The truncated average: ",0
byeMsg		BYTE	"Goodbye! =)",0
numsIn		BYTE	20 DUP(?)
numsOut		SDWORD	MAX_NUM DUP(?) 
strNums		DWORD	30 DUP(?)
sum			SDWORD	0,0,0,0,0
average		SDWORD	0,0,0,0,0
numOfBytes	DWORD	0
sign		BYTE	0

.code
main PROC
; Display program title and author as well as a general overview of the program.
	PUSH	OFFSET intro1
	PUSH	OFFSET intro2
	CALL	introduction

; ---------------------------------------
; Loops ReadVal PROC for MAX_NUM of times
;	to read user input for number values.
;   Also converts string input to numeric
;	values, then stores in memory.
; ---------------------------------------
	PUSH	ECX
	MOV	ECX, MAX_NUM
_dataEntry:
	PUSH	OFFSET numsOut		; ebp+28
	PUSH	OFFSET error		; ebp+24
	PUSH	OFFSET prompt1		; ebp+20
	PUSH	OFFSET numsIn		; ebp+16
	PUSH	MAX_NUM			; ebp+12
	PUSH	OFFSET numOfBytes	; ebp+8
	CALL	ReadVal
	LOOP	_dataEntry
	POP	ECX
	; ...

; --------------------------------------------------------
; Calculates sum and average of stored numeric values, and
;	also converts back the numeric values to string type
;	and finally displays the values.
; --------------------------------------------------------
	PUSH	OFFSET strNums		; ebp+44
	PUSH	OFFSET listMsg		; ebp+40
	PUSH	OFFSET sumMsg		; ebp+36
	PUSH	OFFSET aveMsg		; ebp+32
	PUSH	OFFSET sign		; ebp+28
	PUSH	OFFSET strNums		; ebp+24
	PUSH	OFFSET numsIn		; ebp+20
	PUSH	OFFSET sum		; ebp+16
	PUSH	OFFSET average		; ebp+12
	PUSH	OFFSET numsOut		; ebp+8
	CALL	WriteVal
	; ...

; Displays final farewell before invoking exit.
	PUSH	OFFSET byeMsg
	CALL	goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ===========
; PROCEDURES
; ===========
; ---------------------------------------------------------------------------------
; Name: introduction
;
; Description: Display program title and author as well as a general overview 
;	of the program.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
; [ebp+12] = OFFSET of display message intro1 (program title and author)
; [ebp+8] = OFFSET of intro2 (brief program description)
;
; returns: None
; ---------------------------------------------------------------------------------
introduction PROC
; ...

; Saves edx reg/sets base pointer
	PUSH	EBP
	MOV	EBP, ESP
	PUSH	EDX

; Displays intro1, then intro2 (program title/author/description)
	MOV	EDX, [EBP + 12]
	CALL	WriteString
	CALL	CrLf
	MOV	EDX, [EBP + 8]
	CALL	WriteString
	CALL	CrLf

; Restores reg
	POP	EDX
	POP	EBP
	RET	8
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: Takes user input in the form of a string, using the macro
;		mGetString. Once the macro has stored the entered string in memory
;		these string values are then converted to numeric form and again
;		stored in memory in an array.
;
; Preconditions: None
;
; Postconditions: changes registers eax, ebx, esi, edi
;
; Receives:
; [ebp+28] = OFFSET of numsOut
; [ebp+24] = OFFSET of error message
; [ebp+20] = OFFSET of prompt1 message
; [ebp+16] = OFFSET of numsIn (where user input is temporarily stored)
; [ebp+12] = MAX_NUM (max number of allowed numbers to be entered)
; [ebp+8] = OFFSET numOfBytes (number of bytes read by mGetString)
;
; returns: [ebp+28] numsOut array, where user input has been converted to
; ---------------------------------------------------------------------------------
ReadVal PROC
; ...
; Saves ecx/edx reg (ecx used for count in main)/sets base pointer
	PUSH	EBP
	MOV	EBP, ESP
	PUSH	ECX
	PUSH	EDX

; Invokes mGetString macro, where user input is taken
;	and temporarily stored in numsIn for processing.
	mGetString [EBP+20], [EBP+16], [EBP+12], [EBP+8]

; Validates that the user has not entered 9 or more digits.
;	(EAX should hold the number of char entered from mGetString)
	CMP	EAX, MAX_NUM - 1
	JGE	_error

; ----------------------
; ESI points to beginning of OFFSET of numsIn on each iteration
;	(because numsIn is only a temporary placehold), but EDI value 
;	remains after first iteration because that points to the 
;	destination array numsOut where each number is stored as
;	an SDWORD.
; ----------------------
	CMP	ECX, MAX_NUM
	MOV	ESI, [EBP+16]
	JL	_skipPoint
	MOV	EDI, [EBP+28]
_skipPoint:
	; ...

; ----------------------
; Now we check the first char entered to see whether it was
;	entered as + or - value and then jumps accordingly. 
;	Since EAX should still be holding the number of char entered 
;	as well, then we move the number of digits entered to ecx 
;	for a processing loop found in the subprocedures below.
; ----------------------
	MOV	ECX, EAX
	XOR	EBX, EBX
	CLD
	LODSB
	CMP	AL, minusSign
	JE	_negativeConvert
	CMP	AL, plusSign
	JE	_positiveConvert
	; ...

; ----------------------
; An additional check (if first char is not + or -) to ensure that
;	the entered char are between the ascii codes for 0-9.
;	There are also redundant checks for digit characters in the 
;	subprocedures _positiveIntConvert and _negativeConvert. This
;	is because if the user enters a number say "+293" then we
;	would have jumped this check for the subsequant char "2" but
;	it still must be validated. 
; ----------------------
	CMP	AL, 30h		; 30h ascii hex code for char "0"
	JL	_error
	CMP	AL, 39h		; 39h ascii hex code for char "9"
	JG	_error
	JMP	_skipDecrement
	; ...

; ----------------------
; At this point, we've either passed prior checks or jumped because
;	first char is "+". Thus we continue with conversion of the string
;	to a positive signed integer. 
; ----------------------
_positiveConvert:
	DEC	ECX		; If we've jumped to this point, we don't count "+" as a digit.
	LODSB			; Loads the second digit in string seq for analysis.
_skipDecrement:
	CALL	positiveIntConvert
	JMP	_skipNeg
	; ...

; If the first char entered is "-", then we jump to this point to
;	finish converting the string to a negative signed integer. 
_negativeConvert:
	DEC	ECX
	LODSB
	CALL	negativeIntConvert
_skipNeg:

; ----------------------
; If the user has entered an invalid char in between the string
;	for example "49tjd39", then the prior called subprocedures
;	_positiveIntConvert and _negativeConvert should be able to
;	catch the invalid char with their own checks. However
;	because those subprocedures use their own loops, then any
;	premature termination of the loop would mean we have 
;	encountered an invalid char, so we jump to print the error. 
; ----------------------
	CMP	ECX, 0		; checks for premature loop termination
	JNE	_error
	; ...
	POP	EDX
	POP	ECX
_finish:
	POP	EBP
	RET	20
	
; Dispalys error message if user has entered an invalid char or
;	a number that is either too large or too small.
_error:
	CALL	CrLf
	MOV	EDX, [EBP+24]
	CALL	WriteString
	CALL	CrLf
	POP	EDX
	POP	ECX
	INC	ECX		; increments ecx so the loop in main does not count input as valid.
	JMP	_finish
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: positiveIntConvert
;
; Description: This subprocedure finishes the conversion process from the string the
;		user entered, to a positive signed integer value. 
;
; Preconditions: ECX reg needs to hold the number of digits in the entered string value. 
;		This is set in ReadVal where EAX holds this value from mGetString and is moved
;		to the ECX reg prior to subproc call. ESI and EDI should also be pointing to
;		the appropriate source and destination arrays (which are set in ReadVal prior
;		to procedure call).
;
; Postconditions: EAX, EBX, ECX, ESI, EDI are all modified.
;
; Receives: None
;
;
; returns: [ebp+28] (in parent procedure) = numsOut array. numsOut is where each 
;		number entered is stored as an SDWORD
; ---------------------------------------------------------------------------------
positiveIntConvert PROC
; ...
; ----------------------
; Since we have already loaded the appropriate character to analyze
;	we jump into the middle of the loop below, after the point where
;	we would inc ESI by LODSB to get the next char in the sequence.
; ----------------------
	JMP	_continueLoop
	; ...
_finishLoop:
	LODSB

; Validation check for ascii hex codes 30h-39h which are char "0" through "9"
_continueLoop:
	CMP	AL, 30h
	JL	_sendError
	CMP	AL, 39h
	JG	_sendError

; converts to positive Int by numInt = 10*numInt + (numChar-48)
	SUB	AL, 30h
	PUSH	ECX
	MOV	ECX, 10
	IMUL	EBX, ECX
	ADD	EBX, EAX
	POP	ECX
	LOOP	_finishLoop

; Stores the converted signed Int as an SDWORD
	MOV	EAX, EBX
	STOSD
_sendError:
	RET
positiveIntConvert ENDP

; ---------------------------------------------------------------------------------
; Name: negativeIntConvert
;
; Description: This subprocedure finishes the conversion process from the string the
;		user entered, to a negative signed integer value. 
;
; Preconditions: ECX reg needs to hold the number of digits in the entered string value. 
;		This is set in ReadVal where EAX holds this value from mGetString and is moved
;		to the ECX reg prior to subproc call. ESI and EDI should also be pointing to
;		the appropriate source and destination arrays (which are set in ReadVal prior
;		to procedure call).
;
; Postconditions: EAX, EBX, ECX, ESI, EDI are all modified.
;
; Receives: None
;
;
; returns: [ebp+28] (in parent procedure) = numsOut array. numsOut is where each 
;		number entered is stored as an SDWORD
; ---------------------------------------------------------------------------------
negativeIntConvert PROC
; ...
; ----------------------
; Since we have already loaded the appropriate character to analyze
;	we jump into the middle of the loop below, after the point where
;	we would inc ESI by LODSB to get the next char in the sequence.
; ----------------------
	JMP	_continueLoop
	; ...
_finishLoop:
	LODSB

; Validation check for ascii hex codes 30h-39h which are char "0" through "9"
_continueLoop:
	CMP	AL, 30h
	JL	_sendError
	CMP	AL, 39h
	JG	_sendError
	
; converts to negative Int by numInt = 10*numInt + (numChar-48)
	SUB	AL, 30h
	PUSH	ECX
	MOV	ECX, 10
	IMUL	EBX, ECX

; ----------------------
; Right here is the only difference between the two conversion subprocs.
;	instead of adding EBX, EAX, it's subtracted. I'm sure these can both
;	be combined into just one proc, but due to time constraints, they were
;	broken up into their own separate procs, as this seems to be working. 
; ----------------------
	SUB	EBX, EAX	
	; ...
	POP	ECX
	LOOP	_finishLoop

; Stores the converted signed Int as an SDWORD
	MOV	EAX, EBX
	STOSD
_sendError:
	RET
negativeIntConvert ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: WriteVal calculates, the sum/average for the entered numbers and
;		then stores them as SDWORDs. It then converts the list of SDWORD numbers
;		that were converted from string input, back to an array of strings, which
;		are then printed. A similar process is done for the SDWORD values for the
;		sum and average, which are also converted to string characters and then
;		finally displayed for the program user.
;
; Preconditions: None
;
; Postconditions: changes eax, ebx, ecx, edx, esi, edi registers
;
; Receives:
; [ebp+8] = numsOut offset, where the entered values are stored as SDWORDs
; [ebp+12] = average offset, where the value for the average is stored.
; [ebp+16] = offset for where the sum is stored.
; [ebp+20] = numsIn, this is used for processing, both from string to int as well
;			as back from int to string.
; [ebp+24] = offset for strNums, where the final string array to be printed is stored.
; [ebp+28] = offset of sign variable. This used for determining whether or not to 
;			append a "-" char to an output for a particular number being evaluated.
; [ebp+32] = offset of aveMsg, a message that states what the average is.
; [ebp+36] = offset of sumMsg, a message that state the sum.
; [ebp+40] = listMsg offset, message that displays which numbers have been entered.
; [ebp+44] = a duplicate offset for strNums is also pushed. This was to get around
;			some indexing issues I was running into because of how I was modifying
;			the offset pushed and stored at [ebp+24].
;
; returns: 
; [ebp+12] = average
; [ebp+16] = sum
; [ebp+24] = strNums (final array of str characters for the list of numbers entered)
; ---------------------------------------------------------------------------------
WriteVal PROC
; ...
; Sets/saves base pointer
	PUSH	EBP
	MOV	EBP, ESP
	
; Sum and average are calculated using the subproc averageAndSum
	MOV	EBX, [EBP+16]	; sum
	MOV	ECX, MAX_NUM
	MOV	EDX, [EBP+12]	; average
	MOV	ESI, [EBP+8]	; numsOut array
	CALL	averageAndSum

; ----------------------
; Now the esi/edi pointers are set, ecx is loaded with 10.
;	Then the conversion process starts for the array of
;	SDWORD values that are stored in numsOut by the loop
;	below
; ----------------------
	MOV	ESI, [EBP+8]
	MOV	EDI, [EBP+20]	; numsIn
	MOV	ECX, MAX_NUM
_convertToStr:
	; ...
	MOV	EDI, [EBP+20]
	PUSH	ECX
	XOR	ECX, ECX
	MOV	EBX, 1

; Here we check to see whether the stored SDWORD is a negative
;	or positive integer by used of the sign flag. 
	CLD
	LODSD
	IMUL	EAX, EBX
	JNS	_convertFromPositive
	MOV	EBX, EAX

; ----------------------
; If the value being analyzed is a negative int, then using
;	the "sign" variable, we can store the fact that it 
;	should be printed as a negative value when converted to
;	a string. Because of the way the SDWORD is analyzed, it
;	was appending the "-" at the end of my numbers, so this
;	helps to act as a placeholder incase we encounter neg ints
;	so it can be printed correctly.
; ----------------------
	PUSH	EAX
	PUSH	EDI
	MOV	EAX, 1
	MOV	EDI, [EBP+28]		; sets sign variable 
	MOV	[EDI], EAX
	POP	EDI
	POP	EAX
	; ...

; ----------------------
; If we have a negative integer, then we first convert it to
;	its 2's complement by subtracting itself from itself twice.
;	This gets us the opposite positive value so we can finish
;	converting it into string characters. 
; ----------------------
	MOV	EAX, EBX
	SUB	EAX, EBX
	SUB	EAX, EBX
	; ...

; ----------------------
; At this point, even if we originally had a negative integer, it should
;	have been converted to it's two's complement, so we run this new value
;	through the loop below in order to determine the ascii hex code characters
;	that will be needed for each power of 10 in the numeric value.
;
;   This is done by sequential division. Say we have the number value 360, we
;	first div 360/10 = quotient of 36, remainder of 0. Using the remainder, we
;	store as the first digit char. Then 36/10 =  Q: 3, R: 6, 6 becomes the 
;	second digit to store (which would technically be 6 x 10^1). Finally 3/10 = 
;	Q: 0, R: 3, so 3 is the third digit stored. The quotient value is also used
;	as a way to know when to terminate the loop below, as different number values
;	will have different numbers of digits.
; ----------------------
	INC	ECX
_convertFromPositive:
	MOV	EBX, 10
	XOR	EDX, EDX
	DIV	EBX
	PUSH	EAX		; saves quotient 
	MOV	EAX, EDX
	ADD	EAX, 30h
	STOSB
	POP	EAX		
	INC	ECX		; we need to store a count for number of digits 
	CMP	EAX, 0	 ; checks quotient for end point.
	JNE	_convertFromPositive
	; ...

; Below, this block of code then checks the "sign" variable to
;	determine if the last character to be appended is a "-" sign.
	PUSH	EAX
	PUSH	EDI
	MOV	EDI, [EBP+28]
	MOV	EAX, 0
	CMP	[EDI], EAX
	MOV	[EDI], EAX
	POP	EDI
	JE	_skipNegSign
	MOV	EAX, minusSign
	STOSB
_skipNegSign:
	POP	EAX

; ----------------------
; Now using numsIn (where the newly converted int to string should currently
;	be at), we simply change direction of iteration and also assign ESI to
;	the current value of EDI (which should be pointing towards the end of the
;	numsIn array). EDI pointer is set to the final array where we will print
;	the list of numbers. 
;	
;	Because of the way the newly converted string is stored, i.e. int value 
;	of -360 is stored as the hex codes in the order of 063-, then by setting 
;	the direction flag, we can use the appendToOutput loop to reverse to 
;	characters to the correct order, as well as place all of the entered 
;	numbers in the correctly entered order.
; ----------------------
	PUSH	ESI
	MOV	ESI, EDI
	MOV	EDI, [EBP+24]		; strNums array
	MOV	EAX, 2
	ADD	EAX, ECX
	ADD	[EBP+24], EAX

; Sets direction flag so we can append in the correct order in strNums array.
	STD
	LODSB
_appendToOutput:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_appendToOutput
	; ...
	POP	ESI
	POP	ECX
	CMP	ECX, 1
	JE	_end	; skips the placement of a comma/space if it's the last num.

; ----------------------
; After reversing the order of characters in a number and storing them to
;	the output array strNums, a comma and space are manually appended to 
;	the end, so when the final print is executed, we have a printed "list"
;	of the numbers entered.
; ----------------------
	MOV	EAX, COMMA
	STOSB
	MOV	EAX, SPACE
	STOSB
_end:
	; ...

; Loops back to the outter loop to get the next number stored as an SDWORD.
	DEC	ECX
	CMP	ECX, 0
	JG	_convertToStr
	
; converts the sum from signed int to string.
	MOV	EBX, [EBP+28]
	PUSH	EBX				; sign		ebp+16
	MOV	EBX, [EBP+20]
	PUSH	EBX				; numsIn	ebp+12
	MOV	EBX, [EBP+16]
	PUSH	EBX				; sum		ebp+8
	CALL	ConvertAverageSum	

; converts the average from signed int to string.
	MOV	EBX, [EBP+28]
	PUSH	EBX				; sign		ebp+16
	MOV	EBX, [EBP+20]
	PUSH	EBX				; numsIn	ebp+12
	MOV	EBX, [EBP+12]
	PUSH	EBX				; average	ebp+8
	CALL	ConvertAverageSum
	; ...

; Finally we print to the terminal the arrays which hold the 
;	converted string values using the mDisplayString macro. 
	mDisplayString [EBP+40], [EBP+44]		; prints the user entered list of nums
	mDisplayString [EBP+36], [EBP+16]		; prints the sum
	mDisplayString [EBP+32], [EBP+12]		; prints the truncated average
	POP	EBP
	RET	36
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: averageAndSum
;
; Description: This subprocedure calculates the average and sum of the converted
;		integer values stored in the numsOut array/
;
; Preconditions: The following registers must hold these values in order to
;		execute correctly:
;		EBX, [EBP+16]	; sum
;		ECX, MAX_NUM
;		EDX, [EBP+12]	; average
;		ESI, [EBP+8]	; numsOut array
;
; Postconditions: None
;
; Receives:
; [EBP+16] = sum via ebx reg
; MAX_NUM = 10 via the ecx reg
; [EBP+12] = average via the edx reg
; [EBP+8] = numsOut array offset via the esi register
; 
; returns: 
;	[ebp+16] = sum
;	[ebp+12] = average
; ---------------------------------------------------------------------------------
averageAndSum PROC
; ...
; Saves registers and sets base pointer
	PUSH	EBP
	MOV	EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	PUSH	EDI
	PUSH	ECX

; A loop which iterates through the array holding the signed 
;	integers as SDWORDs and adds them to obtain the total sum.
_sumElements:
	LODSD
	PUSH	EBX
	PUSH	EDX
	MOV	EBX, 1
	XOR	EDX, EDX
	IMUL	EAX, EBX
	POP	EDX
	POP	EBX
	JS	_sub
	ADD	[EBX], EAX
	JMP	_add
_sub:
	PUSH	EBX
	PUSH	EAX
	MOV	EAX, [EBX]
	POP	EBX			; pops old eax value into ebx
	ADD	EAX, EBX
	POP	EBX
	MOV	[EBX], EAX
_add:
	LOOP	_sumElements

; Calculates and stores the truncated average by taking the calculated 
;	sum and div by MAX_NUM=10.
	MOV	EAX, [EBX]
	POP	ECX
	MOV	EDI, EDX
	XOR	EDX, EDX
	MOV	EBX, MAX_NUM
	CDQ
	IDIV	EBX
	STOSD

; Restores registers
	POP	EDI
	POP	EDX
	POP	EBX
	POP	EAX
	POP	EBP
	RET
averageAndSum ENDP

; ---------------------------------------------------------------------------------
; Name: ConvertAverageSum
;
; Description: This subprocedure of WriteVal converts the average or sum, which is 
;		stored as an signed integer, and converts it into a string and stores to
;		memory. Note that this procedure does not convert both the average and sum
;		simultaneously, it needs to be called for each conversion. In retrospect 
;		this procedure could have (and maybe should have) been written as a macro
;		as there are also multiple conversions throughout this program that require
;		similar blocks of code.
;
; Preconditions: None
;
; Postconditions: eax, ebx, esi/edi, edx regs are changed
;
; Receives:
;	[ebp+16] = offset of average or sum (where average is stored as signed int)
;	[ebp+12] = offset of numsIn
;	[ebp+8] = offset of sign variable
;	
; returns: 
;	[ebp+16] = average or sum (as char string)
; ---------------------------------------------------------------------------------
ConvertAverageSum PROC
; ...
; Saves reg and sets base pointer
	PUSH	EBP
	MOV	EBP, ESP
	PUSH	ECX

; Checks if the average/sum is a negative value by the sign flag.
	XOR	ECX, ECX
	MOV	ESI, [EBP+8]		; sum		ebp+8
	MOV	EDI, [EBP+12]		; numsIn	ebp+12
	LODSD
	MOV	EBX, 1
	IMUL	EBX
	JNS	_positiveValueConvert
	INC	ECX
	MOV	EBX, EAX

; Saves sign variable as 1 if average is a negative integer.
	PUSH	EAX
	PUSH	EDI
	MOV	EAX, 1
	MOV	EDI, [EBP+16]		; sets sign variable 
	MOV	[EDI], EAX
	POP	EDI
	POP	EAX

; Converts negative integer to its 2's complement 
	MOV	EAX, EBX
	SUB	EAX, EBX
	SUB	EAX, EBX

; ----------------------
; Converts integer digits to string values coresponding to the ascii hex
;	codes for digits 0-9. For more detail please look at the proc WriteVal
;	where the array of numbers is converted to string characters.
;	It contains a very similary code block for converting the digits to 
;	hex code chars and a more detailed description of the algorithm. (Line 585)
; ----------------------
_positiveValueConvert:
	MOV	EBX, 10
	XOR	EDX, EDX
	DIV	EBX
	PUSH	EAX		; saves quotient 
	MOV	EAX, EDX
	ADD	EAX, 30h
	STOSB
	POP	EAX
	INC	ECX
	CMP	EAX, 0
	JNE	_positiveValueConvert
	; ...

; Appends "-" sign if the average is a negative value after 
;	checking the value of the sign variable.
	PUSH	EAX
	PUSH	EDI
	MOV	EDI, [EBP+16]
	MOV	EAX, 0
	CMP	[EDI], EAX		; sign=0 or sign=1?
	MOV	[EDI], EAX
	POP	EDI
	JE	_skipNegSum
	MOV	EAX, minusSign
	STOSB
_skipNegSum:
	POP	EAX
	
; ----------------------
; Similarly to the conversions for the array elements, we use numsIn
;	as a temporary placehold and reverse the order of characters that
;	are stored at numsIn (since they are currently stored in reversed
;	order). Sets source pointer from EDI (numsIn), then changes our
;	destination pointer to the array that holds the integer values
;	for the sum or average.
; ----------------------
	MOV	ESI, EDI
	MOV	EDI, [EBP+8]
	STD
	LODSB
_reverseInPlace:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_reverseInPlace
	XOR	EAX, EAX
	STOSB
	; ...

	POP	ECX
	POP	EBP
	RET	12
ConvertAverageSum ENDP

; ---------------------------------------------------------------------------------
; Name: goodbye
;
; Description: Displays a simple goodbye message.
;
; Preconditions: None
; Postconditions: None
;
; Receives:
; [ebp+8] = OFFSET of byeMsg
;
; returns: None
; ---------------------------------------------------------------------------------
goodbye PROC
; Saves reg/sets base pointer
	PUSH	EBP
	MOV	EBP, ESP
	PUSHAD

; Display goodbye message
	CALL	CrLf
	MOV	EDX, [EBP+8]
	CALL	WriteString
	CALL	CrLf

; Restores reg
	POPAD
	POP	EBP
	RET	4
goodbye ENDP

END main
