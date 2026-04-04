---
layout: post
title: "Tek Fotoluk İpucu 97–Google Shortener URL Hizmetini C# ile Kullanmak"
date: 2013-03-25 21:30:00
tags:
  - tek-fotoluk-ipucu
  - google
  - google-shorten-url-api
  - csharp
  - httpwebrequest
  - httpwebresponse
  - newtonsoft
  - json
  - stream-reader
  - stream-writer
categories:
  - Foto İpucu
---
Malumunuz bazen Web adreslerine ait URL satırları epeyce uzun olabiliyorlar ve bunları saklamak gibi amaçlarla kullanmak istediğimizde, genellikle kısaltma yoluna gitmeyi tercih ediyoruz (Sanırım kimse 20 haneye sığdırılabilecek 200 karakterlik bir URL bilgisi ile uğraşmak istemez) Bir URL adresini kısaltmak için kullanılabilecek pek çok global hizmet bulunmakta. Bunlardan birisi de Google’ ın Shortener servisi (ki [bu adresten de görebileceğiniz](http://goo.gl/) gibi kendisi de epeyce kısa). Peki bir tarayıcı ile bu söz konusu servise kolayca gönderebildiğimiz bir talebi kod tarafında C# ile gerçekleştirmek isteseydiniz nasıl bir yol izlersiniz? Aşağıdaki gibi olabilir mi?

![tfi97](/assets/images/2013/tfi97.png)

Örnekten de görüleceği üzere [https://www.googleapis.com/urlshortener/v1/url](https://www.googleapis.com/urlshortener/v1/url) adresine JSON formatında bir talep gönderilmekte olup, gelen cevap içerisinden id niteliğinin değeri yakalanmaktadır. Üstelik bu işlem sırasında NewtonSoft’ un ilgili NuGet paketinden yararlanılmış olup söz konusu fonksiyonellik, Uri sınıfı için bir Extension Method olarak tanımlanmıştır. (NewtonSoft ile ilişkili olarak [şuradaki](/2012/11/04/tek-fotoluk-ipucu-69-newtonsoft-jsondotnet-ve-dynamic-keyword/) ve [buradaki](/2012/11/12/tek-fotoluk-ipucu-70-yine-newtonsoft-jsondotnet-ve-dynamic/) ipuçlarına bakabilirsiniz) Bir başka ip ucunda görüşmek dileğiyle

[Örneği denerken Google’ ın Shortener servisinin web adresini kontrol etmenizi öneririm. Yazının yazıldığı tarihe rağmen, yayınlandığı tarihte değişmiş, hatta kaldırılmış dahi olabilir]