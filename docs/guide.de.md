# Humane Space Tab benutzen

[English](guide.md) · [Русский](guide.ru.md) · **Deutsch** · [Français](guide.fr.md) ·
[Español](guide.es.md) · [Português (Brasil)](guide.pt-BR.md) · [Italiano](guide.it.md) ·
[Nederlands](guide.nl.md) · [Polski](guide.pl.md) · [Türkçe](guide.tr.md) ·
[Українська](guide.uk.md) · [日本語](guide.ja.md) · [한국어](guide.ko.md) ·
[简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

Die App hat kein eigenes Fenster, in dem man arbeitet: sie lebt in der Menüleiste, und
alles, was sie tut, geschieht, während ein Tastenkürzel gedrückt gehalten wird.

![Die Leiste](images/ribbon.png)

## Der erste Start

1. Installieren — `brew install --cask n0sfer666/tap/humane-space-tab`, oder das
   Image aus den Releases öffnen und **Humane Space Tab.app** auf das
   Applications-Symbol ziehen — und starten.
2. Eine geladene App wird beim ersten Mal abgewiesen — **Systemeinstellungen →
   Datenschutz & Sicherheit** öffnen, ganz nach unten scrollen, **Trotzdem öffnen**
   drücken und noch einmal starten.
3. Beim Start fragt die App nach **Bedienungshilfen**. Erteile die Berechtigung in
   **Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen**. Der Umschalter
   arbeitet nach ein paar Sekunden; ein Neustart ist nicht nötig.

Das Symbol in der Menüleiste ist der einzige Beleg dafür, dass die App läuft: `⇄`, wenn
sie arbeitet, ein Warndreieck, wenn sie es nicht kann. macOS bindet die Berechtigung an
die Signatur, also muss sie nach jedem Update erneut erteilt werden.

## Zwischen Apps wechseln

**⌘** halten und **Tab** tippen. Was passiert, hängt davon ab, wie lange gehalten wird:

- **Ein kurzer Tipp** — kürzer als die Verzögerung (voreingestellt 120 ms) — wechselt zur
  vorherigen App, ohne etwas zu zeigen, so wie es das Muskelgedächtnis erwartet.
- **⌘ gedrückt lassen**, und die Leiste erscheint mit den Apps des **aktuellen
  Schreibtischs**, zuletzt benutzte zuerst. Jedes weitere **Tab** rückt die Auswahl weiter.

Solange die Leiste offen ist:

| Taste | Was sie tut |
|---|---|
| **Tab** | einen Schritt vorwärts |
| **⇧Tab** | einen Schritt zurück |
| **Escape** | Abbruch — es wird nichts gewechselt |
| **⌘** loslassen | zur ausgewählten App wechseln |

Die ausgewählte App ist das Symbol, das größer und kräftiger ist und seinen Namen darunter
trägt; die Nachbarn sind abgedunkelt. Ab fünf Apps wird die Leiste zum Karussell: die
Auswahl bleibt an ihrem Platz und die Symbole drehen sich darunter, ein Schritt ist also
für das Auge immer derselbe Weg, und die Liste hat kein Ende — nach der letzten App kommt
die erste. Unter fünf behält jedes Symbol seinen Platz und nur die Auswahl wandert. Bei
zehn Plätzen hört die Leiste auf zu wachsen.

Auf einem Schreibtisch, auf dem nichts offen ist, antwortet die Leiste trotzdem und sagt,
dass dort nichts ist, statt den Tastendruck an den System-Umschalter zurückzugeben.

## Zwischen den Fenstern einer App wechseln

**⌘** halten und **`** tippen (die Taste über Tab). Die Leiste zeigt die Fenster der
vordersten App — nur die auf dem aktuellen Schreibtisch, in ihrer Stapelreihenfolge, jedes
mit seinem Titel. Die Geste ist dieselbe: `⇧` kehrt die Richtung um, Escape bricht ab, ein
losgelassenes **⌘** holt das Fenster nach vorn.

Das Systemkürzel zählt die Fenster aller Schreibtische auf einmal — deshalb wirft es einen
auf einen anderen. Dieses hier kann das nicht: ein Fenster, das nicht hier ist, steht auch
nicht in der Liste, also wechselt es nie den Schreibtisch und holt nichts aus dem Dock
zurück.

## Die Maus

Solange die Leiste offen ist, arbeitet der Zeiger auf ihr:

- **die Maus bewegen** über einem Symbol wählt es aus — ein Zeiger, der bloß dort liegt,
  wo die Leiste aufgegangen ist, ändert nichts, bis er sich bewegt;
- **klicken** wechselt sofort zu diesem Symbol, ohne auf **⌘** zu warten;
- **scrollen** über der Leiste rückt die Auswahl weiter.

## Einstellungen

Zu öffnen über das Menüleistensymbol → **Einstellungen…**.

![Einstellungen](images/settings.png)

| Einstellung | Was sie ist |
|---|---|
| **Apps** | das Kürzel, das die Leiste öffnet. In das Feld klicken und die Kombination tippen, oder **Standard wiederherstellen** für `⌘Tab`. |
| **Fenster der vordersten App** | das zweite Kürzel, voreingestellt `` ⌘` ``. |
| **Leiste zeigen auf** | dem Bildschirm mit dem Tastaturfokus oder dem mit dem Zeiger. |
| **Sprache** | die Sprache der Oberfläche. **System** folgt macOS; die mitgelieferten Sprachen stehen in ihrem eigenen Namen. Eine Wahl zeichnet das Fenster sofort neu. |
| **Verzögerung bis zur Anzeige** | wie lange das Kürzel gehalten werden muss, bis die Leiste erscheint — 0 bis 500 ms. Bei `0` erscheint sie sofort. |
| **Beim Anmelden öffnen** | meldet die App bei macOS als Anmeldeobjekt an. |
| **Zwischen Fenstern wechseln statt zwischen Apps** | `⌘Tab` zählt dann Fenster auf, wie unter Windows und Linux. Aus voreingestellt: zwei Dokumente eines Editors sind dann zwei Einträge. |
| **Private Schreibtisch-Ebene verwenden** | die private Ebene weiß, zu welchem Schreibtisch ein im Dock abgelegtes Fenster gehört, ist aber undokumentiert. Aus benutzt die App nur die Fenster auf dem Bildschirm. |

Die App bringt fünfzehn Sprachen mit — Englisch, Russisch, Deutsch, Französisch, Spanisch,
Portugiesisch (Brasilien), Italienisch, Niederländisch, Polnisch, Türkisch, Ukrainisch,
Japanisch, Koreanisch und beide chinesischen Schriften — und antwortet für alles andere
auf Englisch. Die Beschriftungen sind in dieser Anleitung auf Deutsch zitiert.

Ein Kürzel braucht einen Modifikator zum Halten, und der Rekorder weist ab, was der
Entwurf nicht einlösen kann — eine Kombination ohne Modifikator, eine, die bereits **⇧**
enthält (das ist die Gegenrichtung), **Escape**, `⌘Q` und `⌘W` — und sagt, welcher Fall es
war. Das Kürzel wird mit den Tasten der aktuellen Eingabequelle gezeichnet.

## Erscheinungsbild

Der zweite Tab von **Einstellungen…** ist das Aussehen der Leiste, in Profilen gehalten.
**Standard** ist das eingebaute und lässt sich nicht ändern: **Duplizieren** macht eine
Kopie, die es kann, und **Name** gibt ihr einen eigenen. Fünf Profile über dem eingebauten
sind die Grenze; wird das aktive gelöscht, ist wieder **Standard** aktiv.

| Einstellung | Was sie ist |
|---|---|
| **Symbolgröße** | wie groß ein Symbol höchstens gezeichnet wird — eine volle Leiste schrumpft darunter, um auf den Bildschirm zu passen. |
| **Deckkraft der Symbole** | wie kräftig die Symbole gezeichnet werden. 100 % ist das Äußerste; darunter hebt sich die Auswahl weiterhin ab, weil die Vorgabe alles Nichtausgewählte abdunkelt. |
| **Rand der Leiste** | der Platz zwischen den Symbolen und dem Rand der Leiste, als Anteil des Symbols. |
| **Abstand zwischen Symbolen** | der Platz zwischen zwei Symbolen, im selben Anteil. |
| **Eckenradius** | wie rund die Ecken der Leiste sind. |
| **Rahmen um das Symbol**, **Abstand des Rahmens** | eine Kontur um ein Symbol und ihr Abstand dazu. |
| **Hintergrund** | **Glas** ist das Material des Systems; **Abdunklung** verdunkelt es, und bei `0` ist die Leiste blankes Glas, durch das der Schreibtisch scheint. **Transparent** und **Fensterhintergrund** tragen kein Material und werden allein über **Deckkraft** gesetzt. |
| **Karussell** | mit ausgeschaltetem **Reihe unter der Auswahl drehen** steht die Reihe still und schrumpft, um zu passen; eingeschaltet sagt **Plätze**, in wie vielen Symbolen sie sich dreht — 5 bis 12. |
| **Auswahl** | woran das ausgewählte Symbol zu erkennen ist: wie im System-Umschalter, vergrößert, allein stehend oder gerahmt. |

Jede Zahl hat einen Regler und ein Feld mit demselben Wert, und die Bereiche antworten
einander: weitere Abstände lassen dem Rand weniger Raum zum Wachsen. **Beispiel zeigen…**
zeichnet die Leiste mit so vielen Platzhalter-Apps, wie gewählt, für vier Sekunden, ohne
den Schreibtisch zu stören, auf dem gearbeitet wird.

## Die Menüleiste

| Eintrag | Wann er da ist |
|---|---|
| **Bedienungshilfen öffnen…** | solange die Berechtigung fehlt — fragt erneut |
| **Eingabeüberwachung öffnen…** | wenn macOS Tastendrücke zurückhält (siehe unten) |
| **Einstellungen…** | immer |
| **Liste der Apps und Fenster kopieren** | immer — legt die Liste der Apps des aktuellen Schreibtischs in die Zwischenablage; das gehört an einen Fehlerbericht |
| **Humane Space Tab beenden** | immer |

## Wenn etwas nicht stimmt

**Kein Symbol in der Menüleiste.** Eine Menüleiste ohne freien Platz links der Aussparung
lässt das Symbol fallen: macOS zeichnet kein Statussymbol, für das kein Platz ist, und
nichts in der App kann sich den Platz nehmen. Mach einen Platz frei, oder öffne die App
erneut aus dem Finder oder Spotlight — ein zweiter Start öffnet die Einstellungen statt
einer zweiten Kopie.

**Das Symbol sagt, macOS halte Tastendrücke zurück.** Ein alter Eintrag der App verbietet
sie in **Systemeinstellungen → Datenschutz & Sicherheit → Eingabeüberwachung**. Entferne
den Eintrag mit **−** — die App braucht die Berechtigung nicht, nur das Fehlen eines
Verbots — und klicke zurück in die App; der Tap wird ohne Neustart neu aufgebaut.

**`⌘Tab` ist immer noch der System-Umschalter.** Die Berechtigung fehlt oder gehört zur
vorherigen Version. Nimm **Bedienungshilfen öffnen…**, und falls die Liste schon einen
Eintrag hat, entferne ihn mit **−** und erteile sie erneut.

**„Beim Anmelden öffnen“ hält nicht.** Verweigert macOS die Anmeldung, sagt es das unter
dem Markierungsfeld mit seinen eigenen Worten. Der übliche Grund ist eine Version, die das
System nicht kennt: jede lokale Version trägt ihre eigene ad-hoc-Signatur, also gehört die
Anmeldung von gestern nicht zur heutigen. Schalte es an der Kopie in `/Applications` aus
und wieder ein.

## Was die App sehen kann

Sie hält die Bedienungshilfen — eine weitreichende Berechtigung — und tut absichtlich sehr
wenig damit: gar kein Netzwerkcode, keine AppleEvents, keine Plug-ins; Tastendrücke werden
nur auf das eigene Kürzel geprüft; Fenstertitel werden nur gelesen, solange der
Fensterwechsel an ist, und nur, um sie zu zeichnen; der Zeiger wird nur über der Leiste
selbst gesehen. Sie fragt nie nach der Bildschirmaufnahme — deshalb zeigt sie keine
Fenstervorschauen. Das vollständige Bedrohungsmodell ist [S00](specs/S00-threat-model.md).
