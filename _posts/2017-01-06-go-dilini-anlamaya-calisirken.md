---
layout: post
title: "Go Dilini Anlamaya Çalışırken"
date: 2017-01-06 03:56:00
tags:
  - google-go
  - golang
  - programming-languages
  - programlama
categories:
  - Programlama Dilleri
---
Liseye başladığım 1990 yılından beri arkadaşım ve aynı zamanda adaşım olan sevgili dostum Burak ile üniversite yıllarında öğrenip oynamaya başladığımız GO oyunu geldi aklıma. Öğrenmesi zor, kavramak için yıllar geçmesi gereken, iyi bir oyuncu olmak için sizden daha iyi birisiyle yine yıllarca maç yapmanızı gerektiren zevkli bir strateji oyunu. Ünlü matematikçi John Forbes Nash'ten Albert Einstein'a, Alan Turing'den Bill Gates'e tarihi değiştiren pek çok kişinin de oynadığı bir oyun.

![go dilini anlamaya calisirken 01](/assets/images/2017/go-dilini-anlamaya-calisirken-01.png)

Go oldukça yüksek kombinasyon değerlerine sahip olduğundan bir insanı yenebilecek yapay zekanın geliştirilmesi de zaman aldı. Google'ın DeepMind ekibi tarafından yazılan AlphaGo isimli yapay zeka Ekim 2015'te bu durumu değiştirdi. 19X19luk bir tahtada 9ncu Dan'dan olan Lee Sedol'u 4-1 yenmeyi başarmış bir program. Bu arada IBM'in, Garry Kasparov ile 1-1 biten maçın kahramanı olan Deep Blue'dan sonra geliştirdiği ikinci versiyonu Deeper Blue, Kasparo'u 1997'de yenmeyi başarmıştı. Bundan yıllar yıllar sonra GO'da galip gelebilen bir programın yazılması oyunun ne kadar zorlayıcı olduğunun da bir göstergesi.

Google'ın GO kelimesi ile olan ilk teması AlphaGo değil. 2007 yılında Go isimli bir programlama dili çıkarttılar. Unix'in yaratıcısı olan Ken Thompson (ki bu yeni dilde onun izlerine rastlıyoruz), yine Unix takımından olan Rob Pike ve Google'dan Robert Griesemer tarafından geliştirilen bu dilin ilk etapta sistem programlama için tasarlandığı ifade edilmekte. 2009 yılında resmen duyurulmuş olan dil zaten Google'ın üretim bandındaki sistemlerinde aktif olarak kullanılmakta. Benim en çok ilgimi çeken hususlardan birisi ise TIOBE endeksindeki son bir yıllık yükselişi. 50nci sıradan 16ya sıçrıyor.

![golang_2.gif](/assets/images/2017/golang_2.gif)

O zaman bu GO dili de neymiş? Ben öğrendim ilk iki haftada. İşte okuduğum dökümanlardan derlediğim bazı kısa notlar.

## Karakteristiği

İlk başta dilin genel özelliklerine bakmakta yarar var. Okuduğum kaynaklardan şu özet bilgileri çıkartabildim.

