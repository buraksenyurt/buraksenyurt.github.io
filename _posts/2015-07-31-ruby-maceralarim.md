---
layout: post
title: "Ruby Maceralarım"
date: 2015-07-31 16:00:00
tags:
  - ruby-lang
  - programlama
  - oop
  - newEra
categories:
  - Programlama Dilleri
---
Kırklı yaşlarına gelmekte olan bir yazılımcıyım ve uzun zamandır bu işin içerisindeyim. Fark ettim ki yeni bir şeyler araştırmadan rahat edemiyorum. Belki hep.Net üzerine yoğunlaştım ancak zaman zaman farklı alanlara da göz atıyorum. Bu düşüncelere sahip olduğum dönemlerde ağırlıklı olarak farklı programlama dillerini tanımaya çalışıyorum.

![ruby maceralarım 01](/assets/images/2015/ruby-maceralarim-01.jpg)

Zamanında az da olsa Haskell, Scala, Go gibi dillere bakmıştım. Hatta çok uzun zaman önce ciddi olarak Java platformu ile ilgilenmiştim. Farklı programlama dillerini incelemek bir yazılımcı için önemli. Bu sayede örneğin fonksiyonel programlama gerçekten ne anlama geliyor veya dinamik dil denince ne ifade edilmek isteniyor daha kolay anlaşılabiliyor.

Tabii araştırma için de zaman ayırabilmek lazım. İş ve gündelik yaşantımızdaki yoğunluk düşünüldüğünde zaman zaman ciddi fedakarlıklar yapmamız gerektiği de ortada. Ben de sık sık olmasa da öğle aralarımı veya bazı günler mesai sonrası saatlerimi (Her ne kadar hollandalı patronum bu durumu zaman zaman içerlese de) yeni bir şeyleri araştırmaya ayırıyorum.

Yine böyle günlerden birisinde kendimi bir anda "çocuklara programlamayı nasıl öğretebiliriz?" sorusuna cevap ararken buldum. Bu konuda en çok duyduğum ifade MIT'nin [Scratch](https://scratch.mit.edu/) isimli çalışmasıydı. Hatta bu konuda Türkçe kaynak ve eğitim setleri bulmak bile mümkündü. Fakat araştırmalarım sırasında gözüm Ruby diline de takıldı. Özellikle 10 yaş üzeri çocukların programlama mantığını öğrenmesi için bir kitap bile buldum ve hiç vakit kaybetmeden Amazon'dan getirttim.

![ruby maceralarım 02](/assets/images/2015/ruby-maceralarim-02.jpg)

Bir süredir bu dil üzerinde çalışıyorum. Çok yoğun vakit ayıramasam da bir "Merhaba Dünya" demenin zamanı geldi diye düşünüyorum. Öyleyse başlayalım.

## Temel Bilgiler

