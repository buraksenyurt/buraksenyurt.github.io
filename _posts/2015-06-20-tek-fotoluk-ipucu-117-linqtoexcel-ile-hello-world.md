---
layout: post
title: "Tek Fotoluk İpucu 117 - LINQtoExcel ile Hello World"
date: 2015-06-20 07:47:00
categories:
  - Genel
tags:
  - tek-fotoluk-ipucu
  - language-integrated-query
  - excel
---
Yine çok sıkıldığınız günlerden biri ve siz şöyle bir yarım saatlik kodlama uğraşı arıyorsunuz. Hani yeni birNuGet paketi denesem nasıl olur diyorsunuz belki de. Hatta azcık da zorlayıcı bir paket olsa, yükleyince hemen çalışmasa ama çok da vaktimi almasa derdindesiniz. Bir bakıyorsunuz karşınızda Excel dosyalarında LINQ (Language INtegrated Query) sorguları yazabilmenizi sağlayan [LINQtoExcel](http://nugetmusthaves.com/Package/LinqToExcel). Hemen örnek bir Exceldosyası oluşturuyorsunuz belki de.

![tek fotoluk ipucu 117 linqtoexcel ile hello world 01](/assets/images/2015/tek-fotoluk-ipucu-117-linqtoexcel-ile-hello-world-01.png)

Ve bu dosya üzerinde basit bir LINQ sorgusu çalıştırmak istiyorsunuz. İlk olarak olayı kavramaya çalışıyorsunuz. Nasıl olabilir diye?

Aslında teori oldukça basit. Eğer LINQ işin içerisindeyse bir Excel dosyasındaki Sheet'ler sanki birer Entitygibi düşünülebilmeli. Hatta bu Sheet'lerin içerisindeki Column'lar, Entity'nin özellikleri (Property) olarak da değerlendirilebilmeli. Yani bir ORM (Object Relational Mapping) mantığı işin içerisinde olmalı. Sadece ilişkisel veri kaynağı bu senaryo için Excel dosyası.

O zaman Players isimli Sheet'de yer alan oyunculardan Mustafar sisteminde olanları bulmak istersek nasıl bir yol izleyebiliriz. Yoksa aşağıdaki fotoğraftaki gibi olabilir mi?

![tek fotoluk ipucu 117 linqtoexcel ile hello world 02](/assets/images/2015/tek-fotoluk-ipucu-117-linqtoexcel-ile-hello-world-02.png)

Küçük bir not; Örneği ilk kez denediğinizde büyük ihtimalle "The 'Microsoft.ACE.OLEDB.12.0' provider is not registered on the local machine." şeklinde bir hata mesajı alabilirsiniz. Nitekim LINQtoExcel çalışabilmesi için gerekli Access Database Engine'e ihtiyaç duymaktadır. Bu yüzden [şu adresteki](http://uzmanim.net/soru/the-microsoft-ace-oledb-12-0-provider-is-not-registered-on-the-local-machine/1822) çözümü uygulayarak sorunu ortadan kaldırmanız gerekebilir.

Bir başka ipucunda görüşmek dileğiyle.
