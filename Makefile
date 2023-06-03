auto_menu: clean auto_menu.o mainmenu.o readutils.o onoff_submenu.o adv_submenu.o
	ld -m elf_i386 -o bin/auto_menu obj/auto_menu.o obj/mainmenu.o obj/readutils.o obj/onoff_submenu.o obj/adv_submenu.o

clean:
	rm -f bin/auto_menu obj/*.o

auto_menu.o:
	as --32 --gstabs -o obj/auto_menu.o src/auto_menu.s

mainmenu.o:
	as --32 --gstabs -o obj/mainmenu.o src/mainmenu.s

readutils.o:
	as --32 --gstabs -o obj/readutils.o src/readutils.s

onoff_submenu.o:
	as --32 --gstabs -o obj/onoff_submenu.o src/onoff_submenu.s

adv_submenu.o:
	as --32 --gstabs -o obj/adv_submenu.o src/adv_submenu.s
