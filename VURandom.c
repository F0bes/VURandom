#include <stdio.h>
#include <kernel.h>
#include <debug.h>

#include "memorydef.h"
#include "microprog.h"
#include "vifdef.h"

// Slower but helps on emus with alot of logging
// (cough dobie cough)
//#define PRINT_TO_SCREEN

// Array that holds our vif packet
u32 vifdata[255];
int i = 0;

int main(void){

#ifdef PRINT_TO_SCREEN
	init_scr();

	//	Waits for a vsync (taken from graph)
	volatile u64* GS_REG_CSR = (volatile u64 *)0x12001000;
	// Initiate vsync interrupt.
	*GS_REG_CSR |= *GS_REG_CSR & 8;
	// Wait for vsync interrupt to be generated.
	while (!(*GS_REG_CSR & 8));
#endif

	// Get the size of our micro program
	u32 VU0codeSize = &RandomGen_CodeEnd - &RandomGen_CodeStart;
	u32 VU0codeBlocks = VU0codeSize / 2;

	// Wait for previous micro program (shouldn't be one honestly)
	vifdata[i++] = VIFFLUSHE;
	vifdata[i++] = VIFMPG(VU0codeBlocks,0);

	// Put the micro program into the vif packet
	for(int codeSize = 0; codeSize < VU0codeSize; codeSize++){
		vifdata[i++] = ((u32*)&RandomGen_CodeStart)[codeSize];
	}

	// Activate the micro program
	vifdata[i++] = VIFMSCAL(0x0);
	// Wait for the micro program
	vifdata[i++] = VIFFLUSHE;

	// ask dma-chan to upload our packet to vif0
	VIF0MADR = (u32)&vifdata;
	VIF0QWC = (VU0codeBlocks /2) + 1;
	FlushCache(0); // Otherwise uploads ?? to the VIF
	VIF0CHCR = 0x101; // Activate transfer

	// We don't wait for the vpu to finish without this
	FlushCache(0);  

	// Wait for DMA transfer
	while(VIF0CHCR & 0x100) {}

	// Wait for VU0 to finish
	asm(
		"vu_wait:\n"
		"cfc2 $t0, $vi29\n" // VPU-STAT
		"andi $t0,$t0,1\n"
		"bgtz $t0, vu_wait\n"
		:::"$t0"
	);

	for(int i = 0; i < 100; i++)
	{
		printf("[%d] %f\n",i,*(float*)(0x11004000 + (i * 4)));
#ifdef PRINT_TO_SCREEN
		if(i < 25)
			scr_printf("[%d] %f\n",i,*(float*)(0x11004000 + (i * 4)));
		else{
			scr_setXY((u32)(i / 25) * 19,(i - (25*(i / 25))) * 1);
			scr_printf("[%d] %f		",i,*(float*)(0x11004000 + (i * 4)));
		}
#endif
	}

	SleepThread();
}
