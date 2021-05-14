;------------------------------------------------------------------------------
; ZONA I: Constants
;------------------------------------------------------------------------------
      
      ATIV_TEMP               EQU         FFF7h
      CONFIG_TEMP             EQU         FFF6h
      CURSOR		      EQU         FFFCh
      CURSOR_INIT		      EQU	      FFFFh
      END_COLUMN			EQU		79d
      END_LFU_ROW             EQU		16d
      END_LFD_ROW             EQU		22d      
      END_RFU_ROW             EQU		16d
      END_RFD_ROW             EQU		22d
      END_ROW			EQU		23d
      END_WALL_ROW		EQU		23d
      INI_COLUMN			EQU		0d
      FIM_TEXTO               EQU         '@'
      INI_ROW			EQU		0d
      INITIAL_SP              EQU         FDFFh
      LF_COL_START            EQU         33d
      LF_ROW_START            EQU         19d
      NUM_COLUMNS		      EQU	      80d
      NUM_ROWS		      EQU	      24d
      OFF                     EQU         0d
      ON                      EQU         1d
      RF_COL_START            EQU         44d
      RF_ROW_START            EQU         19d
      ROW_SHIFT			EQU		8d
      START_BALL_COL          EQU         53d
      START_BALL_ROW          EQU         22d
      WALL_COLUMN_1		EQU		21d
      WALL_COLUMN_2		EQU		55d
      WALL_ROW			EQU		1d
      WRITE                   EQU         FFFEh

;------------------------------------------------------------------------------
; ZONA II: Variables
;------------------------------------------------------------------------------
                              ORIG        8000h
      BallColumnIndex         WORD        53d
      BallRowIndex            WORD        22d
      ColumnIndex             WORD        0d
      LifeText		      STR         'LIFES: 3', FIM_TEXTO
      RowIndex                WORD        0d
      ScoreText		      STR         'SCORE: 0', FIM_TEXTO
      EndColumnIndex          WORD        0d
      EndRowIndex             WORD        0d
      LeftFlipperUp           WORD        OFF
      RightFlipperUp          WORD        OFF
      PosVerified             WORD        OFF
      PosX                    WORD        0d
      PosY                    WORD        0d
      VerifyRow               WORD        OFF   ; Variables to identify if the row is in the position analyzed
      VerifyColumn            WORD        OFF   ; Variables to identify if the column is in the position analyzed
      InRUDM                  WORD        OFF   ; In Right Up Diagonal Movement
      InRDDM                  WORD        OFF   ; In Right Down Diagonal Movement
      InLUDM                  WORD        OFF   ; In Left Up Diagonal Movement
      InLDDM                  WORD        OFF   ; In Left Down Diagonal Movement
      InRSM                   WORD        OFF   ; In Right Movement
      InDSM                   WORD        OFF   ; In Down Movement
      InLSM                   WORD        OFF   ; In Left Movement
      InUSM                   WORD        OFF   ; In Up Movement

;------------------------------------------------------------------------------
; ZONA III: Interruption
;------------------------------------------------------------------------------

                  ORIG    FE00h
      INT0        WORD    MoveLeftFlipper
      INT1        WORD    MoveRightFlipper
      INT2        WORD    StartGame

                  ORIG    FE0Fh
      INT15       WORD    Timer

;------------------------------------------------------------------------------
; ZONA IV: Functions
;------------------------------------------------------------------------------
      ORIG  0000h                   ; Inicializa programa na posição
      JMP   Main                    ; Salta para a função inicial

;------------------------------------------------------------------------------
; Function StartGame - Define Timer after Interruption
;------------------------------------------------------------------------------
      StartGame:        CALL  SetTimer
                        RTI

;------------------------------------------------------------------------------
; Function Row Ball Index Verification
;------------------------------------------------------------------------------
      IsInRowY:   PUSH  R1
                  PUSH  R2
                  MOV   R1, M[BallRowIndex]
                  MOV   R2, M[PosY]
                  CMP   R1, R2
                  JMP.NZ EndVerificationRow
                  MOV   R1, ON
                  MOV   M[VerifyRow], R1
                  JMP   EndVerificationRow

      EndVerificationRow:     POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Function Column Ball Index Verification
