# Run the test flow

A small VHDL simulation example is provided to **test your environment setup** and **tools installation**.<br/>
A simple GNU `Makefile` can be used to automate the flow.

To run the test flow, **open a terminal** and go inside the `test/` directory :


```
% cd Desktop/fphd/test
```

List the content of the `test/` directory :

```
% ls -l
```


List all available `Makefile` targets with :

```
% make help
```

Create a new fresh working area with :

```
% make area
```


Compile and elaborate the example RTL design and run the simulation with :

```
% make compile
% make elaborate
% make simulate
```

For less typing, this is equivalent to :

```
% make sim
```

Explore simulation results in the **Xilinx XSim simulator** graphical interface. Once happy, close the window.

To delete all log files and other temporary files :

```
% make clean
```

Explore the content of provided files using basic Linux commands, e.g. `cat`, `less` or `more` :

```
% cat  rtl/counter.vhd
% cat  Makefile
% more scripts/sim/compile.tcl etc.
```

