;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
PACMAN			EQU		'C'
INIT_PCCOL		EQU		15d
INIT_PCLIN		EQU		10d
FANTASMA        EQU		'&'
PAREDE			EQU		'#'
VAZIO			EQU		' '
COMIDA			EQU		'.'
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d
TIMER_UNITS		EQU		FFF6h
ACTIVATE_TIMER	EQU		FFF7h
ON				EQU 	1d
OFF				EQU		0d
TIME_TO_WAIT	EQU		3d
RND_MASK		EQU		8016h	; 1000 0000 0001 0110b
LSB_MASK		EQU		0001h	; Mascara para testar o bit menos significativo do Random_Var
PRIME_NUMBER_1	EQU 	11d
PRIME_NUMBER_2	EQU		13d
MOVS_TO_RAND	EQU		4d
POINTS_TO_WIN	EQU		120 ; 694 pts no jogo
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h
Text			STR     'Matheus', FIM_TEXTO
RowIndex		WORD	0d
ColumnIndex		WORD	0d
TextIndex		WORD	0d
L1              STR     '################################################################################', FIM_TEXTO
L2              STR     '################################################################################', FIM_TEXTO
L3              STR     '################################################################################', FIM_TEXTO
L4              STR     '#########################...&.......................############################', FIM_TEXTO
L5              STR     '##################.........................................#####################', FIM_TEXTO
L6              STR     '###############............................######..............#################', FIM_TEXTO
L7              STR     '#############..............................##  ##................###############', FIM_TEXTO
L8              STR     '#########..................................######........########               ', FIM_TEXTO
L9              STR     '#########..........................................######                       ', FIM_TEXTO
L10             STR     '######.......................................&.####                             ', FIM_TEXTO
L11             STR     '######.........C.............................####                               ', FIM_TEXTO
L12             STR     '######.....................................##                  ######     ######', FIM_TEXTO
L13             STR     '######.......................................####              ######     ######', FIM_TEXTO
L14             STR     '######.........................................#####           ######     ######', FIM_TEXTO
L15             STR     '######..............................................####                        ', FIM_TEXTO
L16             STR     '#########.............................................#####                     ', FIM_TEXTO
L17             STR     '#########.&...............................................########              ', FIM_TEXTO
L18             STR     '#############...........................&........................###############', FIM_TEXTO
L19             STR     '###################........................................#####################', FIM_TEXTO
L20             STR     '##########################..........................############################', FIM_TEXTO
L21             STR     '################################################################################', FIM_TEXTO
L22             STR     '################################################################################', FIM_TEXTO
L23             STR     '  SCORE:                                                          VIDAS: C C C  ', FIM_TEXTO
L24             STR     '                                                                                ', FIM_TEXTO
lperdeu			STR		'                        ): VOCE PERDEU! FIM DE JOGO! :(                         ', FIM_TEXTO
lganhou			STR		'                       ^0^ VOCE GANHOU! FIM DE JOGO! ^0^                        ', FIM_TEXTO
pclinha			WORD	10d
pccoluna		WORD	15d
pcend			WORD	0d
estado_anterior WORD	COMIDA ;guarda estado anterior ao fantasma passar, podendo ser uma comida ou vazio
atual_ghostend	WORD	0d
atual_ghostcol	WORD	0d
atual_ghostlin	WORD	0d
fghost_dir		WORD	0d
fghost_esq		WORD	0d
fghost_cima		WORD	0d
fghost_baixo	WORD	0d
I_ghostlinha	WORD	17d
I_ghostcol		WORD	40d
I_ghostend		WORD	0d
I_estanterior	WORD	COMIDA
II_ghostlinha	WORD	3d
II_ghostcol		WORD	28d
II_ghostend		WORD	0d
II_estanterior	WORD	COMIDA
III_ghostlinha	WORD	9d
III_ghostcol	WORD	45d
III_ghostend	WORD	0d
III_estanterior	WORD	COMIDA
IIII_ghostlinha	WORD	16d
IIII_ghostcol	WORD	10d
IIII_ghostend	WORD	0d
IIII_estanterior WORD	COMIDA
score			WORD	0d
cent			WORD	0d
dezn			WORD	0d
unid			WORD	0d
sclinha			WORD	22d 
scoluna			WORD	8d
ascii			WORD	48d
fdir 			WORD    1d
fesq 			WORD	0d 
fcima 			WORD	0d 
fbaixo			WORD	0d 
Random_Var		WORD	A5A5h  ; 1010 0101 1010 0101
RandomState 	WORD	1d
contador		WORD	0d
vidas			WORD	3d
vilin			WORD	22d
vicol			WORD	71d
;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    flag_dir
INT1			WORD	flag_esq
INT2			WORD	flag_cima
INT3			WORD	flag_baixo
				ORIG	FE0Fh
