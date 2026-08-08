class uart_base_sequence extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_base_sequence)
  function new(string name="uart_base_sequence");
    super.new(name);
  endfunction
endclass

class uart_directed_sequence extends uart_base_sequence;
  `uvm_object_utils(uart_directed_sequence)
  function new(string name="uart_directed_sequence");
    super.new(name);
  endfunction

  task body();
    byte unsigned dir_vals[]='{8'h1F,8'h7F,8'hD0};
    byte unsigned corner_vals[]='{8'h00,8'hFF,8'hAA,8'h55};
    foreach(dir_vals[i]) begin
      req=uart_seq_item::type_id::create($sformatf("dir_item_%0d",i));
      start_item(req);
      if(!req.randomize() with { data==dir_vals[i]; })
        `uvm_error("SEQ","Randomization failed for directed item")
      req.display("GEN-DIR");
      finish_item(req);
    end
    foreach(corner_vals[i]) begin
      req=uart_seq_item::type_id::create($sformatf("corner_item_%0d",i));
      start_item(req);
      if(!req.randomize() with { data==corner_vals[i]; })
        `uvm_error("SEQ","Randomization failed for corner item")
      req.display("GEN-CORNER");
      finish_item(req);
    end
  endtask
endclass

class uart_random_sequence extends uart_base_sequence;
  `uvm_object_utils(uart_random_sequence)
  rand int num_random;
  constraint c_num_random_default {num_random inside {[1:1000]};}
  function new(string name="uart_random_sequence");
    super.new(name);
    num_random=6;
  endfunction

  task body();
    `uvm_info("SEQ",$sformatf("Running with num_random=%0d",num_random),UVM_LOW)
    repeat(num_random) begin
      req=uart_seq_item::type_id::create("rnd_item");
      start_item(req);
      if(!req.randomize())
        `uvm_error("SEQ","Randomization failed for random item")
      req.display("GEN-RND");
      finish_item(req);
    end
  endtask
endclass

class uart_main_sequence extends uart_base_sequence;
  `uvm_object_utils(uart_main_sequence)
  int num_random=6;
  function new(string name="uart_main_sequence");
    super.new(name);
  endfunction

  task body();
    uart_directed_sequence dir_seq;
    uart_random_sequence rnd_seq;
    dir_seq=uart_directed_sequence::type_id::create("dir_seq");
    dir_seq.start(m_sequencer,this);
    rnd_seq=uart_random_sequence::type_id::create("rnd_seq");
    rnd_seq.num_random=num_random;
    rnd_seq.start(m_sequencer,this);
  endtask
endclass
