class spi_config extends uvm_object;
  `uvm_object_utils(spi_config)
  
  function new(string name="spi_config");
    super.new(name);
  endfunction
  
  uvm_active_passive_enum is_active=UVM_ACTIVE;
  //THIS IS AN ACTIVE AGENT ,I.E, IT HAS ALL THREE COMPONENTS
  
endclass