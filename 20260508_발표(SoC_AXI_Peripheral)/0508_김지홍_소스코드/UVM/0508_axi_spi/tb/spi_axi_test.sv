`ifndef SPI_AXI_TEST_SV
`define SPI_AXI_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_axi_env.sv"
`include "spi_axi_seq_item.sv"
`include "spi_axi_sequence.sv"

    class spi_axi_base_test extends uvm_test;
        `uvm_component_utils(spi_axi_base_test)
        
        spi_axi_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = spi_axi_env::type_id::create("env", this);
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            `uvm_info(get_type_name(), "=== Hierarchy Structure UVM ===", UVM_MEDIUM)
            uvm_top.print_topology();
        endfunction

        virtual task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            run_test_seq();
            phase.drop_objection(this);
            `uvm_info("TEST", "SPI-AXI test completed successfully", UVM_NONE)
        endtask

        virtual task run_test_seq();
        endtask 

    endclass

    class spi_axi_rand_test extends spi_axi_base_test;
        `uvm_component_utils(spi_axi_rand_test)
        
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_test_seq();
            spi_axi_rand_seq seq;
            seq = spi_axi_rand_seq::type_id::create("seq");
            seq.num_trans = 1000;
            seq.start(env.agt.sqr);
            
            #1000; 
        endtask
    endclass

`endif
