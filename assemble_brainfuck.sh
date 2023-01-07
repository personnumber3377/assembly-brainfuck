
nasm -f elf64 bf.asm -o bf.o
ld bf.o -o bf
rm bf.o