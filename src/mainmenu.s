.section .rodata

    menu:
	.ascii "\033[2J=== MENU ===\n"

    on:
	.ascii "ON"
    off:
	.ascii "OFF"

    voce1:
	.ascii "Setting automobile:"
    voce2:
	.ascii "Data: 15/06/2014"
    voce3:
	.ascii "Ora: 15:32"
    voce4:
	.ascii "Blocco automatico porte: "
    voce5:
	.ascii "Back-home: "
    voce6:
	.ascii "Check olio"
    voce7:
	.ascii "Frecce direzione"
    voce8:
	.ascii "Reset pressione gomme"
    voci_menu:
	.long voce1, voce2, voce3, voce4, voce5, voce6, voce7, voce8

    len_voci:
	.long 19, 16, 10, 25, 11, 10, 16, 21

.section .text

    .global mainmenu__print_voce

    mainmenu__print_voce:
	# Sposto in %edi l'indice della voce da mostrare
	movl %eax, %edi
	
	# Pulisco lo schermo e stampo la scritta "MENU"
	movl $4, %eax
	movl $1, %ebx
	movl $menu, %ecx
	movl $17, %edx
	int $0x80

	# Carico in %eax l'indirizzo del vettore con i puntatori alle voci del menu
	movl $voci_menu, %eax
	# Carico in %ebx l'indirizzo del vettore delle lunghezze delle voci
	movl $len_voci, %ebx
	# La voce si trova all'indirizzo puntato da %eax + 4*%edi
	movl (%eax, %edi, 4), %ecx
	# La lunghezza della voce è puntata da %ebx + 4*%edi
	movl (%ebx, %edi, 4), %edx

	# Stampo la voce richiesta
	movl $4, %eax
	movl $1, %ebx
	int $0x80

	movl $3, %esi
	cmpl %edi, %esi
	je print_statobloccoporte
	movl $4, %esi
	cmpl %edi, %esi
	je print_statobackhome
	ret

	print_statobloccoporte:
	    movl $4, %esi
	    jmp printstato

	print_statobackhome:
	    movl $8, %esi
	    jmp printstato

	printstato:
	    movl $4, %eax
	    movl $1, %ebx
	    movl (%esp, %esi, 1), %esi
	    movl $0, %edi
	    cmpl %esi, %edi
	    je printoff
	    # Stampo la scritta "ON"
	    movl $on, %ecx
	    movl $2, %edx
	    int $0x80
	    jmp doret
	printoff:
	    # Stampo la scritta "OFF"
	    movl $off, %ecx
	    movl $3, %edx
	    int $0x80

	doret:
	    ret
	