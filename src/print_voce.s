.section .rodata

    menu:
	.ascii "=== MENU ===\n"

    voce1:
	.ascii "Setting automobile:"
    voce2:
	.ascii "Data: 15/06/2014"
    voce3:
	.ascii "Ora: 15:32"
    voce4:
	.ascii "Blocco automatico porte: ON"
    voce5:
	.ascii "Back-home: ON"
    voce6:
	.ascii "Check olio"
    voci_menu:
	.long voce1, voce2, voce3, voce4, voce5, voce6

    len_voci:
	.long 19, 16, 10, 27, 13, 10

.section .text

    .global print_voce

    print_voce:
	# Stampo la scritta "MENU"
	movl $4, %eax
	movl $1, %ebx
	movl $menu, %ecx
	movl $13, %edx
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

	ret
	