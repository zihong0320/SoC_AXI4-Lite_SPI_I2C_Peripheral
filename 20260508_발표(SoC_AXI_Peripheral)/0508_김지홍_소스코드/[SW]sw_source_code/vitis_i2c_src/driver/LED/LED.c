/*
 * LED.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#include "LED.h"

void LED_Init()
{
	GPIO_SetMode(GPIOB, 0xff, OUTPUT);
}

void LED_SetTarget(uint32_t LED_Pin, uint8_t on_off)
{
	GPIO_WritePin(GPIOB, LED_Pin, on_off);
}
