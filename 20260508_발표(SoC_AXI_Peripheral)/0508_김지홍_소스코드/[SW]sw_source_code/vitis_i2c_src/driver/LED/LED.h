/*
 * LED.h
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_LED_LED_H_
#define SRC_DRIVER_LED_LED_H_

#include "../../HAL/GPIO/GPIO.h"
#include <stdint.h>

#define LED0 		GPIO_PIN_0
#define LED1 		GPIO_PIN_1
#define LED2 		GPIO_PIN_2
#define LED3		GPIO_PIN_3
#define LED4		GPIO_PIN_4
#define LED5 		GPIO_PIN_5
#define LED6 		GPIO_PIN_6
#define LED7 		GPIO_PIN_7

void LED_Init();
void LED_SetTarget(uint32_t GPIO_Pin, uint8_t on_off);

#endif /* SRC_DRIVER_LED_LED_H_ */