INT15			WORD	Ciclo
;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
; Rotina de Interrupção WriteCharacter
;------------------------------------------------------------------------------
WriteCharacter: PUSH	R1
				PUSH	R2

				MOV		R1, M[ TextIndex ]
				MOV		R1, M[ R1 ]
				CMP 	R1, FIM_TEXTO
				JMP.Z	Halt
				MOV     M[ IO_WRITE ], R1
				INC		M[ RowIndex ]
				INC		M[ ColumnIndex ]
				INC		M[ TextIndex ]
				MOV		R1, M[ RowIndex ]
				MOV		R2, M[ ColumnIndex ]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[ CURSOR ], R1

				POP		R2
				POP		R1
				RTI
;------------------------------------------------------------------------------
; Função: RandomV1 (versão 1)
;
; Random: Rotina que gera um valor aleatório - guardado em M[Random_Var]
; Entradas: M[Random_Var]
; Saidas:   M[Random_Var]
;------------------------------------------------------------------------------

RandomV1:	PUSH	R1

			MOV	R1, LSB_MASK
			AND	R1, M[Random_Var] ; R1 = bit menos significativo de M[Random_Var]
			BR.Z	Rnd_Rotate
			MOV	R1, RND_MASK
			XOR	M[Random_Var], R1

Rnd_Rotate:	ROR	M[Random_Var], 1
			
			POP	R1

			RET

;------------------------------------------------------------------------------
; Random Choice
;
; Irá escolher uma direcao para o fantasma andar de forma aleatória
;------------------------------------------------------------------------------
random_choice:	PUSH	R1
				PUSH	R2

				;CALL	ghost_dir
				CALL	RandomV1
				MOV		R2, M[Random_Var]

				; 4 movimentos possiveis: 1- dir, 2- esq, 3- cima, 4- baixo 
				MOV		R1, 4d
				DIV		R2, R1
				INC		R1

				CMP		R1, 1
				CALL.Z	ghost_dir
				CMP		R1, 2
				CALL.Z  ghost_esq
				CMP		R1, 3
				CALL.Z	ghost_cima
				CMP		R1, 4
				CALL.Z	ghost_baixo

				POP		R2
				POP		R1
				RET
