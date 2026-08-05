`ifndef SPI_AXI_ENV_SV
`define SPI_AXI_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_axi_agent.sv"
`include "spi_axi_scoreboard.sv"
`include "spi_axi_coverage.sv"

    class spi_axi_env extends uvm_env;
        `uvm_component_utils(spi_axi_env)

        spi_axi_agent      agt;
        spi_axi_scoreboard scb;
        spi_axi_coverage   cov;
        
        function new(string name, uvm_component parent);
            super.new(name,parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            agt = spi_axi_agent::type_id::create("agt", this);
            scb = spi_axi_scoreboard::type_id::create("scb", this);
            cov = spi_axi_coverage::type_id::create("cov", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);    
            agt.mon.ap.connect(scb.ap_imp);
            agt.mon.ap.connect(cov.analysis_export);
        endfunction
    endclass

`endif
