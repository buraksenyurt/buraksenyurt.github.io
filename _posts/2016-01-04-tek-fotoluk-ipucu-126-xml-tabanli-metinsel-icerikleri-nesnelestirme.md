---
layout: post
title: "Tek Fotoluk İpucu 126 - XML Tabanlı Metinsel İçerikleri Nesneleştirme"
date: 2016-01-04 07:00:00
tags:
  - xml
  - entity
  - domain-driven-design
  - extension-methods
  - csharp
categories:
  - Foto İpucu
---
Malumunuz nesne yönelimli (Object Oriented) dünyanın en önemli unsurlarından birisi de varlıklar (Entity). Uygulamaların çalıştığı alanlarda (Domains) bu varlıklar dolaşmakta. Birer sınıf olarak tasarlanan bu varklıklar çalışma zamanlarında örneklenmekte ve belirli içerikleri taşımakta. Varlığı niteleyen verinin kaynağı çeşitli enstrümanlar olabiliyor. Veritabanı üzerindeki bir tablo, fiziki bir dosya, bir servis uç noktası, başka bir donanım, bir ara motorunun ürettiği çıktı vb

Geçtiğimiz günlerde yine şirkette çalışırken şöyle bir vaka ile karşılaştık; Aşağıdakine benzer XML içeriklerinin metinsel formatta geldiği bir servis uç noktası söz konusuydu ve bu içeriklerin uygulama alanı içerisinde nesneleştirilerek dolaştırılması gerekiyordu...

```xml
<MUSTERI_BILGISI>
   <UNVAN>Burak Selim Şenyurt</UNVAN>
   <MUSTERI_NO>1111111</MUSTERI_NO>
   <SOSYAL_GUVENLIK_NO>222222222</SOSYAL_GUVENLIK_NO>
</MUSTERI_BILGISI>
```

İşin ilginç yanı uç noktadan farklı şema yapılarında daha pek çok XML içeriğinin gelecek olmasıydı. Belki string tipine bir genişletme metodu yazıp işi kolaylaştırabiliriz diye düşündük. Ayrıca XML içerisindeki elementlerin isimleri, şirket içerisindeki standartlara pek de uymuyordu. Bunu da düzeltmeliydik. Bir başka deyişle gelen XML içerisindeki element adlarının aslında tip tarafında hangi isimlere karşılık geldiğini söyleyebilmeliydik. Sonuçta aşağıdaki fotoğrafki gibi bir kod parçasını ele almaya karar verdik.

![tek fotoluk ipucu 126 xml tabanli metinsel icerikleri nesnelestirme 01](/assets/images/2016/tek-fotoluk-ipucu-126-xml-tabanli-metinsel-icerikleri-nesnelestirme-01.gif)

Kod parçasında dikkat edilmesi gereken bir kaç nokta var. Öncelikle XML ters serileştirme (Deserialize) yaptığımızı belirtelim. Bunun için XmlSerializer tipinden yararlanıyoruz. XML içeriğinden gelen element adlarının Customer sınıfında hangi isimlerle kullanılacağını ise XmlType ve XmlElement nitelikleri (attribute) ile belirtmekteyiz (Xml ile başlayan başka nitelikler de var. Üşenmeyin araştırın) Bu sayede MUSTERI_BILGISI elementinin Customer tipine karşılık geldiğini, UNVAN elementinin Title özelliği ile ifade edileceğini vb belirtmiş oluyoruz.

Mutlaka yazılımcılık hayatınızın bir döneminde serileştirme (XML, SOAP, Binary) işleri ile uğraşmışsınızdır ve büyük ihtimalle hep FileStream kullanmışsınızdır. Ancak örnek senaryoda XML içerikleri string olarak gelmekte. Yani fiziki bir dosyaya kaydedip kullanmak çok mantıklı değil (Kodun bir sunucuda çalıştığını düşünecek olursak disk üzerinde IO işlemlerine izin verilmiyor olabilir) Bu nedenle pratiklik açısından MemoryStream'den yararlanıyoruz. XmlExtensions sınıfı içerisinde yer alan Deserialize fonksiyonunun generic tasarlandığına ve string tipine uygulanabilen bir genişletme metodu (Extension Method) olduğuna dikkat edelim.

İpucundaki kodda sorun oluşturabilecek pek çok nokta var. Özellikle dönüştürülemeyen XML içeriklerinde kodun istisna (InvalidOperationException alınma ihtimali yüksek) vererek sonlanmasını engellemek gerekiyor. Hatta bir şema (Schema) kontrolü bile yapılabilir. Diğer yandan MemoryStream kullanımının yoğun XML-Object dönüşümlerinde performans sorununa neden olup olmayacağına bir bakmak gerekiyor. Ah unutmadan...Generic T tipi için bazı kısıtlamalar da konulabilir. Sadece belli domain tipleri için ilgili genişletme metodunun çalıştırılması garanti altına alınmaya çalışılabilir (Nasıl yapılabilir bir düşünün)

Böylece geldik bir ipucu'nun daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.