;------------------------------------------------------------------------------
      IsInColX:   PUSH  R1
                  PUSH  R2
                  MOV   R1, M[BallColumnIndex]
                  MOV   R2, M[PosX]
                  CMP   R1, R2
                  JMP.NZ EndVerificationCol
                  MOV   R1, ON
                  MOV   M[VerifyColumn], R1
                  MOV   M[PosVerified], R1

                  ; Inverting Movements
                  MOV   R1, M[InRDDM]
                  MOV   R2, M[InLDDM]
                  MOV   M[InRDDM], R2
                  MOV   M[InLDDM], R1
                  MOV   R1, M[InLUDM]
                  MOV   R2, M[InRUDM]
                  MOV   M[InLUDM], R2
                  MOV   M[InRUDM], R1
                  JMP   EndVerificationCol

      EndVerificationCol:     POP   R2
                              POP   R1
                              RET    

;------------------------------------------------------------------------------
; Function Verifying Ball Position
;------------------------------------------------------------------------------
      VerifyRightCornerHit:   PUSH   R1
                              MOV    R1, OFF
                              MOV    M[InLDDM], R1    
                              MOV    R1, M[BallColumnIndex]
                              CMP    R1, START_BALL_COL
                              JMP.NZ VerificationEnd        ; Verify if is in the initial column
                              MOV    R1, M[BallRowIndex]
                              CMP    R1, 2d                 ; Second row
                              JMP.NZ VerificationEnd        ; Verify if hit the upper right corner
                              MOV    R1, ON
                              MOV    M[InLDDM], R1
      
      VerificationEnd:        POP   R1
                              RET

      WhichColumnIsTheBall:   PUSH  R1
                              PUSH  R2                              

                              MOV   R2, 46d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndColumnSearch

                              MOV   R2, 50d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndColumnSearch
                              
      EndColumnSearch:        POP   R2
                              POP   R1
                              RET  

      VerifyingColObstacle1:  PUSH  R1
                              PUSH  R2

                              MOV   R1, ON

                              MOV   R2, 36d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb1

                              MOV   R2, 37d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb1

                              MOV   R2, 38d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb1

      EndVerifyingColOb1:     POP   R2
                              POP   R1
                              RET
      
      VerifyingRowObstacle1:  PUSH  R1
                              PUSH  R2

                              ; Row Range => [14 - 16]
                              ; Column Range => [36 - 38]

                              MOV   R1, ON

                              MOV   R2, 14d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle1
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb1

                              MOV   R2, 15d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle1
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb1

                              MOV   R2, 16d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle1
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb1

      EndVerifyingRowOb1:     POP   R2
                              POP   R1
                              RET

      VerifyingColObstacle2:  PUSH  R1
                              PUSH  R2

                              MOV   R1, ON

                              MOV   R2, 42d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb2

                              MOV   R2, 43d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb2

                              MOV   R2, 44d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb2

                              MOV   R2, 45d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb2
                              
                              MOV   R2, 46d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb2

      EndVerifyingColOb2:     POP   R2
                              POP   R1
                              RET
      
      VerifyingRowObstacle2:  PUSH  R1
                              PUSH  R2

                              ; Row Range => [9 - 11]
                              ; Column Range => [42 - 46]

                              MOV   R1, ON

                              MOV   R2, 9d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle2
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb2

                              MOV   R2, 10d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle2
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb2

                              MOV   R2, 11d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle2
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb2

      EndVerifyingRowOb2:     POP   R2
                              POP   R1
                              RET

      VerifyingColObstacle3:  PUSH  R1
                              PUSH  R2

                              MOV   R1, ON

                              MOV   R2, 32d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb3

                              MOV   R2, 33d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb3

                              MOV   R2, 34d
                              MOV   M[PosX], R2
                              CALL  IsInColX
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingColOb3

      EndVerifyingColOb3:     POP   R2
                              POP   R1
                              RET

      VerifyingRowObstacle3:  PUSH  R1
                              PUSH  R2

                              ; Row Range => [4 - 6]
                              ; Column Range => [32 - 34]

                              MOV   R1, ON

                              MOV   R2, 4d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle3
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb3

                              MOV   R2, 5d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle3
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb3

                              MOV   R2, 6d
                              MOV   M[PosY], R2
                              CALL  IsInRowY
                              CMP   M[VerifyRow], R1
                              CALL.Z VerifyingColObstacle3
                              CMP   M[VerifyColumn], R1
                              JMP.Z EndVerifyingRowOb3

      EndVerifyingRowOb3:     POP   R2
                              POP   R1
                              RET

      VerifyingColRightWall1:       PUSH  R1
                                    PUSH  R2

                                    MOV   R1, ON
                                    MOV   R2, 50d
                                    MOV   M[PosX], R2
                                    CALL  IsInColX
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingColRightWall1

      EndVerifyingColRightWall1:    POP   R2
                                    POP   R1
                                    RET

      VerifyingRowRightWall1:       PUSH  R1
                                    PUSH  R2

                                    ; Row Range => [7 - 14]
                                    ; Column Range => [50]

                                    MOV   R1, ON

                                    MOV   R2, 7d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

                                    MOV   R2, 8d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

                                    MOV   R2, 9d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

                                    MOV   R2, 10d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

                                    MOV   R2, 11d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

                                    MOV   R2, 12d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

                                    MOV   R2, 13d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1
                                    
                                    MOV   R2, 14d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall1
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall1

      EndVerifyingRowRightWall1:    POP   R2
                                    POP   R1
                                    RET

      VerifyingColRightWall2:       PUSH  R1
                                    PUSH  R2

                                    MOV   R1, ON
                                    MOV   R2, 54d
                                    MOV   M[PosX], R2
                                    CALL  IsInColX
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingColRightWall2

      EndVerifyingColRightWall2:    POP   R2
                                    POP   R1
                                    RET

      VerifyingRowRightWall2:       PUSH  R1
                                    PUSH  R2

                                    ; Row Range => [3 - 6]
                                    ; Column Range => [54]

                                    MOV   R1, ON

                                    MOV   R2, 3d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall2
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall2

                                    MOV   R2, 4d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall2
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall2

                                    MOV   R2, 5d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall2
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall2

                                    MOV   R2, 6d
                                    MOV   M[PosY], R2
                                    CALL  IsInRowY
                                    CMP   M[VerifyRow], R1
                                    CALL.Z VerifyingColRightWall2
                                    CMP   M[VerifyColumn], R1
                                    JMP.Z EndVerifyingRowRightWall2

      EndVerifyingRowRightWall2:    POP   R2
                                    POP   R1
                                    RET

      InWhichRowIsTheBall:    PUSH  R1
                              PUSH  R2
                              
                              CALL  ResetFlags
                              
                              ;--->> Obstacle1 <<---;

                              CALL  ResetFlags
                              CALL  VerifyingRowObstacle1
                              CMP   M[PosVerified], R1
                              JMP.Z EndRowSearch   
                              
                              ;--->> Obstacle2 <<---;

                              CALL  ResetFlags
                              CALL  VerifyingRowObstacle2
                              CMP   M[PosVerified], R1
                              JMP.Z EndRowSearch   

                              ;--->> Obstacle3 <<---;

                              CALL  ResetFlags
                              CALL  VerifyingRowObstacle3
                              CMP   M[PosVerified], R1
                              JMP.Z EndRowSearch                              

                              ;--->> Right Wall <<---;

                              CALL  ResetFlags
                              CALL  VerifyingRowRightWall1
                              CMP   M[PosVerified], R1
                              JMP.Z EndRowSearch   

                              CALL  ResetFlags
                              CALL  VerifyingRowRightWall2
                              CMP   M[PosVerified], R1
                              JMP.Z EndRowSearch
                              
      EndRowSearch:           POP   R2
                              POP   R1
                              RET

      ResetFlags:             PUSH  R1
                              MOV   R1, OFF
                              MOV   M[VerifyRow], R1
                              MOV   M[VerifyColumn], R1
                              MOV   M[PosVerified], R1
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Function Ball movements
;------------------------------------------------------------------------------
      StartBallMoves:   DEC   M[BallRowIndex]
                        CALL  VerifyRightCornerHit
                        JMP   EndMoveBall

      LeDoDiagonalMove: DEC   M[BallColumnIndex]      ; Left Down Diagonal Movement
                        INC   M[BallRowIndex]
                        JMP   EndMoveBall

      RiDoDiagonalMove: INC   M[BallColumnIndex]      ; Right Down Diagonal Movement
                        INC   M[BallRowIndex]
                        JMP   EndMoveBall

      LeUpDiagonalMove: DEC   M[BallColumnIndex]      ; Left Up Diagonal Movement
                        DEC   M[BallRowIndex]
                        JMP   EndMoveBall

      RiUpDiagonalMove: INC   M[BallColumnIndex]      ; Right Up Diagonal Movement
                        DEC   M[BallRowIndex]
                        JMP   EndMoveBall

      ResetBall:        PUSH  R1
                        PUSH  R2
                        PUSH  R3

                        MOV   R1, M[BallRowIndex]
                        MOV   R2, M[BallColumnIndex]
                        MOV   R3, '='
                        SHL   R1, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[CURSOR], R1
                        MOV   M[WRITE], R3

                        MOV   R1, OFF
                        MOV   M[ATIV_TEMP], R1
                        MOV   M[CONFIG_TEMP], R1
                        MOV   M[InRUDM], R1
                        MOV   M[InRDDM], R1
                        MOV   M[InLUDM], R1
                        MOV   M[InLDDM], R1
                        MOV   M[BallRowIndex], R1
                        MOV   M[BallColumnIndex], R1

                        POP   R3
                        POP   R2
                        POP   R1
                        JMP   EndMoveBall
      
      MoveBall:         PUSH  R1

                        MOV   R1, M[BallRowIndex]
                        CMP   R1, END_ROW
                        JMP.Z ResetBall
                        
                        CALL  InWhichRowIsTheBall

                        MOV   R1, M[InRUDM]
                        CMP   R1, ON
                        JMP.Z RiUpDiagonalMove

                        MOV   R1, M[InRDDM]
                        CMP   R1, ON
                        JMP.Z RiDoDiagonalMove

                        MOV   R1, M[InLUDM]
                        CMP   R1, ON
                        JMP.Z LeUpDiagonalMove

                        MOV   R1, M[InLDDM]
                        CMP   R1, ON
                        JMP.Z LeDoDiagonalMove

                        MOV   R1, M[BallColumnIndex]
                        CMP   R1, START_BALL_COL
                        JMP.Z StartBallMoves

      EndMoveBall:      POP   R1
                        RET
