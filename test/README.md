# Run the test flow

A small VHDL example is provided to **test your environment setup** and **tools installation**.<br/>
A simple GNU `Makefile` is also used to **automate the flows**.

To run the test flows, **open a terminal** and go inside the `test/` directory :


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


## Run a digital simulation using XSim

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

## Implement the design on a target FPGA

Synthesize and map the example RTL code
targeting a [**Digilent Arty A7 development board**](https://store.digilentinc.com/arty-a7-artix-7-fpga-development-board-for-makers-and-hobbyists/) with :

```
% make bit   (same as make bit mode=gui)
```


By default the flow runs in graphics mode. You can also run the flow in interactive (Tcl) or batch modes by specifying the
`mode` variable when invoking `make` :

```
% make bit [mode=gui|tcl|batch]
```

