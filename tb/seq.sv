class write_data extends uvm_sequence#(transaction);
  `uvm_object_utils(write_data)
    
  transaction tr;    //make a container
  
  function new(string name="write_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr=transaction::type_id::create("tr"); //Make memory for the container
        tr.addr_c.constraint_mode(1);          //make one of the constraint disabled
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);   //Requesting a sequencer to accepet this packet
        assert(tr.randomize());   //randomizing the contents of the packet
      tr.op=writed;
        finish_item(tr);   //This is where the sequence completes the transaction handoff to the sequencer.
      end
  endtask
endclass

class write_err extends uvm_sequence#(transaction);
  `uvm_object_utils(write_err)
  
  transaction tr;
  
  function new(string name="write_err");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr=transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(0);
        tr.addr_c_err.constraint_mode(1);
        start_item(tr);   //sending a sequencer
        assert(tr.randomize());
        tr.op=writed;
        finish_item(tr);
      end
  endtask
endclass


class read_data extends uvm_sequence#(transaction);
  `uvm_object_utils(read_data)
  
  transaction tr;
  
  function new(string name="read_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr=transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);   //sending a sequencer
        assert(tr.randomize());
        tr.op=readd;
        finish_item(tr);
      end
  endtask
endclass



class read_err extends uvm_sequence#(transaction);
  `uvm_object_utils(read_err)
  
  transaction tr;
  
  function new(string name="read_err");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr=transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(0);
        tr.addr_c_err.constraint_mode(1);
        start_item(tr);   //sending a sequencer
        assert(tr.randomize());
        tr.op=readd;
        finish_item(tr);
      end
  endtask
endclass

class reset_dut extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_dut)
  
  transaction tr;
  
  function new(string name="reset_dut");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr=transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(0);
        tr.addr_c_err.constraint_mode(1);
        start_item(tr);   //sending a sequencer
        assert(tr.randomize());
        tr.op=rstdut;
        finish_item(tr);
      end
  endtask
endclass


class writeb_readb extends uvm_sequence#(transaction);
  `uvm_object_utils(writeb_readb)
  
  transaction tr;
  
  function new(string name="writeb_readb");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        tr=transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);   //sending a sequencer
        assert(tr.randomize());
        tr.op=writed;
        finish_item(tr);
      end
    
    repeat(10)
      begin
        tr=transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        start_item(tr);   //sending a sequencer
        assert(tr.randomize());
        tr.op=readd;
        finish_item(tr);
      end
  endtask
endclass



class boundary_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(boundary_seq)
  function new(string name="boundary_seq");
    super.new(name);
  endfunction

  task do_op(oper_mode m, bit [7:0] target);
    transaction tr = transaction::type_id::create("tr");
    tr.addr_c.constraint_mode(0);
    tr.addr_c_err.constraint_mode(0);
    start_item(tr);
    assert(tr.randomize() with {addr == target;});
    tr.op = m;
    finish_item(tr);
  endtask

  virtual task body();
    bit [7:0] addrs[] = '{0, 1, 30, 31, 32, 33, 255};
    foreach (addrs[i]) begin
      do_op(writed, addrs[i]);
      do_op(readd,  addrs[i]);
    end
  endtask
endclass