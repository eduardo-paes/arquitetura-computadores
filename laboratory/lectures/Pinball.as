;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------

FIM_TEXTO       EQU     '@'
WRITE        		EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR		    	EQU     FFFCh
CURSOR_INIT			EQU			FFFFh
TEMP						EQU			FFF7h
INTERVAL				EQU			FFF6h
ROW_SHIFT				EQU			8d
; INT_MASK_ADDR   EQU     FFFAh
; INT_MASK        EQU     0000000000000001b
; NIBBLE_MASK     EQU     000fh
; NUM_NIBBLES     EQU     4
; BITS_PER_NIBBLE EQU     4


;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

								ORIG    8000h
TextScore				STR			'Score:', FIM_TEXTO
TextLifes				STR			'Lifes:', FIM_TEXTO
TextTutorial		STR			'Tutorial', FIM_TEXTO
TextIndex				WORD		0d
RowIndex				WORD		0d
ColumnIndex			WORD		0d
StringIndex			WORD		0d
PalhEsqPos			WORD		0d													; Informa se está ativada ou não: 0 está pra baixo, 1, pra cima
PalhDirPos			WORD		0d													; Informa se está ativada ou não: 0 está pra baixo, 1, pra cima
BallRowIndex		WORD		22d
BallColumnIndex	WORD		54d
Direcao					WORD		0d													; Informa a direção para onde a bola se moverá (0 à 4)
Verificado			WORD		0d													; Informa se a verificação de colisão já foi realizada

;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0						WORD    IniciaJogo
INT1            WORD    SobePalhetaEsq
INT2						WORD    SobePalhetaDir

								ORIG    FE0Fh
INT15           WORD    MoveBola

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;
;==================================================;
; Função para imprimir a linha do topo e do rodapé
;==================================================;
;
WriteLineInit:	PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								MOV 				R1, 0
								MOV					R2, '='
								MOV					R3, 0

WriteTop:				MOV					M[ WRITE ], R2
								MOV					R3, 0
								INC					M[ ColumnIndex ]
								OR					R3, M[ ColumnIndex ]
								MOV					M[ CURSOR ], R3

								MOV					R1, M[ ColumnIndex ]
								CMP 				R1, 80
								JMP.NZ 			WriteTop

								MOV					R3, 23
								MOV					M[ RowIndex ], R3
								MOV					M[ ColumnIndex ], R0
								SHL					R3, ROW_SHIFT
								OR					R3, M[ ColumnIndex ]
								MOV					M[ CURSOR ], R3
								MOV					R1, M[ ColumnIndex ]

WriteFloor: 		MOV					M[ WRITE ], R2
								INC					M[ ColumnIndex ]
								MOV					R3, 23
								SHL					R3, ROW_SHIFT
								OR					R3, M[ ColumnIndex ]
								MOV					M[ CURSOR ], R3

								INC					R1
								CMP 				R1, 80
								JMP.NZ 			WriteFloor

								MOV					R1, 0
								MOV					M[ ColumnIndex ], R1
								MOV					M[ RowIndex ], R1

								POP		 			R4
								POP		 			R3
								POP					R2
								POP					R1
								RET

;
;========================================================;
; Função para imprimir a parede da esquerda e da direita
;========================================================;
;
WriteWallInit:	PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								MOV 				R1, M[ RowIndex ]
								MOV					R2, M[ ColumnIndex ]
								MOV					R3, 1
								MOV					R4, '|'

WriteWall:			MOV					R2, 0
								MOV					R1, R3
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R4

								MOV					R2, 79
								MOV					R1, R3
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R4

								INC					R3

								CMP 				R3, 23
								JMP.NZ 			WriteWall

								POP		 			R4
								POP		 			R3
								POP					R2
								POP					R1
								RET
;
;======================================;
; Função para imprimir os componentes
;======================================;
;
DesignInit:			PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								MOV 				R1, M[ RowIndex ]
								MOV					R2, M[ ColumnIndex ]

ImprimirColInit:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								
								MOV 				R1, 1
								MOV 				R2, 55
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								MOV					R4, 1

