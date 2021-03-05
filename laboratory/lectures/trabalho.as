;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;------------------------------------------------------------------------------
WRITE                   EQU         FFFEh
INITIAL_SP              EQU         FDFFh
CURSOR		      EQU         FFFCh
CURSOR_INIT		      EQU	      FFFFh
NUM_COLUMNS		      EQU	      80d
NUM_ROWS		      EQU	      24d
ROW_SHIFT			EQU		8d
INI_COLUMN			EQU		0d
INI_ROW			EQU		0d
END_COLUMN			EQU		79d
END_ROW			EQU		23d
WALL_COLUMN_1		EQU		21d
WALL_COLUMN_2		EQU		55d
WALL_ROW			EQU		1d
END_WALL_COLUMN		EQU		79d
END_WALL_ROW		EQU		23d

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;------------------------------------------------------------------------------
            ORIG        8000h
RowIndex    WORD        0d
ColumnIndex WORD        0d
TextIndex   WORD        0d

;------------------------------------------------------------------------------
; ZONA IV: instruções
;------------------------------------------------------------------------------
      ORIG  0000h                   ; Inicializa programa na posição
      JMP   Main                    ; Salta para a função inicial

;------------------------------------------------------------------------------
; Função ImprimeColuna - Impressão da Coluna
;------------------------------------------------------------------------------
ImprimeColuna:          PUSH  R1
                        PUSH  R2
                        PUSH  R3
      
CicloImprimeColuna:     MOV   R1, M[ ColumnIndex ]    ; R1 Recebe valor do índice da coluna
                        MOV   R2, M[ RowIndex ]       ; R2 Recebe valor do índice da linha
                        CMP   R2, NUM_ROWS            ; Verifica se o índice das linhas já chegou ao limite
                        JMP.Z FimImprimeColuna        ; Finaliza se o número de colunas for igual a NUM_ROWS
                        MOV   R3, '='                 ; Move o caracter '=' para R3
                        SHL   R2, ROW_SHIFT           ; Move índice da linha para esquerda
                        OR    R1, R2                  ; Soma ambos os índices: ex.: [R2|R1] 01000010|00011100
                        MOV   M[ CURSOR ], R1         ; Move R1 to cursor address
                        MOV   M[ WRITE ], R3          ; Imprime o valor de R3 na tela
                        INC   M[ RowIndex ]           ; Incrementa o índice das linhas
                        JMP   CicloImprimeColuna      ; Chama a função novamente

FimImprimeColuna:       POP   R1
                        POP   R2
                        POP   R3 
                        RET                           ; RTI = Return from interruption (restaura o valor do PC no final da instrução e o valor do ALU)

;------------------------------------------------------------------------------
; Função ImprimeLinha - Impressão da Linha
;------------------------------------------------------------------------------
ImprimeLinha:           PUSH  R1
                        PUSH  R2
                        PUSH  R3
      
CicloImprimeLinha:      MOV   R1, M[ ColumnIndex ]                ; R1 Recebe valor do índice da coluna
                        MOV   R2, M[ RowIndex ]                   ; R2 Recebe valor do índice da linha
                        CMP   R1, NUM_COLUMNS                     ; Verifica se o índice das linhas já chegou ao limite
                        JMP.Z FimImprimeLinha                     ; Finaliza se o número de colunas for igual a NUM_COLUMNS
                        MOV   R3, '='                             ; Move o caracter '=' para R3
                        SHL   R2, ROW_SHIFT                       ; Move índice da linha para esquerda
                        OR    R1, R2                              ; Soma ambos os índices: ex.: [R2|R1] 01000010|00011100
                        MOV   M[ CURSOR ], R1                     ; Move R1 to cursor address
                        MOV   M[ WRITE ], R3                      ; Imprime o valor de R3 na tela
                        INC   M[ ColumnIndex ]                    ; Incrementa o índice das linhas
                        JMP   CicloImprimeLinha                   ; Chama a função novamente

FimImprimeLinha:        POP   R1
                        POP   R2
                        POP   R3 
                        RET                                       ; RTI = Return from interruption (restaura o valor do PC no final da instrução e o valor do ALU)

