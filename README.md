# 🖥️ SoC AXI4-Lite SPI/I2C Peripheral & UVM Verification

> **SoC 기반 AXI4-Lite SPI 및 I2C 주변장치(Peripheral) 설계 & UVM 기반 기능 검증**  
> MicroBlaze 프로세서 연동, AXI4-Lite 마스터-슬레이브 인터페이스 구현, 계층형 소프트웨어 아키텍처 적용 및 SystemVerilog UVM을 활용한 100% 커버리지 무작위 검증

---

## 📌 0. Summary

### 🎯 Overview
- **AXI4-Lite Specification 분석 & IP 설계**: AXI4-Lite 버스 인터페이스 기반의 SPI/I2C Master IP 및 Slave Peripheral 설계
- **계층형 소프트웨어 아키텍처 구현**: MicroBlaze CPU 상에서 동작하는 Application ➔ Driver ➔ HAL ➔ Hardware 구조의 모듈화 소프트웨어 설계
- **UVM 기반 레벨 검증**: AXI4-Lite SPI Controller IP에 대한 UVM(Universal Verification Methodology) 랜덤 테스트 환경 구축 및 100% Coverage 달성

---

### 🛠 개발 환경 및 사용 기술
* **Target Board**: Basys3 (Xilinx Artix-7), STM32
* **SoC Processor**: MicroBlaze
* **Development Tools**: Vivado, Vitis, VS Code
* **Languages**: SystemVerilog, Verilog HDL, C
* **Protocols & Arch**: AXI4-Lite, SPI, I2C, UVM, Layered SW Architecture

---

## 📚 1. Introduction & Background

### 1.1 AXI4-Lite Protocol

<p align="center">
  <img width="55%" alt="AXI Master & Slave" src="https://github.com/user-attachments/assets/59a4600f-148e-4578-86c1-a2a22e637332" /><br>
  <b>[ AXI Protocol - Master & Slave Interface ]</b>
</p>

* **주요 특징**:
  * **Channel-based 통신**: 독립된 5개의 채널을 통한 고속 데이터 송수신
  * **Valid-Ready Handshake**: 모든 채널은 `VALID`와 `READY` 신호의 상호 확인을 통해 신뢰성 있는 데이터 이동 보장
  * **Point-to-Point 통신**: 공유 버스(Shared Bus) 형태가 아닌 마스터-슬레이브 간 점대점 직접 연결 방식으로 데이터 병목 최소화

* #### 5대 채널 구조 (Channel)
  1. **Write Address Channel (AW)**: 쓰기 주소 및 제어 신호 전달
  2. **Write Data Channel (W)**: 실제 쓰기 데이터 전송
  3. **Write Response Channel (B)**: 쓰기 작업 완료 상태 및 응답(ACK) 수신
  4. **Read Address Channel (AR)**: 읽기 주소 및 제어 신호 전달
  5. **Read Data Channel (R)**: 읽기 데이터 및 읽기 상태 응답 수신

* #### AXI vs AHB/APB 차이점
  * **AHB / APB Bus**: 하나의 주소/데이터 버스를 모든 Slave가 공유하는 방송(Broadcasting) 방식
  * **AXI**: Point-to-Point direct 인터페이스로 마스터가 타겟 Slave에 직접 연결하여 고속 전송 가능

| AXI Read Transaction | AXI Write Transaction |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/a33ccb0b-19e2-4355-9eda-9640cc914d4e" width="100%"/> | <img src="https://github.com/user-attachments/assets/4802dbf1-78ca-451f-ac9a-69e6ff5706eb" width="100%"/> |
| 마스터가 읽기 주소 송신 ➔ 슬레이브가 해당하는 데이터 전송 | 마스터가 쓰기 주소/데이터 송신 (Handshake) ➔ 슬레이브가 쓰기 성공 ACK 응답 |

---

### 1.2 SPI (Serial Peripheral Interface)
* **주요 특징**: Full-Duplex 방식을 지원하는 동기식 시리얼 통신 프로토콜. `SCLK`, `MOSI`, `MISO`, `CS` 4개의 라인을 활용하여 고속 데이터 전달.

### 1.3 I2C (Inter-Integrated Circuit)
* **주요 특징**: `SDA`(데이터), `SCL`(클럭) 2개의 신호선만을 이용한 Half-Duplex 동기식 시리얼 통신 프로토콜. 슬레이브 주소(Slave Address) 지정을 통해 다중 기기 제어 지원.

---

## ⚙️ 2. System Design

