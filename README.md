# Pipeline CPU

## Introduction

In this project, we implemented a pipeline CPU based on Verilog language, which can correctly execute our test file `Test_37_Instr` (including data adventure, structure adventure, control adventure, and $$37$$ basic instructions). We can correctly execute instructions on the development board `Nexys A7` after generating a bit stream through `Vivado`.

## Design reference

Our designs are based on the book Computer Organization and Design RISC-V Edition: The Hardware Software Interface.

## Test the CPU

We use `iVerilog` to compile and `WaveTrace` extensions to visualize the wave and get the results in the register.

`sccomp_tb.v` is used for writing the test data to the memory.

More specifically, after configuring the appropriate environment, just run the following commands to test the CPU.

```
iverilog sccomp_tb.v
vvp -n a.out
```



You can also use your test data by modifying the `sccomp_tb.v` file, remembering to convert the test assembly code to machine code.

## Improve the CPU

The CPU performance we implemented still needs to be improved in some aspects, and it can only run one or more frequency division coefficients normally when testing on the development board. But an excellent implementing pipeline CPU can run zero frequency division coefficient.
