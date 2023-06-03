.section .rodata

    submenu:
	.ascii "\033[2J=== SUBMENU ===\n"

    on:
	.ascii "ON"
    off:
	.ascii "OFF"
    onoffarr:
	.long off, on
    onofflens:
	.long 3, 2

    
.section .text

    .global submenu__display_menu

    submenu__display_menu:
	# Trasformo l'indice del menu nel valore di spiazzamento dello stack (4 = Blocco porte, 8 = Back home) e lo carico in %edi
	subl $2, %eax
	movl $4, %ebx
	mull %ebx
	movl %eax, %edi
	# Carico in %esi il valore di partenza della configurazione
	movl (%esp, %edi, 1), %esi
	# Metto sullo stack lo spiazzamento calcolato per riutilizzarlo in fase di salvataggio
	pushl %edi

    printloop:
	# Pulisco lo schermo e stampo la scritta "SUBMENU"
	movl $4, %eax
	movl $1, %ebx
	movl $submenu, %ecx
	movl $20, %edx
	int $0x80

	movl $onoffarr, %eax
	movl $onofflens, %ebx
	movl (%eax, %esi, 4), %ecx
	movl (%ebx, %esi, 4), %edx
	movl $4, %eax
	movl $1, %ebx
	int $0x80

	# Salvo %esi che sarà modificato da readutils
	pushl %esi
	# Preparo un buffer sullo stack
	subl $4, %esp
	# Ne salvo l'indirizzo in %eax
	movl %esp, %eax
	# Recupero il comando
	call readutils__getcommand # PARAMS: %eax => Indirizzo del buffer
	                           # RETURN: %eax => Numero del comando
	# Elimino il buffer
	addl $4, %esp
	# Recupero il valore di %esi
	popl %esi
	
	# Carico i valori di controllo
	movl $1, %ebx # 1 = UP
	movl $2, %ecx # 2 = DOWN
	movl $4, %edx # 3 = ENTER
	# Se l'utente ha inserito UP
	cmpl %eax, %ebx
	je goup
	# Se l'utente ha inserito DOWN
	cmpl %eax, %ecx
	je godown
	# Se l'utente ha inserito ENTER
	cmpl %eax, %edx
	je savesetting
	# Se l'input non è valido, lo ignoro
	jmp printloop

	goup:
	    xorl %eax, %eax
	    cmpl %esi, %eax
	    je cycledown
	    subl $1, %esi
	    jmp printloop
	cycledown:
	    movl $1, %esi
	    jmp printloop
	godown:
	    movl $1, %eax
	    cmpl %esi, %eax
	    je cycleup
	    addl $1, %esi
	    jmp printloop
	cycleup:
	    xorl %esi, %esi
	    jmp printloop
	savesetting:
	    popl %edi
	    movl %esi, (%esp, %edi, 1)
	    ret
