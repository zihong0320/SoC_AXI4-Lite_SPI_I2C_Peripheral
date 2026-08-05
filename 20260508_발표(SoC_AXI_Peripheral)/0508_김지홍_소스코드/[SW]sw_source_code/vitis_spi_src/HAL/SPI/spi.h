/*
 * spi.h
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_

#include <stdint.h>

typedef struct {
    uint32_t TX_START; // Offset 0x00
    uint32_t RX_DATA;  // Offset 0x04
    uint32_t STATUS;   // Offset 0x08
    uint32_t CLK_DIV;  // Offset 0x0C
} SPI_Typedef_t;

#define SPI0_BASE_ADDR 0x44A40000
#define SPI0 ((SPI_Typedef_t *) (SPI0_BASE_ADDR))

void SPI_Init(SPI_Typedef_t *SPIx, uint32_t clk_div);
uint8_t SPI_Transfer(SPI_Typedef_t *SPIx, uint8_t data);

#endif /* SRC_HAL_SPI_SPI_H_ */