ImprimirColuna: CMP					R4, 23
								JMP.Z				ImprimirColEnd
								
								MOV					M[ WRITE ], R3
								
								INC					R4
								INC 				M[ RowIndex ]
								MOV 				R1, M[ RowIndex ]
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								JMP					ImprimirColuna

ImprimirColEnd:	POP					R4
								POP					R3
								POP					R2
								POP					R1
								RET

ImprimirScoreInit:	PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								MOV 				R1, M[ RowIndex ]
								MOV					R2, M[ ColumnIndex ]

								MOV					R1, 2
								MOV					M[ RowIndex ], R1
								MOV					R2, 2
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								; MOV					R3, TextScore
								; JMP 				EscreverString
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, M[ TextScore ]
								MOV					R4, 0


ImprimirScore:	CMP					R3, FIM_TEXTO
								JMP.Z				ImprimirEnd
								
								MOV					M[ WRITE ], R3

								INC 				M[ ColumnIndex ]
								MOV 				R2, M[ ColumnIndex ]
								MOV 				R1, M[ RowIndex ]
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								INC					R4
								MOV					R3, M[ R4 + TextScore ]
								JMP					ImprimirScore

ImprimirLifesInit:	PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								MOV 				R1, M[ RowIndex ]
								MOV					R2, M[ ColumnIndex ]

								MOV					R1, 3
								MOV					M[ RowIndex ], R1
								MOV					R2, 2
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, M[ TextLifes ]
								MOV					R4, 0

ImprimirLifes:	CMP					R3, FIM_TEXTO
								JMP.Z				ImprimirEnd
								
								MOV					M[ WRITE ], R3

								INC 				M[ ColumnIndex ]
								MOV 				R2, M[ ColumnIndex ]
								MOV 				R1, M[ RowIndex ]
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								INC					R4
								MOV					R3, M[ R4 + TextLifes ]
								JMP					ImprimirLifes

ImprimirTutInit:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								MOV 				R1, M[ RowIndex ]
								MOV					R2, M[ ColumnIndex ]

								MOV					R1, 2
								MOV					M[ RowIndex ], R1
								MOV					R2, 63
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, M[ TextTutorial ]
								MOV					R4, 0

ImprimirTutor:	CMP					R3, FIM_TEXTO
								JMP.Z				ImprimirEnd
								
								MOV					M[ WRITE ], R3

								INC 				M[ ColumnIndex ]
								MOV 				R2, M[ ColumnIndex ]
								MOV 				R1, M[ RowIndex ]
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								INC					R4
								MOV					R3, M[ R4 + TextTutorial ]
								JMP					ImprimirTutor

ImprimirEnd:		POP					R4
								POP					R3
								POP					R2
								POP					R1
								RET

ImprimirCol2Init:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								
								MOV 				R1, 4
								MOV 				R2, 53
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								MOV					R4, 4

								JMP					ImprimirColuna



ImprimirQuinInf:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								
								MOV 				R1, 11
								MOV 				R2, 26
								MOV					R3, '\'
								MOV					R4, 0

QuinInfEsq:			MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV 				R1, M[ RowIndex ]
								MOV 				R2, M[ ColumnIndex ]
								INC					R1
								INC					R2
								INC					R4

								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								CMP					R4, 8
								JMP.NZ 			QuinInfEsq

								MOV 				R1, 19
								MOV 				R2, 34
								MOV				  R3, '*'
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV 				R1, M[ RowIndex ]
								MOV 				R2, M[ ColumnIndex ]
								INC					R1
								INC					R2

								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2

								MOV 				R1, 11
								MOV 				R2, 52
								MOV					R3, '/'
								MOV					R4, 0

QuinInfDir:			MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV 				R1, M[ RowIndex ]
								MOV 				R2, M[ ColumnIndex ]
								INC					R1
								DEC					R2
								INC					R4

								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								CMP					R4, 8
								JMP.NZ 			QuinInfDir
								
								MOV 				R1, 19
								MOV 				R2, 44
								MOV				  R3, '*'
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV 				R1, M[ RowIndex ]
								MOV 				R2, M[ ColumnIndex ]
								INC					R1
								DEC					R2

								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2

								POP					R4
								POP					R3
								POP					R2
								POP					R1
								RET								

ImprimirColEsqInit:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								
								MOV 				R1, 1
								MOV 				R2, 25
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								MOV					R4, 1

								JMP					ImprimirColuna	

