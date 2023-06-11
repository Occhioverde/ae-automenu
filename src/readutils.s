.section .rodata

    up:
	.ascii "\033[A\012"
    
    down:
	.ascii "\033[B\012"

    right:
	.ascii "\033[C\012"

    newline:
	.ascii "\012\000\000\000"

    quit:
	.ascii "q\012\000\000"

.section .text

    .global readutils__getcommand
    
    readutils__getcommand:

	# Sposto l'indirizzo del buffer in %ecx e lo svuoto
	subl $4, %esp
	movl %esp, %ecx
	movl $0, (%ecx)
	
	# Leggo l'input
	movl $3, %eax
	movl $0, %ebx
	movl $4, %edx
	int $0x80 # %eax = 3 => SYS_READ(%ebx = 0 => STDIN, %ecx => Indirizzo del buffer, %edx = 4 => Byte da leggere)

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %ecx, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per la freccia in su
	movl $up, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito SU: vado alla voce precedente
	je uparrw

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %ecx, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per la freccia in giù
	movl $down, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito GIÙ: vado alla voce precedente
	je downarrw

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %ecx, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per la freccia a destra
	movl $right, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito GIÙ: vado alla voce precedente
	je rightarrw

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %ecx, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per l'andata a capo
	movl $newline, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito newline: vado alla voce precedente
	je newlinein

	# Copio l'indirizzo dell'input in %esi per effettuare il confronto
	movl %ecx, %esi
	# Carico in %edi l'indirizzo ove è memorizzata la sequenza di escape per l'uscita
	movl $quit, %edi
	# Confronto le due stringhe puntate da %esi e %edi
	cmpsl
	# Se sono uguali l'utente ha inserito la sequenza di uscita: vado alla voce precedente
	je quitin

	# Nel caso in cui nessun comando valido sia stato inserito, azzero %eax e ritorno
	xorl %eax, %eax
	jmp exit

	uparrw:
	    movl $1, %eax
	    jmp exit
	downarrw:
	    movl $2, %eax
	    jmp exit
	rightarrw:
	    movl $3, %eax
	    jmp exit
	newlinein:
	    movl $4, %eax
	    jmp exit
	quitin:
	    movl $5, %eax

    exit:
	addl $4, %esp
	ret
