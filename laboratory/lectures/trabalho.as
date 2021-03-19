;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;------------------------------------------------------------------------------
      CURSOR		      EQU         FFFCh
      CURSOR_INIT		      EQU	      FFFFh
      END_COLUMN			EQU		79d
      END_ROW			EQU		23d
      END_WALL_COLUMN		EQU		79d
      END_WALL_ROW		EQU		23d
      INI_COLUMN			EQU		0d
      FIM_TEXTO               EQU         '@'
      INI_ROW			EQU		0d
      INITIAL_SP              EQU         FDFFh
      NUM_COLUMNS		      EQU	      80d
      NUM_ROWS		      EQU	      24d
      ROW_SHIFT			EQU		8d
      WALL_COLUMN_1		EQU		21d
      WALL_COLUMN_2		EQU		55d
      WALL_ROW			EQU		1d
      WRITE                   EQU         FFFEh

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;------------------------------------------------------------------------------
                              ORIG        8000h
      CharIndex               WORD        0d
      ColumnIndex             WORD        0d
      Count                   WORD        0d 
      LifeText		      STR         'LIFES:', FIM_TEXTO
      NumDots                 WORD        0d
      RowIndex                WORD        0d
      ScoreText		      STR         'SCORE:', FIM_TEXTO
      TextIndex               WORD        0d
      EndColumnIndex          WORD        0d
      EndRowIndex             WORD        0d

;------------------------------------------------------------------------------
; ZONA IV: instruções
;------------------------------------------------------------------------------
      ORIG  0000h                   ; Inicializa programa na posição
      JMP   Main                    ; Salta para a função inicial

;------------------------------------------------------------------------------
; Function Printing Center Column
;------------------------------------------------------------------------------
      PrintCenterColumn:      PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              MOV   M[ColumnIndex], R1
                              MOV   R2, END_WALL_ROW
                              MOV   M[EndRowIndex], R2 
                              MOV   R3, '|'
                              CALL  StartVerticalPrint

                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              MOV   R3, '.'
                              CALL  StartVerticalPrint

                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              MOV   R3, '.'
                              CALL  StartVerticalPrint

                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              MOV   R3, '|'
                              CALL  StartVerticalPrint

                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              POP   R3
                              POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Função ImprimeCanaleta - Imprime Canaleta Central
;------------------------------------------------------------------------------
      IniciaSequenciaPontos:  PUSH  R1
                              PUSH  R2
                              PUSH  R3

      ImprimeSequenciaPontos: MOV   R3, M[ CharIndex ]
                              CMP   R3, M[ NumDots ]
                              JMP.Z FimSequenciaPontos
                              MOV   R1, M[ ColumnIndex ]
                              MOV   R2, M[ RowIndex ]
                              MOV   R3, '.'
                              SHL   R2, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[ CURSOR ], R1
                              MOV   M[ WRITE ], R3
                              INC   M[ CharIndex ]
                              INC   M[ ColumnIndex ]
                              JMP   ImprimeSequenciaPontos

      FimSequenciaPontos:     POP   R3
                              POP   R2 
                              POP   R1
                              RET

      ImprimeCanaleta:        PUSH  R1    ; Coluna
                              PUSH  R2    ; Linha
                              PUSH  R3    ; Caracter / Auxiliar

                              MOV   R3, 0d
                              MOV   M[ CharIndex ], R3
                              MOV   R3, 27d
                              MOV   M[ ColumnIndex ], R3
                              CALL  IniciaSequenciaPontos
                              
                              MOV   R1, M[ ColumnIndex ]
                              MOV   R2, M[ RowIndex ]
                              MOV   R3, '|'
                              SHL   R2, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[ CURSOR ], R1
                              MOV   M[ WRITE ], R3

                              MOV   R1, 45d
                              MOV   M[ ColumnIndex ], R1
                              MOV   R2, M[ RowIndex ]
                              SHL   R2, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[ CURSOR ], R1
                              MOV   M[ WRITE ], R3

                              INC   M[ ColumnIndex ]
                              MOV   R3, 0d
                              MOV   M[ CharIndex ], R3
                              CALL  IniciaSequenciaPontos

                              POP   R3
                              POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Função ImprimeAsterisco - Imprime Asterisco