ImprimirCol3Init:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								
								MOV 				R1, 20
								MOV 				R2, 34
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								MOV					R4, 20

								JMP					ImprimirColuna

ImprimirCol4Init:PUSH 				R1
								PUSH				R2
								PUSH				R3
								PUSH				R4
								
								MOV 				R1, 20
								MOV 				R2, 44
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								MOV					R4, 20

								JMP					ImprimirColuna

EscCar:         MOV     R1, M[SP+3]
                MOV     M[WRITE], R1
                RETN    1

EscreverString: PUSH    R1
                PUSH    R2
								PUSH    R3
Ciclo:          MOV     R1, M[R3]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                PUSH    R1
                CALL    EscCar
                INC     R2
                BR      Ciclo
FimEsc:         POP     R3
								POP     R2
                POP     R1
                RET

ImprimirObst1:	PUSH 				R1
								PUSH				R2
								PUSH				R3

								MOV 				R1, 4
								MOV 				R2, 38
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 4
								MOV 				R2, 39
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '-'

								MOV					M[ WRITE ], R3

								MOV 				R1, 4
								MOV 				R2, 40
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3

								MOV 				R1, 5
								MOV 				R2, 38
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								
								MOV					M[ WRITE ], R3

								MOV 				R1, 5
								MOV 				R2, 40
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 6
								MOV 				R2, 38
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 6
								MOV 				R2, 39
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '-'

								MOV					M[ WRITE ], R3

								MOV 				R1, 6
								MOV 				R2, 40
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3

								POP					R3
								POP					R2
								POP					R1
								RET

ImprimirObst2:	PUSH 				R1
								PUSH				R2
								PUSH				R3

								MOV 				R1, 10
								MOV 				R2, 32
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 10
								MOV 				R2, 33
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '-'

								MOV					M[ WRITE ], R3

								MOV 				R1, 10
								MOV 				R2, 34
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3

								MOV 				R1, 11
								MOV 				R2, 32
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								
								MOV					M[ WRITE ], R3

								MOV 				R1, 11
								MOV 				R2, 34
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 12
								MOV 				R2, 32
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 12
								MOV 				R2, 33
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '-'

								MOV					M[ WRITE ], R3

								MOV 				R1, 12
								MOV 				R2, 34
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3

								POP					R3
								POP					R2
								POP					R1
								RET

ImprimirObst3:	PUSH 				R1
								PUSH				R2
								PUSH				R3

								MOV 				R1, 10
								MOV 				R2, 44
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 10
								MOV 				R2, 45
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '-'

								MOV					M[ WRITE ], R3

								MOV 				R1, 10
								MOV 				R2, 46
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3

								MOV 				R1, 11
								MOV 				R2, 44
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '|'
								
								MOV					M[ WRITE ], R3

								MOV 				R1, 11
								MOV 				R2, 46
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 12
								MOV 				R2, 44
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3
								
								MOV 				R1, 12
								MOV 				R2, 45
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '-'

								MOV					M[ WRITE ], R3

								MOV 				R1, 12
								MOV 				R2, 46
								MOV 				M[ RowIndex ], R1
								MOV					M[ ColumnIndex ], R2
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, '+'

								MOV					M[ WRITE ], R3

								POP					R3
								POP					R2
								POP					R1
								RET

;
;==================================================;
;		 Funções Relacionadas às Palhetas		 ;
;==================================================;
;
ImprimirPalhetas:PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3

								MOV					R1, 20
								MOV					R2, 35
								MOV					R3, '\'

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV					R1, 21
								MOV					R2, 36

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 20
								MOV					R2, 43
								MOV					R3, '/'

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV					R1, 21
								MOV					R2, 42

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								POP					R3
								POP					R2
								POP					R1
								RET

SobePalhetaEsq: PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3

								MOV					R1, 20
								MOV					R2, 35
								MOV					R3, ' '

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 21
								MOV					R2, 36

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 19
								MOV					R2, 35
								MOV					R3, '/'

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV					R1, 18
								MOV					R2, 36

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3	

								POP					R3
								POP					R2
								POP					R1
								RTI

