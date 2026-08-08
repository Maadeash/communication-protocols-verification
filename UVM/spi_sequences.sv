class spi_base_sequence extends uvm_sequence #(spi_seq_item);
  `uvm_object_utils(spi_base_sequence)
  function new(string name="spi_base_sequence");
    super.new(name);
  endfunction
endclass

class spi_directed_sequence extends spi_base_sequence;
  `uvm_object_utils(spi_directed_sequence)
  typedef struct {
    string label;
    bit [7:0]master_tx;
    bit [7:0]slave_tx;
  } item_t;
  function new(string name="spi_directed_sequence");
    super.new(name);
  endfunction
  task body();
    item_t items[]='{
      '{"GEN_CORNER1",8'h00,8'h10},
      '{"GEN_CORNER2",8'hFF,8'h80},
      '{"GEN_CORNER3",8'hAA,8'hF0},
      '{"GEN_CORNER4",8'h55,8'h10},
      '{"GEN_X1",8'h10,8'h10},
      '{"GEN_X2",8'h10,8'h80},
      '{"GEN_X3",8'h10,8'hF0},
      '{"GEN_X4",8'h55,8'h10},
      '{"GEN_X5",8'h55,8'h80},
      '{"GEN_X6",8'h55,8'hF0},
      '{"GEN_X7",8'hF0,8'h10},
      '{"GEN_X8",8'hF0,8'h80},
      '{"GEN_X9",8'hF0,8'hF0}
    };

    foreach(items[i]) begin
      req=spi_seq_item::type_id::create($sformatf("item_%0d",i));
      start_item(req);
      if(!req.randomize() with {
            master_tx==items[i].master_tx;
            slave_tx==items[i].slave_tx;
          })
        `uvm_error("SEQ","Randomization failed for directed item")
      req.display(items[i].label);
      finish_item(req);
      #100;
    end
  endtask
endclass

class spi_random_sequence extends spi_base_sequence;
  `uvm_object_utils(spi_random_sequence)
  int num_random=10;
  function new(string name="spi_random_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_info("SEQ",$sformatf("Running with num_random=%0d",num_random),UVM_LOW)
    repeat(num_random) begin
      req=spi_seq_item::type_id::create("rnd_item");
      start_item(req);
      if(!req.randomize())
        `uvm_error("SEQ","Randomization failed for random item")
      req.display("GEN_RND");
      finish_item(req);
      #100;
    end
  endtask
endclass

class spi_main_sequence extends spi_base_sequence;
  `uvm_object_utils(spi_main_sequence)
  function new(string name="spi_main_sequence");
    super.new(name);
  endfunction
  task body();
    spi_directed_sequence dir_seq;
    dir_seq=spi_directed_sequence::type_id::create("dir_seq");
    dir_seq.start(m_sequencer,this);
  endtask
endclass