Ruby, Japon bilgisayar ve yazılım uzmanı [Yukihiro "Matz" Matsumoto](https://en.wikipedia.org/wiki/Yukihiro_Matsumoto) tarafından geliştirilmiş bir programlama dilidir. Matz bu dili inşa ederken özellikle kolay yazılabilir ve aynı zamanda güçlü bir dil olmasına gayret etmiştir. Dilin felsefesini kendisi şu paragraf ile özetlemiştir.

Dili daha iyi tanıyabilmek için diğer karakteristik özelliklerine bakmamızda yarar var. Bunlar temel olarak aşağıdaki maddeler halinde sıralayabiliriz.

- Her şeyden önce nesne yönelimli (Object Oriented) bir dildir.
- İngilizce dilbilgisine çok yakındır bu yüzden kolay okunur ve anlaşılırdır.
- Yeri geldiğinde procedural veya fonksiyonel bir dil olarak kullanılabilir.
- Dinamik bir programlama dildir.(Dynamic Programming Language)
- Söz dizimi kolaylığı ve OOP gibi özellikleri sayesinde DSL (Domain Specific Language) geliştirilmesi kolaydır.
- Meta programlama (Metaprogramming) yetenekleri içerir.
- Ruby geliştirilirken Ada, Eiffel, Lisp, Smalltalk, Perl gibi diller dikkate alınmıştır.
- Kaynak kodu açık, özgür bir programlama dili olarak tasarlanmıştır.

Ruby platform bağımsızdır. Yani bir makinede geliştirilen Ruby kodları farklı bir platform için de geçerlidir. Bunun yanında özellikle öğrencilere programlama mantığını eğlenceli bir şekilde öğretebilmek için ideal bir dildir. [Quora](http://goo.gl/uVCycw)'daki bilgilere göre GitHub ve Twitter, Ruby on Rails kullanmışlardır. Zaman içerisinde Sun Microsystems, Microsoft, Intel, Apple ve Amazon gibi büyük çaplı firmaların Ruby programlama dilini kullandığı belirtilmiştir ([Kaynak:Beginning Ruby:From novice to professional-Apress](http://www.amazon.com/Beginning-Ruby-Novice-Professional-Experts/dp/1430223634))

Pek tabi kullanım alanları düşünüldüğünde özellikle bilimsel çalışmalar için de ideal olduğu ifade edilebilir. Güçlü Regex desteği sayesinde metinsel sorgulama ve işleme alanında, CGI programlamada, Network operasyonlarında, XML işlemede, prototip geliştirmede yoğun bir şekilde kullanılmaktadır. Desteklediği platform yelpazesi son derece geniştir. Windows, Linux, MacOs bir yana Java Symbion yüklü cihazlarda dahi programlama yapabileceğimiz ifade edilmektedir. Hatta kaynaklara göre Amiga üzerinde bile Ruby kodlaması yapılabilinir. (Bunu denemek istiyorum gerçekten de.)

## Kurulum ve İlk Kodlar

Ruby dili tercih edilen platforma göre [şu adresten](https://www.ruby-lang.org/tr/downloads/) indirilip kurulabilir. Ben klasik olarak Windows platformu üzerinde bir kurulum gerçekleştirdim. Ancak ilerleyen zamanlarda Linux ve MacOSx üzerinde de denemeler yapmayı planlıyorum. Kurulum işlemi tamamlandığında hemen kodlamaya başlayabileceğimiz Interactive Ruby isimli komut satırı aracının da yüklendiği görülebilir. İlk kodlarımızı irb komut satırında aşağıdaki gibi yazabiliriz.

![ruby maceralarım 03](/assets/images/2015/ruby-maceralarim-03.jpg)

Yukarıdaki ekran görüntüsünde yer alan kod parçası dilin İngilizce'ye ne kadar yakın olduğunu da göstermektedir. Bu sebepten söz dizimi okunurluğu oldukça kolaydır. (Aslında böyle bir söz dizimini yazmak ve okumak oldukça eğlencelidir de. En azından ben çok eğlendiğimi ifade edebilirim. İnsan kod yazarken gülümser mi? Evet gülümser.)

## Her Şey Bir Nesnedir

Ruby dili OOP (Object Oriented Programming) özelliklerini taşır. Bu yüzden her şey bir nesne olarak düşünülebilir. Aşağıdaki kod parçasını bu anlamda göz önüne alabiliriz.

![ruby maceralarım 04](/assets/images/2015/ruby-maceralarim-04.jpg)

Burada Ruby'nin temel nesne yapısı da az çok görülmektedir. C# veya Java dili ile uğraşanlar için her şeyin nesne olarak ifade edilebilmesi aslında her şeyin bir super/base sınıftan türemesi anlamına da gelmektedir. Aşağıdaki şekil Ruby'nin temel tip hiyerarşisini göstermektedir. (Tabi bunun en güncel halini bulmamız da yarar var. Buraya not düşelim)

![ruby maceralarım 05](/assets/images/2015/ruby-maceralarim-05.jpg)

## Var Olan Tipleri Genişletmek

Ruby'de sınıfları genişletmek oldukça kolaydır. Yani var olan bir tipe yeni bir fonksiyonellik kazandırmak basittir. Bu anlamda aşağıdaki kod parçasını göz önüne alabiliriz.

```ruby
class String
	def KarizmatikYap
		newWord=""
		self.split("").each{|c| newWord<<c<<" "}
		newWord.chop
	end
end

if __FILE__ == $0
	puts "Mesajiniz nedir?"
	mesaj=gets
	karizmatikHali=mesaj.KarizmatikYap
	puts karizmatikHali
end
```

Hemen şunu ifade edelim. Yukarıdaki kod parçasını rb uzantılı bir dosya olarak kaydedip normal komut satırından ruby programı ile aşağıdaki gibi çalıştırabiliriz. Dejavuuu:)

![ruby maceralarım 06](/assets/images/2015/ruby-maceralarim-06.jpg)

String zaten ruby diline ait bir sınıftır. def ve end bloğu arasında tanımlanan kod parçası, KarizmatikYap isimli bir metoda aittir.String tipinde herhangi bir değişken üzerinden KarizmatikYap isimli metod kullanılabilir. Bunu C# tarafındaki genişletme metodlarına (Extension Methods) benzetebiliriz.

Metod içerisinde kullanılan self anahtar kelimesi ile çalışma zamanındaki string değişkeni işaret edilir. Bu yüzden self üzerinden de String sınıfına ait olan metodlar çağırılabilir. split bunlardan birisidir. Hemen arkasında gelen each ifadesinde süslü paranetezler içerisinde bir operayon gerçekleştirildiği gözden kaçmamalıdır.

Bu ifadeye benzer bir yapı LINQ (Language INtegrated Query) tarafında da mevcuttur. c ile self'in işaret ettiği ve split ile ayrıştırılarak karakter katarı haline getirilmiş dizinin elemanları işaret edilir. Sonrasında newWord isimli değişkene << operatörü ile sağdan olmak üzere o anki karakter ile bir boşluk eklenir. chop metodu en sondaki boşluk karakterini atmak için idealdir.

__FILE__ bloğu içerisinde ise öncelikle komut satırından bir bilgi istenmekte ve sonrasında KarizmatikYap metodu çağırılarak sonuçlar ekrana yazdırılmaktadır. puts bir alt satıra geçirecek şekilde ekrana bilgi yazarken, gets ile ekrandan mesaj alınması sağlanır. Bu arada self sonrası kullanımlarda bir metod zinciri oluştuğunu ve hafiften Fluent bir söz dizimine gidildiğine de dikkat edelim derim.

## Ruby'nin Büyük Sayılar ile Arası

Oldukça iyidir:) Bunu ifade etmek için aşağıdaki kod parçasını göz önüne alabiliriz.

```ruby
def Faktoryel(sayi)
	if sayi==0
		1
	else
		sayi*Faktoryel(sayi-1)
	end
end

if __FILE__ == $0
	puts "Bir sayi giriniz"
	sayi=gets.to_i
	f=Faktoryel sayi
	puts f
end
```

Yine bu kod parçasını rb uzantılı bir dosya adı ile kaydedip komut satırından ruby aracı ile aşağıdaki ekran görüntüsünde yer aldığı gibi çalıştırabiliriz.

![ruby maceralarım 07](/assets/images/2015/ruby-maceralarim-07.jpg)

Sayı aslında bir kaç satır daha devam ediyor bunu belirteyim.

Bu kod parçasında ise pek çok dilde sıklıkla ele aldığımız faktöryel hesabı yapılmaktadır. Özyinelemeli (Recursive) bir fonksiyon kullanımı söz konusudur. Faktoryel isimli metod sayi isimli bir parametre almaktadır. if bloklarında en çok göze çarpan şey ise return gibi bir anahtar kelime kullanılmamış olmasıdır ki aslında kullanılabilir ve bazı durumlarda kullanmak gerekir. Diğer yandan Faktoryel isimli metodun çağırılması sırasında parantezlerin de açılmadığı gözden kaçmamalıdır ki açılabilir de:) Tüm bunlar aslında basit kod okunurluğu ve gereksiz detayların kodlamadan çıkartılmış olması adına önemlidir.

