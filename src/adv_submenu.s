.section .rodata

    submenu:
	.ascii "\033[2J=== SUBMENU ===\n"

    resetok:
	.ascii "Pressione gomme resettata"

    msglampaggi:
	.ascii "Una cifra; minimo 2, massimo 5:\n"

    arrow:
	.ascii " => "
    
.section .text

    .global submenu_adv__display_menu

    submenu_adv__display_menu:
	# Carico in %esi il numero attuale di lampeggi
	movl 4(%esp), %esi

	# Verifico se devo mostrare il menu delle frecce
	movl $6, %ebx # 6 = Menu frecce direzionali
	cmp %eax, %ebx
	je reqlampeggi

	# Pulisco lo schermo e stampo la scritta "SUBMENU"
	movl $4, %eax
	movl $1, %ebx
	movl $submenu, %ecx
	movl $20, %edx
	int $0x80

	# Stampo la scritta di conferma del reset
	movl $4, %eax
	movl $1, %ebx
	movl $resetok, %ecx
	movl $25, %edx
	int $0x80

	# Leggo il comando
	call readutils__getcommand # RETURN: %eax => Numero del comando
	# Esco dal submenu
	ret

    reqlampeggi:
	# Pulisco lo schermo e stampo la scritta "SUBMENU"
	movl $4, %eax
	movl $1, %ebx
	movl $submenu, %ecx
	movl $20, %edx
	int $0x80
	# Stampo il messaggio con le istruzioni
	movl $4, %eax
	movl $1, %ebx
	movl $msglampaggi, %ecx
	movl $32, %edx
	int $0x80

	# Calcolo il codice ASCII dell'attuale numero di lampeggi
	movl %esi, %ecx
	addl $48, %ecx
	# ...lo salvo in RAM
	pushl %ecx
	# ...e lo stampo a schermo
	movl $4, %eax
	movl $1, %ebx
	movl %esp, %ecx
	movl $1, %edx
	int $0x80
	addl $4, %esp
	# Stampo una freccetta
	movl $4, %eax
	movl $1, %ebx
	movl $arrow, %ecx
	movl $4, %edx
	int $0x80

	# Leggo il nuovo numero di lampaggi
	call readutils__getnum # RETURN: %eax => Numero inserito dall'utente
	
	# Carico i valori di controllo
	movl $2, %ebx # 2 = Minimo numero di lampeggi
	movl $5, %ecx # 5 = Massimo numero di lampeggi
	cmpl %ebx, %eax
	jl applyminimo
	cmpl %ecx, %eax
	jg applymassimo

	savesetting:
	    movl %eax, 4(%esp)
	    ret
	applyminimo:
	    movl $2, 4(%esp)
	    ret
	applymassimo:
	    movl $5, 4(%esp)
	    ret
