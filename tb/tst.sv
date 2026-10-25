class test extends uvm_test;
  `uvm_component_utils(test);
  
  function new(input string inst="test",uvm_component c=null);
    super.new(inst,c);
  endfunction
  
  
  
  env e;
  write_data wdata;
  write_err werr;
  
  read_data rdata;
  read_err rerr;boundary_seq bseq;         
  
  writeb_readb wrrdb;
  
  reset_dut rstdut;
  
  //make memory for all the sequences
  virtual function void
    build_phase(uvm_phase phase);
    super.build_phase(phase);
    e=env::type_id::create("env",this);
   bseq=boundary_seq::type_id::create("bseq");    wdata=write_data::type_id::create("wdata");
    werr=write_err::type_id::create("werr");
    rdata=read_data::type_id::create("rdata");
    wrrdb=writeb_readb::type_id::create("wrrdb");
    rerr=read_err::type_id::create("rerr");
    rstdut=reset_dut::type_id::create("rstdut");

  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
     wdata.start(e.a.seqr);   // valid writes
  rdata.start(e.a.seqr);   // valid reads
  wrrdb.start(e.a.seqr);   // write then read back
  werr.start(e.a.seqr);    // write with addr > 31
  rerr.start(e.a.seqr);    // read with addr > 31
  rstdut.start(e.a.seqr);  
    bseq.start(e.a.seqr);  // reset
    #20;
    phase.drop_objection(this);
    
  endtask
endclass
