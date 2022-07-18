# An Improved LZW Algorithm for Large Data Size and Low Bitwidth per Code
## About this repository
  This repository is about the paper "An Improved LZW Algorithm for Large Data Size and Low Bitwidth per Code". [Paper Link](https://ieeexplore.ieee.org/document/9707201)
## The problem this paper solves
  This paper solves the problem of the LZW algorithm. The compression rate of the LZW algorithm diminished when dealing with too little dictionary capacity for too much input data, causing dictionary overflow and compression rate reduction.
## Brief introduction to the algorithm
  The paper applies the idea of entropy coding by reducing the code length of frequent symbols to improve the LZW algorithm. Specifically, strings are added to the dictionary only when their frequency exceeds a threshold, leaving the dictionary room for frequent strings for further optimization.