### 2.1 AXI4-Lite 기반 SPI Peripheral Hardware Architecture (Basys3)

<p align="center">
  <img width="85%" alt="SPI Hardware Block Diagram" src="https://github.com/user-attachments/assets/f15cf5b2-4cd8-40a8-bd7c-7c0285e9b18f" /><br>
  <b>[ AXI4-Lite 기반 SPI Peripheral Hardware Block Diagram ]</b>
</p>

* **MicroBlaze (Main CPU)**: AXI4-Lite Bus Master로서 전체 시스템 소프트웨어 제어 총괄
* **SPI IP (AXI4-Lite SPI Master IP)**: AXI4-Lite 명령을 입력받아 하드웨어 SPI 신호로 변환하고 내부 제어 레지스터(`0x00 ~ 0x0C`) 제공
* **SPI Slave**: SPI 규격에 따라 SPI Master IP와 최종 데이터(`MOSI`/`MISO`)를 송수신하는 주변 장치

---

### 2.2 AXI4-Lite 기반 SPI Software Architecture & Address Map

| AXI SPI Address Map | 계층형 소프트웨어 아키텍처 (Layered SW) |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/1aa2e927-e58f-49e9-857d-778edd5935f1" width="100%"/> | <img src="https://github.com/user-attachments/assets/6400ca39-17d2-457c-871b-40b8f3df4978" width="100%"/> |
| **MicroBlaze IP 제어를 위한 Address Map 매핑** | **Application ➔ Driver ➔ HAL ➔ HW 레이어 분리** |

---

### 2.3 AXI4-Lite 기반 I2C Peripheral Hardware Architecture (Basys3)

<p align="center">
  <img width="85%" alt="I2C Hardware Block Diagram" src="https://github.com/user-attachments/assets/9e963825-b7ad-46c3-acad-c012dd17c18d" /><br>
  <b>[ AXI4-Lite 기반 I2C Peripheral Hardware Block Diagram ]</b>
</p>

* **MicroBlaze (Main CPU)**: AXI4-Lite Bus Master 역할 수행
* **I2C IP (AXI4-Lite I2C Master IP)**: AXI4-Lite 프로토콜 입력을 하드웨어 I2C 신호(`SDA`, `SCL`)로 변환 및 제어 레지스터 제공
* **I2C Slave**: I2C 프로토콜 통신을 통해 데이터를 주고받는 최종 슬레이브 주변 장치

---

### 2.4 AXI4-Lite 기반 I2C Software Architecture & Address Map

| AXI I2C Address Map | 계층형 소프트웨어 아키텍처 (Layered SW) |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/782b8ced-bb32-467b-b3d4-7d1981cd47bb" width="100%"/> | <img src="https://github.com/user-attachments/assets/b89cd7ec-306e-42de-98a7-16a6d14e3e74" width="100%"/> |
| **I2C IP 제어를 위한 Memory Address Map 매핑** | **독립성를 위한 Layered Software Structure** |

---

## 🛠️ 3. Implementation & Hardware Mechanism

### 3.1 AXI4-Lite 기반 SPI Master & Slave FPGA 구현

| Peripheral SPI Logic | SPI Master & Slave FPGA 실물 구현 |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/b4742501-3315-4a61-9981-63c6f6e87e36" width="100%"/> | <img src="https://github.com/user-attachments/assets/c65f7699-12cb-4d06-bd99-53efd3f3bfef" width="100%"/> |
| **AXI4-Lite SPI Peripheral 전체 구조** | **Basys3(FPGA) 기반 SPI Master & Slave 연동** |

#### 🔄 SPI Master/Slave 동작 Mechanism
* **Write 동작**: Slave에 쓰고자 하는 8비트 데이터를 Master 스위치로 입력 ➔ Start 버튼 클릭 ➔ Write 수행 (Slave의 FND 및 LED에 데이터 즉시 출력)
* **Read 동작**: Master가 읽어올 8비트 데이터를 Slave 스위치로 입력 ➔ Start 버튼 클릭 ➔ Read 수행 (Master의 FND 및 LED에 읽어온 데이터 출력)

---

### 3.2 AXI4-Lite 기반 I2C Master & Slave FPGA 구현

| Peripheral I2C Logic | I2C Master & Slave FPGA 실물 구현 |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/22b7a12c-4597-4a82-86ec-b332156c6d82" width="100%"/> | <img src="https://github.com/user-attachments/assets/3b8673e9-49c6-417a-85c0-892f93666a47" width="100%"/> |
| **AXI4-Lite I2C Peripheral 전체 구조** | **Basys3 FPGA 기반 I2C Master & Slave 연동** |

