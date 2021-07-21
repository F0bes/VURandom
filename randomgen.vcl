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
ADDI.x VF01, VF00, I 	; Load the seed into VF01
RINIT R, VF01[x] 		; RINIT (random Init) with our seed

IADDIU VI01, VI00, 25	; Currently we generate 100 random numbers

Loop:

; Generate our random numbers
RNEXT.x VF01, R
RNEXT.y VF01, R
RNEXT.z VF01, R
RNEXT.w VF01, R

; Currently, VF01 has our random numbers
; The current value would be 1.??????
; Subtract 1 and Multiply by 100000 to get a better number to show on the EE 
SUB.xyzw VF01, VF01, VF00[w]

LOI 100000
MULI.xyzw VF01, VF01, I

; Store the random number in 
SQd.xyzw VF01, (--VI01)

IBNE VI01, VI00, Loop

--exit
--endexit

RandomGen_CodeEnd:
