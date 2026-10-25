class env extends uvm_env;
  `uvm_component_utils(env)
  
  function new(input string inst ="env",uvm_component c=null);
    super.new(inst,c);
  endfunction
  
  agent a;
  sco s;
  cov c;
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a=agent::type_id::create("a",this);
    s=sco::type_id::create("s",this);
    c = cov::type_id::create("c", this); 
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);  //connecting the monitor send port to scoreboard recv port
    a.m.send.connect(c.analysis_export); 
  endfunction
  
endclass