;------------------------------------------------------------------------------
; Function Timer - Define ball timer and basic functions
;------------------------------------------------------------------------------
      SetTimer:         PUSH  R1
                        MOV   R1, ON                  ; Set Timer time
                        MOV   M[CONFIG_TEMP], R1
                        MOV   R1, ON                  ; Set Timer status
                        MOV   M[ATIV_TEMP], R1
                        POP   R1
                        RET

      PrintBall:        PUSH  R1
                        PUSH  R2
                        PUSH  R3

                        MOV   R1, M[BallRowIndex]
                        MOV   R2, M[BallColumnIndex]
                        MOV   R3, 'o'
                        SHL   R1, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[CURSOR], R1
                        MOV   M[WRITE], R3

                        POP   R3
                        POP   R2
                        POP   R1
                        RET

      ClearBall:        PUSH  R1
                        PUSH  R2
                        PUSH  R3

                        MOV   R1, M[BallRowIndex]
                        MOV   R2, M[BallColumnIndex]
                        MOV   R3, ' '
                        SHL   R1, ROW_SHIFT
                        OR    R1, R2
                        MOV   M[CURSOR], R1
                        MOV   M[WRITE], R3

                        POP   R3
                        POP   R2
                        POP   R1
                        RET

      Timer:            PUSH  R1
                        PUSH  R2
                        PUSH  R3                                                      

                        CALL  ClearBall
                        CALL  MoveBall
                        CALL  PrintBall

                        CALL  SetTimer                ; Reset timer

                        MOV   R1, M[BallColumnIndex]
                        CMP   R1, OFF
                        JMP.NZ EndTimer

                        MOV   R1, 53d
                        MOV   M[BallRowIndex], R1
                        MOV   R1, 22d
                        MOV   M[BallColumnIndex], R1

      EndTimer:         POP   R3
                        POP   R2
                        POP   R1
                        RTI