- Nesne yönelimli (Object Oriented) bir dil değil ve bu yüzden sınıf (class), kalıtım (inheritance) gibi kavramlar içermiyor. Inheritance yerine Composition mümkün ama. Güle güle SOLID diyebilir miyiz bilemedim. Bunlara karşın Interface ve Type Embedding desteği mevcut.
- Derleme süresi yüksek bir dil. Zaten kulislerde dilin yüksek performansından sıklıkla bahsedilmekte.
- MultiThreading sistemlerin önemli konularından olan Concurrency işleyişi sık kullandığımız C#, Java dillerindeki gibi Actor tabanlı değil de, [Communicating Sequential Process](https://en.wikipedia.org/wiki/Communicating_sequential_processes) isimli diğer bir metodolojiye dayanıyor. CSP'de Process'ler arası mesaj gönderimi karşılıklı anlaşmaya bağlı. Yani bir Process diğerine mesaj göndermek istiyorsa diğer tarafın bu mesajı almaya hazır olması (veya dinliyor olması) gerekiyor. Bir nevi senkronize mesaj trafiği var diyebiliriz. Actor modelde ise Process'ler arası mesajlaşmaların asenkron işleyebildiğini görüyoruz. Yani dinleyicilerin mesajları almaya hazır olup olmamasının bir önemi yok. Diğer yandan CSP modelinde process'ler isimsiz oluşurken Actor model'de benzersiz bir tanımlayıcı değere sahip olmalılar. Actor modelin CSP'den önce geliştirildiğini de belirtelim. Son söz olarak Go dilinin kendi içerisinde light-weight concurrency desteği verdiğini de söyleyelim. Çok parçacıklı işlerde Go doğuştan kabiliyetli diyebiliriz belki de.
- C ve C++ dillerinden aşina olduğumuz, üniversite eğitimi sırasında kafamızı paramparça eden Pointer kavramı Go dilinde de mevcut. Ne var ki Pointer aritmetiği veya fonksiyonlardan geriye Pointer döndürmek gibi zorlayıcı şeyler yok.
- Bellek yönetimi için kullanılan bir Garabage Collector mekanizması var.
- En büyük özelliklerden birisi tabii ki de kodun doğrudan makine diline derlenmesi. Java tarafındaki Java Virtual Machine veya.Net dünyasındaki Common Language Runtime gibi ara katmanlar bulunmuyor.
- Static tip sistemine sahip. Booelan, Numeric, String gibi ana tipler dışında Pointer, Array, Structure, Function, Slice, Interface, Map ve Channel gibi tipler de söz konusu.
Integer Types -> uint8,uint16,uint32,uint64,int8,int16,int32,int64
Floating Types -> float32,float64,complex64,complex128
Diğer Numeric Tipler -> byte,rune,uint,int,uintptr
Tip zenginliği içeren bir dil olarak da ifade edilmekte. 8 bitlik işaretli işaretesiz tamsayılar dişında 64 ve 128 bitlik float kompleks sayılara da yer verilmiş. Açıkçası Üniversiteden beri Pointer kullanmayan birisi olarak Map, Channel, Slice,rune gibi tiplerin ne işe yaradığını çok merak ediyorum. Çalışıp öğreneceğiz.
- Küçük büyük harf duyarlıklı bir dildir (Case Sensitive)
- Tabii olmayan bir çok şey de var. Bir C# programcısı, Ruby ve Python meraklısı olarak benim de "yok artık" dediğim durumlar söz konusu. Örneğin metodların veya operatörlerin davranışlarını değiştiremiyoruz (Yani overloading desteği yok) Ayrıca generic bir programlama ortamı söz konusu değil. GO dilinde Package odaklı bir geliştirme bulunuyor ve paketler arası Circular Dependency desteği de bulunmuyor.

## Merhaba Diyelim

Bir Hello World desek iyi olmaz mı? E hadi o zaman. Öncesinde GO'nun derleyicisini sistemimize kurmamız gerekiyor. [Bu adresten de görebileceğiniz gibi](https://golang.org/dl/) neredeyse tüm platformlar için bir derleyici söz konusu. Linux, Max OS X, FreeBSD ve son olarak Windows. Elinizin altında bir GO derleyicisi olmayabilir. Benim gibi şirket bilgisayarına program indirip yükleme yetkiniz yoksa, alternatif yollara ihtiyacınız var demektir. Cidden tutturduysanız "Go öğreneceğim Go öğreneceğim, yemek aralarında, sabah mesai öncesinde, akşam mesai sonrasında vakir ayıracağım" diye, [bu adresteki gibi online IDE](https://play.golang.org/)'leri de kullanabilirsiniz.

İlk uygulama kodumuzu aşağıdaki gibi geliştirebiliriz.

```golang
/*
 Bu benim ilk GO programım.
 Sevdim gibi sanki.
*/
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	fmt.Println("Hoş geldin öğrenci\nBugün ki şanslı sayın")
	fmt.Println(GetRandomNumber(36))
}
func GetRandomNumber(seedValue int64) int{
	rand.Seed(seedValue)
	var luckyNumber int
	luckyNumber=rand.Intn(100)
	return luckyNumber
}
```

Öncelikle çalışma zamanı çıktısına bir bakalım.

![01_GoLang_4.gif](/assets/images/2017/01_GoLang_4.gif)

Program temel olarak selamlama yapmakta ve sonrasında rastgele bir sayı üretmektedir (Online çalıştığınız ortam, oturum-session kullanımı sebebiyle sürekli olarak aynı rastgele sayıyı üretebilir. Size tavsiyem kişisel bilgisayarınıza GO yükleyip aynı kodu notepad++ gibi bir editör ile yazdıktan sonra komut satırından go run programadi.go şeklinde çalıştırmanız olacaktır) Program anlamlı bir şeyler yapmasa da üzerinde konuşulması gereken bir çok konuyu içermekte. Şimdi bunlara bir bakalım.

