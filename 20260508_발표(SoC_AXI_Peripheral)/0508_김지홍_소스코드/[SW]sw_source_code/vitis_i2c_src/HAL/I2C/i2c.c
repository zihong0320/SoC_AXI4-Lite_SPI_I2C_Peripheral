/*
 * i2c.c
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#include "I2C.h"
#include "../../common/common.h"

// 100MHz 시스템 클럭 기준
#define SYS_CLK 100000000

void I2C_Init(I2C_Typedef_t *I2Cx, uint32_t i2c_freq) {
    // 분주비 설정 (100MHz -> i2c_freq)
    I2Cx->PRESCALER = SYS_CLK / (i2c_freq * 4);
    I2Cx->CONTROL = 0x00;
}

// IP가 작업을 끝낼 때까지 대기하는 내부 함수
void I2C_Wait_Busy(I2C_Typedef_t *I2Cx) {
    // STATUS의 Busy(bit 1)가 0이 될 때까지 폴링
    while(I2Cx->STATUS & 0x02);
}

void I2C_WriteByte(I2C_Typedef_t *I2Cx, uint8_t slaveAddr, uint8_t data) {
    // [STEP 1] Start + Slave Address 전송
    I2Cx->TX_DATA = (slaveAddr << 1) | 0; // Write mode (0)
    I2Cx->CONTROL = I2C_CMD_START | I2C_CMD_WRITE;
    I2C_Wait_Busy(I2Cx);

    // [STEP 2] 실제 Data 전송
    I2Cx->TX_DATA = data;
    I2Cx->CONTROL = I2C_CMD_WRITE;
    I2C_Wait_Busy(I2Cx);

    // [STEP 3] Stop 신호 생성
    I2Cx->CONTROL = I2C_CMD_STOP;
    I2C_Wait_Busy(I2Cx);
}

uint8_t I2C_ReadByte(I2C_Typedef_t *I2Cx, uint8_t slaveAddr) {
    // [STEP 1] Start + Slave Address 전송
    I2Cx->TX_DATA = (slaveAddr << 1) | 1; // Read mode (1)
    I2Cx->CONTROL = I2C_CMD_START | I2C_CMD_WRITE;
    I2C_Wait_Busy(I2Cx);

    // [STEP 2] 데이터 수신 명령
    I2Cx->CONTROL = I2C_CMD_READ;
    I2C_Wait_Busy(I2Cx);

    // [STEP 3] Stop 신호 생성
    uint8_t received = (uint8_t)I2Cx->RX_DATA;
    I2Cx->CONTROL = I2C_CMD_STOP;
    I2C_Wait_Busy(I2Cx);

    return received;
}