;------------------------------------------------------------------------------
; Function MoveLeftFlipperUp
;------------------------------------------------------------------------------
      StartClearLFD:          PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              MOV   R1, LF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, LF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, ' '

      ClearLFD:               MOV   R1, M[RowIndex]
                              CMP   R1, END_LFD_ROW
                              JMP.Z EndClearLFD
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              INC   M[RowIndex]       ; From 19d to 21d
                              INC   M[ColumnIndex]    ; From 33d to 35d
                              JMP   ClearLFD            
      
      EndClearLFD:            POP   R3
                              POP   R2
                              POP   R1   
                              RET

      StartMoveLFU:           PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              ; Clear the old flipper printing
                              CALL  StartClearLFD

                              ; Setting coordinates to print flipper to down
                              MOV   R1, LF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, LF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, '/'

      MoveLeftFlipperUp:      MOV   R1, M[RowIndex]
                              CMP   R1, END_LFU_ROW                                          
                              JMP.Z EndMoveLFU
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              DEC   M[RowIndex]       ; From 19d to 16d
                              INC   M[ColumnIndex]    ; From 33d to 35d
                              JMP   MoveLeftFlipperUp

      EndMoveLFU:             MOV   R1, ON
                              MOV   M[LeftFlipperUp], R1
                              POP   R3
                              POP   R2
                              POP   R1   
                              RET

