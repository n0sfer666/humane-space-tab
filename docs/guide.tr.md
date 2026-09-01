# Humane Space Tab nasıl kullanılır

[English](guide.md) · [Русский](guide.ru.md) · [Deutsch](guide.de.md) ·
[Français](guide.fr.md) · [Español](guide.es.md) · [Português (Brasil)](guide.pt-BR.md) ·
[Italiano](guide.it.md) · [Nederlands](guide.nl.md) · [Polski](guide.pl.md) · **Türkçe** ·
[Українська](guide.uk.md) · [日本語](guide.ja.md) · [한국어](guide.ko.md) ·
[简体中文](guide.zh-Hans.md) · [繁體中文](guide.zh-Hant.md)

Uygulamanın içinde çalışılacak bir penceresi yok: menü çubuğunda yaşar ve yaptığı her şey,
sen bir kısayolu basılı tuttuğun sürece olur.

![Şerit](images/ribbon.png)

## İlk çalıştırma

1. Kur — `brew install --cask n0sfer666/tap/humane-space-tab` ya da Releases’ten disk
   kalıbını aç ve **Humane Space Tab.app**’i Applications kısayoluna sürükle — sonra
   başlat.
2. İnternetten indirilen bir uygulama ilk seferde reddedilir: **Sistem Ayarları →
   Gizlilik ve Güvenlik**’i aç, en aşağı in, **Yine de Aç**’a bas ve yeniden başlat.
3. Uygulama açılırken **Erişilebilirlik** ister. İzni **Sistem Ayarları → Gizlilik ve
   Güvenlik → Erişilebilirlik**’ten ver. Değiştirici birkaç saniye içinde çalışmaya
   başlar; yeniden başlatmaya gerek yok.

Menü çubuğundaki simge, uygulamanın çalıştığının tek kanıtıdır: çalışıyorsa `⇄`,
çalışamıyorsa bir uyarı üçgeni. macOS izni kodun imzasına bağlar, bu yüzden her
güncellemeden sonra izni yeniden vermek gerekir.

## Uygulamalar arasında geçiş

**⌘**’i basılı tut ve **Tab**’a bas. Ne olacağı, ne kadar tuttuğuna bağlıdır:

- **Kısa bir dokunuş** — gecikmenin altında (varsayılan 120 ms) — hiçbir şey göstermeden
  bir önceki uygulamaya geçer, kas belleğinin beklediği gibi.
- **⌘’i bırakma**, şerit **geçerli masaüstünün** uygulamalarıyla belirir, en son
  kullanılanlar önde. Sonraki her **Tab** seçimi bir adım ilerletir.

Şerit açıkken:

| Tuş | Ne yapar |
|---|---|
| **Tab** | bir adım ileri |
| **⇧Tab** | bir adım geri |
| **Escape** | iptal — hiçbir şey değişmez |
| **⌘**’i bırakmak | seçili uygulamaya geç |

Seçili uygulama, daha büyük ve daha güçlü çizilen, altında adı yazan simgedir; komşuları
soluklaşır. Beş uygulamadan itibaren şerit bir karusele dönüşür: seçim yerinde durur,
simgeler onun altında döner; böylece bir adım göz için hep aynı mesafedir ve listenin ucu
yoktur — son uygulamadan sonra ilki gelir. Beşin altında her simge yerinde kalır, yalnızca
seçim gezer. Şerit on yuvada büyümeyi bırakır.

Hiçbir şeyin açık olmadığı bir masaüstünde şerit yine de yanıt verir ve orada bir şey
olmadığını söyler; tuşu sistemin değiştiricisine geri vermez.

## Bir uygulamanın pencereleri arasında geçiş