SobePalhetaDir: PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3

								MOV					R1, 20
								MOV					R2, 43
								MOV					R3, ' '

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 21
								MOV					R2, 42

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 19
								MOV					R2, 43
								MOV					R3, '\'

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV					R1, 18
								MOV					R2, 42

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3	

								POP					R3
								POP					R2
								POP					R1
								RTI


DescePalhetEsq: PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3

								MOV					R1, 20
								MOV					R2, 35
								MOV					R3, '\'

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 21
								MOV					R2, 36

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 19
								MOV					R2, 35
								MOV					R3, ' '

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV					R1, 18
								MOV					R2, 36

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3	

								POP					R3
								POP					R2
								POP					R1
								RET

DescePalhetDir: PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3

								MOV					R1, 20
								MOV					R2, 43
								MOV					R3, '/'

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 21
								MOV					R2, 42

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								MOV					R1, 19
								MOV					R2, 43
								MOV					R3, ' '

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3
								
								MOV					R1, 18
								MOV					R2, 42

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3	

								POP					R3
								POP					R2
								POP					R1
								RET


;
;==================================================;
;	Verifica se a bola colide com o Topo ;
;==================================================;
;
ColisaoTopo:		PUSH 				  R1   
								PUSH 				  R3      

								MOV    				R1, M[BallRowIndex]
								CMP    				R1, 1                              
								JMP.NZ 				FimColisaoTopo

								MOV    				R1, M[BallColumnIndex]

								MOV						R3, M[ Direcao ]
								CMP						R3, 0
								CALL.Z				MudaDiagEsqInf

								CMP						R3, 2
								CALL.Z				MudaDiagDirInf

								CMP						R1, 54
								JMP.NZ				FimColisaoTopo

								CMP						R1, 26
								CALL.Z				MudaDiagDirInf

								INC						M[ Verificado ]


FimColisaoTopo: POP   				R3
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com a parede esquerda  ;
;==================================================;
;
ColisaoColEsq:	PUSH 				  R1     
								PUSH 				  R3      

								MOV    				R1, M[BallColumnIndex]
								CMP    				R1, 26                              
								JMP.NZ 				FimColisaoColEsq

								MOV    				R1, M[BallRowIndex]
								MOV						R3, M[ Direcao ]

								CMP						R3, 3
								CALL.Z				MudaDiagDirInf

								CMP						R3, 4
								CALL.Z				MudaDiagDirSup

								CMP						R1, 10
								CALL.Z				MudaDiagDirSup

								INC						M[ Verificado ]

FimColisaoColEsq:POP   				R3
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com a parede interna   ;
;==================================================;
;
ColisaoColInt:	PUSH 				  R1     
								PUSH 				  R3      

								MOV    				R1, M[BallColumnIndex]
								CMP    				R1, 52                              
								JMP.NZ 				FimColisaoColInt
								
								MOV    				R1, M[BallRowIndex]
								CMP    				R1, 4                              
								JMP.N 				FimColisaoColInt
								
								INC						M[ Verificado ]

								MOV						R3, M[ Direcao ]

								CMP						R3, 1
								CALL.Z				MudaDiagEsqInf

								CMP						R3, 2
								CALL.Z				MudaDiagEsqSup

								CMP						R3, 3
								JMP.Z 				FimColisaoColInt

								CMP						R1, 3
								CALL.Z				MudaDiagDirSup


FimColisaoColInt:POP   				R3
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com a parede direita   ;
;==================================================;
;
ColisaoColDir:	PUSH 				  R1  
								PUSH 				  R3      

								MOV    				R1, M[BallColumnIndex]
								CMP    				R1, 54                              
								JMP.NZ 				FimColisaoColDir

								MOV    				R1, M[BallRowIndex]
								MOV						R3, M[ Direcao ]

								CMP						R3, 0
								JMP.Z 				FimColisaoColDir

								CMP						R3, 1
								CALL.Z				MudaDiagEsqInf

								CMP						R3, 2
								CALL.Z				MudaDiagEsqSup

								CMP						R1, 3
								CALL.Z				MudaDiagEsqSup

								INC						M[ Verificado ]

