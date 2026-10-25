class transaction extends uvm_sequence_item;
  rand oper_mode op;
  logic wr;
  logic rst;
  randc logic[7:0]addr;
  rand logic[7:0]din;
  logic [7:0]dout;
  logic done;
  logic err;
  //Why is this useful for a transaction? Because your testbench frequently needs to inspect, copy or compare transaction objects while debugging and checking DUT behavior.
  
  //so u need to register this to the factory
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(wr,UVM_ALL_ON)
  `uvm_field_int(rst,UVM_ALL_ON)
  `uvm_field_int(addr,UVM_ALL_ON)
  `uvm_field_int(din,UVM_ALL_ON)
  `uvm_field_int(dout,UVM_ALL_ON)
  `uvm_field_int(done,UVM_ALL_ON)
  `uvm_field_int(err,UVM_ALL_ON)
  `uvm_field_enum(oper_mode,op,UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint addr_c{addr<32;}
  constraint addr_c_err{addr>31;}
  
  
  function new(string name="transaction");
    super.new(name);
  endfunction
  
endclass