# An Improved LZW Algorithm for Large Data Size and Low Bitwidth per Code

## Table of contents

<!--ts-->
   * [About this repository](#about-this-repository)
   * [The challenge this paper solves](#the-challenge-this-paper-solves)
   * [Brief introduction to the algorithm](#brief-introduction-to-the-algorithm)
<!--te-->

## About this repository
  1. This repository is about the paper "An Improved LZW Algorithm for Large Data Size and Low Bitwidth per Code" published on [TENCON 2021](https://tencon2021.com/). [Paper Link](https://ieeexplore.ieee.org/document/9707201)
  2. The compression ratio of the proposed algorithm increases by 6.0% compared to the [LZW algorithm](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch)..

## The challenge this paper solves
  This paper solves the challenge of the LZW algorithm when the bit-width for a code is limited and the input size is large. The size of a dictionary = $2^b$ , where *b* is the bit-width of a code. As a result, the challenge for LZW is that when *b* is limited and the input size is large, the dictionary will be prematurely full. Therefore, no new strings can be added to the dictionary, which compromises the compression efficiency.

## Brief introduction to the algorithm
  The paper applies the idea of entropy coding by reducing the code length of frequent symbols to improve the LZW algorithm. Specifically, strings are added to the dictionary only when their frequency reaches a threshold, leaving the dictionary room for frequent strings for further optimization.

## Introduction to the files
  1. `./src/proposed_algorithm.m`: This file is the proposed algorithm. It outperforms the LZW algorithm by 6.0% on the compression ratio.
  2. `./src/Control_group/LZW.m`The implementation of a [LZW algorithm](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch).
  3. `./src/Control_group/LZ77.m`The implementation of [LZ77](https://en.wikipedia.org/wiki/LZ77_and_LZ78#LZ77).
  4. `./src/Control_group/LZ78.m`The implementation of [LZ78](https://en.wikipedia.org/wiki/LZ77_and_LZ78#LZ78).
  5. `./src/Control_group/LZSS.m`The implementation of [Lempel–Ziv–Storer–Szymanski](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Storer%E2%80%93Szymanski).
  6. `./src/Control_group/Adaptive_arithmetic_coding.m`: The implementation of [adaptive arithmetic coding](https://en.wikipedia.org/wiki/Arithmetic_coding#Adaptive_arithmetic_coding).
  7. `./src/Control_group/Static_arithmetic_coding.m`:The implementation of [arithmetic coding](https://en.wikipedia.org/wiki/Arithmetic_coding), with the pre-defined frequency table.
  8. `./src/Control_group/Huffman_coding.m`: The implementation of [Huffman coding](https://en.wikipedia.org/wiki/Huffman_coding).
  9. `./Test_patterns` Six test patterns used in the simulation.