;------------------------------------------------------------------------------
      ImprimeAsterisco:       PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              MOV   R1, M[ ColumnIndex ]
                              MOV   R2, M[ RowIndex ]
                              MOV   R3, '#'
                              SHL   R2, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[ CURSOR ], R1
                              MOV   M[ WRITE ], R3

                              POP   R3
                              POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Função ImprimeInclinacaoEsq - Imprime Inclinação do Lado Esquerdo
;------------------------------------------------------------------------------
      ImprimeInclinacaoEsq:   PUSH  R1

                              MOV   R1, 27d
                              MOV   M[ColumnIndex], R1
                              MOV   R1, 14d
                              MOV   M[RowIndex], R1
                              CALL  ImprimeAsterisco

                              INC   M[RowIndex]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              MOV   R1, 1d
                              MOV   M[NumDots], R1
                              CALL  IniciaSequenciaPontos
                              CALL  ImprimeAsterisco

                              INC   M[ RowIndex ]
                              INC   M[ NumDots ]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              MOV   R1, 27d
                              MOV   M[ColumnIndex], R1
                              CALL  IniciaSequenciaPontos
                              CALL  ImprimeAsterisco

                              INC   M[ RowIndex ]
                              INC   M[ NumDots ]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              MOV   R1, 27d
                              MOV   M[ColumnIndex], R1
                              CALL  IniciaSequenciaPontos
                              CALL  ImprimeAsterisco

                              INC   M[ RowIndex ]
                              INC   M[ NumDots ]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              MOV   R1, 27d
                              MOV   M[ColumnIndex], R1
                              CALL  IniciaSequenciaPontos
                              CALL  ImprimeAsterisco

                              INC   M[ RowIndex ]
                              INC   M[ NumDots ]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              MOV   R1, 27d
                              MOV   M[ColumnIndex], R1
                              CALL  IniciaSequenciaPontos
                              CALL  ImprimeAsterisco

                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Função ImprimeInclinacaoDir - Imprime Inclinação do Lado Direita
;------------------------------------------------------------------------------
      ImprimeInclinacaoDir:   PUSH  R1

                              MOV   R1, 50d
                              MOV   M[ColumnIndex], R1
                              MOV   R1, 14d
                              MOV   M[RowIndex], R1
                              CALL  ImprimeAsterisco

                              DEC   M[ColumnIndex]
                              INC   M[RowIndex]
                              CALL  ImprimeAsterisco
                              INC   M[ColumnIndex]

                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              MOV   R1, 1d
                              MOV   M[NumDots], R1
                              CALL  IniciaSequenciaPontos

                              MOV   R1, 48d
                              MOV   M[ColumnIndex], R1
                              INC   M[RowIndex]
                              CALL  ImprimeAsterisco
                              INC   M[ColumnIndex]
                              INC   M[NumDots]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              CALL  IniciaSequenciaPontos

                              MOV   R1, 47d
                              MOV   M[ColumnIndex], R1
                              INC   M[RowIndex]
                              CALL  ImprimeAsterisco
                              INC   M[ColumnIndex]
                              INC   M[NumDots]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              CALL  IniciaSequenciaPontos

                              MOV   R1, 46d
                              MOV   M[ColumnIndex], R1
                              INC   M[RowIndex]
                              CALL  ImprimeAsterisco
                              INC   M[ColumnIndex]
                              INC   M[NumDots]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              CALL  IniciaSequenciaPontos

                              MOV   R1, 45d
                              MOV   M[ColumnIndex], R1
                              INC   M[RowIndex]
                              CALL  ImprimeAsterisco
                              INC   M[ColumnIndex]
                              INC   M[NumDots]
                              MOV   R1, 0d
                              MOV   M[CharIndex], R1
                              CALL  IniciaSequenciaPontos

                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Function Score Printing
