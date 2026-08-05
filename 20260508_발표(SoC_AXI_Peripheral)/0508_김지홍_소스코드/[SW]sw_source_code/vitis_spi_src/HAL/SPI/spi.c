/*
 * spi.c
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#include "SPI.h"
#include "xil_io.h"

void SPI_Init(SPI_Typedef_t *SPIx, uint32_t clk_div) {
    SPIx->CLK_DIV = clk_div;
}

uint8_t SPI_Transfer(SPI_Typedef_t *SPIx, uint8_t data) {
    uint32_t fixed_data = (uint32_t)(data << 1); // Slave의 요구사항에 따른 shift라면 유지

    // 1. 이전 전송이 끝났는지 먼저 확인 (Busy Check)
    while (SPIx->STATUS & 0x01);

    // 2. 데이터와 Start 비트 동시 전송
    SPIx->TX_START = (1 << 8) | fixed_data;

    // 3. [매우 중요] 하드웨어가 "알았어, 나 이제 바빠(Busy)!"라고 답할 때까지 대기
        // CPU가 다음 줄로 넘어가서 바로 Start를 꺼버리는 것을 방지합니다.
        int timeout = 0;
        while (!(SPIx->STATUS & 0x01)) {
            timeout++;
            if (timeout > 100000) break; // 하드웨어가 응답 없으면 탈출
        }

        // 4. [선택 사항] 하드웨어가 전송을 확실히 시작했다면, 이제 Start 비트를 꺼도 됩니다.
        // 하지만 안전하게 하려면 전송이 완전히 끝날 때까지 켜두는 것도 방법입니다.
        // 일단 여기서는 끄지 않고 전송 완료까지 기다려 보겠습니다.

        // 5. 전송 완료(Busy가 다시 0이 됨)를 기다림
        while (SPIx->STATUS & 0x01);

        // 6. 전송이 완전히 끝났으므로 다음 전송을 위해 Start 비트를 0으로 초기화
        SPIx->TX_START = fixed_data;

        return (uint8_t)(SPIx->RX_DATA & 0xFF);
}

