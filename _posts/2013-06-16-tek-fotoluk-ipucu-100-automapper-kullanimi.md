---
layout: post
title: "Tek Fotoluk İpucu 100–AutoMapper Kullanımı"
date: 2013-06-16 09:45:00 +0300
categories:
  - Genel
tags:
  - automapper
  - poco
  - plain-old-clr-objects
  - map
  - type-casting
  - type-map
---
Bildiğiniz üzere [şu yazımızda](/2013/03/25/tek-fotoluk-ipucu-99-tipler-arasi-property-eslestirme/) nesneler arası özellik (Property) eşleştirmelerinin nasıl yapılabileceğini incelemeye çalışmıştık. Ancak işin çok daha profesyonel bir boyutu var. Örneğin tipler arası özellik adları birbirlerinden farklı olabilir ve bu nedenle bir haritayı önceden söylemeniz gerekebilir. Neyseki NuGet üzerinden yayınlanan AutoMapper kütüphanesi çok gelişmiş özellikleri ile buna imkan vermektedir. Söz gelimi aşağıdaki fotoğraf özellik adlarının farklı olması halinde bile AutoMapper ile başarılı bir şekilde eşleştirme yapılabileceğini göstermektedir.

![tfi_100](/assets/images/2013/tfi_100.png)

Denemeden önce en azından install-package AutoMapper komutunu Package Manager Console’ dan çalıştırıp ilgili kütüphaneyi yüklemeyi unutmayınız.