---
layout: post
title: "Tek Fotoluk İpucu 125 - Single Instance Application"
date: 2015-12-22 15:00:00
categories:
  - Genel
tags:
  - csharp
  - mutex
  - single-instance-applications
  - multiple-instance-applications
---
Bazı uygulamaların çalışma zamanında sadece tek bir örneğinin yaşaması istenebilir (Single Instance Applications) Bilindiği üzere uygulamaların T anında birden fazla örneği olabilir (Multiple Instance Applications) Uygulamanın herhangi T anında tekil olması için ele alınabilecek bir kaç teknik vardır. Bunlardan birisi de Mutex tipinden yararlanmaktır. Aynen aşağıdaki fotoğrafta olduğu gibi.

![tek fotoluk ipucu 125 single instance application 01](/assets/images/2015/tek-fotoluk-ipucu-125-single-instance-application-01.gif)

ApplicationControl sınıfıdaki static Runnable metodu içerisinde Mutex sınıfı kullanılmaktadır.

İşin sırrı Mutex'e verilen isimdir. Eğer aynı isimden bir Mutex nesnesi var ise yeni bir uygulamanın başlatılmasına izin vermemek adına Runnable fonksiyonu geriye false değer döndürür. Tersi durumda ise yeni bir Mutex nesnesi oluşturulacaktır (Örnekte Commander adı kullanılmıştır)

Böylece geldik bir tek fotoluk ipucunun daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
