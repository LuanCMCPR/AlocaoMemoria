# Dynamic memory allocator
On this project, we implemented a version of the [malloc()](https://man7.org/linux/man-pages/man3/malloc.3.html) and [free()](https://man7.org/linux/man-pages/man3/free.3p.html) functions from C, in Assembly AMD64.

To implement this, we included records in the heap for every allocation.

## The record
![image](https://github.com/user-attachments/assets/9814f8a9-6935-4f5a-af0f-f389f5db6cc0)
* Consists of two quadwords, which is 16 bytes (8+8 bytes)
* Use : 0 if the block is free, and 1 if the block is being used
* Size : Size in bytes of the Data Block
After the record is added to the heap, the data block is allocated

## Allocating
1. Searches for a free block of size greater or equal to the request (First-fit strategy).
2. If found, marks as used, and uses just how much was requested, leaving the rest free, and returning the address of the first block.
3. If not found, a new block is created.

## Freeing memory (Avoiding [memory fragmentation](https://en.wikipedia.org/wiki/Fragmentation_(computing)))
1. Checks if the address is valid.
2. If it is, sets use to 0.
3. Checks if there are consecutive free blocks connecting them into larger free blocks.
