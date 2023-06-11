MODULES = obj/auto_menu.o obj/mainmenu.o obj/readutils.o obj/onoff_submenu.o obj/adv_submenu.o

ASFLAGS = --32
LDFLAGS = -m elf_i386
GCCFLAGS =

release: clean bin/auto_menu bin/auto_menu-c

debug: ASFLAGS += --gstabs
debug: GCCFLAGS += -g
debug: clean bin/auto_menu bin/auto_menu-c

bin/auto_menu: $(MODULES)
	ld $(LDFLAGS) -o bin/auto_menu $^

bin/auto_menu-c:
	gcc $(GCCFLAGS) -o bin/auto_menu-c src/auto_menu.c

clean:
	rm -f bin/auto_menu* obj/*.o

obj/%.o: src/%.s
	as $(ASFLAGS) -o $@ $<