;------------------------------------------------------------------------------
      StartScore: PUSH  R1
                  PUSH  R2
                  PUSH  R3
                  PUSH  R4
                  MOV   R4, 0d

      PrintScore: MOV   R3, M[R4 + ScoreText]
                  CMP 	R3, FIM_TEXTO
                  JMP.Z EndScore

                  MOV   R1, M[ColumnIndex]
                  MOV   R2, M[RowIndex]
                  SHL   R2, ROW_SHIFT
                  OR    R1, R2
                  MOV   M[CURSOR], R1
                  MOV   M[WRITE], R3
                  INC   M[ColumnIndex]
                  INC   R4
                  JMP   PrintScore

      EndScore:   POP   R4
                  POP   R3
                  POP   R2
                  POP   R1
                  RET

;------------------------------------------------------------------------------
; Function Life Printing
;------------------------------------------------------------------------------
      StartLife:  PUSH  R1
                  PUSH  R2
                  PUSH  R3
                  PUSH  R4
                  MOV   R4, 0d

      PrintLife:  MOV   R3, M[R4 + LifeText]
                  CMP 	R3, FIM_TEXTO
                  JMP.Z EndLife

                  MOV   R1, M[ColumnIndex]
                  MOV   R2, M[RowIndex]
                  SHL   R2, ROW_SHIFT
                  OR    R1, R2
                  MOV   M[CURSOR], R1
                  MOV   M[WRITE], R3
                  INC   M[ColumnIndex]
                  INC   R4
                  JMP   PrintLife

      EndLife:    POP   R4
                  POP   R3
                  POP   R2
                  POP   R1
                  RET

;------------------------------------------------------------------------------
; Function Generic Horizontal Printing
;------------------------------------------------------------------------------
      StartHorizontalPrint:   PUSH  R1
                              PUSH  R2
                              PUSH  R3    ; 'K'

      HorizontalPrint:        MOV   R1, M[ColumnIndex]
                              CMP   R1, M[EndColumnIndex]
                              JMP.Z EndHorizontalPrint
                              
                              MOV   R2, M[RowIndex]
                              SHL   R2, ROW_SHIFT
                              OR    R2, R1
                              MOV   M[CURSOR], R2
                              MOV   M[WRITE], R3
                              INC   M[ColumnIndex]

                              JMP   HorizontalPrint

      EndHorizontalPrint:     POP   R3
                              POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Function Generic Vertical Printing
;------------------------------------------------------------------------------
      StartVerticalPrint:     PUSH  R1
                              PUSH  R2
                              PUSH  R3 

      VerticalPrint:          MOV   R1, M[RowIndex]
                              CMP   R1, M[EndRowIndex]
                              JMP.Z EndVerticalPrint
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              INC   M[RowIndex]
                              JMP   VerticalPrint

      EndVerticalPrint:       POP   R3
                              POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Function StartScreen
