# Utiliser Humane Space Tab

[English](guide.md) · [Русский](guide.ru.md) · [Deutsch](guide.de.md) · **Français** ·
[Español](guide.es.md) · [Português (Brasil)](guide.pt-BR.md) · [Italiano](guide.it.md) ·
[Nederlands](guide.nl.md) · [Polski](guide.pl.md) · [Türkçe](guide.tr.md) ·
[Українська](guide.uk.md) · [日本語](guide.ja.md) · [한국어](guide.ko.md) ·
[简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

L’app n’a pas de fenêtre à elle : elle vit dans la barre des menus, et tout ce qu’elle
fait se passe pendant qu’un raccourci est maintenu.

![Le bandeau](images/ribbon.png)

## Premier lancement

1. Installez-la — `brew install --cask n0sfer666/tap/humane-space-tab`, ou ouvrez l’image
   disque depuis Releases et glissez **Humane Space Tab.app** sur le raccourci
   Applications — puis lancez-la.
2. Une app téléchargée est refusée la première fois — ouvrez **Réglages Système →
   Confidentialité et sécurité**, descendez tout en bas, appuyez sur **Ouvrir quand
   même**, puis relancez-la.
3. L’app demande l’**Accessibilité** au démarrage. Accordez-la dans **Réglages Système →
   Confidentialité et sécurité → Accessibilité**. Le sélecteur se met à fonctionner en
   quelques secondes ; aucun relancement n’est nécessaire.

L’icône dans la barre des menus est la seule preuve que l’app tourne : `⇄` quand elle
fonctionne, un triangle d’avertissement quand elle ne peut pas. macOS lie l’autorisation à
la signature du code, elle doit donc être redonnée après chaque mise à jour.

## Passer d’une app à l’autre

Maintenez **⌘** et frappez **Tab**. Ce que vous obtenez dépend de la durée :

- **Une frappe brève** — sous le délai d’affichage (120 ms par défaut) — bascule vers l’app
  précédente sans rien montrer, comme la mémoire du geste l’attend.
- **Gardez ⌘ enfoncée** et le bandeau apparaît avec les apps du **bureau courant**, les
  plus récemment utilisées d’abord. Chaque **Tab** suivant déplace la sélection d’un cran.

Tant que le bandeau est ouvert :

| Touche | Ce qu’elle fait |
|---|---|
| **Tab** | un cran en avant |
| **⇧Tab** | un cran en arrière |
| **Escape** | annuler — rien n’est basculé |
| relâcher **⌘** | passer à l’app sélectionnée |

L’app sélectionnée est l’icône la plus grande et la plus vive, avec son nom en dessous ;
ses voisines sont atténuées. À partir de cinq apps le bandeau devient un carrousel : la
sélection garde sa place et les icônes tournent dessous, si bien qu’un pas fait toujours la
même distance pour l’œil et que la liste n’a pas de bout — après la dernière app vient la
première. En dessous de cinq, chaque icône garde sa place et seule la sélection bouge. Le
bandeau cesse de grandir à dix emplacements.

Sur un bureau où rien n’est ouvert, le bandeau répond quand même et dit qu’il n’y a rien,
au lieu de rendre la frappe au sélecteur du système.

## Passer d’une fenêtre à l’autre dans une app

Maintenez **⌘** et frappez **`** (la touche au-dessus de Tab). Le bandeau liste les
fenêtres de l’app au premier plan — seulement celles du bureau courant, dans l’ordre de la
pile, chacune avec son titre. Le geste est le même : `⇧` inverse, Escape annule, relâcher
**⌘** fait passer la fenêtre devant.

Le raccourci du système compte les fenêtres de tous les bureaux à la fois, et c’est ainsi
qu’il vous jette sur un autre. Celui-ci ne le peut pas : une fenêtre qui n’est pas ici
n’est pas dans la liste, donc il ne change jamais de bureau et ne restaure rien depuis le
Dock.

## La souris

Tant que le bandeau est ouvert, le pointeur agit dessus :

- **bougez la souris** au-dessus d’une icône pour la sélectionner — un pointeur qui se
  trouve simplement là où le bandeau s’est ouvert ne change rien tant qu’il ne bouge pas ;
- **cliquez** sur une icône pour y passer aussitôt, sans attendre que **⌘** soit relâchée ;
- **faites défiler** au-dessus du bandeau pour avancer la sélection.

## Réglages

À ouvrir depuis l’icône de la barre des menus → **Réglages…**.

![Réglages](images/settings.png)

| Réglage | Ce que c’est |
|---|---|
| **Apps** | le raccourci qui ouvre le bandeau. Cliquez dans le champ et tapez la combinaison, ou **Rétablir la valeur par défaut** pour `⌘Tab`. |
| **Fenêtres de l’app au premier plan** | le second raccourci, `` ⌘` `` par défaut. |
| **Afficher le bandeau sur** | l’écran qui a le focus clavier, ou celui où se trouve le pointeur. |
| **Langue** | la langue de l’interface. **Système** suit macOS ; les langues embarquées sont listées dans leur propre nom. Un choix redessine la fenêtre aussitôt. |
| **Délai avant affichage** | combien de temps le raccourci doit être maintenu avant que le bandeau paraisse — 0 à 500 ms. À `0` il paraît tout de suite. |
| **Ouvrir à l’ouverture de session** | inscrit l’app auprès de macOS comme ouverture automatique. |
| **Passer d’une fenêtre à l’autre plutôt que d’une app à l’autre** | `⌘Tab` liste alors les fenêtres, comme sous Windows et Linux. Désactivé par défaut : deux documents d’un même éditeur font alors deux entrées. |
| **Utiliser la couche privée des bureaux** | la couche privée sait à quel bureau appartient une fenêtre placée dans le Dock, mais elle n’est pas documentée. Désactivée, l’app ne regarde que les fenêtres à l’écran. |

L’app embarque quinze langues — anglais, russe, allemand, français, espagnol, portugais
(Brésil), italien, néerlandais, polonais, turc, ukrainien, japonais, coréen et les deux
écritures chinoises — et répond en anglais pour tout le reste. Les libellés sont cités en
français dans ce guide.

Un raccourci a besoin d’un modificateur à maintenir, et l’enregistreur refuse ce que la
conception ne peut pas tenir — une combinaison sans modificateur, une qui contient déjà
**⇧** (c’est le sens inverse), **Escape**, `⌘Q` et `⌘W` — en disant lequel de ces cas
c’était. Le raccourci est dessiné avec les touches de votre source de saisie du moment.

## Apparence

Le second onglet des **Réglages…**, c’est l’allure du bandeau, tenue dans des profils.
**Par défaut** est celui qui est fourni et ne se modifie pas : **Dupliquer** en fait une
copie qui, elle, se modifie, et **Nom** lui donne le vôtre. Cinq profils au-delà de celui
fourni est le plafond ; supprimer l’actif laisse **Par défaut** actif.

| Réglage | Ce que c’est |
|---|---|
| **Taille des icônes** | la taille maximale d’une icône — un bandeau chargé les rétrécit quand même en dessous pour tenir à l’écran. |
| **Opacité des icônes** | la force avec laquelle les icônes sont dessinées. 100 % est le maximum ; en dessous, la sélection ressort toujours, parce que le préréglage atténue tout ce qui n’est pas sélectionné. |
| **Marge du bandeau** | l’espace entre les icônes et le bord du bandeau, en part de l’icône. |
| **Espace entre les icônes** | l’espace entre deux icônes, dans la même part. |
| **Rayon des coins** | l’arrondi des coins du bandeau. |
| **Cadre autour de l’icône**, **Marge du cadre** | un contour tracé autour d’une icône, et sa distance à celle-ci. |
| **Fond** | **Verre** est le matériau du système ; **Assombrissement** le fonce, et à `0` le bandeau est du verre nu, le bureau se lit à travers. **Transparent** et **Couleur de fond des fenêtres** ne portent aucun matériau et se règlent par la seule **Opacité**. |
| **Carrousel** | **Faire tourner la rangée sous la sélection** désactivé, la rangée reste immobile et rétrécit pour tenir ; activé, **Emplacements** dit dans combien d’icônes elle tourne — de 5 à 12. |
| **Sélection** | ce qui distingue l’icône sélectionnée : comme le sélecteur du système, agrandie, seule en avant ou encadrée. |

Chaque nombre a un curseur et un champ montrant la même valeur, et les plages se répondent :
élargir les espaces laisse moins de place à la marge pour grandir. **Afficher un aperçu…**
dessine le bandeau avec autant d’apps fictives que vous choisissez, pendant quatre
secondes, sans déranger le bureau où vous êtes.

## La barre des menus

| Élément | Quand il est là |
|---|---|
| **Ouvrir Accessibilité…** | tant que l’autorisation manque — la redemande |
| **Ouvrir Surveillance de la saisie…** | quand macOS retient les frappes (voir plus bas) |
| **Réglages…** | toujours |
| **Copier la liste des apps et des fenêtres** | toujours — copie dans le presse-papiers la liste des apps du bureau courant ; c’est ce qu’il faut joindre à un rapport de bogue |
| **Quitter Humane Space Tab** | toujours |

## Quand quelque chose ne va pas

**Pas d’icône dans la barre des menus.** Une barre sans place libre à gauche de l’encoche
laisse tomber l’icône : macOS ne dessine pas un élément de menu qu’il ne peut pas loger, et
rien dans l’app ne peut réclamer la place. Libérez une place, ou rouvrez l’app depuis le
Finder ou Spotlight — un second lancement ouvre les réglages, pas une seconde copie.

**L’icône dit que macOS retient les frappes.** Une vieille entrée de l’app la lui interdit
dans **Réglages Système → Confidentialité et sécurité → Surveillance de la saisie**.
Supprimez cette entrée avec **−** — l’app n’a pas besoin de l’autorisation, seulement de
l’absence d’un refus — puis recliquez dans l’app ; la capture est reconstruite sans
relancement.

**Le menu nomme une application qui retient les frappes.** Tant qu’un champ de mot de passe a
le focus, macOS active la *saisie sécurisée*, et aucune application ne reçoit alors les
frappes — celle-ci comprise. Cela s’arrête normalement avec le champ ; si cela dure, une
application l’a laissée active. Le nom est celui auquel macOS attribue la retenue ;
verrouillez l’écran puis déverrouillez-le pour y mettre fin.

**`⌘Tab` est toujours celui du système.** L’autorisation manque ou appartient à la version
précédente. Prenez **Ouvrir Accessibilité…**, et si la liste contient déjà une entrée pour
l’app, supprimez-la avec **−** et accordez-la de nouveau.

**« Ouvrir à l’ouverture de session » ne tient pas.** Si macOS refuse l’inscription, il le
dit sous la case, avec ses propres mots. La raison habituelle est une version que le
système ne reconnaît pas : chaque compilation locale porte sa propre signature ad hoc, donc
l’inscription faite hier n’appartient pas à la copie d’aujourd’hui. Décochez et recochez
sur la copie qui est dans `/Applications`.

## Ce que l’app peut voir

Elle détient l’Accessibilité, qui est large, et n’en fait délibérément que très peu : aucun
code réseau, pas d’AppleEvents, pas de modules externes ; les frappes ne sont examinées que
pour reconnaître votre raccourci ; les titres de fenêtres ne sont lus que si le changement
de fenêtre est activé, et seulement pour être dessinés ; le pointeur n’est vu qu’au-dessus
du bandeau lui-même. Elle ne demande jamais l’Enregistrement de l’écran, et c’est pourquoi
elle ne montre aucun aperçu de fenêtre. Le modèle de menaces complet est
[S00](specs/S00-threat-model.md).