;------------------------------------------------------------------------------
; Function MoveLeftFlipperDown
;------------------------------------------------------------------------------
      StartClearLFU:          PUSH  R1
                              PUSH  R2
                              PUSH  R3
                              MOV   R1, LF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, LF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, ' '

      ClearLFU:               MOV   R1, M[RowIndex]
                              CMP   R1, END_LFU_ROW                                          
                              JMP.Z EndClearLFU
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              DEC   M[RowIndex]       ; From 19d to 17d
                              INC   M[ColumnIndex]    ; From 33d to 35d
                              JMP   ClearLFU            
      
      EndClearLFU:            POP   R3
                              POP   R2
                              POP   R1   
                              RET

      StartMoveLFD:           PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              ; Clear the old flipper printing
                              CALL  StartClearLFU

                              ; Setting coordinates to print flipper to up
                              MOV   R1, LF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, LF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, '\'

      MoveLeftFlipperDown:    MOV   R1, M[RowIndex]
                              CMP   R1, END_LFD_ROW
                              JMP.Z EndMoveLFD
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              INC   M[RowIndex]       ; From 19d to 21d
                              INC   M[ColumnIndex]    ; From 33d to 35d
                              JMP   MoveLeftFlipperDown

      EndMoveLFD:             MOV   R1, OFF
                              MOV   M[LeftFlipperUp], R1
                              POP   R3
                              POP   R2
                              POP   R1   
                              RET

;------------------------------------------------------------------------------
; Function MoveLeftFlipper (main)
;------------------------------------------------------------------------------
      MoveLeftFlipper:        PUSH  R1
                              MOV   R1, M[LeftFlipperUp]
                              CMP   R1, ON
                              CALL.Z  StartMoveLFD     ; Print Left Flipper to Down
                              CALL.NZ StartMoveLFU     ; Print Left Flipper to Up
                              POP   R1
                              RTI

;------------------------------------------------------------------------------
; Function MoveRightFlipperUp
;------------------------------------------------------------------------------
      StartClearRFD:          PUSH  R1
                              PUSH  R2
                              PUSH  R3
                              MOV   R1, RF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, RF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, ' '

      ClearRFD:               MOV   R1, M[RowIndex]
                              CMP   R1, END_RFD_ROW
                              JMP.Z EndClearRFD
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              INC   M[RowIndex]       ; From 19d to 21d
                              DEC   M[ColumnIndex]    ; From 44d to 42d
                              JMP   ClearRFD            
      
      EndClearRFD:            POP   R3
                              POP   R2
                              POP   R1   
                              RET

      StartMoveRFU:           PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              ; Clear the old flipper printing
                              CALL  StartClearRFD

                              ; Set coordinates to print flipper to down
                              MOV   R1, RF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, RF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, '\'

      MoveRightFlipperUp:     MOV   R1, M[RowIndex]
                              CMP   R1, END_RFU_ROW                                          
                              JMP.Z EndMoveRFU
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              DEC   M[RowIndex]       ; From 19d to 17d
                              DEC   M[ColumnIndex]    ; From 44d to 42d
                              JMP   MoveRightFlipperUp

      EndMoveRFU:             MOV   R1, ON
                              MOV   M[RightFlipperUp], R1
                              POP   R3
                              POP   R2
                              POP   R1   
                              RET

