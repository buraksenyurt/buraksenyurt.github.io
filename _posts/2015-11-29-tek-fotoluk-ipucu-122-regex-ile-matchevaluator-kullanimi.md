---
layout: post
title: "Tek Fotoluk İpucu 122 - Regex ile MatchEvaluator Kullanımı"
date: 2015-11-29 17:00:00
categories:
  - Programlama Dilleri
tags:
  - regex
  - MatchEvaluator
  - anonymous-methods
  - csharp
---
Geçtiğimiz günlerde üzerinde çalıştığımız bir projede, sıkıştırılmış metinsel içeriklerin açılması ile ilgili bir ihtiyaç doğdu. Cümle biraz karışık gelmiş olabilir. İfinim müsadenizle senaryoyu anlatayım öncelikle;

Vaktiyle zamanında üyelerine çeşitli finansal verilerden harmanlanmış metinsel içerik sağlayan bir kurum varmış. Bu kurum geliştirme döneminde bakmış ki verinin boyutu epeyce büyük. Ne yapalım ne edelim derken, üretilen metinsel içerikte çok sık tekrar eden bazı karakterler olduğunu fark etmişler. "Nasıl yapsak da bu çok sayıda tekrar eden karakteri metin içerisinden kırpsak ama bütünün anlamını bozmasak" demişler. Bunu üzerine tekrar eden kısımların yerine geçecek ve orada bunlardan kaç tane olduğunu ifade edecek basit söz dizimleri kullanmaya karar vermişler. Demişler ki, örneğin @9@ geçen bir aslında 9 tane 0 karakterini ifade etsin.

Tabi kurum bunu yapmış yapmasına ama, bu içeriği alıp kullanmak isteyenlerin ilgili veriyi bu kurallar dahilinde açması gerekmiş. İşte tam da böyle bir zamanda gelen bu ihtiyaç üzerine ne yapabiliriz diye düşününce hemen Regex sınıfından ve Replace metodundan yararlanalım dedik. Nasıl mı? Aynen aşağıdaki fotoğrafta olduğu gibi.

![tek fotoluk ipucu 122 regex ile matchevaluator kullanimi 01](/assets/images/2015/tek-fotoluk-ipucu-122-regex-ile-matchevaluator-kullanimi-01.gif)

Çıktıya dikkat edilecek olursa orjinal metinde @ sembolleri içeren kısımların arada belirtilen sayı kadar sıfırla değiştirildiği görülür. Üst metin kısa olsa da, bir gerçek hayat projesinde büyük boyutlarda dosya içeriklerinin olacağı gözden kaçırılmamalıdır.

Burada dikkat edilmesi gereken en önemli husus, Regex örneği oluşturulurken kullanılan ifadeden ziyade Replace metodunun ikinci parametresinde kullanılan Anonymous Method'dur. Aslında ikinci parametre MatchEvalutor temsilcisi (delegate) tipinden bir nesne örneğidir (Ve siz biliyorsunuz ki temsilci gördüğünüz yerlerde isimsiz metod kullanabilirsiniz) Yani MatchEvalutor temsilcisinin işaret ettiği imzaya (Match tipinden örnek alıp string döndüren) sahip olan metodlar/isimsiz bloklar Replace fonksiyonu tarafından kullanılabilirler. Replace metodu, belirtilen ifadeye eş düşen her değer için bu temsilcinin işaret ettiği metodu (veya bu örnekte olduğu gibi isimsiz kod bloğunu) çalıştıracaktır.

Pek tabi içerik boyutunun yükseldiği durumlarda bu teknik, içeriğin açılması işini yavaşlatabilir mi bakmak ve belki de alternatif yolları araştırmak lazım. Yine uyguladığımız tekniğin pratik bir yol sunduğunu ifade edebiliriz. (Kodu Refactor etmek sizde) Böylece geldik bir tek fotoluk ipucunun daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.