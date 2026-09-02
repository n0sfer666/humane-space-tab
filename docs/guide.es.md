# Cómo usar Humane Space Tab

[English](guide.md) · [Русский](guide.ru.md) · [Deutsch](guide.de.md) ·
[Français](guide.fr.md) · **Español** · [Português (Brasil)](guide.pt-BR.md) ·
[Italiano](guide.it.md) · [Nederlands](guide.nl.md) · [Polski](guide.pl.md) ·
[Türkçe](guide.tr.md) · [Українська](guide.uk.md) · [日本語](guide.ja.md) ·
[한국어](guide.ko.md) · [简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

La app no tiene ventana propia en la que trabajar: vive en la barra de menús, y todo lo
que hace ocurre mientras se mantiene pulsada una combinación de teclas.

![La franja](images/ribbon.png)

## La primera vez

1. Instálala — `brew install --cask n0sfer666/tap/humane-space-tab`, o abre la imagen de
   disco desde Releases y arrastra **Humane Space Tab.app** al acceso directo de
   Applications — y ábrela.
2. Una app descargada se rechaza la primera vez: abre **Ajustes del Sistema → Privacidad
   y seguridad**, baja hasta el final, pulsa **Abrir igualmente** y ábrela otra vez.
3. Al arrancar, la app pide **Accesibilidad**. Concédela en **Ajustes del Sistema →
   Privacidad y seguridad → Accesibilidad**. El selector empieza a funcionar en un par de
   segundos; no hace falta reiniciarla.

El icono de la barra de menús es la única prueba de que la app está funcionando: `⇄`
cuando funciona, un triángulo de aviso cuando no puede. macOS ata el permiso a la firma
del código, así que hay que volver a concederlo tras cada actualización.

## Cambiar entre apps

Mantén **⌘** y pulsa **Tab**. Lo que pasa depende de cuánto la mantengas:

- **Un toque rápido** —por debajo del retardo (120 ms por omisión)— cambia a la app
  anterior sin mostrar nada, como espera la memoria del gesto.
- **Deja ⌘ pulsada** y aparece la franja con las apps del **escritorio actual**, primero
  las usadas más recientemente. Cada **Tab** siguiente mueve la selección un paso.

Mientras la franja está abierta:

| Tecla | Qué hace |
|---|---|
| **Tab** | un paso adelante |
| **⇧Tab** | un paso atrás |
| **Escape** | cancelar: no se cambia nada |
| soltar **⌘** | cambiar a la app seleccionada |

La app seleccionada es el icono más grande y más vivo, con su nombre debajo; los vecinos
quedan atenuados. A partir de cinco apps la franja se vuelve un carrusel: la selección
mantiene su sitio y los iconos giran bajo ella, de modo que un paso siempre recorre la
misma distancia para el ojo y la lista no tiene extremos —tras la última app viene la
primera—. Con menos de cinco, cada icono conserva su sitio y solo se mueve la selección. La
franja deja de crecer a los diez huecos.

En un escritorio donde no hay nada abierto, la franja responde igualmente y dice que ahí no
hay nada, en lugar de devolver la pulsación al selector del sistema.

## Cambiar entre las ventanas de una app

Mantén **⌘** y pulsa **`** (la tecla encima de Tab). La franja lista las ventanas de la
app que está en primer plano —solo las del escritorio actual, en orden de apilado, cada una
con su título—. El gesto es el mismo: `⇧` invierte, Escape cancela y soltar **⌘** trae la
ventana al frente.

La combinación del sistema cuenta las ventanas de todos los escritorios a la vez, y por eso
te lanza a otro. Esta no puede: una ventana que no está aquí no está en la lista, así que
nunca cambia de escritorio ni recupera nada del Dock.

## El ratón

Mientras la franja está abierta, el puntero actúa sobre ella:

- **mueve el ratón** sobre un icono para seleccionarlo: un puntero que simplemente estaba
  donde se abrió la franja no cambia nada hasta que se mueve;
- **haz clic** en un icono para cambiar a él de inmediato, sin esperar a soltar **⌘**;
- **desplaza** sobre la franja para mover la selección.

## Ajustes

Se abren desde el icono de la barra de menús → **Ajustes…**.

![Ajustes](images/settings.png)

| Ajuste | Qué es |
|---|---|
| **Apps** | la combinación que abre la franja. Haz clic en el campo y tecléala, o usa **Restaurar el valor por omisión** para `⌘Tab`. |
| **Ventanas de la app en primer plano** | la segunda combinación, `` ⌘` `` por omisión. |
| **Mostrar la franja en** | la pantalla con el foco del teclado o aquella donde está el puntero. |
| **Idioma** | el idioma de la interfaz. **Sistema** sigue a macOS; los idiomas que trae la app aparecen en su propio nombre. Elegir uno redibuja la ventana al momento. |
| **Retardo antes de mostrarla** | cuánto hay que mantener la combinación antes de que aparezca la franja: de 0 a 500 ms. En `0` aparece enseguida. |
| **Abrir al iniciar sesión** | registra la app en macOS como ítem de inicio. |
| **Cambiar entre ventanas, no entre apps** | `⌘Tab` pasa a listar ventanas, como en Windows y Linux. Desactivado por omisión: dos documentos de un mismo editor serán entonces dos entradas. |
| **Usar la capa privada de escritorios** | la capa privada sabe a qué escritorio pertenece una ventana guardada en el Dock, pero no está documentada. Desactivada, la app solo mira las ventanas que hay en pantalla. |

La app trae quince idiomas —inglés, ruso, alemán, francés, español, portugués (Brasil),
italiano, neerlandés, polaco, turco, ucraniano, japonés, coreano y las dos escrituras
chinas— y responde en inglés para cualquier otro. En esta guía los nombres de los ajustes
se citan en español.

Una combinación necesita un modificador que mantener, y el grabador rechaza lo que el
diseño no puede cumplir —una combinación sin modificador, una que ya contiene **⇧** (esa es
la dirección inversa), **Escape**, `⌘Q` y `⌘W`— y dice cuál de esos casos era. La
combinación se dibuja con las teclas de tu fuente de entrada actual.

## Aspecto

La segunda pestaña de **Ajustes…** es el aspecto de la franja, guardado en perfiles. **Por
omisión** es el integrado y no se puede editar: **Duplicar** hace una copia que sí, y
**Nombre** le da uno tuyo. Cinco perfiles además del integrado es el tope; borrar el activo
deja activo el de **Por omisión**.

| Ajuste | Qué es |
|---|---|
| **Tamaño de los iconos** | lo grande que se dibuja un icono como máximo: una franja llena los encoge por debajo de eso para caber en la pantalla. |
| **Opacidad de los iconos** | con cuánta fuerza se dibujan los iconos. El 100 % es el máximo; por debajo la selección sigue destacando, porque el ajuste preestablecido atenúa todo lo que no está seleccionado. |
| **Margen de la franja** | el espacio entre los iconos y el borde de la franja, como parte del icono. |
| **Espacio entre iconos** | el espacio entre dos iconos, en la misma parte. |
| **Radio de las esquinas** | lo redondeadas que son las esquinas de la franja. |
| **Marco alrededor del icono**, **Margen del marco** | un contorno dibujado alrededor de un icono y su distancia a él. |
| **Fondo** | **Cristal** es el material del sistema; **Oscurecimiento** lo oscurece, y en `0` la franja es cristal desnudo y el escritorio se lee a través de ella. **Transparente** y **Color de fondo de ventana** no llevan material y se ajustan solo con **Opacidad**. |
| **Carrusel** | con **Girar la fila bajo la selección** desactivado, la fila se queda quieta y se encoge para caber; activado, **Huecos** dice en cuántos iconos gira, de 5 a 12. |
| **Selección** | cómo se distingue el icono seleccionado: como en el selector del sistema, más grande, solo en primer plano o enmarcado. |

Cada número tiene un regulador y un campo con el mismo valor, y los rangos se responden
entre sí: ensanchar los espacios deja menos sitio para que crezca el margen. **Ver un
ejemplo…** dibuja la franja con tantas apps de muestra como elijas, durante cuatro
segundos, sin molestar al escritorio en el que estás.

## La barra de menús

| Ítem | Cuándo aparece |
|---|---|
| **Abrir Accesibilidad…** | mientras falta el permiso: lo vuelve a pedir |
| **Abrir Monitorización de entrada…** | cuando macOS retiene las pulsaciones (más abajo) |
| **Ajustes…** | siempre |
| **Copiar la lista de apps y ventanas** | siempre: copia al portapapeles la lista de apps del escritorio actual, que es lo que conviene adjuntar a un informe de error |
| **Salir de Humane Space Tab** | siempre |

## Cuando algo va mal

**No hay icono en la barra de menús.** Una barra sin sitio libre a la izquierda de la muesca
descarta el icono: macOS no dibuja un ítem de estado que no cabe, y nada en la app puede
reclamar ese sitio. Libera espacio, o vuelve a abrir la app desde el Finder o Spotlight: un
segundo arranque abre los ajustes, no una segunda copia.

**El icono dice que macOS retiene las pulsaciones.** Una entrada antigua de la app se lo
prohíbe en **Ajustes del Sistema → Privacidad y seguridad → Monitorización de entrada**.
Quita esa entrada con **−** —la app no necesita el permiso, solo la ausencia de una
negativa— y vuelve a hacer clic en la app; la captura se reconstruye sin reiniciarla.

**El menú nombra una aplicación que está reteniendo las pulsaciones.** Mientras un campo de
contraseña tiene el foco, macOS activa la *entrada segura*, y entonces ninguna aplicación
recibe las pulsaciones, esta incluida. Normalmente termina con el campo; si dura, alguna
aplicación la dejó activada. El nombre es a quien macOS se lo atribuye; bloquea la pantalla y
desbloquéala para terminarlo.

**`⌘Tab` sigue siendo el del sistema.** Falta el permiso o pertenece a la versión anterior.
Usa **Abrir Accesibilidad…**, y si la lista ya tiene una entrada para la app, quítala con
**−** y concédelo de nuevo.

**«Abrir al iniciar sesión» no se queda.** Si macOS rechaza el registro, lo dice bajo la
casilla con sus propias palabras. El motivo habitual es una versión que el sistema no
reconoce: cada compilación local lleva su propia firma ad hoc, así que un registro hecho
por la copia de ayer no pertenece a la de hoy. Desactívalo y vuelve a activarlo en la copia
que está en `/Applications`.

## Qué puede ver la app

Tiene Accesibilidad, que es un permiso amplio, y hace deliberadamente muy poco con él: nada
de código de red, ni AppleEvents, ni plugins; las pulsaciones solo se examinan para
reconocer tu combinación; los títulos de ventana solo se leen mientras el cambio entre
ventanas está activado, y solo para dibujarlos; el puntero solo se ve sobre la propia
franja. Nunca pide Grabación de pantalla, y por eso no muestra vistas previas de ventanas.
El modelo de amenazas completo está en [S00](specs/S00-threat-model.md).