## İlginç Bir Kod Parçası

Pek tabi Ruby dili ile uğraşırken bana enteresan gelen kod parçaları da öğrenmedim değil. Örneğin bir metoddan birden fazla parametre nasıl döndürülebilir sorusuna cevaben aşağıdaki kod parçasında olduğu gibi.

```ruby
def Hesapla(x,y)
	return x+y,x-y,x*y,x/y 
end
toplam,fark,carpim,bolum=Hesapla 8,3.14
puts "#{toplam}\n#{fark}\n#{carpim}\n#{bolum}"
```

![ruby maceralarım 08](/assets/images/2015/ruby-maceralarim-08.jpg)

Özellikle toplam, fark, carpim ve bolum değişkenlerin Hesapla metodunun çalışma sonuçlarının nasıl atandığına dikkat edelim. puts'dan sonra gelen ifade içerisinde yer alan #{toplam} gibi terimler ile kod dosyası içerisindeki değişkenlere erişip metin içerisine gömdüğümüzü belirtebiliriz. Çok basit ve eğlenceli değil mi?

> Ruby is designed to make programmers happy. -Matz-

## Sonuç Olarak

Görüldüğü üzere Ruby ile programlama oldukça eğlenceli. Dilin gerçekten çok güçlü özellikleri var. OOP temellerini taşıyor olması bunun en büyük sebebi. Diğer yandan İngilizce diline çok yakın tasarlanması, kolay okunabilir kod yazılabilmesi, "aklın yolu bir" dedirten ifadeleri ile Fluent yapıların ve doğal olarak Domain'e özgü dillerin geliştirilmesi için de ideal.

Bu yazımızda Ruby dilini kısaca tanımlamaya çalıştık. Kod parçaları biraz dağınık olsalar da size fikir verebilmişimdir diye ümit ediyorum. Henüz benim de yeni yeni öğrenmeye çalıştığım bu dil ile ilgili maceralarımız devam edecek. Bir başka yazımızda görüşmek dileğiyle, hepinize mutlu günler dilerim.