FimColisaoColDir:POP   				R3
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com a quina esquerda   ;
;==================================================;
;
ColisaoQuiEsq:	PUSH 				  R1
								PUSH 				  R2      
								PUSH 				  R3
								PUSH 				  R4      
								PUSH 				  R5       

								MOV    				R1, M[BallColumnIndex]
								MOV    				R2, M[BallRowIndex]
								
								CMP 					R1, 34
								JMP.N					FimColisaoQuiEsq
								CMP 					R2, 11
								JMP.N					FimColisaoQuiEsq

								MOV 					R3, 8
								MOV						R4, 27
								MOV						R5, 11
CicloQuinaEsq:	CMP						R3, 0
								JMP.Z					FimCicloQuinaEsq

								CMP    				R1, R4
								JMP.NZ				ProximaQuinaEsq                              
								CMP 					R2, R5
								JMP.NZ				FimCicloQuinaEsq
								CALL					MudaDiagDirSup
								JMP						FimCicloQuinaEsq

ProximaQuinaEsq:DEC						R3
								INC						R4
								INC						R5
								JMP						CicloQuinaEsq

FimCicloQuinaEsq:INC					M[ Verificado ]

FimColisaoQuiEsq:POP   				R5
								POP   				R4
								POP   				R3
								POP   				R2
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com a quina direita    ;
;==================================================;
;
ColisaoQuiDir:	PUSH 				  R1
								PUSH 				  R2      
								PUSH 				  R3
								PUSH 				  R4      
								PUSH 				  R5       

								MOV    				R1, M[BallColumnIndex]
								MOV    				R2, M[BallRowIndex]
								
								CMP 					R1, 44
								JMP.N					FimColisaoQuiEsq
								CMP 					R2, 11
								JMP.N					FimColisaoQuiEsq

								MOV 					R3, 8
								MOV						R4, 51
								MOV						R5, 11
CicloQuinaDir:	CMP						R3, 0
								JMP.Z					FimCicloQuinaDir

								CMP    				R1, R4
								JMP.NZ				ProximaQuinaDir                              
								CMP 					R2, R5
								JMP.NZ				FimCicloQuinaDir
								CALL					MudaDiagEsqSup
								JMP						FimCicloQuinaDir

ProximaQuinaDir:DEC						R3
								DEC						R4
								INC						R5
								JMP						CicloQuinaDir

FimCicloQuinaDir:INC					M[ Verificado ]

FimColisaoQuiDir:POP   				R5
								POP   				R4
								POP   				R3
								POP   				R2
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com o obstáculo 1      ;
;==================================================;
;
ColisaoObst1:		PUSH 				  R1
								PUSH 				  R2      
								PUSH 				  R3

								MOV    				R1, M[BallColumnIndex]
								MOV    				R2, M[BallRowIndex]
								
								CMP 					R2, 7
								JMP.P					FimColisaoObst1

								MOV						R3, 3
								
VerLinhaObst1:	CMP						R2, R3
								JMP.N				  FimVerObst1
								JMP.Z					VerColObst1
								INC						R3
								JMP						VerLinhaObst1

VerColObst1:		CMP    				R1, 37
								CALL.Z				RefleteVertical

								CMP    				R1, 41
								CALL.Z				RefleteVertical
								
								CMP    				R1, 38
								CALL.Z				RefleteHorizont

								CMP    				R1, 39
								CALL.Z				RefleteHorizont

								CMP    				R1, 40
								CALL.Z				RefleteHorizont

FimVerObst1:		INC					M[ Verificado ]

FimColisaoObst1:POP						R3
								POP   				R2
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com o obstáculo 2 e 3  ;
;==================================================;
;
ColisaoObst2e3:	PUSH 				  R1
								PUSH 				  R2    
								PUSH 				  R3

								MOV    				R1, M[BallColumnIndex]
								MOV    				R2, M[BallRowIndex]
								
								CMP 					R2, 9
								JMP.N					FimColisaoObst2e3

								CMP 					R2, 13
								JMP.P					FimColisaoObst2e3

								MOV						R3, 9
								
VerLinhaObst2e3:CMP						R2, R3
								JMP.Z					VerColObst2e3
								INC						R3
								JMP						VerLinhaObst2e3