;------------------------------------------------------------------------------
; Ciclo que é executado a cada iteracao do timer
;------------------------------------------------------------------------------
Ciclo:			PUSH 	R1
				PUSH	R2

				MOV		R1, 0
				MOV		R1, M[fesq]
				CMP		R1, ON
				CALL.Z  esquerda
				MOV		R1, M[fdir]
				CMP		R1, ON
				CALL.Z	direita
				MOV		R1, M[fcima]
				CMP		R1, ON
				CALL.Z  cima
				MOV		R1, M[fbaixo]
				CMP		R1, ON
				CALL.Z  baixo

				; verificando o que cada fantasma vai fazer:

				; fantasma 1
				; atual_ghost <- informacoes do fantasma 1
				MOV		R1, M[I_ghostend]
				MOV		M[atual_ghostend], R1
				MOV		R1, M[I_ghostcol]
				MOV		M[atual_ghostcol], R1
				MOV		R1, M[I_ghostlinha]
				MOV		M[atual_ghostlin], R1
				MOV		R1, M[I_estanterior]
				MOV		M[estado_anterior], R1

				MOV		R1, M[contador]
				MOV		R2, MOVS_TO_RAND
				DIV		R1, R2
				CMP		R2, 0d; A cada 4 movimentos, 1 será aleatório
				CALL.Z  random_choice
				CMP		R2, 0d
			 	CALL.NZ	direcao
				
				; atual_ghost -> informacoes do fantasma 1
				MOV		R1, M[atual_ghostend]
				MOV		M[I_ghostend], R1
				MOV		R1, M[atual_ghostcol]
				MOV		M[I_ghostcol], R1
				MOV		R1, M[atual_ghostlin]
				MOV		M[I_ghostlinha], R1
				MOV		R1, M[estado_anterior]
				MOV		M[I_estanterior], R1

				; fantasma 2
				; atual_ghost <- informacoes do fantasma 2
				MOV		R1, M[II_ghostend]
				MOV		M[atual_ghostend], R1
				MOV		R1, M[II_ghostcol]
				MOV		M[atual_ghostcol], R1
				MOV		R1, M[II_ghostlinha]
				MOV		M[atual_ghostlin], R1
				MOV		R1, M[II_estanterior]
				MOV		M[estado_anterior], R1

				MOV		R1, M[contador]
				MOV		R2, MOVS_TO_RAND
				DIV		R1, R2
				CMP		R2, 0d; A cada 4 movimentos, 1 será aleatório
				CALL.Z  random_choice
				CMP		R2, 0d
			 	CALL.NZ	direcao
				
				; atual_ghost -> informacoes do fantasma 2
				MOV		R1, M[atual_ghostend]
				MOV		M[II_ghostend], R1
				MOV		R1, M[atual_ghostcol]
				MOV		M[II_ghostcol], R1
				MOV		R1, M[atual_ghostlin]
				MOV		M[II_ghostlinha], R1
				MOV		R1, M[estado_anterior]
				MOV		M[II_estanterior], R1

				; fantasma 3
				; atual_ghost <- informacoes do fantasma 3
				MOV		R1, M[III_ghostend]
				MOV		M[atual_ghostend], R1
				MOV		R1, M[III_ghostcol]
				MOV		M[atual_ghostcol], R1
				MOV		R1, M[III_ghostlinha]
				MOV		M[atual_ghostlin], R1
				MOV		R1, M[III_estanterior]
				MOV		M[estado_anterior], R1

				MOV		R1, M[contador]
				MOV		R2, MOVS_TO_RAND
				DIV		R1, R2
				CMP		R2, 0d; A cada 4 movimentos, 1 será aleatório
				CALL.Z  random_choice
				CMP		R2, 0d
			 	CALL.NZ	direcao
				
				; atual_ghost -> informacoes do fantasma 3
				MOV		R1, M[atual_ghostend]
				MOV		M[III_ghostend], R1
				MOV		R1, M[atual_ghostcol]
				MOV		M[III_ghostcol], R1
				MOV		R1, M[atual_ghostlin]
				MOV		M[III_ghostlinha], R1
				MOV		R1, M[estado_anterior]
				MOV		M[III_estanterior], R1
				
				; fantasma 4
				; atual_ghost <- informacoes do fantasma 4
				MOV		R1, M[IIII_ghostend]
				MOV		M[atual_ghostend], R1
				MOV		R1, M[IIII_ghostcol]
				MOV		M[atual_ghostcol], R1
				MOV		R1, M[IIII_ghostlinha]
				MOV		M[atual_ghostlin], R1
				MOV		R1, M[IIII_estanterior]
				MOV		M[estado_anterior], R1

				MOV		R1, M[contador]
				MOV		R2, MOVS_TO_RAND
				DIV		R1, R2
				CMP		R2, 0d; A cada 4 movimentos, 1 será aleatório
				CALL.Z  random_choice
				CMP		R2, 0d
			 	CALL.NZ	direcao

				; atual_ghost -> informacoes do fantasma 4
				MOV		R1, M[atual_ghostend]
				MOV		M[IIII_ghostend], R1
				MOV		R1, M[atual_ghostcol]
				MOV		M[IIII_ghostcol], R1
				MOV		R1, M[atual_ghostlin]
				MOV		M[IIII_ghostlinha], R1
				MOV		R1, M[estado_anterior]
				MOV		M[IIII_estanterior], R1


				INC		M[contador]
				CALL 	Configura_timer

				POP		R2
				POP		R1
				RTI
