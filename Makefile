auto_menu: clean auto_menu.o mainmenu.o readutils.o submenu.o
	ld -m elf_i386 -o bin/auto_menu obj/auto_menu.o obj/mainmenu.o obj/readutils.o obj/submenu.o

clean:
	rm -f bin/auto_menu obj/*.o

auto_menu.o:
	as --32 --gstabs -o obj/auto_menu.o src/auto_menu.s

mainmenu.o:
	as --32 --gstabs -o obj/mainmenu.o src/mainmenu.s

readutils.o:
	as --32 --gstabs -o obj/readutils.o src/readutils.s

submenu.o:
	as --32 --gstabs -o obj/submenu.o src/submenu.s