#### 🔄 I2C Master/Slave 동작 메커니즘
* **Write 동작**: Start ➔ `{Slave Address, 0(Write)}`를 스위치로 입력 ➔ Write 버튼 ➔ Slave에 전송할 8비트 Data를 Master 스위치 입력 ➔ Write ➔ Stop
* **Read 동작**: Start ➔ `{Slave Address, 1(Read)}`를 스위치로 입력 ➔ Write 버튼 ➔ Master가 수신할 8비트 Data를 Slave 스위치 입력 ➔ Read ➔ Stop

---

## 📈 4. Verification & Result (UVM)

### 4.1 UVM Verification Environment

<p align="center">
  <img width="50%" alt="UVM Verification Block Diagram" src="https://github.com/user-attachments/assets/db6bfbe0-77bd-4e81-b2c4-c777c3f12033" /><br>
  <b>[ AXI4-Lite SPI Controller UVM Verification Environment ]</b>
</p>

* SystemVerilog UVM(Universal Verification Methodology) 기법을 도입하여 AXI4-Lite Interface 기반 SPI Master IP에 대한 Random Testbench 구조 설계 및 기능 검증 수행

---

### 4.2 UVM Test Results & Functional Coverage

| Random Test Result Log | Functional Coverage Result |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/d6bd7471-67cb-489e-b285-f7ab078e4e1f" width="100%"/> | <img src="https://github.com/user-attachments/assets/2fa0a4a7-c110-4ff5-a462-87690596c075" width="100%"/> |
| **SPI AXI Random Full-Duplex Test 2,000회 PASS** | **TX/RX Data 구간별 Coverage 100% 달성** |

* **Random Test Result**: SPI AXI Random Write/Read Full-Duplex 무작위 검증 결과 **2000/2000회 전체 PASS**
* **Coverage 데이터 범위**:
  * `TX Data (Master)`: `0x00 ~ 0x3F`, `0x40 ~ 0xBF`, `0xC0 ~ 0xFF` 구간 검증
  * `RX Data (Master)`: `0x00 ~ 0x3F`, `0x40 ~ 0xBF`, `0xC0 ~ 0xFF` 구간 검증

---

### 🎬 4.3 Demo Video (AXI4-Lite SPI)

https://github.com/user-attachments/assets/de378de3-4408-418c-a17c-a13f42982469

* **시연 내용**: MicroBlaze CPU ➔ AXI4-Lite SPI IP ➔ SPI Slave(FPGA) 간 레지스터 읽기/쓰기(R/W) 및 FND/LED 데이터 출력 실시간 시연

---


### 🎬 4.4 Demo Video (AXI4-Lite I2C)

https://github.com/user-attachments/assets/227d7d05-222d-44a8-9e02-b8cad8c35f37

* **시연 내용**: MicroBlaze CPU ➔ AXI4-Lite I2C IP ➔ I2C Slave(FPGA) 간 레지스터 읽기/쓰기(R/W) 및 FND/LED 데이터 출력 실시간 시연
---

## 🚨 5. TroubleShooting & Review

### 🚨 SW vs HW Start Pulse 생성 및 오동작 해결
* **문제점**: 최초 설계 시 SW 레벨에서 Start Pulse를 생성하도록 구현했으나, Read 동작 시 타이밍 동기화 불일치로 인해 데이터 신뢰도가 떨어지고 불안정하게 동작하는 현상 발생.
* **해결 방법**:
  1. 소프트웨어 제어 방식에서 HW 내부에 Start Pulse 생성 로직을 직접 구현하는 방식으로 구조 변경.
  2. HW 로직 타이밍 보완을 통해 Read 동작의 안정성 확보.
* **고찰**:
  * 프로젝트 진행 중 이미 완성된 코드를 HW 방식으로 재설계하는 과정에서 "과연 하드웨어 타이밍 보완이 맞는지"에 대한 구조적 고민을 깊게 경험.
  * 초기에 SoC 및 계층형 소프트웨어 아키텍처(Application-Driver-HAL) 개념이 미숙하여 하드웨어/소프트웨어 간의 각 역할을 명확히 정의하지 못했던 아쉬움이 남음.
  * 이 경험을 통해 SoC 시스템 구축 시 **Hardware/Software Co-design** 단계에서 타이밍 크리티컬한 신호 처리 위치를 명확히 정하는 설계 전략의 중요성을 깨달음.