;------------------------------------------------------------------------------
; Função que define direção que fantasma irá
;------------------------------------------------------------------------------
direcao:		PUSH	R1

				; direita: se pacman está com coluna maior, mover para direita, se for parede, verifica próximo
				MOV		R1, M[pccoluna]
				CMP		M[atual_ghostcol], R1
				JMP.Z   direcao_cima
				CMP		M[atual_ghostcol], R1
				JMP.P	direcao_esq
				MOV		R1, M[atual_ghostend]
				INC		R1
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z	direcao_cima
				CALL	ghost_dir
				JMP		fim_direcao
						

direcao_esq:	MOV		R1, M[pccoluna]
				CMP		M[atual_ghostcol], R1
				JMP.NP	direcao_cima
				MOV		R1, M[atual_ghostend]
				DEC		R1
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z	direcao_cima
				CALL	ghost_esq
				JMP		fim_direcao


direcao_cima:	MOV		R1, M[pclinha]
				CMP		M[atual_ghostlin], R1
				JMP.NP	direcao_baixo
				MOV		R1, M[atual_ghostend]
				SUB		R1, 81d
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z   direcao_baixo
				CALL	ghost_cima
				JMP		fim_direcao

direcao_baixo:	MOV		R1, M[pclinha]
				CMP		M[atual_ghostlin], R1
				JMP.P   fim_direcao
				MOV		R1, M[atual_ghostend]
				ADD		R1, 81d
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z   fim_direcao
				CALL	ghost_baixo

fim_direcao:	POP		R1
				RET
;------------------------------------------------------------------------------
; Flags - Atribuindo flags de movimento do pacman
;------------------------------------------------------------------------------
flag_dir: 		PUSH	R1

				MOV		R1, ON
				MOV		M[fdir], R1

				MOV		R1, OFF
				MOV		M[fesq], R1
				MOV		M[fbaixo], R1
				MOV		M[fcima], R1

				POP 	R1
				RTI

flag_esq:		PUSH	R1
				
				MOV		R1, ON
				MOV		M[fesq], R1

				MOV		R1, OFF
				MOV		M[fdir], R1
				MOV		M[fbaixo], R1
				MOV		M[fcima], R1

				POP 	R1
				RTI

flag_cima:		PUSH	R1

				MOV		R1, ON
				MOV		M[fcima], R1

				MOV		R1, 0
				MOV		M[fesq], R1
				MOV		M[fbaixo], R1
				MOV		M[fdir], R1

				POP 	R1
				RTI

flag_baixo:		PUSH	R1

				MOV		R1, ON
				MOV		M[fbaixo], R1

				MOV		R1, OFF
				MOV		M[fesq], R1
				MOV		M[fcima], R1
				MOV		M[fdir], R1

				POP 	R1
				RTI
;------------------------------------------------------------------------------
; Timer
;------------------------------------------------------------------------------

Configura_timer: PUSH R1

				 MOV	R1, TIME_TO_WAIT
				 MOV	M[ TIMER_UNITS ], R1
				 MOV	R1, ON
				 MOV	M[ACTIVATE_TIMER], R1

				 POP	R1
				 RET

