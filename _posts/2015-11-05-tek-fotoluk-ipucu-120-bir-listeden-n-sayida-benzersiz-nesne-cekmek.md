---
layout: post
title: "Tek Fotoluk İpucu 120 - Bir Listeden N Sayıda Benzersiz Nesne Çekmek"
date: 2015-11-05 08:30:00
categories:
  - Genel
tags:
  - csharp
  - generic
  - generics
---
Vaktiyle zamanında (bugün aslında) çalışmakta olduğumuz projede şöyle bir ihtiyacımız oldu; "Bir Oracle tablosundan Entity Framework aracılığı ile çektiğimiz nesne koleksiyonundan benzersiz olan n sayıdakini elde etmek" Elbette bu işi önce SQL tarafında halledip, sonrasında EF tarafına aktarmayı da tercih edebilirdik. Ancak değerli çalışma arkadaşım ile konuyu tartışırken fikir fikri doğurdu ve ortaya şöyle bir ihtiyaç daha çıktı. "Ya bunu T tipinde elemanlardan oluşan herhangi bir koleksiyon üzerinde, herhangi bir kritere göre yaptırmak istesek..."

İşte bu noktada aklımıza aşağıdaki gibi bir çözüm geldi.

![QAAAOw==](/assets/images/2015/tek-fotoluk-ipucu-120-bir-listeden-n-sayida-benzersiz-nesne-cekmek-01.gif)

Kodu kısaca incelediğinizde tahmin edeceğiniz üzere en kritik noktalardan birisi Randomizer sınıfının GetRandomList metoduna bool sonuç döndürüp T tipinden değer alan Func temsilcisi tipinden bir referans geçirilmesi.

Bu sayede sorgu koşulunu (örneğin sadece iki numaralı kategoriyi baz al, ya da her zaman doğru olacak bir kriteri göndererek tüm listeyi değerlendir) yine metoda gelen T türündeki IEnumerable arayüzü (Interface) türevli koleksiyon üzerinde uygulayabiliyoruz. Metod içerisinde ise aynı elemanları tekrar tekrar almamak için basit bir çözüm söz konusu. Çok daha iyi bir çözüm olabileceğinden eminim. Bazı hata ürtebilecek durumlar kontrol edilmeye çalışıldı. (Örneğin n değerinin koşula uygun elemanların toplam sayısının yarısından yüksek olmaması vb.)

Kısacası uygulanan çözüm yolu için değerli yorumlarınızı eksik etmeyiniz ifinim. Bir başka ipucunda görüşünceye dek hepinize mutlu günler dilerim.