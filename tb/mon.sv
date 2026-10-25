class mon extends uvm_monitor;
   `uvm_component_utils(mon)
   
   uvm_analysis_port#(transaction)send;  //analysis port for montior to send the data to a scoreboard 
   transaction tr;
   virtual spi_i vif;
   
   
   function new(input string inst="mon",uvm_component parent=null);
     super.new(inst,parent);
   endfunction
   
   //Again Mske memory for the container and the port handle
virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  tr=transaction::type_id::create("tr");  //constructor to a transaction
  send=new("send",this);//constructor to our analysis port
  
  
    if(!uvm_config_db#(virtual spi_i)::get(this,"","vif",vif))
      `uvm_error("Mon","Unable To access interface")
  endfunction
    
      virtual task run_phase(uvm_phase phase);
  forever begin
    @(posedge vif.clk);
    if(vif.rst)
      begin
        tr.op=rstdut;   //TR.OP IS A SIGNAL WHICH WE WILL NOT BE GETTING FROM OUR DUT!
        `uvm_info("Mon","System reset detetcted",UVM_NONE);
        send.write(tr);
      end
    
    else if(!vif.rst && vif.wr)
      begin
        @(posedge vif.done);
        tr.op=writed;
        tr.din=vif.din;
        tr.addr=vif.addr;
        tr.err=vif.err;
        `uvm_info("MON",$sformatf("DATA WRITE addr:%0d data:%0d err:%0d",tr.addr,tr.din,tr.err),UVM_NONE);
        send.write(tr);
      end
    
    else if(!vif.rst && !vif.wr)
      begin
        @(posedge vif.done);
        tr.op=readd;
        tr.addr=vif.addr;
        tr.err=vif.err;
        tr.dout=vif.dout;
        `uvm_info("MON",$sformatf("DATA READ addr:%0d data:%0d slverr:%0d",tr.addr,tr.dout,tr.err),UVM_NONE);
        send.write(tr);
      end
  end
  endtask
endclass
  
  