;------------------------------------------------------------------------------
; Function MoveRightFlipperDown
;------------------------------------------------------------------------------
      StartClearRFU:          PUSH  R1
                              PUSH  R2
                              PUSH  R3
                              MOV   R1, RF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, RF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, ' '

      ClearRFU:               MOV   R1, M[RowIndex]
                              CMP   R1, END_RFU_ROW                                          
                              JMP.Z EndClearRFU
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              DEC   M[RowIndex]       ; From 19d to 17d
                              DEC   M[ColumnIndex]    ; From 44d to 42d
                              JMP   ClearRFU            
      
      EndClearRFU:            POP   R3
                              POP   R2
                              POP   R1   
                              RET

      StartMoveRFD:           PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              ; Clear the old flipper printing
                              CALL  StartClearRFU

                              ; Set coordinates to print flipper to up
                              MOV   R1, RF_ROW_START
                              MOV   M[RowIndex], R1
                              MOV   R1, RF_COL_START
                              MOV   M[ColumnIndex], R1
                              MOV   R3, '/'

      MoveRightFlipperDown:   MOV   R1, M[RowIndex]
                              CMP   R1, END_RFD_ROW
                              JMP.Z EndMoveRFD
                              MOV   R1, M[RowIndex]
                              MOV   R2, M[ColumnIndex]
                              SHL   R1, ROW_SHIFT
                              OR    R1, R2
                              MOV   M[CURSOR], R1
                              MOV   M[WRITE], R3
                              INC   M[RowIndex]       ; From 19d to 21d
                              DEC   M[ColumnIndex]    ; From 44d to 42d
                              JMP   MoveRightFlipperDown

      EndMoveRFD:             MOV   R1, OFF
                              MOV   M[RightFlipperUp], R1
                              POP   R3
                              POP   R2
                              POP   R1   
                              RET

;------------------------------------------------------------------------------
; Function MoveRightFlipper (main)
;------------------------------------------------------------------------------
      MoveRightFlipper:       PUSH  R1
                              MOV   R1, M[RightFlipperUp]
                              CMP   R1, ON
                              CALL.Z  StartMoveRFD
                              CALL.NZ StartMoveRFU
                              POP   R1
                              RTI

;------------------------------------------------------------------------------
; Function Printing Center Column
;------------------------------------------------------------------------------
      PrintCenterColumn:      PUSH  R1
                              PUSH  R2
                              PUSH  R3

                              MOV   R3, '|'
                              MOV   R2, END_WALL_ROW
                              MOV   M[EndRowIndex], R2 
                              MOV   R2, WALL_ROW
                              MOV   M[RowIndex], R2
                              MOV   M[ColumnIndex], R1
                              CALL  StartVerticalPrint

                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              MOV   R3, '.'
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              MOV   R3, '|'
                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              MOV   M[RowIndex], R2
                              INC   M[ColumnIndex]
                              CALL  StartVerticalPrint

                              POP   R3
                              POP   R2
                              POP   R1
                              RET

;------------------------------------------------------------------------------
; Function Printing Obstacle
;------------------------------------------------------------------------------
      PrintObstacle:    PUSH  R1
                        PUSH  R2
                        PUSH  R3
                        PUSH  R4

                        ; Save original index
                        MOV   R2, M[RowIndex]
                        MOV   R4, M[ColumnIndex]
                        MOV   R5, M[EndColumnIndex]
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        ; Increment and restore index
                        INC   R2
                        MOV   M[RowIndex], R2
                        MOV   M[ColumnIndex], R4 
                        MOV   M[EndColumnIndex], R5 
                        CALL  StartHorizontalPrint

                        ; Repeat the process
                        INC   R2
                        MOV   M[RowIndex], R2
                        MOV   M[ColumnIndex], R4 
                        MOV   M[EndColumnIndex], R5 
                        CALL  StartHorizontalPrint

                        POP   R4
                        POP   R3
                        POP   R2
                        POP   R1
                        RET