;------------------------------------------------------------------------------
; Função ImprimeParede - Impressão da Parede
;------------------------------------------------------------------------------
ImprimeParede:          PUSH  R1
                        PUSH  R2
                        PUSH  R3
      
CicloImprimeParede:     MOV   R1, M[ ColumnIndex ]    ; R1 Recebe valor do índice da coluna
                        MOV   R2, M[ RowIndex ]       ; R2 Recebe valor do índice da linha
                        CMP   R2, END_WALL_ROW        ; Verifica se o índice das linhas já chegou ao limite
                        JMP.Z FimImprimeParede        ; Finaliza se o número de colunas for igual a END_WALL_ROW
                        MOV   R3, '|'                 ; Move o caracter '|' para R3
                        SHL   R2, ROW_SHIFT           ; Move índice da linha para esquerda
                        OR    R1, R2                  ; Soma ambos os índices: ex.: [R2|R1] 01000010|00011100
                        MOV   M[ CURSOR ], R1         ; Move R1 to cursor address
                        MOV   M[ WRITE ], R3          ; Imprime o valor de R3 na tela
                        INC   M[ RowIndex ]           ; Incrementa o índice das linhas
                        JMP   CicloImprimeParede      ; Chama a função novamente

FimImprimeParede:       POP   R1
                        POP   R2
                        POP   R3 
                        RET 

;------------------------------------------------------------------------------
; Função ICP - Impressão da coluna de preencimento da parede
;------------------------------------------------------------------------------
ICP:                    PUSH  R1
                        PUSH  R2
                        PUSH  R3
      
CicloICP:               MOV   R1, M[ ColumnIndex ]    ; R1 Recebe valor do índice da coluna
                        MOV   R2, M[ RowIndex ]       ; R2 Recebe valor do índice da linha
                        CMP   R2, END_WALL_ROW        ; Verifica se o índice das linhas já chegou ao limite
                        JMP.Z FimICP                  ; Finaliza se o número de colunas for igual a END_WALL_ROW
                        MOV   R3, '.'                 ; Move o caracter '.' para R3
                        SHL   R2, ROW_SHIFT           ; Move índice da linha para esquerda
                        OR    R1, R2                  ; Soma ambos os índices: ex.: [R2|R1] 01000010|00011100
                        MOV   M[ CURSOR ], R1         ; Move R1 to cursor address
                        MOV   M[ WRITE ], R3          ; Imprime o valor de R3 na tela
                        INC   M[ RowIndex ]           ; Incrementa o índice das linhas
                        JMP   CicloICP                ; Chama a função novamente

FimICP:                 POP   R1
                        POP   R2
                        POP   R3 
                        RET 
;------------------------------------------------------------------------------
; Função ImprimeColunaCentral - Imprime Coluna Central
;------------------------------------------------------------------------------
CicloImprimeColunaCental:     PUSH  R4
                              PUSH  R5
                              MOV   R4, WALL_ROW
                              MOV   M[RowIndex], R4
                              MOV   R4, R5
                              MOV   M[ColumnIndex], R4
                              CALL  ImprimeParede            ; Imprime Parede

                              MOV   R4, WALL_ROW
                              MOV   M[RowIndex], R4
                              INC   M[ColumnIndex]
                              CALL  ImprimeParede            ; Imprime Parede

                              MOV   R4, WALL_ROW
                              MOV   M[RowIndex], R4
                              INC   M[ColumnIndex]
                              CALL  ICP                     ; Imprime Preencimento da Coluna

                              MOV   R4, WALL_ROW
                              MOV   M[RowIndex], R4
                              INC   M[ColumnIndex]
                              CALL  ICP                     ; Imprime Preencimento da Coluna

                              MOV   R4, WALL_ROW
                              MOV   M[RowIndex], R4
                              INC   M[ColumnIndex]
                              CALL  ImprimeParede            ; Imprime Parede

                              MOV   R4, WALL_ROW
                              MOV   M[RowIndex], R4
                              INC   M[ColumnIndex]
                              CALL  ImprimeParede            ; Imprime Parede

                              POP   R4
                              POP   R5
                              RET