VerColObst2e3:	CMP    				R1, 31
								CALL.Z				RefleteVertical

								CMP    				R1, 35
								CALL.Z				RefleteVertical

								CMP    				R1, 43
								CALL.Z				RefleteVertical

								CMP    				R1, 47
								CALL.Z				RefleteVertical
								
								CMP    				R1, 32
								CALL.Z				RefleteHorizont

								CMP    				R1, 33
								CALL.Z				RefleteHorizont

								CMP    				R1, 34
								CALL.Z				RefleteHorizont

								CMP    				R1, 44
								CALL.Z				RefleteHorizont

								CMP    				R1, 45
								CALL.Z				RefleteHorizont

								CMP    				R1, 46
								CALL.Z				RefleteHorizont

FimVerObst2e3:	INC					M[ Verificado ]

FimColisaoObst2e3:POP						R3
								POP   				R2
								POP   				R1                              
								RET

;
;==================================================;
;	Verifica se a bola colide com a palheta esquerda ;
;==================================================;
;
; ColisaoPalhEsq:	PUSH 				  R1
; 								PUSH 				  R2      
; 								PUSH 				  R3
; 								PUSH 				  R4

; 								MOV    				R1, M[BallColumnIndex]
; 								MOV    				R2, M[BallRowIndex]
								
; 								CMP 					R2, 20
; 								JMP.N					FimColisaoPalhEsq

; 								MOV						R3, M[ PalhEsqPos ]
; 								CMP						R3, 0

; 								JMP.NZ				PalhEsqAtivada

; 								MOV						R4, M[ Direcao ]
; 								CMP						R4, 1
; 								JMP.Z					FimColisaoPalhEsq

; 								CMP						R2, 20
; 								CALL.Z				
; 								CMP						R1, 36
; 								CALL.Z				

; 								CMP						R2, 21
; 								CALL.Z				
; 								CMP						R1, 37
; 								CALL.Z				

; PalhEsqAtivada:


; 								MOV						R4, 9
								
; VerLinhaPalhEsq:CMP						R2, R4
; 								JMP.Z					VerColPalhEsq
; 								INC						R4
; 								JMP						VerLinhaPalhEsq

; VerColPalhEsq:	CMP    				R1, 31
; 								CALL.Z				RefleteVertical

; 								CMP    				R1, 35
; 								CALL.Z				RefleteVertical

; 								CMP    				R1, 43
; 								CALL.Z				RefleteVertical

; 								CMP    				R1, 47
; 								CALL.Z				RefleteVertical
								
; 								CMP    				R1, 32
; 								CALL.Z				RefleteHorizont

; 								CMP    				R1, 33
; 								CALL.Z				RefleteHorizont

; 								CMP    				R1, 34
; 								CALL.Z				RefleteHorizont

; 								CMP    				R1, 44
; 								CALL.Z				RefleteHorizont

; 								CMP    				R1, 45
; 								CALL.Z				RefleteHorizont

; 								CMP    				R1, 46
; 								CALL.Z				RefleteHorizont

; FimVerPalhEsq:	INC					M[ Verificado ]

; FimColisaoPalhEsq:POP						R4
; 								POP   				R3
; 								POP   				R2
; 								POP   				R1                              
; 								RET

;
;======================================;
;				Funções Relacionadas à Bola		 ;
;======================================;
;
ImprimirBolaIni:PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3

								MOV					R1, M[ BallRowIndex ] 
								MOV					R2, M[ BallColumnIndex ]

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1

								MOV					R3, 'o'
								MOV					M[ WRITE ], R3

								POP					R3
								POP					R2
								POP					R1
								RET

RefleteVertical:PUSH					R1
								MOV						R1, M[ Direcao ]

								CMP						R1, 1
								CALL.Z				MudaDiagEsqInf

								CMP						R1, 2
								CALL.Z				MudaDiagEsqSup

								CMP						R1, 3
								CALL.Z				MudaDiagDirInf

								CMP						R1, 4
								CALL.Z				MudaDiagDirSup

								POP						R1
								RET

RefleteHorizont:PUSH					R1
								MOV						R1, M[ Direcao ]
								
								CMP						R1, 1
								CALL.Z				MudaDiagDirSup

								CMP						R1, 2
								CALL.Z				MudaDiagDirInf

								CMP						R1, 3
								CALL.Z				MudaDiagEsqSup

								CMP						R1, 4
								CALL.Z				MudaDiagEsqInf

								POP						R1
								RET

