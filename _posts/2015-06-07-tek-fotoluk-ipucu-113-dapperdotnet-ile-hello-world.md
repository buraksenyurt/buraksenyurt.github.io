---
layout: post
title: "Tek Fotoluk İpucu 113 - Dapper.Net ile Hello World"
date: 2015-06-07 08:14:00
categories:
  - Genel
tags:
  - tek-fotoluk-ipucu
  - nuget
  - dapper.net
  - orm
  - sql
  - language-integrated-query
  - query
  - entity-framework
  - dynamic
---
Gecenin bir yarısı. Bilgisayarınızın başındasınız. Önünüzde Visual Studio. Yanınızda kahveniz/çayınız. Canınız da sıkılmış. Acaba ne yapsam da vaktimi iyi değerlendirebilsem diye düşünüyorsunuz. Böyle hallerde şöyle bir NuGet paketi bulup araştırmak bünyeye iyi gelebiliyor. Bunun için [Nuget Must Haves](http://nugetmusthaves.com/) isimli siteyi ziyaret edebilirsiniz.

Diyelim ki öyle bir gece ve orada [Dapper.Net](https://github.com/StackExchange/dapper-dot-net) diye bir paket gördünüz. Hatta azcık Entity Framework, Oracel/SQL ve O-RM (Object Relational Mapping) bilginiz var. Hazır elinizin altında da Microsoft'un emektar Northwind veritabanı. O halde ne duruyorsunuz. Bir Hello World diyivirsiniz ya! Aynen aşağıdaki fotoğrafta görüldüğü gibi:)

![tek fotoluk ipucu 113 dapperdotnet ile hello world 01](/assets/images/2015/tek-fotoluk-ipucu-113-dapperdotnet-ile-hello-world-01.png)

Bu örnekte ilk dikkati çeken noktaları ise şu şekilde ifade edebiliriz.

Aynen Ado.Net'te olduğu gibi SqlConnection nesnesi kullanıyoruz.
Normal bir SQL sorgusu çalıştırıp sonuçlarını doğrudan POCO (Plain Old CLR Object) tipinden bir listeye atabiliyoruz.
for döngüsünde dynamic kullanımı söz konusu (Debug edip bakın)
Query metoduna yapılan çağrı sonucu elde edilen liste üzerinden LINQ (Language INtegrated Query) kabiliyetlerini kullanabiliyoruz.
Dapper.Net'in tek bir dll olarak geldiğini görüyoruz.
Epey zamandır var olan bu NuGet paketini yeni keşfettiğimiz için üzülüyoruz.

Dapper.Net benim çok hoşuma gitti. Özellikle işin içerisinde Stackoverflow geliştiricilerinin yer alması, basit ve anlaşılır olması ile Oracle desteği sunması beni onu araştırmaya itti diyebilirim.

Başka bir ipucunda görüşmek dileğiyle, hepinize mutlu günler dilerim.