## Kodun Analizi

İlk olarak aşağıdaki çizelgeyi ele alalım derim.

![GoLang_3.gif](/assets/images/2017/GoLang_3.gif)

Go paket (Package) mantığı üzerine kurulu bir dildir. Uygulama main paketi ile başlamak zorundadır ve programın giriş fonksiyonu main'dir. import ifadesinde bu pakette kullanılacak olan diğer paketlere yer verilmiştir. Eğer programa eklediğimiz pakete ait üyeleri kod içerisinde hiç bir yerde kullanmıyorsak derleme zamanında imported and not used: "os" benzeri bir hata almamız muhtemeldir (os bir Go paketidir. Hata mesajında bunun yerine kullanılmayan hangi paket/paketler varsa onları adı gelecektir) GO dili ile birlikte gelen diğer paketlere [şu adresten](https://golang.org/pkg/) bakabilirsiniz.

main metodu entry point'imizdir. İçerisinde fmt paketinden Println fonksiyonunun kullanımı söz konusudur. Tahmin edileceği üzere Println ile ekrana Console ekranına bilgi yazdırıp bir alt satıra geçilmesi sağlanır. İlk ifadede \n gibi bir escape karakteri de kullanılmıştır. İkinci ifade biraz daha dikkate değerdir. Println fonksiynu içerisinde GetRandomNumber metoduna bir çağrı yapılır. Çok şaşırtıcı bir durum değil aslında. Fonksiyona parametre olarak bir başka fonksiyon çağrısının sonucunu veriyoruz. GetRandomNumber, seedValue isimli 64 bitlik bir tamsayı alır ve geriye int tipinden (varsayılan olarak 32 bitlik tamsayıyı işaret eder) bir değer verir. Fonksiyon içerisinde rand paketinden Seed ve Intn isimli fonksiyonlara çağrılar gerçekleştirilmiş ve elde edilen sayı geriye döndürülmüştür.

Metodda ayrıca luckyNumber isimli bir yerel değişken (local variable declaration) tanımlanmıştır. Metod dışında paket seviyesinde değişkenler de tanımlanabilir (Global Variables) Bu tip global değişkenler tanımlandıkları noktadan itibaren kodun kalan kısmında kullanılabilir. luckyNumber değişkeni statik tip tanımlamasına bir örnektir. var anahtar kelimesinden sonra değişken adı ve son olarak değişkenin tipi gelir. Dinamik değişkenler de tanımlayabiliriz. pi:=3.14 gibi bir ifadeyi buna örnek gösterebiliriz. Tabii ki burada C#'tan tanıdık gelecek Type Inference söz konusudur. Yani derleyici eşitliğin sağ tarafındaki değerin hangi tipe uygun olacağını tahmin ederek işlem gerçekleştirir. Yeri gelmişken Go dilinde de az sayıda anahtar kelime (Keyword) bulunduğunu belirtelim.

> break, default, func, interface, select, case, defer, go, map, struct, chan, else, goto, package, switch, const, fallthrough, if, range, type, continue, for, import, return ve var

## Katı Yazım Kuralları

Go katı yazım kurallarına sahip bir dil gibi görünüyor. Burada katılıktan kasıt sadece case-sensitive olma olayı değil. Aşağıdaki hata mesajlarına baktığınızda ne demek istediğimi biraz daha iyi anlayacaksınız.

### { yerleşim durumu

![01_GoLang_4.gif](/assets/images/2017/01_GoLang_4.gif)

### import'taki paket adlarının yerleşimi

![golang_6.gif](/assets/images/2017/golang_6.gif)

### main paketinin olma zorunluluğu

![GoLang_7.gif](/assets/images/2017/GoLang_7.gif)

### Tanımlanmış ama kullanılmayan paket durumu

![golang_8.gif](/assets/images/2017/golang_8.gif)

### main'in ilk fonksiyon olma zorunluluğu

Ha haa...Şaka yaptım. Öyle bir şey yok neyse ki.

Go bende merak uyandıran bir dil. Dokümanları taramaya devam ediyorum. Merak ettiğim pek çok yanı var. Başka dillerle olan benzerlikleri veya farklılıkları söz konusu. İlerleyen zamanlarda farklı Go yazıları ile görüşmek üzere hepinize mutlu günler dilerim.
