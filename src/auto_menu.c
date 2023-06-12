#include <string.h>
#include <unistd.h>

void mainmenu__print_voce(int curr_voce, _Bool stato_bloccoporte,
			  _Bool stato_backhome, _Bool supervisor_mode) {
  // Header del Menu
  char *menu = "\033[2J=== MENU ===\n";
  // Array di voci del menu (e relative lunghezze)
  char *voci_menu[] = {
      "Setting automobile",       "Data: 15/06/2014",     "Ora: 15:32",
      "Blocco automatico porte: ", "Back-home: ",          "Check olio",
      "Frecce direzione",          "Reset pressione gomme"};
  int len_voci[] = {18, 16, 10, 25, 11, 10, 16, 21};
  // Array di diciture on/off (e relative lunghezze)
  char *onoffarr[] = {"OFF", "ON"};
  int onofflens[] = {3, 2};
  // Array di messaggi per "Setting automobile"
  char *notices[] = {":", " (Supervisor):"};
  int len_notices[] = {1, 14};

  // Pulisco lo schermo e stampo la scritta "MENU"
  (void)!write(1, menu, 17);

  // Stampo la voce attuale
  (void)!write(1, voci_menu[curr_voce], len_voci[curr_voce]);

  if (curr_voce == 0) {
    (void)!write(1, notices[supervisor_mode], len_notices[supervisor_mode]);
  } else if (curr_voce == 3) { // Se la voce corrente è blocco porte o back
			       // home, ne stampo lo stato
    (void)!write(1, onoffarr[stato_bloccoporte], onofflens[stato_bloccoporte]);
  } else if (curr_voce == 4) {
    (void)!write(1, onoffarr[stato_backhome], onofflens[stato_backhome]);
  }
}

int readutils__getcommand() {
  // Preparo un buffer
  char buf[4] = {};

  // Leggo l'input
  (void)!read(0, buf, 4);

  // Inserito UP
  if (!strncmp("\033[A\012", buf, 4))
    return 1;
  // Inserito DOWN
  else if (!strncmp("\033[B\012", buf, 4))
    return 2;
  // Inserito RIGHT
  else if (!strncmp("\033[C\012", buf, 4))
    return 3;
  // Inserito NEWLINE
  else if (!strncmp("\012\000\000\000", buf, 4))
    return 4;
  // Inserito q
  else if (!strncmp("q\012\000\000", buf, 4))
    return 5;
  return 0;
}

int readutils__getnum() {
  // Preparo un buffer
  char buf[4] = {};

  // Leggo l'input
  (void)!read(0, buf, 2);

  // Se il carattere inserito non è un numero
  if (buf[0] < 48 || buf[0] > 57)
    return 0; // Ritorno 0
  // Altrimenti lo ritorno dopo averlo convertito da ASCII
  return buf[0] - 48;
}

void submenu_onoff__display_menu(int menuid, _Bool *stato_bloccoporte,
				 _Bool *stato_backhome) {
  // Header del Submenu
  char *submenu = "\033[2J=== SUBMENU ===\n";
  // Array di diciture on/off (e relative lunghezze)
  char *onoffarr[] = {"OFF", "ON"};
  int onofflens[] = {3, 2};
  // Riferimento allo stato della voce in modifica
  _Bool *stato_voce;

  // Carico lo stato corretto
  if (menuid == 3)
    stato_voce = stato_bloccoporte;
  else if (menuid == 4)
    stato_voce = stato_backhome;

  while (1) {
    // Pulisco lo schermo e stampo la scritta "SUBMENU"
    (void)!write(1, submenu, 20);

    // Stampo la voce attuale
    (void)!write(1, onoffarr[*stato_voce], onofflens[*stato_voce]);

    // Leggo il comando dell'utente
    int usrcmd = readutils__getcommand();
    // Se ha inserito UP o DOWN, nego lo stato attuale
    if (usrcmd == 1) {
      *stato_voce = !(*stato_voce);
    } else if (usrcmd == 2) {
      *stato_voce = !(*stato_voce);
    } else if (usrcmd == 4) {
      // Esco quando viene premuto invio
      return;
    }
  }
}

