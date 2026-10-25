`include "uvm_macros.svh"
import uvm_pkg::*;
`include "config.sv"

typedef enum bit[2:0] {readd=0,writed=1,rstdut=2,writerr=3,readerr=4}oper_mode;
`include "transac.sv"
`include "seq.sv"
`include "driv.sv"
`include "mon.sv"
`include "sco.sv"            
`include "cg.sv"
`include "ag.sv"
`include "env.sv"
`include "tst.sv"

module tb;
  import uvm_pkg::*;
  spi_i vif();
  
  top dut(.wr(vif.wr), .clk(vif.clk), .rst(vif.rst), .addr(vif.addr), .din(vif.din), .dout(vif.dout), .done(vif.done), .err(vif.err));
   
  initial
    begin
      vif.clk<=0;
    end
  
  always #10 vif.clk<=~vif.clk;
  
  initial begin
  uvm_config_db#(virtual spi_i)::set(
    null, "*", "vif", vif
  );

  run_test("test");
end
 
endmodule
                          