;------------------------------------------------------------------------------
; Função Mapa
;------------------------------------------------------------------------------
Mapa:		PUSH		R1
			PUSH		R2
			PUSH		R3
			MOV 		R3, 0d

while1:		CMP 		R3, 24d
			JMP.Z 		endwhile1
			CALL		PrintString
			INC			M[ TextIndex ]
			INC			R3
			MOV         R2, 0
			INC 		M[ RowIndex ]
			MOV			R1, M[RowIndex ]
			MOV         M[ ColumnIndex ], R2
			SHL			R1, ROW_SHIFT
			OR 			R1, R2
			MOV			M[ CURSOR ], R1
			JMP			while1

			

endwhile1:	POP			R3
			POP			R2
			POP			R1
			RET

;------------------------------------------------------------------------------
; Função PrintString
;------------------------------------------------------------------------------
PrintString: PUSH		R1
			 PUSH		R2

while:		 MOV		R1, M[ TextIndex ]
			 MOV		R1, M[ R1 ]
			 CMP		R1, FIM_TEXTO
			 JMP.Z 		endwhile
			 MOV		M[ IO_WRITE ], R1
			 INC 		M[ ColumnIndex ]
			 INC		M[ TextIndex ]
			 MOV		R1, M[ RowIndex ]
			 MOV		R2, M[ ColumnIndex ]
			 SHL		R1, ROW_SHIFT
			 OR   		R1, R2
			 MOV		M[ CURSOR ], R1
			 JMP		while

endwhile:   POP			R2
		  	POP			R1
		  	RET

;------------------------------------------------------------------------------
; Função de print da linha de vitoria
;------------------------------------------------------------------------------
vitoria:	PUSH	R1
			PUSH	R2

			MOV		R1, lganhou
			MOV		M[TextIndex], R1
			MOV		R2, 0d
			MOV		M[ColumnIndex], R2
			MOV		R1, 23d
			MOV		M[RowIndex], R1
			SHL		R1, ROW_SHIFT
			OR		R1, R2
			MOV		M[CURSOR], R1
			CALL	PrintString

			JMP		Halt

			POP		R2
			POP		R1
			RET
;------------------------------------------------------------------------------
; Função atualizar score
;------------------------------------------------------------------------------
conta_score:PUSH	R1
			PUSH 	R2

			INC		M[score]
			MOV 	R2, M[score]
			MOV     R1, 100d
			DIV		R2, R1
			MOV     M[cent], R2
			MOV     R2, 10d
			DIV     R1, R2
			MOV     M[dezn], R1
			MOV     R1, 1d
			DIV		R2, R1
			MOV     M[unid], R2

			;print centena
			MOV		R2, M[scoluna]		
			MOV		R1, M[sclinha]
			SHL		R1, ROW_SHIFT
			OR		R1, R2
			MOV		R2, R1 ; guardando posicao pra reutilizar na dezena e unidade
			MOV		M[CURSOR], R1
			MOV		R1, M[cent];
			ADD		R1, '0'
		    MOV		M[IO_WRITE], R1

			;print dezena
			INC		R2
			MOV		M[CURSOR], R2
			MOV		R1, M[dezn]
			ADD		R1, '0'
			MOV		M[IO_WRITE], R1

			;print unidade
			INC		R2
			MOV		M[CURSOR], R2
			MOV		R1, M[unid]
			ADD		R1, '0'
			MOV		M[IO_WRITE], R1

			; Verificando se jogador ganhou
			MOV		R1, M[score]
			CMP		R1, POINTS_TO_WIN
			CALL.Z  vitoria

			POP     R2
			POP     R1
			RET

