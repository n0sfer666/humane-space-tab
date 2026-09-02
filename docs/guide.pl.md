# Jak używać Humane Space Tab

[English](guide.md) · [Русский](guide.ru.md) · [Deutsch](guide.de.md) ·
[Français](guide.fr.md) · [Español](guide.es.md) · [Português (Brasil)](guide.pt-BR.md) ·
[Italiano](guide.it.md) · [Nederlands](guide.nl.md) · **Polski** · [Türkçe](guide.tr.md) ·
[Українська](guide.uk.md) · [日本語](guide.ja.md) · [한국어](guide.ko.md) ·
[简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

Aplikacja nie ma własnego okna, w którym się pracuje: mieszka na pasku menu, a wszystko,
co robi, dzieje się, dopóki trzymasz skrót klawiszowy.

![Pasek](images/ribbon.png)

## Pierwsze uruchomienie

1. Zainstaluj — `brew install --cask n0sfer666/tap/humane-space-tab` albo otwórz obraz dysku
   z Releases i przeciągnij **Humane Space Tab.app** na skrót Applications — i uruchom.
2. Pobrana aplikacja za pierwszym razem zostaje odrzucona: otwórz **Ustawienia systemowe →
   Prywatność i ochrona**, przewiń na sam dół, kliknij **Otwórz mimo to** i uruchom
   jeszcze raz.
3. Przy starcie aplikacja prosi o **Dostępność**. Przyznaj ją w **Ustawienia systemowe →
   Prywatność i ochrona → Dostępność**. Przełącznik zaczyna działać po paru sekundach;
   ponowne uruchomienie nie jest potrzebne.

Ikona na pasku menu to jedyny dowód, że aplikacja działa: `⇄`, kiedy działa, i trójkąt
ostrzegawczy, kiedy nie może. macOS wiąże uprawnienie z podpisem kodu, więc po każdej
aktualizacji trzeba je przyznać na nowo.

## Przełączanie między aplikacjami

Trzymaj **⌘** i naciskaj **Tab**. To, co zobaczysz, zależy od tego, jak długo trzymasz:

- **krótkie naciśnięcie** — krótsze niż opóźnienie (domyślnie 120 ms) — przełącza na
  poprzednią aplikację, niczego nie pokazując, tak jak spodziewa się pamięć ruchowa;
- **trzymaj ⌘ dalej**, a pojawi się pasek z aplikacjami **bieżącego pulpitu**, ostatnio
  używane najpierw. Każdy kolejny **Tab** przesuwa zaznaczenie o krok.

Dopóki pasek jest otwarty:

| Klawisz | Co robi |
|---|---|
| **Tab** | krok do przodu |
| **⇧Tab** | krok wstecz |
| **Escape** | anuluj — nic nie zostaje przełączone |
| puszczenie **⌘** | przełącz na zaznaczoną aplikację |

Zaznaczona aplikacja to ikona większa i mocniejsza, z nazwą pod spodem; sąsiednie są
przygaszone. Od pięciu aplikacji pasek staje się karuzelą: zaznaczenie stoi w miejscu, a
ikony obracają się pod nim, więc krok to dla oka zawsze ta sama odległość, a lista nie ma
końców — po ostatniej aplikacji przychodzi pierwsza. Poniżej pięciu każda ikona zostaje na
swoim miejscu i porusza się tylko zaznaczenie. Pasek przestaje rosnąć na dziesięciu
miejscach.

Na pulpicie, gdzie nic nie jest otwarte, pasek i tak odpowiada i mówi, że nic tam nie ma,
zamiast oddać naciśnięcie systemowemu przełącznikowi.

## Przełączanie między oknami jednej aplikacji

Trzymaj **⌘** i naciskaj **`** (klawisz nad Tab). Pasek pokaże okna aplikacji na
wierzchu — tylko te z bieżącego pulpitu, w kolejności stosu, każde z własnym tytułem. Gest
jest ten sam: `⇧` odwraca kierunek, Escape anuluje, puszczone **⌘** wysuwa okno na wierzch.

Systemowy skrót liczy okna wszystkich pulpitów naraz i właśnie dlatego przerzuca na inny.
Ten nie potrafi: okna, którego tu nie ma, nie ma i na liście, więc nigdy nie zmienia
pulpitu ani nie przywraca niczego z Docka.

## Mysz

Dopóki pasek jest otwarty, wskaźnik działa na nim:

- **rusz myszą** nad ikoną, żeby ją zaznaczyć — wskaźnik, który tylko stoi tam, gdzie pasek
  się otworzył, niczego nie zmienia, dopóki się nie ruszy;
- **kliknij** ikonę, żeby przełączyć się od razu, nie czekając na puszczenie **⌘**;
- **przewijaj** nad paskiem, żeby przesuwać zaznaczenie.

## Ustawienia

Otwierają się z ikony na pasku menu → **Ustawienia…**.

![Ustawienia](images/settings.png)

| Ustawienie | Co to jest |
|---|---|
| **Aplikacje** | skrót otwierający pasek. Kliknij w pole i wpisz swój albo **Przywróć domyślny**, żeby wrócić do `⌘Tab`. |
| **Okna aktywnej aplikacji** | drugi skrót, domyślnie `` ⌘` ``. |
| **Pokazuj pasek na** | ekranie z fokusem klawiatury albo tym, na którym jest wskaźnik. |
| **Język** | język interfejsu. **Systemowy** idzie za macOS; języki, które niesie aplikacja, wypisane są własnymi nazwami. Wybór przerysowuje okno od razu. |
| **Opóźnienie przed pokazaniem** | jak długo trzeba trzymać skrót, zanim pasek się pojawi — od 0 do 500 ms. Przy `0` pojawia się natychmiast. |
| **Otwieraj przy logowaniu** | rejestruje aplikację w macOS jako element logowania. |
| **Przełączaj okna zamiast aplikacji** | `⌘Tab` zaczyna wyliczać okna, jak w Windows i Linuksie. Domyślnie wyłączone: dwa dokumenty jednego edytora będą wtedy dwiema pozycjami. |
| **Używaj prywatnej warstwy pulpitów** | prywatna warstwa wie, do którego pulpitu należy okno schowane w Docku, ale nie jest udokumentowana. Wyłączona — aplikacja patrzy tylko na okna widoczne na ekranie. |

Aplikacja niesie piętnaście języków — angielski, rosyjski, niemiecki, francuski,
hiszpański, portugalski (Brazylia), włoski, niderlandzki, polski, turecki, ukraiński,
japoński, koreański i oba pisma chińskie — a dla pozostałych odpowiada po angielsku. Nazwy
ustawień przytaczane są w tym przewodniku po polsku.

Skrót potrzebuje modyfikatora, który się trzyma, a rejestrator odrzuca to, czego projekt
nie może spełnić — kombinację bez modyfikatora, taką, która już zawiera **⇧** (to kierunek
odwrotny), **Escape**, `⌘Q` i `⌘W` — i mówi, który to był przypadek. Skrót rysowany jest
klawiszami bieżącego źródła wprowadzania.

## Wygląd

Druga karta **Ustawień…** to wygląd paska, trzymany w profilach. **Domyślny** jest wbudowany
i nie da się go zmienić: **Powiel** robi kopię, którą już można zmieniać, a **Nazwa** daje
jej własną. Pięć profili ponad wbudowany to sufit; usunięcie aktywnego zostawia aktywny
profil **Domyślny**.

| Ustawienie | Co to jest |
|---|---|
| **Wielkość ikon** | jak duża jest ikona co najwyżej — zatłoczony pasek i tak zmniejszy je poniżej, żeby zmieścić się na ekranie. |
| **Krycie ikon** | jak mocno rysowane są ikony. 100 % to maksimum; poniżej zaznaczenie i tak się wyróżnia, bo ustawienie wstępne przygasza wszystko, co nie jest zaznaczone. |
| **Margines paska** | miejsce między ikonami a krawędzią paska, jako część ikony. |
| **Odstęp między ikonami** | miejsce między dwiema ikonami, w tej samej części. |
| **Zaokrąglenie rogów** | jak zaokrąglone są rogi paska. |
| **Ramka wokół ikony**, **Margines ramki** | obrys rysowany wokół ikony i jego odległość od niej. |
| **Tło** | **Szkło** to materiał systemu; **Przyciemnienie** go przyciemnia, a przy `0` pasek jest gołym szkłem, przez które widać pulpit. **Przezroczyste** i **Kolor tła okna** nie niosą materiału i ustawia się je samym **Kryciem**. |
| **Karuzela** | przy wyłączonym **Obracaj rząd pod zaznaczeniem** rząd stoi i kurczy się, żeby się zmieścić; włączone — **Miejsca** mówią, w ilu ikonach się obraca, od 5 do 12. |
| **Zaznaczenie** | po czym poznać zaznaczoną ikonę: jak w systemowym przełączniku, powiększona, sama na wierzchu albo w ramce. |

Każda liczba ma suwak i pole z tą samą wartością, a zakresy odpowiadają sobie nawzajem:
szersze odstępy zostawiają marginesowi mniej miejsca na wzrost. **Pokaż przykład…** rysuje
pasek z tyloma zastępczymi aplikacjami, ile wybierzesz, przez cztery sekundy, nie ruszając
pulpitu, na którym jesteś.

## Pasek menu

| Pozycja | Kiedy jest |
|---|---|
| **Otwórz Dostępność…** | dopóki brakuje uprawnienia — prosi ponownie |
| **Otwórz Monitorowanie wprowadzania…** | kiedy macOS wstrzymuje naciśnięcia (patrz niżej) |
| **Ustawienia…** | zawsze |
| **Kopiuj listę aplikacji i okien** | zawsze — kopiuje do schowka listę aplikacji bieżącego pulpitu; to właśnie dołącza się do zgłoszenia błędu |
| **Zakończ Humane Space Tab** | zawsze |

## Kiedy coś nie działa

**Brak ikony na pasku menu.** Pasek bez wolnego miejsca na lewo od wcięcia porzuca ikonę:
macOS nie rysuje elementu statusu, dla którego nie ma miejsca, i nic w aplikacji nie może
tego miejsca zająć. Zwolnij miejsce albo otwórz aplikację ponownie z Findera lub
Spotlighta — drugie uruchomienie otwiera ustawienia, a nie drugą kopię.

**Ikona mówi, że macOS wstrzymuje naciśnięcia.** Stary wpis aplikacji zabrania jej tego w
**Ustawienia systemowe → Prywatność i ochrona → Monitorowanie wprowadzania**. Usuń ten wpis
przyciskiem **−** — aplikacja nie potrzebuje uprawnienia, potrzebuje braku zakazu — i
kliknij z powrotem w aplikację; podsłuch zdarzeń odbudowuje się bez restartu.

**Menu nazywa aplikację, która wstrzymuje naciśnięcia klawiszy.** Dopóki pole hasła ma fokus,
macOS włącza *bezpieczne wprowadzanie*, a wtedy żadna aplikacja nie dostaje naciśnięć
klawiszy — ta również. Zwykle kończy się to razem z polem; jeśli trwa dłużej, jakaś aplikacja
to zostawiła. Nazwa to ta, której macOS to przypisuje; zablokuj ekran i odblokuj go, aby to
zakończyć.

**`⌘Tab` nadal jest systemowy.** Uprawnienia nie ma albo należy do poprzedniej wersji.
Kliknij **Otwórz Dostępność…**, a jeśli na liście jest już wpis aplikacji, usuń go
przyciskiem **−** i przyznaj uprawnienie na nowo.

**„Otwieraj przy logowaniu” nie trzyma.** Jeśli macOS odmówi rejestracji, mówi o tym pod
polem wyboru własnymi słowami. Zwykły powód to wersja, której system nie rozpoznaje: każda
lokalna kompilacja niesie własny podpis ad hoc, więc rejestracja wczorajszej kopii nie
należy do dzisiejszej. Wyłącz i włącz ponownie na kopii, która leży w `/Applications`.

## Co aplikacja widzi

Ma Dostępność, uprawnienie szerokie, i celowo robi z nim bardzo niewiele: żadnego kodu
sieciowego, żadnych AppleEvents, żadnych wtyczek; naciśnięcia sprawdzane są tylko pod kątem
zgodności z twoim skrótem; tytuły okien czytane są tylko wtedy, gdy przełączanie okien jest
włączone, i tylko po to, żeby je narysować; wskaźnik widziany jest jedynie nad samym
paskiem. Nigdy nie prosi o Nagrywanie ekranu — dlatego nie pokazuje podglądów okien. Pełny
model zagrożeń to [S00](specs/S00-threat-model.md).
