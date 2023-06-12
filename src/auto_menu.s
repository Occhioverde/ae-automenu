## File auto_menu.s
##
## Entrypoint del programma. Contiene il loop principale.
##
## Ghellere Nicolò, Milli Manuel, Riccardo Sacchetto
    
.section .rodata

    admincode:
	.ascii "2244"

.section .bss

    supervisor_mode:
	.long 0

    curr_voce:
	.long 0

    stato_bloccoporte:
	.long 0

    stato_backhome:
	.long 0

.section .data

    stato_freccedirezione:
	.long 3

.section .text

    .global _start

    _start:
	# Verifico che ci sia ESATTAMENTE un parametro (il codice supervisor)
	movl (%esp), %eax
	movl $2, %ebx
	# Se ci sono più o meno di due parametri, entro come utente
	cmpl %eax, %ebx
	jne printloop
	
	# Preparo il codice di sicurezza per il controllo
	movl 8(%esp), %edi
	movl $admincode, %esi
	# Controllo l'inserimento del codice supervisor
	cmpsl
	# Se è errato, entro come utente
	jne printloop

	# Altrimenti, entro come supervisiore
	movl $1, supervisor_mode

    printloop:
	# Recupero il valore di curr_voce per decidere la voce da mostrare e lo carico in %edi per print_voce
	movl curr_voce, %eax
	pushl supervisor_mode
	pushl stato_backhome
	pushl stato_bloccoporte
	call mainmenu__print_voce # PARAMS: %eax => Indice della voce da mostrare
	                          #         %esp => Stato del blocco delle porte
				  #         %esp+4 => Stato del back-home
				  #         %esp+8 => Stato della modalità supervisor

	# Leggo il comando
	call readutils__getcommand # RETURN: %eax => Numero del comando

	# Se l'utente ha inserito una sequenza non riconosciuta, ignoro l'input
	xorl %ebx, %ebx
	cmpl %eax, %ebx
	je printloop
	
	# Altrimenti, decodifico l'input
	movl $1, %ebx # UP = 1
	movl $2, %ecx # DOWN = 2
	movl $3, %edx # RIGHT = 3
	movl $5, %edi # Quit = 5
	cmpl %eax, %ebx
	je prevvoce
	cmpl %eax, %ecx
	je nextvoce
	cmpl %eax, %edx
	je entersubmenu

	# Se l'utente non ha inserito la sequenza di uscita, ignoro l'input
	cmpl %eax, %edi
	jne printloop
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
	je onoff_submenu
	movl $4, %ebx # Back home = 4
	cmpl %eax, %ebx
	je onoff_submenu
	movl $6, %ebx # Back home = 4
	cmpl %eax, %ebx
	je adv_submenu
	movl $7, %ebx # Back home = 4
	cmpl %eax, %ebx
	je adv_submenu
	jmp nosubmenu

	onoff_submenu:
	    # Entro nel submenu ON/OFF
	    pushl stato_backhome
	    pushl stato_bloccoporte
	    call submenu_onoff__display_menu # PARAMS: %eax => ID del menu da mostrare
	                                     #         %esp => Stato del back home
	                                     #         %esp+4 => Stato del blocco delle porte
	    popl %eax
	    movl %eax, stato_bloccoporte
	    popl %eax
	    movl %eax, stato_backhome
	    jmp printloop
	adv_submenu:
	    # Entro nel submenu avanzato
	    pushl stato_freccedirezione
	    call submenu_adv__display_menu # PARAMS: %eax => ID del menu da mostrare
	                                   #         %esp => Stato delle frecce di direzione
	    popl %eax
	    movl %eax, stato_freccedirezione
	nosubmenu:
	    # Torno in cima al printloop
	    jmp printloop
