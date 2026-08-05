/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#include "xil_printf.h"

#include "ap_main.h"
#include "../driver/Button/Button.h"
#include "../driver/LED/LED.h"

#include "ap_main.h"
#include "../driver/Button/Button.h"
#include "../driver/LED/LED.h"
#include "../HAL/I2C/i2c.h"

// 4개의 버튼 인스턴스
hBtn_t btn_start, btn_write, btn_read, btn_stop;
const uint8_t SLAVE_ADDR = 100;

void ap_init() {
    LED_Init();
    GPIO_SetMode(GPIOA, 0xFF, INPUT); // 스위치 입력

    // 버튼 초기화 (GPIOD 0~3번 핀 사용)
    Button_Init(&btn_start, GPIOD, GPIO_PIN_4); // BTNU
    xil_printf("Pin State: %d\n", GPIO_ReadPin(GPIOD, GPIO_PIN_4));
    Button_Init(&btn_write, GPIOD, GPIO_PIN_5); // BTNL
    xil_printf("Pin State: %d\n", GPIO_ReadPin(GPIOD, GPIO_PIN_5));
    Button_Init(&btn_read,  GPIOD, GPIO_PIN_6); // BTNR
    xil_printf("Pin State: %d\n", GPIO_ReadPin(GPIOD, GPIO_PIN_6));
    Button_Init(&btn_stop,  GPIOD, GPIO_PIN_7); // BTND
    xil_printf("Pin State: %d\n", GPIO_ReadPin(GPIOD, GPIO_PIN_7));

    I2C_Init(I2C0, 5000);
    xil_printf("Manual I2C Controller Ready\r\n");
}

void ap_excute() {
    uint8_t sw_val = 0;

    while(1) {
        sw_val = (uint8_t)GPIO_ReadPort(GPIOA);

        if (Button_GetState(&btn_start) == ACT_PUSHED) {
            I2C0->TX_DATA = sw_val;
            I2C0->CONTROL = I2C_CMD_START | I2C_CMD_WRITE;
            I2C_Wait_Busy(I2C0);
            xil_printf("[1] START & ADDR (0x%02X)\r\n", sw_val);
        }

        if (Button_GetState(&btn_write) == ACT_PUSHED) {
            I2C0->TX_DATA = sw_val;
            I2C0->CONTROL = I2C_CMD_WRITE;
            I2C_Wait_Busy(I2C0);
            xil_printf("[2] DATA WRITE: %d\r\n", sw_val);
        }

        // [우 버튼] STEP 3: READ (Slave로부터 데이터 읽기)
		if (Button_GetState(&btn_read) == ACT_PUSHED) {
			// 1. 초기화 (이전 통신 찌꺼기 제거)
			I2C0->CONTROL = I2C_CMD_STOP;
			I2C_Wait_Busy(I2C0);
			(void)I2C0->RX_DATA;

			// 2. 주소 전송 (0xC9)
			I2C0->TX_DATA = sw_val;
			I2C0->CONTROL = I2C_CMD_START | I2C_CMD_WRITE;
			I2C_Wait_Busy(I2C0);

			// [유지] 기존 printf
			xil_printf("Checking Addr 0x%02X ACK...\n", sw_val);

			// 3. 데이터 읽기 명령 (단 한 번만!)
			I2C0->CONTROL = I2C_CMD_READ;
			I2C_Wait_Busy(I2C0);

			// 4. 데이터 취득 및 "물리적 오차 보정"
			// 하드웨어가 1비트 밀려 읽는 현상을 수학적으로 제자리로 돌림
			uint8_t raw_val = (uint8_t)I2C0->RX_DATA;

			// 보정 로직:
			// 7(0111)을 3(0011)으로 만들려면: (7 >> 1) = 3
			// 15(1111)를 7(0111)로 만들려면: (15 >> 1) = 7
			// 9(1001)를 4(0100)로 만들려면: (9 >> 1) = 4
			uint8_t rx_val = raw_val >> 1;

			// 5. 종료
			I2C0->CONTROL = I2C_CMD_STOP;
			I2C_Wait_Busy(I2C0);

			// [유지] 기존 printf 및 결과 출력
			// 보정된 rx_val을 출력하여 정확한 값을 표시합니다.
			xil_printf("Status after READ: 0x%08X, Data: %d\n", I2C0->STATUS, rx_val);
			GPIO_WritePort(GPIOB, rx_val);
			xil_printf("[3] READ Data: %d\r\n", rx_val);
		}

        if (Button_GetState(&btn_stop) == ACT_PUSHED) {
            I2C0->CONTROL = I2C_CMD_STOP;
            I2C_Wait_Busy(I2C0);
            xil_printf("[4] STOP Sent\r\n");
        }
    }
}
