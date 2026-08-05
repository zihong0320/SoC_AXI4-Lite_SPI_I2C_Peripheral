/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#include "xil_printf.h"

#include "ap_main.h"
#include "../DRIVER/Button/Button.h"
#include "../DRIVER/LED/LED.h"
#include "../HAL/SPI/SPI.h"

hBtn_t btn_send;

void ap_init()
{
    // 1. LED 초기화
    LED_Init();

    // 2. 버튼 초기화 (GPIOD_4 핀 사용 예시)
    Button_Init(&btn_send, GPIOD, GPIO_PIN_4);

    // 3. SPI 초기화 (분주비 설정)
    SPI_Init(SPI0, 100);

    // 4. 스위치 입력 모드 설정 (GPIOA 전체)
    GPIO_SetMode(GPIOA, 0xFF, INPUT);
}

void ap_excute()
{
    uint8_t sw_data = 0;
    uint8_t received_data = 0;

    while(1)
    {
        // Button_GetState를 변수에 담아 딱 한 번만 호출 (상태 꼬임 방지)
        button_act_t btn_event = Button_GetState(&btn_send);

        if (btn_event == ACT_PUSHED)
        {
            // 1. 스위치 값 읽기
            sw_data = (uint8_t)GPIO_ReadPort(GPIOA);

            // 2. SPI 전송 (보정 로직이 포함된 함수)
            received_data = SPI_Transfer(SPI0, sw_data);

            // 3. LED 출력 및 로그
            GPIO_WritePort(GPIOB, received_data);
            xil_printf("SW: 0x%02X -> Slave, RX: 0x%02X\r\n", sw_data, received_data);
        }

        // 루프가 너무 빨라 버튼 디바운싱(5ms)과 충돌하는 걸 방지
        // 하지만 SPI 분주비가 1000이면 이미 충분히 느리므로 1ms만 줌
        delay_ms(1);
    }
}
