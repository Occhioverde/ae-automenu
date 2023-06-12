.section .rodata

    menu:
	.ascii "\033[2J=== MENU ===\n"

    on:
	.ascii "ON"
    off:
	.ascii "OFF"
    onoffarr:
	.long off, on
    onofflens:
	.long 3, 2

    voce1:
	.ascii "Setting automobile"
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
	.long 18, 16, 10, 25, 11, 10, 16, 21

    std_notice:
	.ascii ":"
    sup_notice:
	.ascii " (Supervisor):"
    notices:
	.long std_notice, sup_notice
    len_notices:
	.long 1, 14


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

	# La voce si trova all'indirizzo puntato da voci_menu + 4*%edi
	movl voci_menu(, %edi, 4), %ecx
	# La lunghezza della voce è puntata da len_voci + 4*%edi
	movl len_voci(, %edi, 4), %edx

	# Stampo la voce richiesta
	movl $4, %eax
	movl $1, %ebx
	int $0x80

	movl $0, %esi
	cmpl %edi, %esi
	je print_notice
	movl $3, %esi
	cmpl %edi, %esi
	je print_statobloccoporte
	movl $4, %esi
	cmpl %edi, %esi
	je print_statobackhome
	ret

	print_notice:
	    movl $4, %eax
	    movl $1, %ebx
	    movl 12(%esp), %esi
	    movl notices(, %esi, 4), %ecx
	    movl len_notices(, %esi, 4), %edx
	    int $0x80
	    ret

	print_statobloccoporte:
	    movl $4, %esi
	    jmp printstato

	print_statobackhome:
	    movl $8, %esi

	printstato:
	    movl $4, %eax
	    movl $1, %ebx
	    movl (%esp, %esi, 1), %esi
	    movl onoffarr(, %esi, 4), %ecx
	    movl onofflens(, %esi, 4), %edx
	    int $0x80
	    ret
	