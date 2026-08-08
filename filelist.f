// Compile order matters: i2c_if.sv must precede i2c_pkg.sv (virtual
// interface handles) and i2c_assertions.sv (module port type); i2c_pkg.sv
// must precede tb_top.sv (imports i2c_pkg).
i2c_if.sv
i2c_master.v
i2c_slave.v
i2c_assertions.sv
i2c_pkg.sv
tb_top.sv
