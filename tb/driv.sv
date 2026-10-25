class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
  virtual spi_i vif; //interface through which we trigger our dut
  transaction tr;  //container in which data received from teh sequencer will be stored
  
  function new(input string path="uvm",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  //in build pahse make memory for the container and get the access of the interface
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr=transaction::type_id::create("tr");
    
    if(!uvm_config_db#(virtual spi_i)::get(this,"","vif",vif))
      `uvm_error("drv","Unable To access interface")
  endfunction
         task reset_dut();
    repeat(5)
      begin
        vif.rst<=1'b1;
        vif.addr<='h0;
        vif.din<='h0;
        vif.wr<=1'b0;
        
        `uvm_info("DRV","SYSTEM RESET: START OF SIMULATION",UVM_MEDIUM);
        @(posedge vif.clk);
      end
 endtask
   
    task drive();
      reset_dut(); 
    forever
      begin    //so that we r always ready to receive sequence from the sequencer
        seq_item_port.get_next_item(tr);  //This is a request to the sequencer to send the next item 
      
      if(tr.op==rstdut)
        begin
          vif.rst<=1'b1;
          @(posedge vif.clk);
        end
      
      else if(tr.op==writed)
        begin
          vif.rst<=1'b0;
          vif.wr<=1;
          vif.addr<=tr.addr;
          vif.din<=tr.din;
          @(posedge vif.clk);
`uvm_info("DRV", $sformatf("mode: Write addr :%0d din:%0d", tr.addr, tr.din), UVM_NONE);  
          @(posedge vif.done);
        end
      
      
      else if(tr.op==readd)
        begin
          vif.rst<=1'b0;
          vif.wr<=1'b0;
          vif.addr<=tr.addr;
          vif.din<=tr.din;
`uvm_info("DRV", $sformatf("mode: Read addr :%0d din:%0d", tr.addr, tr.din), UVM_NONE)
          @(posedge vif.done);
        end
      
      seq_item_port.item_done();
      end
      endtask
      
      virtual task run_phase(uvm_phase phase);
        drive();
        
      endtask
         
endclass
      