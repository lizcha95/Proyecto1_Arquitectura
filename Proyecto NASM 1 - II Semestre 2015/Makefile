regex: regex.o
	ld -o regex regex.o

regex.o: regex.asm
	nasm -felf64 regex.asm
