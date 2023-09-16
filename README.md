# VHDL Implementation of Parallel Shear Sort on Mesh

This project demonstrates the implementation of a mesh with a dynamic size to execute the Shear Sort algorithm using VHDL. The primary goal is to efficiently sort a matrix with arbitrary dimensions in a parallel computing environment.

## Project Description

The project contains simulating a matrix with 'n' rows and 'm' columns, where 'n' and 'm' can be configured generically. The simulation is achieved by representing the matrix as an array of nodes initialized in a testbench. The algorithm then converts this array into a matrix, forming the mesh. Additionally, a connections matrix is defined to establish the connections between nodes, based on the torus topology. Once initialized, the Shear Sort algorithm is executed.

### Shear Sort Algorithm

The Shear Sort algorithm is applied to the mesh 'm x n' times using the bubble sort method. The sorting process consists of two main steps:
1. Snakelike sorting of all rows, where even rows are sorted from left to right, and odd rows are sorted from right to left.
2. Column-wise sorting of all columns.

To calculate 'log(n)' before the main algorithm execution, a function is defined to compute the logarithm. The additional unit added to 'log(n)' accounts for the upper limit in the algorithm's complexity.

At the end of the Shear Sort algorithm, the matrix is organized back into the Snakelike form, resulting in an ascending and sorted matrix.

## Results

The project's results showcase the initialization process and the step-by-step execution of the Shear Sort algorithm using VHDL. The initial reset signal is set to '1' in the first clock cycle to reset all matrices and values to zero. Subsequently, in the following clock cycle, the reset signal is reset to '0', allowing the matrix to be initialized and sorted, resulting in the final sorted matrix.

For a visual representation of the project results, refer to the images provided in the repository.

