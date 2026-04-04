---
layout: post
title: "Tek Fotoluk İpucu 121 - Code Contracts ve Immutable Type"
date: 2015-11-16 06:00:00
categories:
  - Genel
tags:
  - Immutable-Types
  - code-contracts
  - csharp
  - Static-Checking
  - Perform-Runtime-Contract-Checking
  - precondition
---
Bazı durumlarda tanımladığımız tiplerin Immutable olmasını isteriz. Bildiğiniz üzere bir nesne örneğinin özellikleri ile nitelenen durumunun (State) çalışma zamanı boyunca değişmesini istemiyorsak Immutable hale getirebiliriz.

Bir tipin Immutable olması için yapılacaklar bellidir. Nesne durumunu taşıyan özellikler (Property) dışarıdan erişime kapatılır ve değerleri sadece yapıcı metod (Constructor) tarafından belirlenir. Eğer çalışma zamanında bu nesne örneğinin durumunun değişmesi gerekiyorsa (Örneğin belirli özelliklerinin değerlerinin değişmesi), kendisine ait yeni nesne örneği üretip döndüren fonksiyonlardan yararlanılır.

Temel olarak aşağıdaki fotoğraflarda yer alan Scene tipini bu anlamda baz alabiliriz. Width, Height ve Title özelliklerine ait set blokları private erişim belirleyicisi ile tanımlanmıştır. (Yani nesne örneklendikten sonra değiştirilemezler) Nesne örneklenirken bu özelliklerin alması gereken değerler yapıcı metod (Constructor) ile belirlenir. Eğer üretilen bir Scene'in genişlik,yükseklik veya adı değiştirilmek isteniyorsa bu yeni değerleri baz alarak geriye başka bir Scene örneğinin döndürülmesi sağlanmalıdır. IncreaseArea metodu bunu sağlıyor.

Tabi Immutable tiplerin kullanılması sırasında ilk değerler verilirken yapılmasını istediğimiz kontroller olabilir. Burada bazı sözleşmeleri devreye sokarak gerekli doğrulatmaları sağlayabiliriz. Nasıl mı? Örneğin Code Contracts bunun için kullanılabilir. Aynen aşağıdaki ipuçlarında olduğu gibi.

Proje Özellikleri -> Code Contracts -> Static Checking aktifken

![rgVjAAAAAElFTkSuQmCC](/assets/images/2015/tek-fotoluk-ipucu-121-code-contracts-ve-immutable-type-01.png)

Proje Özellikleri -> Code Contracts -> Perform Runtime Contract Checking aktifken

![P9C134KIK9m5AAAAAElFTkSuQmCC](/assets/images/2015/tek-fotoluk-ipucu-121-code-contracts-ve-immutable-type-02.png)

Görüldüğü gibi ön koşullandırma (Precondition) özelliklerini kullanarak Immutable bir tipin ilk değerlerinin çeşitli kriterleri sağlamasını garanti etmemiz oldukça kolay.

Bir başka ipucunda görüşmek dileğiyle hepinize mutlu günler dilerim.