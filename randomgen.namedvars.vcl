.syntax new
.vu
.name RandomGen

.init_vf_all
.init_vi_all

.global RandomGen_CodeStart
.global RandomGen_CodeEnd

--enter
--endenter

RandomGen_CodeStart:

LOI 1234.567 			; <- that number is our random seed, change it if you want!
ADDI.x RandomSeed, VF00, I 	; Load the seed into VF01
RINIT R, RandomSeed[x] 		; RINIT (random Init) with our seed

IADDIU IterCount, VI00, 25	; Currently we generate 100 random numbers

Loop:

; Generate our random numbers
RNEXT.x RandomNumbers, R
RNEXT.y RandomNumbers, R
RNEXT.z RandomNumbers, R
RNEXT.w RandomNumbers, R

; Currently, VF01 has our random numbers
; The current value would be 1.??????
; Subtract 1 and Multiply by 100000 to get a better number to show on the EE 
SUB.xyzw RandomNumbers, RandomNumbers, VF00[w]

;LOI 100000
MULI.xyzw RandomNumbers, RandomNumbers, I

; Store the random numbers in 
SQd.xyzw RandomNumbers, (--IterCount)

IBNE IterCount, VI00, Loop

--exit
--endexit

RandomGen_CodeEnd:
