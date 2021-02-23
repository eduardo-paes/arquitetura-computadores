;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;------------------------------------------------------------------------------

WRITE           EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR		      EQU     FFFCh
CURSOR_INIT		  EQU		  FFFFh

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; ZONA IV: instruções
;------------------------------------------------------------------------------
      ORIG    0000h
      JMP     Main

Escreve:  PUSH  R3
          INC   R1
          MOV   M[ CURSOR ], R1   ; Move R1 to cursor address
          MOV   R3, '='           ; Mode caracter 'B' to R3
          MOV   M[ WRITE ], R3    ; Print R3
          POP   R3
          RET

Rotina:     CMP   R1, 79d
            BR.Z  FimRotina
            CALL  Escreve
            BR    Rotina

FimRotina:  POP     R2
            POP     R1
            RET

Main:	ENI
			MOV		R1, INITIAL_SP
			MOV		SP, R1		 		    ; We need to initialize the stack
			MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
			MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
      MOV   R1, 0
      MOV   M[ CURSOR ], R1   ; Move R1 to cursor address
	    MOV   R3, '='           ; Mode caracter 'A' to R3
      MOV   M[ WRITE ], R3    ; Print R3 
      CALL Rotina

Cycle: 	BR		Cycle	
Halt:   BR		Halt