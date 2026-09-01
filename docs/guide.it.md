# Come usare Humane Space Tab

[English](guide.md) · [Русский](guide.ru.md) · [Deutsch](guide.de.md) ·
[Français](guide.fr.md) · [Español](guide.es.md) · [Português (Brasil)](guide.pt-BR.md) ·
**Italiano** · [Nederlands](guide.nl.md) · [Polski](guide.pl.md) · [Türkçe](guide.tr.md) ·
[Українська](guide.uk.md) · [日本語](guide.ja.md) · [한국어](guide.ko.md) ·
[简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

L’app non ha una finestra propria in cui lavorare: vive nella barra dei menu, e tutto
quello che fa avviene mentre tieni premuta una combinazione di tasti.

![La striscia](images/ribbon.png)

## Il primo avvio

1. Installala — `brew install --cask n0sfer/tap/humane-space-tab`, oppure apri
   l’immagine disco dai Releases e trascina **Humane Space Tab.app** sull’alias di
   Applications — e aprila.
2. Un’app scaricata viene rifiutata la prima volta: apri **Impostazioni di Sistema →
   Privacy e sicurezza**, scorri fino in fondo, premi **Apri comunque** e riaprila.
3. All’avvio l’app chiede l’**Accessibilità**. Concedila in **Impostazioni di Sistema →
   Privacy e sicurezza → Accessibilità**. Il selettore comincia a funzionare in un paio di
   secondi; non serve riaprire l’app.

L’icona nella barra dei menu è l’unica prova che l’app è in funzione: `⇄` quando funziona,
un triangolo di avviso quando non ci riesce. macOS lega il permesso alla firma del codice,
quindi va concesso di nuovo dopo ogni aggiornamento.

## Passare da un’app all’altra

Tieni premuto **⌘** e batti **Tab**. Cosa ottieni dipende da quanto lo tieni:

- **Un tocco rapido** — sotto l’attesa (120 ms di default) — passa all’app precedente
  senza mostrare nulla, come si aspetta la memoria del gesto.
- **Tieni giù ⌘** e appare la striscia con le app della **scrivania corrente**, prima
  quelle usate più di recente. Ogni **Tab** successivo sposta la selezione di un passo.

Mentre la striscia è aperta:

| Tasto | Cosa fa |
|---|---|
| **Tab** | un passo avanti |
| **⇧Tab** | un passo indietro |
| **Escape** | annulla — non viene cambiato nulla |
| rilasciare **⌘** | passa all’app selezionata |

L’app selezionata è l’icona più grande e più viva, con il nome sotto; le vicine sono
smorzate. Da cinque app in poi la striscia diventa un carosello: la selezione resta al suo
posto e le icone scorrono sotto di essa, così un passo è sempre la stessa distanza per
l’occhio e l’elenco non ha estremi — dopo l’ultima app viene la prima. Sotto le cinque ogni
icona resta al suo posto e si muove solo la selezione. La striscia smette di crescere a
dieci posti.

Su una scrivania dove non c’è niente di aperto la striscia risponde lo stesso e dice che lì
non c’è nulla, invece di restituire la battuta al selettore di sistema.

## Passare da una finestra all’altra della stessa app

Tieni premuto **⌘** e batti **`** (il tasto sopra Tab). La striscia elenca le finestre
dell’app in primo piano — solo quelle sulla scrivania corrente, nell’ordine della pila,
ognuna con il suo titolo. Il gesto è lo stesso: `⇧` inverte, Escape annulla, rilasciare
**⌘** porta la finestra davanti.

La combinazione di sistema conta le finestre di tutte le scrivanie insieme, ed è così che
ti sposta su un’altra. Questa non può: una finestra che non è qui non è nell’elenco, quindi
non cambia mai scrivania e non ripristina nulla dal Dock.

## Il mouse

Mentre la striscia è aperta il puntatore agisce su di essa:

- **muovi il mouse** su un’icona per selezionarla — un puntatore che sta soltanto dove la
  striscia si è aperta non cambia nulla finché non si muove;
- **fai clic** su un’icona per passarci subito, senza aspettare che **⌘** venga rilasciato;
- **scorri** sopra la striscia per spostare la selezione.

## Impostazioni

Si aprono dall’icona nella barra dei menu → **Impostazioni…**.

![Impostazioni](images/settings.png)

| Impostazione | Che cos’è |
|---|---|
| **App** | la combinazione che apre la striscia. Fai clic nel campo e digitala, oppure **Ripristina il valore di default** per `⌘Tab`. |
| **Finestre dell’app in primo piano** | la seconda combinazione, `` ⌘` `` di default. |
| **Mostra la striscia su** | lo schermo con il fuoco della tastiera, o quello dove si trova il puntatore. |
| **Lingua** | la lingua dell’interfaccia. **Sistema** segue macOS; le lingue incluse sono elencate con il loro nome. Sceglierne una ridisegna subito la finestra. |
| **Attesa prima di mostrarla** | quanto va tenuta la combinazione prima che la striscia compaia — da 0 a 500 ms. A `0` compare subito. |
| **Apri al login** | registra l’app in macOS come elemento login. |
| **Passa tra finestre, non tra app** | `⌘Tab` elenca allora le finestre, come su Windows e Linux. Disattivo di default: due documenti dello stesso editor diventano due voci. |
| **Usa il livello privato delle scrivanie** | il livello privato sa a quale scrivania appartiene una finestra riposta nel Dock, ma non è documentato. Disattivo, l’app guarda solo le finestre sullo schermo. |

L’app porta quindici lingue — inglese, russo, tedesco, francese, spagnolo, portoghese
(Brasile), italiano, olandese, polacco, turco, ucraino, giapponese, coreano ed entrambe le
scritture cinesi — e per tutto il resto risponde in inglese. In questa guida le diciture
sono citate in italiano.

Una combinazione ha bisogno di un modificatore da tenere premuto, e il registratore rifiuta
ciò che il progetto non può mantenere — una combinazione senza modificatore, una che
contiene già **⇧** (quella è la direzione inversa), **Escape**, `⌘Q` e `⌘W` — e dice quale
dei casi era. La combinazione è disegnata con i tasti della sorgente di input attuale.

## Aspetto

Il secondo pannello di **Impostazioni…** è l’aspetto della striscia, tenuto in profili.
**Default** è quello incorporato e non si modifica: **Duplica** ne fa una copia che si può
modificare, e **Nome** le dà il tuo. Cinque profili oltre a quello incorporato sono il
massimo; eliminando quello attivo resta attivo **Default**.

| Impostazione | Che cos’è |
|---|---|
| **Dimensione delle icone** | quanto grande viene disegnata un’icona al massimo — una striscia affollata le rimpicciolisce comunque per stare nello schermo. |
| **Opacità delle icone** | con quanta forza sono disegnate le icone. 100 % è il massimo; sotto, la selezione si distingue lo stesso, perché il preset smorza tutto ciò che non è selezionato. |
| **Margine della striscia** | lo spazio tra le icone e il bordo della striscia, come frazione dell’icona. |
| **Spazio tra le icone** | lo spazio tra due icone, nella stessa frazione. |
| **Raggio degli angoli** | quanto sono arrotondati gli angoli della striscia. |
| **Cornice attorno all’icona**, **Margine della cornice** | un contorno disegnato attorno all’icona e la sua distanza da essa. |
| **Sfondo** | **Vetro** è il materiale del sistema; **Oscuramento** lo scurisce, e a `0` la striscia è vetro nudo e la scrivania si legge attraverso. **Trasparente** e **Colore di sfondo della finestra** non portano materiale e si regolano con la sola **Opacità**. |
| **Carosello** | con **Fai scorrere la fila sotto la selezione** disattivo la fila resta ferma e si stringe per stare dentro; attivo, **Posti** dice in quante icone scorre — da 5 a 12. |
| **Selezione** | come si riconosce l’icona selezionata: come nel selettore di sistema, ingrandita, sola in evidenza o incorniciata. |

Ogni numero ha un cursore e un campo che mostrano lo stesso valore, e gli intervalli si
rispondono: allargare gli spazi lascia al margine meno spazio per crescere. **Mostra un
esempio…** disegna la striscia con quante app fittizie scegli, per quattro secondi, senza
disturbare la scrivania su cui sei.

## La barra dei menu

| Voce | Quando c’è |
|---|---|
| **Apri Accessibilità…** | finché manca il permesso — lo chiede di nuovo |
| **Apri Monitoraggio ingresso…** | quando macOS trattiene i tasti (vedi sotto) |
| **Impostazioni…** | sempre |
| **Copia l’elenco di app e finestre** | sempre — copia negli appunti l’elenco delle app della scrivania corrente, ed è ciò che va allegato a una segnalazione |
| **Esci da Humane Space Tab** | sempre |

## Quando qualcosa non va

**Nessuna icona nella barra dei menu.** Una barra senza posto libero a sinistra del notch
lascia cadere l’icona: macOS non disegna un elemento di stato che non ci sta, e l’app non
può rivendicare quello spazio. Libera un posto, oppure riapri l’app dal Finder o da
Spotlight — un secondo avvio apre le impostazioni, non una seconda copia.

**L’icona dice che macOS trattiene i tasti.** Una vecchia voce dell’app glielo vieta in
**Impostazioni di Sistema → Privacy e sicurezza → Monitoraggio ingresso**. Rimuovi quella
voce con **−** — all’app il permesso non serve, serve l’assenza di un divieto — e fai di
nuovo clic nell’app; il tap viene ricostruito senza riavvii.

**`⌘Tab` è ancora il selettore di sistema.** Il permesso manca o appartiene alla versione
precedente. Usa **Apri Accessibilità…**, e se l’elenco ha già una voce per l’app,
rimuovila con **−** e concedilo di nuovo.

**«Apri al login» non regge.** Se macOS rifiuta la registrazione lo dice sotto la casella,
con parole sue. Il motivo solito è una versione che il sistema non riconosce: ogni build
locale porta la propria firma ad hoc, quindi una registrazione fatta dalla copia di ieri
non appartiene a quella di oggi. Disattivalo e riattivalo sulla copia che sta in
`/Applications`.

## Che cosa vede l’app

Ha l’Accessibilità, che è ampia, e di proposito ne fa pochissimo uso: nessun codice di
rete, niente AppleEvents, nessun plugin; i tasti vengono esaminati solo per riconoscere la
tua combinazione; i titoli delle finestre sono letti solo mentre il passaggio tra finestre è
attivo, e solo per essere disegnati; il puntatore è visto solo sopra la striscia stessa.
Non chiede mai la Registrazione schermo, ed è per questo che non mostra anteprime delle
finestre. Il modello delle minacce completo è [S00](specs/S00-threat-model.md).