**⌘**’i basılı tut ve **`**’a bas (Tab’ın üstündeki tuş). Şerit, öndeki uygulamanın
pencerelerini listeler — yalnızca geçerli masaüstündekileri, yığın sırasına göre, her biri
kendi başlığıyla. Hareket aynıdır: `⇧` yönü ters çevirir, Escape iptal eder, bırakılan
**⌘** pencereyi öne getirir.

Sistemin kısayolu bütün masaüstlerinin pencerelerini bir arada sayar; seni başka bir
masaüstüne atmasının nedeni budur. Bu kısayol bunu yapamaz: burada olmayan bir pencere
listede de yoktur, dolayısıyla masaüstü hiç değişmez ve Dock’tan hiçbir şey geri
getirilmez.

## Fare

Şerit açıkken imleç onun üzerinde iş görür:

- bir simgenin üzerinde **fareyi hareket ettir**, o simge seçilir — şeridin açıldığı yerde
  öylece duran bir imleç, kımıldayana kadar hiçbir şeyi değiştirmez;
- bir simgeye **tıkla**, **⌘**’in bırakılmasını beklemeden hemen ona geçilir;
- şeridin üzerinde **kaydır**, seçim adım adım ilerler.

## Ayarlar

Menü çubuğu simgesinden → **Ayarlar…**.

![Ayarlar](images/settings.png)

| Ayar | Nedir |
|---|---|
| **Uygulamalar** | şeridi açan kısayol. Alana tıkla ve kombinasyonu yaz ya da `⌘Tab` için **Varsayılana döndür**. |
| **Öndeki uygulamanın pencereleri** | ikinci kısayol, varsayılan olarak `` ⌘` ``. |
| **Şeridi şurada göster** | klavye odağının olduğu ekran ya da imlecin olduğu ekran. |
| **Dil** | arayüzün dili. **Sistem** macOS’u izler; uygulamanın taşıdığı diller kendi adlarıyla yazılıdır. Bir dil seçmek pencereyi hemen yeniden çizer. |
| **Görünmeden önceki gecikme** | şerit belirene kadar kısayolun ne kadar tutulacağı — 0 ile 500 ms arası. `0`’da hemen belirir. |
| **Girişte aç** | uygulamayı macOS’a giriş öğesi olarak kaydeder. |
| **Uygulamalar yerine pencereler arasında geç** | `⌘Tab` artık pencereleri listeler, Windows ve Linux’taki gibi. Varsayılan olarak kapalı: aynı düzenleyicinin iki belgesi o zaman iki kayıt olur. |
| **Masaüstlerinin özel katmanını kullan** | özel katman, Dock’a küçültülmüş bir pencerenin hangi masaüstüne ait olduğunu bilir ama belgelenmemiştir. Kapalıyken uygulama yalnızca ekrandaki pencerelere bakar. |

Uygulama on beş dil taşır — İngilizce, Rusça, Almanca, Fransızca, İspanyolca, Portekizce
(Brezilya), İtalyanca, Felemenkçe, Lehçe, Türkçe, Ukraynaca, Japonca, Korece ve iki Çin
yazısı — diğer her şey için İngilizce yanıt verir. Bu kılavuzda etiketler Türkçe olarak
alıntılanır.

Bir kısayolun basılı tutulacak bir değiştirici tuşa ihtiyacı vardır ve kaydedici, tasarımın
yerine getiremeyeceğini reddeder — değiştiricisi olmayan bir kombinasyon, içinde zaten
**⇧** olan biri (o ters yöndür), **Escape**, `⌘Q` ve `⌘W` — ve hangisi olduğunu söyler.
Kısayol, o anki giriş kaynağının tuşlarıyla çizilir.

## Görünüm

**Ayarlar…**’ın ikinci sekmesi, profillerde tutulan şerit görünümüdür. **Varsayılan**
yerleşiktir ve değiştirilemez: **Çoğalt** değiştirilebilir bir kopya yapar, **Ad** ona kendi
adını verir. Yerleşiğin üstüne beş profil sınırdır; etkin olanı silmek **Varsayılan**’ı
etkin bırakır.

