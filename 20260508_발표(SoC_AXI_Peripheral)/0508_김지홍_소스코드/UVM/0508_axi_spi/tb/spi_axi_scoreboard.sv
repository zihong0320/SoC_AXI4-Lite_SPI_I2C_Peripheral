`ifndef SPI_AXI_SCOREBOARD_SV
`define SPI_AXI_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_axi_seq_item.sv"

    class spi_axi_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(spi_axi_scoreboard)

        uvm_analysis_imp #(spi_axi_seq_item, spi_axi_scoreboard) ap_imp;

        int pass_cnt = 0;
        int fail_cnt = 0;

        logic [7:0] exp_rx_q[$];

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ap_imp = new("ap_imp", this);
        endfunction

        function void write(spi_axi_seq_item item);
            
            if (item.is_write && (item.addr == spi_axi_seq_item::ADDR_TX)) begin
                exp_rx_q.push_back(item.s_tx_data);
                `uvm_info(get_type_name(), $sformatf("Stored Expected RX Data: 0x%02h", item.s_tx_data), UVM_HIGH)
            end

            else if (!item.is_write && (item.addr == spi_axi_seq_item::ADDR_RX)) begin
                if (exp_rx_q.size() > 0) begin
                    logic [7:0] exp_data = exp_rx_q.pop_front();
                    logic [7:0] act_data = item.rdata[7:0]; // 32비트 데이터 중 하위 8비트만 추출

                    if (act_data === exp_data) begin
                        pass_cnt++;
                        `uvm_info(get_type_name(), $sformatf("Match!! Master Read RX: 0x%02h (Expected: 0x%02h)", 
                            act_data, exp_data), UVM_MEDIUM)
                    end else begin
                        fail_cnt++;
                        `uvm_error(get_type_name(), $sformatf("Mismatch!! Master Read RX: 0x%02h (Expected: 0x%02h)", 
                            act_data, exp_data))
                    end
                end else begin
                    `uvm_error(get_type_name(), "Read from RX Register, but no expected data in queue!")
                end
            end
        endfunction

        virtual function void report_phase(uvm_phase phase);
            `uvm_info(get_type_name(), "\n\n", UVM_LOW)
            `uvm_info(get_type_name(), "==== AXI Scoreboard Summary ====", UVM_LOW)
            `uvm_info(get_type_name(), $sformatf(" Total Checked: %0d", pass_cnt + fail_cnt), UVM_LOW)
            `uvm_info(get_type_name(), $sformatf(" PASS: %0d", pass_cnt), UVM_LOW)
            `uvm_info(get_type_name(), $sformatf(" FAIL: %0d", fail_cnt), UVM_LOW)

            if(fail_cnt > 0) begin
                `uvm_error(get_type_name(), $sformatf("TEST FAILED: %0d mismatches detected!", fail_cnt))
            end else begin
                `uvm_info(get_type_name(), $sformatf("TEST PASSED: %0d all matches detected!", pass_cnt), UVM_LOW)
            end
            `uvm_info(get_type_name(), "\n\n", UVM_LOW)
        endfunction

        task run_phase(uvm_phase phase);
        endtask

    endclass

`endif
