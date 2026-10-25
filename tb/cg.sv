class cov extends uvm_subscriber#(transaction);
    `uvm_component_utils(cov)
     transaction tr;
  //In cov we wrote extends uvm_subscriber#(transaction) instead of extends uvm_scoreboard. uvm_subscriber is a built-in UVM class made for this job, and it already contains:

  covergroup cg;
    cp_op:coverpoint tr.op{
      bins rd={readd};
      bins wr={writed};
    }  
    
    cp_addr:coverpoint tr.addr{
      bins low={[0:10]};
      bins mid={[11:29]};
      bins edge30={30};
      bins edge31={31};
      bins edge32={32};
      bins illegal={[33:255]};
    }
    
    cp_err:coverpoint tr.err{
      bins no_err={0};
      bins err={1};
    }
    
    x_op_addr: cross cp_op, cp_addr;
  endgroup 
  
  function new(string name="cov",uvm_component parent=null);
    super.new(name,parent);
    cg=new();
  endfunction
  
  virtual function void write(transaction t);
    if(t.op!=rstdut)
      begin
        tr=t;
        cg.sample();
      end
    
  endfunction
  
  virtual function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Overall   = %0.2f%%", cg.get_coverage()),          UVM_NONE)
  `uvm_info("COV", $sformatf("cp_op     = %0.2f%%", cg.cp_op.get_coverage()),    UVM_NONE)
  `uvm_info("COV", $sformatf("cp_addr   = %0.2f%%", cg.cp_addr.get_coverage()),  UVM_NONE)
  `uvm_info("COV", $sformatf("cp_err    = %0.2f%%", cg.cp_err.get_coverage()),   UVM_NONE)
    `uvm_info("COV", $sformatf("cross     = %0.2f%%", cg.x_op_addr.get_coverage()),UVM_NONE)
    //cg.get_coverage() returns a number from 0 to 100: the percentage of bins ticked across the whole covergroup.
  endfunction
  
  
endclass