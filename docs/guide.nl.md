# Humane Space Tab gebruiken

[English](guide.md) · [Русский](guide.ru.md) · [Deutsch](guide.de.md) ·
[Français](guide.fr.md) · [Español](guide.es.md) · [Português (Brasil)](guide.pt-BR.md) ·
[Italiano](guide.it.md) · **Nederlands** · [Polski](guide.pl.md) · [Türkçe](guide.tr.md) ·
[Українська](guide.uk.md) · [日本語](guide.ja.md) · [한국어](guide.ko.md) ·
[简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

De app heeft geen eigen venster om in te werken: hij leeft in de menubalk, en alles wat
hij doet gebeurt terwijl je een toetscombinatie ingedrukt houdt.

![De balk](images/ribbon.png)

## De eerste keer

1. Installeer hem — `brew install --cask n0sfer666/tap/humane-space-tab`, of open het
   schijfkopiebestand uit Releases en sleep **Humane Space Tab.app** naar de snelkoppeling
   Applications — en start hem.
2. Een gedownloade app wordt de eerste keer geweigerd: open **Systeeminstellingen →
   Privacy en beveiliging**, scrol helemaal naar beneden, klik op **Toch openen** en start
   hem opnieuw.
3. Bij het starten vraagt de app om **Toegankelijkheid**. Geef die in
   **Systeeminstellingen → Privacy en beveiliging → Toegankelijkheid**. De wisselaar werkt
   binnen een paar seconden; opnieuw starten is niet nodig.

Het symbool in de menubalk is het enige bewijs dat de app draait: `⇄` als hij werkt, een
waarschuwingsdriehoek als hij het niet kan. macOS koppelt de toestemming aan de
handtekening van de code, dus na elke update moet ze opnieuw worden gegeven.

## Tussen apps wisselen

Houd **⌘** ingedrukt en tik op **Tab**. Wat je krijgt hangt af van hoe lang je hem houdt:

- **Een korte tik** — korter dan de wachttijd (standaard 120 ms) — wisselt naar de vorige
  app zonder iets te tonen, zoals het spiergeheugen verwacht.
- **Houd ⌘ ingedrukt** en de balk verschijnt met de apps van het **huidige bureaublad**,
  de laatst gebruikte eerst. Elke volgende **Tab** verplaatst de selectie één stap.

Zolang de balk open is:

| Toets | Wat hij doet |
|---|---|
| **Tab** | één stap vooruit |
| **⇧Tab** | één stap terug |
| **Escape** | annuleren — er wordt niets gewisseld |
| **⌘** loslaten | naar de geselecteerde app wisselen |

De geselecteerde app is het symbool dat groter en sterker is, met de naam eronder; de buren
zijn gedempt. Vanaf vijf apps wordt de balk een carrousel: de selectie houdt haar plaats en
de symbolen draaien eronder door, zodat een stap voor het oog altijd dezelfde afstand is en
de lijst geen einde heeft — na de laatste app komt de eerste. Onder de vijf houdt elk
symbool zijn plaats en beweegt alleen de selectie. De balk groeit niet verder dan tien
plaatsen.

Op een bureaublad waar niets open staat antwoordt de balk toch, en zegt dat daar niets is,
in plaats van de toetsaanslag terug te geven aan de wisselaar van het systeem.

## Tussen de vensters van één app wisselen

Houd **⌘** ingedrukt en tik op **`** (de toets boven Tab). De balk toont de vensters van de
voorste app — alleen die op het huidige bureaublad, in stapelvolgorde, elk met zijn eigen
titel. Het gebaar is hetzelfde: `⇧` keert de richting om, Escape annuleert, **⌘** loslaten
haalt het venster naar voren.

De systeemcombinatie telt de vensters van alle bureaubladen tegelijk, en zo gooit hij je
naar een ander. Deze kan dat niet: een venster dat hier niet is, staat ook niet in de
lijst, dus hij wisselt nooit van bureaublad en haalt niets terug uit het Dock.

## De muis

Zolang de balk open is werkt de aanwijzer erop:

- **beweeg de muis** over een symbool om het te selecteren — een aanwijzer die alleen maar
  ligt waar de balk openging, verandert niets tot hij beweegt;
- **klik** op een symbool om er meteen naartoe te wisselen, zonder op **⌘** te wachten;
- **scrol** boven de balk om de selectie te verplaatsen.

## Instellingen

Te openen via het menubalksymbool → **Instellingen…**.

![Instellingen](images/settings.png)

| Instelling | Wat het is |
|---|---|
| **Apps** | de combinatie die de balk opent. Klik in het veld en typ hem, of **Herstel standaardwaarde** voor `⌘Tab`. |
| **Vensters van de voorste app** | de tweede combinatie, standaard `` ⌘` ``. |
| **Toon de balk op** | het scherm met de toetsenbordfocus, of het scherm waar de aanwijzer is. |
| **Taal** | de taal van de interface. **Systeem** volgt macOS; de meegeleverde talen staan in hun eigen naam. Een keuze tekent het venster meteen opnieuw. |
| **Wachttijd voor de balk verschijnt** | hoe lang de combinatie ingedrukt moet blijven voor de balk verschijnt — 0 tot 500 ms. Bij `0` verschijnt hij meteen. |
| **Open bij inloggen** | meldt de app bij macOS aan als inlogonderdeel. |
| **Wissel tussen vensters in plaats van apps** | `⌘Tab` toont dan vensters, zoals op Windows en Linux. Standaard uit: twee documenten van één editor zijn dan twee regels. |
| **Gebruik de privélaag van de bureaubladen** | de privélaag weet bij welk bureaublad een in het Dock geplaatst venster hoort, maar is niet gedocumenteerd. Uit kijkt de app alleen naar de vensters op het scherm. |

De app draagt vijftien talen — Engels, Russisch, Duits, Frans, Spaans, Portugees (Brazilië),
Italiaans, Nederlands, Pools, Turks, Oekraïens, Japans, Koreaans en beide Chinese schriften
— en antwoordt voor al het andere in het Engels. De labels worden in deze handleiding in
het Nederlands geciteerd.

Een combinatie heeft een modificatietoets nodig om vast te houden, en de opnemer weigert
wat het ontwerp niet kan waarmaken — een combinatie zonder modificatietoets, een die al
**⇧** bevat (dat is de omgekeerde richting), **Escape**, `⌘Q` en `⌘W` — en zegt welk van
die gevallen het was. De combinatie wordt getekend met de toetsen van je huidige
invoerbron.

## Weergave

Het tweede tabblad van **Instellingen…** is het uiterlijk van de balk, bewaard in
profielen. **Standaard** is het ingebouwde profiel en kan niet worden aangepast:
**Dupliceer** maakt een kopie die dat wel kan, en **Naam** geeft die een eigen naam. Vijf
profielen naast het ingebouwde is het maximum; wie het actieve verwijdert, houdt
**Standaard** actief.

| Instelling | Wat het is |
|---|---|
| **Symboolgrootte** | hoe groot een symbool hoogstens wordt getekend — een volle balk krimpt ze daaronder om op het scherm te passen. |
| **Dekking van de symbolen** | hoe sterk de symbolen worden getekend. 100 % is het maximum; daaronder valt de selectie nog steeds op, omdat de voorinstelling alles wat niet geselecteerd is dempt. |
| **Marge van de balk** | de ruimte tussen de symbolen en de rand van de balk, als deel van het symbool. |
| **Ruimte tussen de symbolen** | de ruimte tussen twee symbolen, in hetzelfde deel. |
| **Hoekronding** | hoe rond de hoeken van de balk zijn. |
| **Kader om het symbool**, **Marge van het kader** | een omtrek rond een symbool, en de afstand daartoe. |
| **Achtergrond** | **Glas** is het materiaal van het systeem zelf; **Verduistering** maakt het donkerder, en bij `0` is de balk kaal glas waar het bureaublad doorheen te lezen is. **Transparant** en **Vensterachtergrondkleur** dragen geen materiaal en worden alleen met **Dekking** ingesteld. |
| **Carrousel** | met **Draai de rij onder de selectie door** uit staat de rij stil en krimpt om te passen; aan zegt **Plaatsen** in hoeveel symbolen ze draait — 5 tot 12. |
| **Selectie** | waaraan het geselecteerde symbool te herkennen is: als bij de wisselaar van het systeem, vergroot, alleen vooraan of met een kader. |

Elk getal heeft een schuifknop en een veld met dezelfde waarde, en de bereiken antwoorden
elkaar: bredere tussenruimten laten de marge minder ruimte om te groeien. **Toon een
voorbeeld…** tekent de balk met zoveel voorbeeld-apps als je kiest, vier seconden lang,
zonder het bureaublad waarop je werkt te storen.

## De menubalk

| Onderdeel | Wanneer het er is |
|---|---|
| **Open Toegankelijkheid…** | zolang de toestemming ontbreekt — vraagt opnieuw |
| **Open Invoerbewaking…** | wanneer macOS toetsaanslagen tegenhoudt (zie hieronder) |
| **Instellingen…** | altijd |
| **Kopieer de lijst met apps en vensters** | altijd — zet de lijst met apps van het huidige bureaublad op het klembord; dat is wat je aan een foutmelding hangt |
| **Stop Humane Space Tab** | altijd |

## Als er iets misgaat

**Geen symbool in de menubalk.** Een menubalk zonder vrije plek links van de inkeping laat
het symbool vallen: macOS tekent geen statussymbool waarvoor geen plaats is, en niets in de
app kan die plaats opeisen. Maak een plek vrij, of open de app opnieuw vanuit de Finder of
Spotlight — een tweede start opent de instellingen, geen tweede kopie.

**Het symbool zegt dat macOS toetsaanslagen tegenhoudt.** Een oude regel voor de app
verbiedt ze in **Systeeminstellingen → Privacy en beveiliging → Invoerbewaking**. Verwijder
die regel met **−** — de app heeft de toestemming niet nodig, alleen het ontbreken van een
verbod — en klik terug in de app; de tap wordt opnieuw opgebouwd zonder herstart.

**Het menu noemt een app die toetsaanslagen tegenhoudt.** Zolang een wachtwoordveld de focus
heeft, zet macOS *beveiligde invoer* aan, en dan krijgt geen enkele app toetsaanslagen — deze
ook niet. Normaal eindigt het met het veld; duurt het langer, dan heeft een app het laten
staan. De naam is die waaraan macOS het toeschrijft; vergrendel het scherm en ontgrendel het
weer, dan is het weg.

**`⌘Tab` is nog steeds die van het systeem.** De toestemming ontbreekt of hoort bij de
vorige versie. Gebruik **Open Toegankelijkheid…**, en staat er al een regel voor de app in
de lijst, verwijder die dan met **−** en geef de toestemming opnieuw.

**‘Open bij inloggen’ blijft niet staan.** Weigert macOS de registratie, dan zegt het dat
onder het aankruisvak, in zijn eigen woorden. De gebruikelijke reden is een versie die het
systeem niet herkent: elke lokale build draagt zijn eigen ad-hoc handtekening, dus een
registratie van de kopie van gisteren hoort niet bij die van vandaag. Zet het uit en weer
aan op de kopie die in `/Applications` staat.

## Wat de app kan zien

Hij heeft Toegankelijkheid, wat ruim is, en doet daar met opzet heel weinig mee: geen
netwerkcode, geen AppleEvents, geen plug-ins; toetsaanslagen worden alleen bekeken om jouw
combinatie te herkennen; venstertitels worden alleen gelezen zolang het wisselen tussen
vensters aan staat, en alleen om ze te tekenen; de aanwijzer wordt alleen boven de balk
zelf gezien. Hij vraagt nooit om Schermopname, en daarom toont hij geen
venstervoorbeelden. Het volledige dreigingsmodel is [S00](specs/S00-threat-model.md).