;------------------------------------------------------------------------------
; Função de imprimir linha de derrota
;------------------------------------------------------------------------------
fim_jogo:	PUSH	R1
			PUSH	R2

			MOV		R1, lperdeu
			MOV		M[TextIndex], R1
			MOV		R2, 0d
			MOV		M[ColumnIndex], R2
			MOV		R1, 23d
			MOV		M[RowIndex], R1
			SHL		R1, ROW_SHIFT
			OR		R1, R2
			MOV		M[CURSOR], R1
			CALL	PrintString

			JMP		Halt

			POP		R2
			POP		R1
			RET
;------------------------------------------------------------------------------
; Função para contagem de vidas e reset do pacman
;------------------------------------------------------------------------------
conta_vida:	PUSH	R1
			PUSH	R2

			MOV		R1, M[vidas]
			DEC		M[vidas]
			MOV		R2, 2d
			MUL		R2, R1
			MOV		R2, M[vicol]
			ADD		R2, R1
			MOV		R1, M[vilin]
			SHL		R1, ROW_SHIFT
			OR		R1, R2
			MOV		M[CURSOR], R1
			MOV		R1, VAZIO
			MOV		M[IO_WRITE], R1
			
			; verificando se jogador está sem vidas e, caso sim, finalizando jogo
			MOV		R1, M[vidas]
			CMP		R1, 0d 
			CALL.Z	fim_jogo

			; retirando pacman de onde ele estava
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR		R1, R2
			MOV		M[CURSOR], R1
			MOV		R1, VAZIO
			MOV		M[IO_WRITE], R1

			; voltando pacman para posicao inicial
			MOV		R1, L1
			ADD		R1, 825d
			MOV		M[pcend], R1
			MOV		R1, INIT_PCCOL
			MOV		M[pccoluna], R1
			MOV		R1, INIT_PCLIN
			MOV		M[pclinha], R1


			
			POP		R2
			POP		R1
			RET

;------------------------------------------------------------------------------
; Função mover direita
;------------------------------------------------------------------------------
direita:	PUSH 	R1
			PUSH	R2

			; verificando o que terá na próxima posicao do pacman
			MOV		R1, M[pcend]
			INC 	R1
			MOV		R1, M[R1]
			CMP		R1, PAREDE
			JMP.Z 	fim_direita
			CMP		R1, FANTASMA
			CALL.Z   conta_vida
			CMP		R1, COMIDA
			CALL.Z	conta_score

			; movendo vazio para posicao passada do pacman
			MOV		R1, M[pcend]
			MOV 	R2, VAZIO
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, VAZIO
			MOV		M[IO_WRITE], R1

			INC 	M[pcend]
			INC		M[pccoluna]

			; printando pacman no local correto
print_dir:	MOV 	R2, PACMAN
			MOV		R1, M[pcend]		
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, PACMAN
			MOV		M[IO_WRITE], R1

fim_direita:	POP 	R2
				POP 	R1
				
				RET


;------------------------------------------------------------------------------
; Função mover esquerda
;------------------------------------------------------------------------------
esquerda:	PUSH	R1
			PUSH	R2

			MOV		R1, M[pcend]
			DEC 	R1
			MOV		R1, M[R1]
			CMP		R1, PAREDE
			JMP.Z 	fim_esquerda
			CMP		R1, FANTASMA
			CALL.Z   conta_vida
			CMP		R1, COMIDA
			CALL.Z	conta_score			

			MOV		R1, M[pcend]
			MOV 	R2, VAZIO
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, VAZIO
			MOV		M[IO_WRITE], R1

			DEC 	M[pcend]
			DEC		M[pccoluna]	
			MOV		R1, M[pcend]
			MOV 	R2, PACMAN
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, PACMAN
			MOV		M[IO_WRITE], R1

fim_esquerda:	POP R2
				POP	R1
				RET

