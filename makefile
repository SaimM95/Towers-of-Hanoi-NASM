all: hantow

hantow: hantow.o asm_io.o driver.c
	 gcc -m32 -o hantow hantow.o driver.c asm_io.o
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm
hantow.o: hantow.asm
	nasm -f elf32 -o hantow.o hantow.asm
clean:
	rm *.o hantow