void submenu_adv__display_menu(int menuid, int *stato_freccedirezione) {
  // Header del Submenu e stringhe varie
  char submenu[] = "\033[2J=== SUBMENU ===\n", msglampeggi[] = "Una cifra; minimo 2, massimo 5:\n", arrow[] = " => ";

  // Se non è stato aperto il menu della voce 6 (numero lampeggi)
  if (menuid != 6) {
    // Dicitura reset riuscito
    char *resetok = "Pressione gomme resettata";
    // Pulisco lo schermo e stampo la scritta "SUBMENU"
    (void)!write(1, submenu, 20);
    // Stampo la scritta di conferma del reset
    (void)!write(1, resetok, 25);
    // Attendo l'input
    readutils__getcommand();
    // Esco dal sottomenu
    return;
  }

  // Pulisco lo schermo e stampo la scritta "SUBMENU"
  (void)!write(1, submenu, 20);

  // Stampo il messaggio con le istruzioni
  (void)!write(1, msglampeggi, 32);

  // Stampo il codice ASCII dell'attuale numero di lampeggi
  int ascii_num_lampeggi = *stato_freccedirezione + 48;
  (void)!write(1, &ascii_num_lampeggi, 1);

  // Stampo la freccetta
  (void)!write(1, arrow, 4);

  // Leggo il nuovo numero di lampaggi
  int newlampeggi = readutils__getnum();
  // Controllo che il valore sia nel range 2-5
  if (newlampeggi < 2)
    *stato_freccedirezione = 2;
  else if (newlampeggi > 5)
    *stato_freccedirezione = 5;
  else
    *stato_freccedirezione = newlampeggi;
  return;
}

int main(int argc, char **argv) {
  // Variabili di stato
  int curr_voce = 0, stato_freccedirezione = 3;
  _Bool supervisor_mode = 0, stato_bloccoporte = 0, stato_backhome = 0;

  // Verifico che ci sia ESATTAMENTE un parametro (il codice supervisor)
  if (argc == 2) {
    // Controllo l'inserimento del codice supervisor
    if (!strncmp("2244", argv[1], 4)) {
      // Se è ccorretto, entro come supervisiore
      supervisor_mode = 1;
    }
  }

  while (1) {
    // Stampo a schermo la voce da mostrare
    mainmenu__print_voce(curr_voce, stato_bloccoporte, stato_backhome, supervisor_mode);

    // Leggo il comando dell'utente
    int usrcmd = readutils__getcommand();
    // Calcolo l'indice dell'ultima voce esistente
    int maxvoce = 5 + (2 * supervisor_mode);
    // Se l'utente ha inserito UP
    if (usrcmd == 1) {
      // Se sono alla prima voce
      if (curr_voce == 0)
	// vado all'ultima,
	curr_voce = maxvoce;
      else
	// altrimenti torno alla precedente
	curr_voce--;
    } else if (usrcmd == 2) { // Se l'utente ha inserito DOWN
      // Se sono all'ultima voce
      if (curr_voce == maxvoce)
	// torno alla prima,
	curr_voce = 0;
      else
	// altrimenti vado alla successiva
	curr_voce++;
    } else if (usrcmd == 3 && (curr_voce == 3 || curr_voce == 4)) { // Se l'utente ha inserito RIGHT per una voce con menu on/off
      // Entro nel submenu on/off
      submenu_onoff__display_menu(curr_voce, &stato_bloccoporte, &stato_backhome);
    } else if (usrcmd == 3 && (curr_voce == 6 || curr_voce == 7)) { // Se l'utente ha inserito RIGHT per una voce con menu avanzato
      // Entro nel submenu avanzato
      submenu_adv__display_menu(curr_voce, &stato_freccedirezione);
    } else if (usrcmd == 5) {
      // Esco quando viene inserito "q"
      return 0;
    }
  }
}
