.section .rodata

    submenu:
	.ascii "\033[2J=== SUBMENU ===\n"

    resetok:
	.ascii "Pressione gomme resettata"
    
.section .text

    .global submenu_adv__display_menu

    submenu_adv__display_menu:
	# Carico in %esi il numero attuale di lampeggi
	movl 4(%esp), %esi

	# Verifico se devo mostrare il menu delle frecce
	movl $6, %ebx # 6 = Menu frecce direzionali
	cmp %eax, %ebx
	je printloop

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

    printloop:
	# Pulisco lo schermo e stampo la scritta "SUBMENU"
	movl $4, %eax
	movl $1, %ebx
	movl $submenu, %ecx
	movl $20, %edx
	int $0x80

	# Calcolo il codice ASCII dell'attuale numero di lampeggi
	movl %esi, %ecx
	addl $48, %ecx
	# Lo salvo in RAM
	pushl %ecx
	# E lo stampo a schermo
	movl $4, %eax
	movl $1, %ebx
	movl %esp, %ecx
	movl $1, %edx
	int $0x80
	addl $4, %esp

	# Salvo %esi che sarà modificato da readutils
	pushl %esi
	# Leggo il comando
	call readutils__getcommand # RETURN: %eax => Numero del comando
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
	    movl $2, %eax
	    cmpl %esi, %eax
	    je cycledown
	    subl $1, %esi
	    jmp printloop
	cycledown:
	    movl $5, %esi
	    jmp printloop
	godown:
	    movl $5, %eax
	    cmpl %esi, %eax
	    je cycleup
	    addl $1, %esi
	    jmp printloop
	cycleup:
	    movl $2, %esi
	    jmp printloop
	savesetting:
	    movl %esi, 4(%esp)
	    ret
