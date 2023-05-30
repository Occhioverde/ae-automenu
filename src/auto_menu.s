.section .rodata

    clear:
	# Sequenza di pulizia "^[2J" ("\033" = ESC in ottale)
	.ascii "\033[2J"

    up:
	.ascii "\033[A\012"
    
    down:
	.ascii "\033[B\012"

    right:
	.ascii "\033[C\012"

.section .bss

    supervisor_mode:
	.long 0

    curr_voce:
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
	movl curr_voce, %edi
	call print_voce # %edi => Indice della voce da mostrare

	# Leggo l'input
	# UP\n = a415b1b
	# DOWN\n = a425b1b
	# RIGHT\n = a435b1b
	# LEFT\n = a445b1b
	movl $3, %eax
	movl $0, %ebx
	movl %esp, %ecx
	movl $4, %edx
	int $0x80 # %eax = 3 => SYS_READ(%ebx = 0 => STDIN, %ecx => Indirizzo del buffer, %edx = 4 => Byte da leggere)

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %esp, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per la freccia in su
	movl $up, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito SU: vado alla voce precedente
	je prevvoce

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %esp, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per la freccia in giù
	movl $down, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito GIÙ: vado alla voce precedente
	je nextvoce

	# Se nessuno dei due tasti è stato premuto:
	# System call di uscita (syscall exit)
	movl $1, %eax
	movl $0, %ebx
	int $0x80

    nextvoce:
	movl curr_voce, %eax
	addl $1, %eax
	movl %eax, curr_voce
	jmp printloop

    prevvoce:
	movl curr_voce, %eax
	subl $1, %eax
	movl %eax, curr_voce
	jmp printloop
