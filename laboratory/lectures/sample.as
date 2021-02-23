;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------

WRITE           EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR		      EQU     FFFCh
CURSOR_INIT		  EQU		  FFFFh
FIM_TEXTO       EQU     '@'

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

              ORIG    8000h
Text					STR     'Palavra', FIM_TEXTO

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
      ORIG    0000h
      JMP     Main

Main:	ENI
			MOV		R1, INITIAL_SP
			MOV		SP, R1		 		    ; We need to initialize the stack
			MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
			MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
      
      MOV   R1, 12            ; Row 12                                          (00000000|0001100) Left(Row) = 00 / Right(Col) = 12
      MOV   R2, 40            ; Column 40                                       (00000000|0101000) Left(Row) = 00 / Right(Col) = 40
      SHL   R1, 8             ; Shift Left in R1 of 8 positions                 (00001100|0000000) Left(Row) = 12 / Right(Col) = 00
      OR    R1, R2            ; R1 will has the correct position (R1 + R2)      (00001100|0101000) Left(Row) = 12 / Right(Col) = 40
      MOV   M[ CURSOR ], R1   ; Move R1 to cursor address
      
	    MOV   R3, 'A'           ; Mode caracter 'A' to R3
      MOV   M[ WRITE ], R3    ; Print R3 

      INC   R1
      MOV   M[ CURSOR ], R1   ; Move R1 to cursor address

      MOV   R3, 'B'           ; Mode caracter 'B' to R3
      MOV   M[ WRITE ], R3    ; Print R3

      INC   R1
      MOV   M[ CURSOR ], R1   ; Move R1 to cursor address

      MOV   R3, 'C'           ; Mode caracter 'C' to R3
      MOV   M[ WRITE ], R3    ; Print R3

Cycle: 	BR		Cycle	
Halt:   BR		Halt