| Ayar | Nedir |
|---|---|
| **Simge boyutu** | bir simgenin en fazla ne kadar büyük çizileceği — kalabalık bir şerit, ekrana sığmak için simgeleri yine de bunun altına küçültür. |
| **Simge opaklığı** | simgelerin ne kadar güçlü çizildiği. %100 en üst sınırdır; altında da seçim yine öne çıkar, çünkü hazır ayar seçili olmayan her şeyi soluklaştırır. |
| **Şerit kenar boşluğu** | simgelerle şeridin kenarı arasındaki yer, simgenin bir oranı olarak. |
| **Simgeler arası boşluk** | iki simge arasındaki yer, aynı oranla. |
| **Köşe yarıçapı** | şeridin köşelerinin ne kadar yuvarlak olduğu. |
| **Simgenin çevresindeki çerçeve**, **Çerçeve boşluğu** | simgenin çevresine çizilen bir çizgi ve ona olan uzaklığı. |
| **Arka plan** | **Cam** sistemin kendi malzemesidir; **Koyuluk** onu karartır ve `0`’da şerit çıplak camdır, masaüstü içinden okunur. **Saydam** ve **Pencere arka plan rengi** malzeme taşımaz, yalnızca **Matlık** ile ayarlanır. |
| **Karusel** | **Sırayı seçimin altında döndür** kapalıyken sıra yerinde durur ve sığmak için küçülür; açıkken **Yuvalar** kaç simgede döndüğünü söyler — 5 ile 12 arası. |
| **Seçim** | seçili simgenin nasıl ayırt edildiği: sistem değiştiricisindeki gibi, büyütülmüş, tek başına öne çıkmış ya da çerçeveli. |

Her sayının aynı değeri gösteren bir sürgüsü ve bir alanı vardır ve aralıklar birbirine
yanıt verir: boşlukları genişletmek kenar boşluğuna büyüyecek daha az yer bırakır. **Bir
örnek göster…**, seçtiğin sayıda örnek uygulamayla şeridi dört saniye boyunca çizer;
üzerinde çalıştığın masaüstünü rahatsız etmez.

## Menü çubuğu

| Öğe | Ne zaman görünür |
|---|---|
| **Erişilebilirlik’i aç…** | izin eksik olduğu sürece — yeniden ister |
| **Girdi İzleme’yi aç…** | macOS tuş vuruşlarını tuttuğunda (aşağıya bak) |
| **Ayarlar…** | her zaman |
| **Uygulama ve pencere listesini kopyala** | her zaman — geçerli masaüstünün uygulama listesini panoya kopyalar; hata bildirimine eklenecek şey budur |
| **Humane Space Tab’den çık** | her zaman |

## Bir şeyler ters gittiğinde

**Menü çubuğunda simge yok.** Çentiğin solunda boş yer kalmamış bir menü çubuğu simgeyi
düşürür: macOS sığdıramadığı bir durum öğesini çizmez ve uygulamanın o yeri talep etmesinin
yolu yoktur. Bir yer aç ya da uygulamayı Finder veya Spotlight’tan yeniden aç — ikinci
açılış, ikinci bir kopya değil, ayarları açar.

**Simge, macOS’un tuş vuruşlarını tuttuğunu söylüyor.** Uygulamanın eski bir kaydı buna
**Sistem Ayarları → Gizlilik ve Güvenlik → Girdi İzleme** içinde izin vermiyor. O kaydı
**−** ile sil — uygulamanın izne değil, yasağın yokluğuna ihtiyacı var — ve yeniden
uygulamaya tıkla; dinleyici yeniden başlatmadan kurulur.

**`⌘Tab` hâlâ sistemin değiştiricisi.** İzin yok ya da bir önceki sürüme ait.
**Erişilebilirlik’i aç…**’ı kullan; listede uygulamanın kaydı zaten varsa **−** ile sil ve
izni yeniden ver.

**“Girişte aç” yerinde durmuyor.** macOS kaydı reddederse bunu onay kutusunun altında kendi
sözleriyle söyler. Alışılmış neden, sistemin tanımadığı bir sürümdür: her yerel derleme
kendi ad-hoc imzasını taşır, yani dünkü kopyanın yaptığı kayıt bugünküne ait değildir.
`/Applications` içindeki kopyada kapat ve yeniden aç.

## Uygulama ne görebilir

Geniş bir izin olan Erişilebilirlik’i tutar ve onunla bilerek çok az şey yapar: hiç ağ
kodu yok, AppleEvents yok, eklenti yok; tuş vuruşlarına yalnızca senin kısayolunla eşleşip
eşleşmediklerine bakılır; pencere başlıkları yalnızca pencere geçişi açıkken ve yalnızca
çizilmek üzere okunur; imleç yalnızca şeridin kendi paneli üzerinde görülür. Ekran Kaydı
iznini hiç istemez — pencere önizlemeleri göstermemesinin nedeni budur. Tam tehdit modeli:
[S00](specs/S00-threat-model.md).