MudaDiagDirInf:	PUSH					R1
								MOV						R1, 1
								MOV						M[ Direcao ], R1
								POP						R1
								RET

MudaDiagDirSup:	PUSH					R1
								MOV						R1, 2
								MOV						M[ Direcao ], R1
								POP						R1
								RET

MudaDiagEsqInf:	PUSH					R1
								MOV						R1, 3
								MOV						M[ Direcao ], R1
								POP						R1
								RET

MudaDiagEsqSup:	PUSH					R1
								MOV						R1, 4
								MOV						M[ Direcao ], R1
								POP						R1
								RET

Cima:						DEC					M[ BallRowIndex ]
								JMP					ImprimiBola

DiagInfDir:			INC					M[ BallRowIndex ]
								INC					M[ BallColumnIndex ]
								JMP					ImprimiBola

DiagSupDir:			DEC					M[ BallRowIndex ]
								INC					M[ BallColumnIndex ]
								JMP					ImprimiBola

DiagInfEsq:			INC					M[ BallRowIndex ]
								DEC					M[ BallColumnIndex ]
								JMP					ImprimiBola

DiagSupEsq:			DEC					M[ BallRowIndex ]
								DEC					M[ BallColumnIndex ]
								JMP					ImprimiBola

MoveBola:				PUSH 				R1
						 		PUSH				R2
						 		PUSH				R3
								
								MOV					R1, M[ BallRowIndex ]
								MOV					R2, M[ BallColumnIndex ]
								MOV					R3, ' '

								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					M[ WRITE ], R3

								CALL				ColisaoTopo
								
								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoColEsq

								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoColInt

								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoColDir

								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoQuiEsq

								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoQuiDir

								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoObst1

								MOV					R3, M[ Verificado ]
								CMP					R3, 1
								CALL.NZ			ColisaoObst2e3

								MOV					R3, M[ Direcao ]

								CMP					R3, 0
								JMP.Z				Cima

								CMP					R3, 1
								JMP.Z				DiagInfDir

								CMP					R3, 2
								JMP.Z				DiagSupDir

								CMP					R3, 3
								JMP.Z				DiagInfEsq
								
								CMP					R3, 4
								JMP.Z				DiagSupEsq		

								DEC					M[ Verificado ]


ImprimiBola:		MOV 				R1, M[ BallRowIndex ]
								MOV					R2, M[ BallColumnIndex ]
								SHL					R1, ROW_SHIFT
								OR					R1, R2
								MOV					M[ CURSOR ], R1
								MOV					R3, 'o'

								MOV					M[ WRITE ], R3

								CALL				ConfiguraTempo

								POP					R3
								POP					R2
								POP					R1
								RTI

;
;======================================;
;				Função Básicas do Jogo				 ;
;======================================;
;

ConfiguraTempo:	PUSH 				R1

								MOV					R1, 1
								MOV					M[ INTERVAL ], R1
								MOV					R1, 1
								MOV					M[ TEMP ], R1

								POP					R1
								RET

IniciaJogo: 		CALL				ConfiguraTempo
								RTI
;
;======================================;
;							Função Main							 ;
;======================================;
;
Main:						ENI
								MOV					R1, INITIAL_SP
								MOV					SP, R1		 												; We need to initialize the stack
								MOV					R1, CURSOR_INIT										; We need to initialize the cursor 
								MOV					M[ CURSOR ], R1										; with value CURSOR_INIT

								CALL				WriteLineInit
								CALL				WriteWallInit
								CALL				ImprimirColInit

								CALL				ImprimirScoreInit
								CALL				ImprimirLifesInit
								
								CALL				ImprimirCol2Init
								CALL				ImprimirQuinInf
								CALL				ImprimirColEsqInit
								CALL				ImprimirBolaIni
								CALL				ImprimirPalhetas
								CALL				ImprimirCol3Init
								CALL				ImprimirCol4Init
								CALL				ImprimirObst1
								CALL				ImprimirObst2
								CALL				ImprimirObst3


Cycle: 					BR		Cycle	
Halt:           BR		Halt

