/*
 * i2c.h
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#ifndef SRC_HAL_I2C_I2C_H_
#define SRC_HAL_I2C_I2C_H_

#include <stdint.h>
#include "xparameters.h"

// I2C Master IP 레지스터 구조체
typedef struct {
    volatile uint32_t CONTROL;   // 0x00: CMD 전송 레지스터
    volatile uint32_t TX_DATA;   // 0x04: 데이터 송신
    volatile uint32_t RX_DATA;   // 0x08: 데이터 수신
    volatile uint32_t STATUS;    // 0x0C: [0]Done, [1]Busy
    volatile uint32_t PRESCALER; // 0x10: SCL 속도 설정
} I2C_Typedef_t;

#define I2C0 ((I2C_Typedef_t *)XPAR_I2C_0_S00_AXI_BASEADDR)

// Verilog CMD 정의 (설계하신 비트 위치에 맞게 수정하세요)
#define I2C_CMD_START  (1 << 0)
#define I2C_CMD_WRITE  (1 << 1)
#define I2C_CMD_READ   (1 << 2)
#define I2C_CMD_STOP   (1 << 3)

// 함수 원형
void I2C_Init(I2C_Typedef_t *I2Cx, uint32_t i2c_freq);
void I2C_Wait_Busy(I2C_Typedef_t *I2Cx);
void I2C_WriteByte(I2C_Typedef_t *I2Cx, uint8_t slaveAddr, uint8_t data);
uint8_t I2C_ReadByte(I2C_Typedef_t *I2Cx, uint8_t slaveAddr);

#endif /* SRC_HAL_I2C_I2C_H_ */
