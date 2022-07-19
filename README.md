# An Improved LZW Algorithm for Large Data Size and Low Bitwidth per Code

## About this repository
  This repository is about the paper "An Improved LZW Algorithm for Large Data Size and Low Bitwidth per Code". [Paper Link](https://ieeexplore.ieee.org/document/9707201)

## The challenge this paper solves
  This paper solves the challenge of the LZW algorithm when the bit-width for a code is limited and the input size is large. The size of a dictionary = $2^b$ , where *b* is the bit-width of a code. As a result, the challenge for LZW is that when *b* is limited and the input size is large, the dictionary will be prematurely full. Therefore, no new strings can be added to the dictionary, which compromises the compression efficiency.

## Brief introduction to the algorithm
  The paper applies the idea of entropy coding by reducing the code length of frequent symbols to improve the LZW algorithm. Specifically, strings are added to the dictionary only when their frequency reaches a threshold, leaving the dictionary room for frequent strings for further optimization.