;------------------------------------------------------------------------------
; Função ImprimeCaminhoBola - Imprime Caminho da Bola
;------------------------------------------------------------------------------
ImprimeCaminhoBola:     PUSH  R4
                        PUSH  R5
                        MOV   R4, 7d
                        MOV   M[RowIndex], R4
                        MOV   R4, R5
                        MOV   M[ColumnIndex], R4
                        CALL  ImprimeParede            ; Imprime Parede

                        MOV   R4, 7d
                        MOV   M[RowIndex], R4
                        INC   R5
                        MOV   R4, R5
                        MOV   M[ColumnIndex], R4
                        CALL  ImprimeParede            ; Imprime Parede

                        POP   R4
                        POP   R5
                        RET

;------------------------------------------------------------------------------
; Função ImprimeCantoEsquerdo - Imprime Canto Superior Esquerdo
;------------------------------------------------------------------------------
ImprimeCantoEsquerdo:   PUSH  R1
                        PUSH  R2
                        PUSH  R3

                        MOV   R1, 27d
                        MOV   R2, 1d
                        MOV   R3, '#'
                        SHL   R2, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[ CURSOR ], R1
                        MOV   M[ WRITE ], R3

                        MOV   R1, 27d
                        MOV   R2, 2d
                        SHL   R2, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[ CURSOR ], R1
                        MOV   M[ WRITE ], R3

                        MOV   R1, 28d
                        MOV   R2, 1d
                        SHL   R2, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[ CURSOR ], R1
                        MOV   M[ WRITE ], R3

                        POP   R1
                        POP   R2
                        POP   R3
                        RET

;------------------------------------------------------------------------------
; Função ImprimeCantoDireito - Imprime Canto Superior Direito
;------------------------------------------------------------------------------
ImprimeCantoDireito:    PUSH  R1
                        PUSH  R2
                        PUSH  R3

                        MOV   R1, 53d
                        MOV   R2, 1d
                        MOV   R3, '#'
                        SHL   R2, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[ CURSOR ], R1
                        MOV   M[ WRITE ], R3

                        MOV   R1, 54d
                        MOV   R2, 1d
                        SHL   R2, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[ CURSOR ], R1
                        MOV   M[ WRITE ], R3

                        MOV   R1, 54d
                        MOV   R2, 2d
                        SHL   R2, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[ CURSOR ], R1
                        MOV   M[ WRITE ], R3

                        POP   R1
                        POP   R2
                        POP   R3
                        RET

;------------------------------------------------------------------------------
; Função Inicializa Tela
;------------------------------------------------------------------------------
InicializaTela:   PUSH  R4
                  PUSH  R5
                  CALL  ImprimeColuna           ; Imprime Coluna
                  
                  MOV   R4, INI_ROW
                  MOV   M[RowIndex], R4
                  CALL  ImprimeLinha            ; Imprime Linha
                  
                  MOV   R4, END_COLUMN
                  MOV   M[ColumnIndex], R4
                  CALL  ImprimeColuna           ; Imprime Coluna
                  
                  MOV   R4, END_ROW
                  MOV   M[RowIndex], R4
                  MOV   R4, INI_COLUMN
                  MOV   M[ColumnIndex], R4
                  CALL  ImprimeLinha            ; Imprime Linha
                  
                  MOV   R5, WALL_COLUMN_1
                  CALL  CicloImprimeColunaCental

                  MOV   R5, WALL_COLUMN_2
                  CALL  CicloImprimeColunaCental

                  MOV   R5, 51d
                  CALL  ImprimeCaminhoBola

                  CALL  ImprimeCantoEsquerdo
                  CALL  ImprimeCantoDireito

                  POP   R4
                  POP   R5
                  RET

;------------------------------------------------------------------------------
; Função Principal
;------------------------------------------------------------------------------
Main:	ENI                           ; Initialization
      MOV	R1, INITIAL_SP
      MOV	SP, R1		      ; We need to initialize the stack
      MOV	R1, CURSOR_INIT	      ; We need to initialize the cursor 
      MOV	M[ CURSOR ], R1	      ; with value CURSOR_INIT

      CALL InicializaTela

Cycle: 	BR		Cycle	
Halt:       BR		Halt