;------------------------------------------------------------------------------
StartScreen:      PUSH  R1
                  PUSH  R3
                  ; Print Left Column
                        MOV   R1, NUM_ROWS
                        MOV   M[EndRowIndex], R1 
                        MOV   R3, '='
                        CALL  StartVerticalPrint

                  ; Print Up Line
                        MOV   R1, INI_ROW
                        MOV   M[RowIndex], R1
                        MOV   R1, NUM_COLUMNS
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '='
                        CALL  StartHorizontalPrint

                  ; Print Right Column
                        MOV   R1, 0d
                        MOV   M[RowIndex], R1 
                        MOV   R1, END_COLUMN
                        MOV   M[ColumnIndex], R1
                        MOV   R1, NUM_ROWS
                        MOV   M[EndRowIndex], R1 
                        MOV   R3, '='
                        CALL  StartVerticalPrint

                  ; Print Bottom Line
                        MOV   R1, END_ROW
                        MOV   M[RowIndex], R1
                        MOV   R1, INI_COLUMN
                        MOV   M[ColumnIndex], R1
                        MOV   R1, NUM_COLUMNS
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '='
                        CALL  StartHorizontalPrint
                  
                  ; Print Central Column
                        MOV   R1, WALL_COLUMN_1
                        CALL  PrintCenterColumn
                        MOV   R1, WALL_COLUMN_2
                        CALL  PrintCenterColumn

                  ; Print Ball Way
                        MOV   R1, 7d
                        MOV   M[RowIndex], R1 
                        MOV   R1, 51d
                        MOV   M[ColumnIndex], R1
                        MOV   R1, END_WALL_ROW
                        MOV   M[EndRowIndex], R1 
                        MOV   R3, '|'
                        CALL  StartVerticalPrint
                        MOV   R1, 7d
                        MOV   M[RowIndex], R1 
                        MOV   R1, 52d
                        MOV   M[ColumnIndex], R1
                        MOV   M[EndRowIndex], R1 
                        CALL  StartVerticalPrint

                  ; Print Left Corner
                        MOV   R1, 1d
                        MOV   M[RowIndex], R1
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 29d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        MOV   R1, 2d
                        MOV   M[RowIndex], R1
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 28d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                  ; Print Right Corner
                        MOV   R1, 1d
                        MOV   M[RowIndex], R1
                        MOV   R1, 53d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 55d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        MOV   R1, 2d
                        MOV   M[RowIndex], R1
                        MOV   R1, 54d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 55d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint
                  
                  ; Print Declives (To Optimize)
                        CALL  ImprimeInclinacaoEsq    ; Declividade do lado Esquerdo
                        CALL  ImprimeInclinacaoDir    ; Declividade do lado Direito

                  ; Print Channel (To Optimize)
                        MOV   R1, 5d
                        MOV   M[NumDots], R1
                        MOV   R1, 20d
                        MOV   M[RowIndex], R1         ; Linha 20
                        CALL  ImprimeCanaleta

                        MOV   R1, 21d
                        MOV   M[RowIndex], R1         ; Linha 21
                        CALL  ImprimeCanaleta

                        MOV   R1, 22d
                        MOV   M[RowIndex], R1         ; Linha 22
                        CALL  ImprimeCanaleta

                  ; Simple Trace Sequence
                        MOV   R1, 19d
                        MOV   M[RowIndex], R1
                        MOV   R1, 33d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 37d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '-'
                        CALL  StartHorizontalPrint
                        
                        MOV   R1, 19d
                        MOV   M[RowIndex], R1
                        MOV   R1, 41d
                        MOV   M[ColumnIndex], R1
                        MOV   R1, 45d
                        MOV   M[EndColumnIndex], R1 
                        CALL  StartHorizontalPrint

                  ; Score Printing
                        MOV   R1, 1d
                        MOV   M[RowIndex], R1         ; Linha 1
                        MOV   R1, 2d
                        MOV   M[ColumnIndex], R1      ; Linha 1
                        CALL  StartScore
                  ; Lifes Printing
                        MOV   R1, 2d
                        MOV   M[RowIndex], R1         ; Linha 1
                        MOV   R1, 2d
                        MOV   M[ColumnIndex], R1      ; Linha 1
                        CALL  StartLife
                  POP   R3
                  POP   R1
                  RET

;------------------------------------------------------------------------------
; Function Main
;------------------------------------------------------------------------------
Main:	      ENI                           ; Initialization
            MOV	R1, INITIAL_SP
            MOV	SP, R1		      ; We need to initialize the stack
            MOV	R1, CURSOR_INIT	      ; We need to initialize the cursor 
            MOV	M[ CURSOR ], R1	      ; with value CURSOR_INIT

            CALL StartScreen

Cycle: 	BR		Cycle	
Halt:       BR		Halt