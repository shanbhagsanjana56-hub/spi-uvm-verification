`include "spi_mem.sv"
`include "intf.sv"

module top(
input wr,clk,rst,
  input [7:0] addr,din,
  output [7:0] dout,
  output done,err);  //These are the signals that are present in the top module
  
  //here we also require a few handshaking signals which are not present in the top module but are there insdie
  
  wire csreg,mosireg,misoreg,readyreg,opdonereg;
  
  
  //the below connections can be understood once u define the interface and the memory
  
  spi_intf intf(wr,clk,rst,readyreg,opdonereg,addr,din,dout,csreg,mosireg,misoreg,done,err);//(controller)
  
  spi_mem mem_inst(clk,rst,csreg,mosireg,readyreg,misoreg,opdonereg);
  //memory
endmodule