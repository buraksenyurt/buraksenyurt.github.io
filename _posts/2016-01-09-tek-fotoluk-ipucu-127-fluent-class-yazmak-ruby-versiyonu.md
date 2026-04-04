---
layout: post
title: "Tek Fotoluk İpucu 127 – Fluent Class Yazmak (Ruby versiyonu)"
date: 2016-01-09 20:00:00
tags:
  - fluent-api
  - fluent-interface
  - ruby-lang
categories:
  - Foto İpucu
---
Geçtiğimiz günlerde her zamanki gibi Google Chrome’ un RSS Feed Reader’ ındaki blog yazılarında geziniyordum. Derken Fatih Boy hocanın [bu adresteki](http://www.enterprisecoding.com/post/verbalexpressions-sozlu-duzenli-ifade-kutuphaneleri) yazısına denk geldim. Aslında buradaki gibi Fluent geliştirilen tipler kod tarafındaki işlerimizi oldukça kolaylaştırmakta. Felsefesi oldukça basit olan bu yaklaşımda anahtar nokta, tipin kendisine ait çalışma zamanı örneklerini döndüren fonksiyonelliklere başvurulması. Böylece bir metod zinciri ile bir tipe davranışlar yüklemek son derece kolaylaşıyor.

> Fluent Interface Nedir?
> Fluent Interface Prensibi ile Daha Okunabilir Kod Geliştirmek
> Fluent Interface Prensibi ile Daha Okunabilir Kod Geliştirmek - İkinci Yarı
> Tek Fotoluk İpucu 118 – Fluent Command Line Parser ile Hello World

Peki ya Ruby tarafında (bir süredir bu dil ile hobi olarak uğraştığımı biliyorsunuzdur belki) bir tipi Fluent hale nasıl getirebiliriz? Bunu en basit haliyle aşağıdaki gibi yapabiliriz.

![KAAAA7](/assets/images/2016/tek-fotoluk-ipucu-127-fluent-class-yazmak-ruby-versiyonu-01.gif)

Dikkat edileceği üzere foo isimli Soldier sınıfı kullanılırken bağımsız sırada bir metot zinciri oluşturulmuştur. Önce askerin ismi verilmiş, ardından bir silah yüklemesi yapılmış, zırhı kuşandırılmış, öne doğru hareket etmesi sağlanmış, sonrasında durdurulmuş, tekrar geriye doğru hareket etmesi emredilmiş ve son olarak yine durması söylenmiştir. Anahtar nokta Soldier sınıfı içerisindeki metodların, self anahtar kelimesini kullanarak var olan nesne örneğinin içeriğini değiştirmesi ve bu içeriğin son halini geriye döndürmesidir.

Örnek çok basittir ve sadece puts ile ekrana bilgi yazılmaktadır. Daha da geliştirilebilir. Örneğin askerin silahı veya zırhı başka birer sınıf olarak tasarlansa daha iyi olur. Diğer yandan askerin birden fazla silaha sahip olması da muhtemeldir. Dolayısıyla n sayıda silahı temsil edecek şekilde bir tip dizisi kullanılması düşünülebilir. Bunları siz değerli okurlarımdan Ruby ile uğraşanlara bırakıyorum. Artık Verbal Expressions kütüphanesini daha iyi anayabileceğinize inanıyorum. Hatta Ruby ile nasıl kullanıldığına bakabilir ve böyle bir sınıfı geliştirmeyi deneyebilirsiniz. Bir başka ipucunda görüşmek dileğiyle hepinize mutlu günler dilerim.