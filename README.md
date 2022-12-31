# 5stage-pipelined-cpu

Five-stage pipelined CPU written in SystemVerilog. The image below shows the components and the five stages. Not pictured in the image is a control system that determines the control signals. The dotted lines indicate the pipeline registers that hold data for the respective stage.

![image](https://user-images.githubusercontent.com/72935428/210109509-f4e97ad3-6d55-41d6-824c-8d7d5b98858c.png)

The folder "benchmarks" contains instructions written in machine code, and the CPU converts the machine code into an instruction. 
The code can be tested in ModelSim by running "do runlab.do". 

Below are the following instructions that the pipelined CPU supports. All benchmarks except fibonacci run 100% correctly.

<img width="528" alt="image" src="https://user-images.githubusercontent.com/72935428/210109760-7eaa4910-b908-4983-b7d2-a1e20b3bbeec.png">


