/*
 * main.c
 *
 *  Created on: 2026. 5. 2.
 *      Author: kccistc
 */


#include "ap/ap_main.h"

int main()
{
	ap_init();

	while(1)
	{
		ap_excute();
	}
	return 0;
}
