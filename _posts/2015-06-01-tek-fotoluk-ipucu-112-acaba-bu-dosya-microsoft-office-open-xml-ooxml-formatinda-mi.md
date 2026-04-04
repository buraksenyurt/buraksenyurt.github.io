---
layout: post
title: "Tek Fotoluk İpucu 112 - Acaba Bu Dosya Microsoft Office Open XML(OOXML) Formatında mı?"
date: 2015-06-01 18:00:00
tags:
  - OOXML
  - io
  - csharp
  - tek-fotoluk-ipucu
categories:
  - Foto İpucu
---
Diyelim ki bir yerlerde saklanmış ve kod tarafında byte[] array olarak ifade ediebilecek çeşitli tipte dosya içerikleriniz var ve siz bunların Microsoft Office Open XML formatında olup olmadıklarını anlamak istiyorsunuz. Bir süreci başlatmadan önce DB gibi bir ortamda duran dosyaların gerçekten de istenen tipte olup olmadığını anlamak kritik bir operasyon olabilir. Peki bu tip bir kontrolü gerçekleştirmek için nasıl bir kod parçasına ihtiyacımız olur?

Aslında dosyaların byte içeriklerinin hexadecimal karşılıkları bizlere tipleri hakkında da bir takım ipuçları vermekte ([Şu adrese bir bakın derim](http://www.garykessler.net/library/file_sigs.html)) Dolayısıyla biz de aynı felsefeyi kullanabiliriz. Aynen aşağıdaki fotoğrafta görüldüğü gibi.

![tek fotoluk ipucu 112 acaba bu dosya microsoft office open xml ooxml formatinda mi 01](/assets/images/2015/tek-fotoluk-ipucu-112-acaba-bu-dosya-microsoft-office-open-xml-ooxml-formatinda-mi-01.png)

Tabii tek yol bu olmayabilir. Daha pratik ve efektif yolları bulup paylaşmak siz değerli okurlarıma görev olsun. Bir başka ipucunda görüşmek dileğiyle, hepinize mutlu günler dilerim.