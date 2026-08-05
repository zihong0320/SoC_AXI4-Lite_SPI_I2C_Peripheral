`ifndef SPI_AXI_SCOREBOARD_SV
`define SPI_AXI_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_axi_seq_item.sv"

class spi_axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_axi_scoreboard)

    uvm_analysis_imp #(spi_axi_seq_item, spi_axi_scoreboard) ap_imp;

    // 쓰기(Write) 및 읽기(Read) 성공/실패 카운트 분리
    int write_pass_cnt = 0;
    int write_fail_cnt = 0;
    int read_pass_cnt  = 0;
    int read_fail_cnt  = 0;

    // Expected Data를 저장할 큐
    logic [7:0] exp_rx_q[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    // 모니터로부터 데이터를 받는 표준 write 함수
    function void write(spi_axi_seq_item item);
        spi_axi_seq_item local_item;
        
        // 안전을 위해 딥 카피(Deep Copy) 수행
        if (!$cast(local_item, item.clone())) begin
            `uvm_fatal(get_type_name(), "Clone and cast failed in Scoreboard!")
        end

        // 읽기 / 쓰기에 따라 내부 검증 함수로 분기
        if (local_item.is_write) begin
            check_write_transaction(local_item);
        end else begin
            check_read_transaction(local_item);
        end
    endfunction

    // ==========================================
    // 1. WRITE(쓰기) 트랜잭션 검증 및 Pass/Fail 판단
    // ==========================================
    virtual function void check_write_transaction(spi_axi_seq_item item);
        if (item.addr == spi_axi_seq_item::ADDR_TX) begin
            exp_rx_q.push_back(item.s_tx_data);
            write_pass_cnt++; // 예상 데이터가 정상적으로 버퍼에 쌓임
            `uvm_info("SCB_WRITE", $sformatf(" [WRITE PASS] TX Reg Write Monitored. Stored Expected Slave MISO: 0x%02h", item.s_tx_data), UVM_MEDIUM)
        end else begin
            // TX 레지스터 외의 다른 레지스터(CTRL 등) 쓰기는 로그만 남김 (필요시 검증 로직 추가 가능)
            `uvm_info("SCB_WRITE", $sformatf(" [WRITE INFO] Other Reg Write (Addr: 0x%02h, Data: 0x%08h)", item.addr, item.wdata), UVM_HIGH)
        end
    endfunction

    // ==========================================
    // 2. READ(읽기) 트랜잭션 검증 및 Pass/Fail 판단
    // ==========================================
    virtual function void check_read_transaction(spi_axi_seq_item item);
        if (item.addr == spi_axi_seq_item::ADDR_RX) begin
            if (exp_rx_q.size() > 0) begin
                logic [7:0] exp_data = exp_rx_q.pop_front();
                logic [7:0] act_data = item.rdata[7:0]; // 하위 8비트 추출

                if (act_data === exp_data) begin
                    read_pass_cnt++;
                    `uvm_info("SCB_READ", $sformatf(" [READ PASS] Match!! Master Read RX Reg: 0x%02h (Expected: 0x%02h)", 
                        act_data, exp_data), UVM_MEDIUM)
                end else begin
                    read_fail_cnt++;
                    `uvm_error("SCB_READ", $sformatf(" [READ FAIL] Mismatch!! Master Read RX Reg: 0x%02h (Expected: 0x%02h)", 
                        act_data, exp_data))
                end
            end else begin
                read_fail_cnt++;
                `uvm_error("SCB_READ", " [READ FAIL] Read from RX Register, but NO expected data in Queue!")
            end
        end else begin
            // RX 레지스터 외의 다른 레지스터(STATUS polling 등) 읽기 처리
            `uvm_info("SCB_READ", $sformatf(" [READ INFO] Other Reg Read (Addr: 0x%02h, Data: 0x%08h)", item.addr, item.rdata), UVM_HIGH)
        end
    endfunction

    // ==========================================
    // 3.최종 결과 리포트 페이즈 (분리 출력)
    // ==========================================
    virtual function void report_phase(uvm_phase phase);
        int total_pass = write_pass_cnt + read_pass_cnt;
        int total_fail = write_fail_cnt + read_fail_cnt;

        `uvm_info(get_type_name(), "\n", UVM_LOW)
        `uvm_info(get_type_name(), "==================================================", UVM_LOW)
        `uvm_info(get_type_name(), "=========== AXI SCOREBOARD SUMMARY ===============", UVM_LOW)
        `uvm_info(get_type_name(), "==================================================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" [WRITE CHANNEL] PASS: %17d | FAIL: %0d", write_pass_cnt, write_fail_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" [READ  CHANNEL] PASS: %17d | FAIL: %0d", read_pass_cnt,  read_fail_cnt),  UVM_LOW)
        `uvm_info(get_type_name(), "--------------------------------------------------", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(" [TOTAL SUMMARY] TOTAL CHECKED: %0d", total_pass + total_fail), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("                 TOTAL PASS   : %0d", total_pass), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("                 TOTAL FAIL   : %0d", total_fail), UVM_LOW)
        `uvm_info(get_type_name(), "==================================================", UVM_LOW)

        if(total_fail > 0) begin
            `uvm_error(get_type_name(), $sformatf("TEST FAILED: %0d mismatches detected!", total_fail))
        end else begin
            `uvm_info(get_type_name(), "TEST PASSED: All transactions matched successfully!", UVM_LOW)
        end
        `uvm_info(get_type_name(), "==================================================\n", UVM_LOW)
    endfunction

endclass

`endif