;------------------------------------------------------------------------------
; Function PrintChannel - Print Central Channel
;------------------------------------------------------------------------------
      PrintChannel:     PUSH  R1    ; Coluna
                        PUSH  R3    ; Caracter / Auxiliar

                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 32d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        INC   M[EndColumnIndex] 
                        MOV   R3, '|'
                        CALL  StartHorizontalPrint

                        MOV   R1, 45d
                        MOV   M[ColumnIndex], R1
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '|'
                        CALL  StartHorizontalPrint

                        MOV   R1, 51d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        POP   R3
                        POP   R1
                        RET

;------------------------------------------------------------------------------
; Function PrintLeftSlope - Print the Left slope
;------------------------------------------------------------------------------
      PrintLeftSlope:   PUSH  R1

                        MOV   R1, 14d
                        MOV   M[RowIndex], R1
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        MOV   R1, 28d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 29d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        MOV   R1, 29d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 30d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        MOV   R1, 30d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 31d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        MOV   R1, 31d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 27d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 32d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        MOV   R1, 32d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        POP   R1
                        RET

;------------------------------------------------------------------------------
; Function PrintRightSlope - Print the Right slope
;------------------------------------------------------------------------------
      PrintRightSlope:  PUSH  R1

                        MOV   R1, 14d
                        MOV   M[RowIndex], R1
                        MOV   R1, 50d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 49d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint
                        MOV   R1, 50d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 48d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint
                        MOV   R1, 49d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 51d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 47d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint
                        MOV   R1, 48d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 51d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 46d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint
                        MOV   R1, 47d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 51d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

                        INC   M[RowIndex]
                        MOV   R1, 45d
                        MOV   M[ColumnIndex], R1 
                        INC   R1
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '#'
                        CALL  StartHorizontalPrint
                        MOV   R1, 46d
                        MOV   M[ColumnIndex], R1 
                        MOV   R1, 51d
                        MOV   M[EndColumnIndex], R1 
                        MOV   R3, '.'
                        CALL  StartHorizontalPrint

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
                              PUSH  R3

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
                              MOV   R1, END_WALL_ROW
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
                        
                        ; Print Obstacles
                              MOV   R1, 4d
                              MOV   M[RowIndex], R1
                              MOV   R1, 32d
                              MOV   M[ColumnIndex], R1 
                              MOV   R1, 35d
                              MOV   M[EndColumnIndex], R1 
                              CALL  PrintObstacle

                              MOV   R1, 9d
                              MOV   M[RowIndex], R1
                              MOV   R1, 43d
                              MOV   M[ColumnIndex], R1 
                              MOV   R1, 46d
                              MOV   M[EndColumnIndex], R1 
                              CALL  PrintObstacle

                              MOV   R1, 14d
                              MOV   M[RowIndex], R1
                              MOV   R1, 36d
                              MOV   M[ColumnIndex], R1 
                              MOV   R1, 39d
                              MOV   M[EndColumnIndex], R1 
                              CALL  PrintObstacle

                        ; Print Slopes
                              CALL  PrintLeftSlope     ; Left slope
                              CALL  PrintRightSlope    ; Right slope

                        ; Print Channel
                              MOV   R1, 20d
                              MOV   M[RowIndex], R1
                              CALL  PrintChannel

                              INC   M[RowIndex]
                              CALL  PrintChannel

                              INC   M[RowIndex]
                              CALL  PrintChannel

                        ; Print Flippers
                              CALL  StartMoveLFD
                              CALL  StartMoveRFD

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
                              MOV   M[ColumnIndex], R1      ; Coluna 1
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
                  CALL  StartScreen             ; Print screen components

      Cycle: 	BR		Cycle	
      Halt:       BR		Halt