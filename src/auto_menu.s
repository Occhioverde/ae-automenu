.section .rodata

    clear:
	# Sequenza di pulizia "^[2J" ("\033" = ESC in ottale)
	.ascii "\033[2J"

.section .bss

    supervisor_mode:
	.long 0

    curr_voce:
	.long 0

    stato_bloccoporte:
	.long 0

    stato_backhome:
	.long 0

.section .text

    .global _start
    .extern print_voce # Importato da src/print_voce.s

    _start:
	# Preparo dello spazio nello stack
	subl $4, %esp


    printloop:
	# Pulisco il terminale inviando la apposita sequenza attraverso la syscall write.
	movl $4, %eax
	movl $1, %ebx
	movl $clear, %ecx
	movl $4, %edx
	int $0x80

	# Recupero il valore di curr_voce per decidere la voce da mostrare e lo carico in %edi per print_voce
	movl curr_voce, %eax
	pushl stato_backhome
	pushl stato_bloccoporte
	call mainmenu__print_voce # PARAMS: %eax => Indice della voce da mostrare
	                          #         %esp => Stato del back home
				  #         %esp+4 => Stato del blocco delle porte

	# Leggo il comando
	movl %esp, %eax
	call readutils__getcommand # PARAMS: %eax => Indirizzo del buffer
	                           # RETURN: %eax => Numero del comando
	movl $1, %ebx # UP = 1
	movl $2, %ecx # DOWN = 2
	movl $3, %edx # RIGHT = 3
	cmpl %eax, %ebx
	je prevvoce
	cmpl %eax, %ecx
	je nextvoce
	cmpl %eax, %edx
	je entersubmenu

	# Se nessuno dei due tasti è stato premuto:
	# System call di uscita (syscall exit)
	movl $1, %eax
	movl $0, %ebx
	int $0x80

    nextvoce:
	# Carico l'indice della voce attuale
	movl curr_voce, %ecx
	# Computo l'indice massimo
	# Indice massimo per la voce: 5 + (2 * supervisor_mode)
	movl supervisor_mode, %eax
	movl $2, %ebx
	mull %ebx
	addl $5, %eax
	# Confronto i due indici
	cmpl %ecx, %eax
	# Se sono uguali, wrap a 0, altrimenti attuale + 1
	je wrapnext
	gtnext:
	    addl $1, %ecx
	    jmp savecambio
	wrapnext:
	    xorl %ecx, %ecx # %ecx = 0
	    jmp savecambio

    prevvoce:
	# Carico l'indice della voce attuale
	movl curr_voce, %ecx
	# Verifico se l'attuale indirizzo è 0
	xorl %eax, %eax
	cmpl %ecx, %eax
	# Se sì, wrap al massimo, altrimenti attuale - 1
	je wrapprev
	gtprev:
	    subl $1, %ecx
	    jmp savecambio
	wrapprev:
	    # Per fare il wrap al massimo, computo quest'ultimo
	    # Indice massimo per la voce: 5 + (2 * supervisor_mode)
	    movl supervisor_mode, %eax
	    movl $2, %ebx
	    mull %ebx
	    addl $5, %eax
	    # Lo salvo nel registro dell'indice attuale
	    movl %eax, %ecx
	    jmp savecambio
	
    savecambio:
	# Salvo il nuovo indice in RAM
	movl %ecx, curr_voce
	# Torno in cima al printloop
	jmp printloop

    entersubmenu:
	# Carico l'indice della voce attuale
	movl curr_voce, %eax
	movl $3, %ebx # Blocco porte = 3
	cmpl %eax, %ebx
	je doentersubmenu
	movl $4, %ebx # Back home = 4
	cmpl %eax, %ebx
	je doentersubmenu
	jmp noentersubmenu

	doentersubmenu:
	    # Entro nel submenu
	    pushl stato_backhome
	    pushl stato_bloccoporte
	    call submenu__display_menu # PARAMS: %eax => ID del menu da mostrare
	                             #         %esp => Stato del back home
	                             #         %esp+4 => Stato del blocco delle porte
	    popl %eax
	    movl %eax, stato_bloccoporte
	    popl %eax
	    movl %eax, stato_backhome
	noentersubmenu:
	    # Torno in cima al printloop
	    jmp printloop