;------------------------------------------------------------------------------
; Função mover cima
;------------------------------------------------------------------------------
cima:		PUSH 	R1
			PUSH	R2

			MOV		R1, M[pcend]
			SUB 	R1, 81d
			MOV		R1, M[R1]
			CMP		R1, PAREDE
			JMP.Z 	fim_cima
			CMP		R1, FANTASMA
			CALL.Z   conta_vida
			CMP		R1, COMIDA
			CALL.Z	conta_score	
			
			MOV		R1, M[pcend]
			MOV 	R2, VAZIO
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, VAZIO
			MOV		M[IO_WRITE], R1

			MOV 	R1, M[pcend]
			SUB		R1, 81d
			MOV		M[pcend], R1
			DEC		M[pclinha]	
			MOV		R1, M[pcend]
			MOV 	R2, PACMAN
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, PACMAN
			MOV		M[IO_WRITE], R1


fim_cima:		POP 	R2
				POP 	R1
				
				RET
;------------------------------------------------------------------------------
; Função mover baixo
;------------------------------------------------------------------------------
baixo:		PUSH 	R1
			PUSH	R2

			MOV		R1, M[pcend]
			ADD 	R1, 81d
			MOV		R1, M[R1]
			CMP		R1, PAREDE
			JMP.Z 	fim_baixo
			CMP		R1, FANTASMA
			CALL.Z  conta_vida
			CMP		R1, COMIDA
			CALL.Z	conta_score	
			
			MOV		R1, M[pcend]
			MOV 	R2, VAZIO
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, VAZIO
			MOV		M[IO_WRITE], R1

			MOV 	R1, M[pcend]
			ADD		R1, 81d
			MOV		M[pcend], R1
			INC		M[pclinha]	
			MOV		R1, M[pcend]
			MOV 	R2, PACMAN
			MOV 	M[R1], R2
			MOV		R2, M[pccoluna]
			MOV		R1, M[pclinha]
			SHL		R1, ROW_SHIFT
			OR 		R1, R2
			MOV		M[CURSOR], R1
			MOV 	R1, PACMAN
			MOV		M[IO_WRITE], R1

fim_baixo:		POP 	R2
				POP 	R1
				
				RET
;------------------------------------------------------------------------------
; funcoes de movimento dos fantasmas
;------------------------------------------------------------------------------
ghost_dir:		PUSH	R1
				PUSH	R2

				; verificando se fantasma irá se mover
				MOV		R1, M[atual_ghostend]
				INC		R1
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z   fim_ghost_dir

				; colocando o que tinha anteriormente no lugar do fantasma
				MOV		R1, M[atual_ghostend]
				MOV		R2, M[estado_anterior]
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, M[estado_anterior]
				MOV		M[IO_WRITE], R1

				; movimento do fantasma
				INC		M[atual_ghostend]
				INC		M[atual_ghostcol]
				
				; guardando o que tem antes de sobreescrever com o fantasma
				MOV		R1, M[atual_ghostend]
				MOV		R2, M[R1]
				CMP		R2, FANTASMA
				JMP.Z   escreve_dir
				CMP		R2, PACMAN
				CALL.Z	conta_vida
				CMP		R2, PACMAN
				JMP.Z   escreve_dir
				MOV		M[estado_anterior], R2


escreve_dir:	MOV		R2, FANTASMA
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, FANTASMA
				MOV		M[IO_WRITE], R1
				
fim_ghost_dir:	POP		R2
				POP		R1

				RET	

ghost_esq:		PUSH	R1
				PUSH	R2

				MOV		R1, M[atual_ghostend]
				DEC		R1
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z	fim_ghost_esq

				MOV		R1, M[atual_ghostend]
				MOV		R2, M[estado_anterior]
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, M[estado_anterior]
				MOV		M[IO_WRITE], R1

				DEC		M[atual_ghostend]
				DEC		M[atual_ghostcol]

				MOV		R1, M[atual_ghostend]
				MOV		R2, M[R1]
				CMP		R2, FANTASMA
				JMP.Z 	escreve_esq
				CMP		R2, PACMAN
				CALL.Z	conta_vida
				CMP		R2, PACMAN
				JMP.Z   escreve_esq
				MOV		M[estado_anterior], R2
				
