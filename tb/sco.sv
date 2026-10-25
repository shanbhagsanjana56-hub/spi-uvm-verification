class sco extends uvm_scoreboard;
    `uvm_component_utils(sco)
    
  uvm_analysis_imp#(transaction,sco) recv; //analysis implementation which will recover data from the monitor
    bit exp_err;
    bit[7:0] arr[32]='{default:0};  //memory of 8 bit wide and 32 depth
    bit[7:0] addr=0;
    bit[7:0] data_rd=0;
    
    
    function new(input string inst="sco",uvm_component parent=null);
      super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      recv=new("recv",this);
    endfunction
    
    virtual function void write(transaction tr);
  if(tr.op==rstdut)
    begin
      `uvm_info("SCO","SYSTEM RESET DETECTED",UVM_NONE)
    end
  else
    begin
      // NEW: independent check of the DUT's err flag
      exp_err = (tr.addr > 31);
      if(tr.err !== exp_err)
        `uvm_error("SCO", $sformatf("ERR MISMATCH addr:%0d exp_err:%0b got:%0b",
                                    tr.addr, exp_err, tr.err))

      if(tr.op==writed)
        begin
          if(tr.err==1'b1)
            `uvm_info("SCO","SLV ERROR DURING WRITE OP",UVM_NONE)
          else
            begin
              arr[tr.addr]=tr.din;
              `uvm_info("SCO",$sformatf("DATA WRITE OP addr:%0d wdata:%0d arr_wr:%0d",tr.addr,tr.din,arr[tr.addr]),UVM_MEDIUM)
            end
        end
      else if(tr.op==readd)
        begin
          if(tr.err==1'b1)
            `uvm_info("SCO","SLV ERROR during READ OP",UVM_NONE)
          else
            begin
              data_rd=arr[tr.addr];
              if(data_rd==tr.dout)
                `uvm_info("SCO","DATA MATCHED",UVM_NONE)
              else
                `uvm_error("SCO","TEST FAILED")
            end
        end
    end
  $display("---------------------");
endfunction
  endclass