escreve_esq:	MOV		R2, FANTASMA
				MOV		M[R1], R2

				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, FANTASMA
				MOV		M[IO_WRITE], R1

fim_ghost_esq:	POP		R2
				POP		R1

				RET

ghost_cima:		PUSH	R1
				PUSH	R2

				MOV		R1, M[atual_ghostend]
				SUB		R1, 81d
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z   fim_ghost_cima

				MOV		R1, M[atual_ghostend]
				MOV		R2, M[estado_anterior]
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, M[estado_anterior]
				MOV		M[IO_WRITE], R1

				MOV		R1, M[atual_ghostend]
				SUB		R1, 81d
				MOV		M[atual_ghostend], R1
				DEC		M[atual_ghostlin]

				MOV		R1, M[atual_ghostend]
				MOV		R2, M[R1]
				CMP		R2, FANTASMA
				JMP.Z   escreve_cima
				CMP		R2, PACMAN
				CALL.Z	conta_vida
				CMP		R2, PACMAN
				JMP.Z   escreve_cima
				MOV		M[estado_anterior], R2
				
escreve_cima:	MOV		R2, FANTASMA
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, FANTASMA
				MOV		M[IO_WRITE], R1

fim_ghost_cima:	POP		R2
				POP		R1

				RET

ghost_baixo:	PUSH	R1
				PUSH	R2

				MOV		R1, M[atual_ghostend]
				ADD		R1, 81d
				MOV		R1, M[R1]
				CMP		R1, PAREDE
				JMP.Z   fim_ghost_baixo

				MOV		R1, M[atual_ghostend]
				MOV		R2, M[estado_anterior]
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, M[estado_anterior]
				MOV		M[IO_WRITE], R1

				MOV		R1, M[atual_ghostend]
				ADD		R1, 81d
				MOV		M[atual_ghostend], R1
				INC		M[atual_ghostlin]

				MOV		R1, M[atual_ghostend]
				MOV		R2, M[R1]
				CMP		R2, FANTASMA
				JMP.Z   escreve_baixo
				CMP		R2, PACMAN
				CALL.Z	conta_vida
				CMP		R2, PACMAN
				JMP.Z   escreve_baixo
				MOV		M[estado_anterior], R2
				
				
escreve_baixo:	MOV		R2, FANTASMA
				MOV		M[R1], R2
				MOV		R2, M[atual_ghostcol]
				MOV		R1, M[atual_ghostlin]
				SHL		R1, ROW_SHIFT
				OR		R1, R2
				MOV		M[CURSOR], R1
				MOV		R1, FANTASMA
				MOV		M[IO_WRITE], R1

fim_ghost_baixo:	POP 	R2
					POP		R1

					RET
;------------------------------------------------------------------------------
; Função de inicializacao do pacman
;------------------------------------------------------------------------------
init_pacman:	PUSH	R1

				MOV 	R1, L1
				ADD 	R1, 825d
				MOV 	M[pcend], R1

				POP		R1
				RET
;------------------------------------------------------------------------------
; Função de inicializacao dos fantasmas
;------------------------------------------------------------------------------
init_ghots:		PUSH	R1

				MOV		R1, L1
				ADD		R1, 1417d
				MOV		M[I_ghostend], R1

				MOV		R1, L1
				ADD		R1, 271d
				MOV		M[II_ghostend], R1

				MOV		R1, L1
				ADD		R1, 774d
				MOV		M[III_ghostend], R1

				MOV		R1, L1
				ADD		R1, 1306d
				MOV		M[IIII_ghostend], R1

				POP		R1
				RET
;------------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------
Main:			ENI

				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
				
				MOV     R1, L1
				MOV		M[ TextIndex ], R1
				CALL 	Mapa

				CALL	init_pacman

				CALL	init_ghots

				CALL 	Configura_timer

				
Cycle: 			BR		Cycle
Halt:           BR		Halt
