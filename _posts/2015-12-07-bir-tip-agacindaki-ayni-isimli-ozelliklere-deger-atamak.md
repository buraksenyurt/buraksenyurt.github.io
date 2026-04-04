---
layout: post
title: "Bir Tip Ağacındaki Aynı İsimli Özelliklere Değer Atamak"
date: 2015-12-07 20:00:00
categories:
  - Programlama Dilleri
tags:
  - csharp
  - generic
  - reflection
  - IList
  - type-safety
  - recursive-method
---
Çalışmakta olduğumuz projelerde zaman zaman bizi zorlayan vakalar ile karşılaşıyoruz. Bu gibi durumlarda Google abimiz en büyük yardımcımız olabiliyor. Hatta pek çoğumuz sorunların çözümünde Stackoverflow gibi kaynaklardan yararlanıyor ya da daha deneyimli birisinden yardım istiyor. Ne var ki bazı vakaları kendimiz çözmeye çalışsak çok daha yararlı olabilir.

![2Q==](/assets/images/2015/bir-tip-agacindaki-ayni-isimli-ozelliklere-deger-atamak-01.jpg)

Sevdiğim çalışma arkadaşlarımdan birisi (ki kendisi ile aynı projeler üzerinde kodlama yapıyoruz) bu konuda gerçekten örnek aldığım insanlardan. Öncelikli olarak problemi kendisi çözmek için uğraşıyor. Sahip olduğu bilgi ile bunu yaparken Google'dan veya Stackoverflow gibi kaynaklardan yardım almakta ısrarcı olmuyor. Muhakkak kendi başına çözebilmek için çaba sarf ediyor. Pek tabi söz konusu iş olunca zaman sınırı da kısıtlayıcı bir rol üstleniyor. Problem ne zamanki zaman kaybına neden olacak noktaya geliyor, işte o zaman arkadaşım arama yöntemlerini tercih ediyor. Bence bu iş yapıp şekli kişisel gelişim açısından son derece kıymetli.

Efendim sözü çok fazla uzatmadan ben makalenin konusuna geleyim. Vaktizamanında üzerinde çalıştığımız bir projede şöyle bir ihtiyaç doğdu; N seviyede derinliğe inen bir nesne örneğinin tamamında geçen aynı isimli özelliklerin aynı değere eşitlenmesi gerekti. Senaryoyu gözümüzde canlandırabilmek için aşağıdaki sınıf çizelgesine bir bakalım dilerseniz.

![BBTmc6UpjW16U1xmlOd7pSnPfXpT4EaVKEGNRCuMKFLkUoTOS6VqU11KlOTGtWLSOOpVbXqVbGqPIBKlatd9epXwRpWsY6VrGU1NetZ0ZpWta6VrW1161vhGle5zpWudbXrXfGaV73ula999etfARtYwQ6WsIU17GERm1jFKikgADs=](/assets/images/2015/bir-tip-agacindaki-ayni-isimli-ozelliklere-deger-atamak-02.gif)

Sorunu çözmek için öncelikle tip yapısını bir incelemeye çalışalım. Basket tipi içerisinde üç özellik bulunuyor. ID hedef özelliklerimizden birisi. Ancak Customer isimli Owner tipinden olan özelliğin içerisinde de ID var. Hatta List tipinden olan Products özelliğine yakından bakacak olursak, her bir Product örneği içinde de ID niteliğinin söz konusu olduğunu ifade edebiliriz. Üstelik, Owner tipi içerisinde yer alan Score özelliğine yakından bakacak olursak benzer bir durumun olduğunu görebiliriz. Score sınıfının da bir ID özelliği bulunmaktadır.

Tip ağacındaki derinlik daha da artabilir. İç içe geçen tiplerin sayısı çoğalabilir. Bu demek oluyor ki Basket sınfına ait nesne örneğini çalışma zamanında Recursive olarak gezmeli ve tespit ettiğimiz ID özelliklerine istediğimiz değeri atayabilmeliyiz. (Pek tabi yarın öbür gün ID özelliği dışında var olan başka bir özellik için de benzer atama ihtiyacı oluşabilir. O yüzden kodu biraz daha akıllı tasarlamalıyız)

Öyleyse gelelim kod parçasına. Olayı her zaman olduğu gibi basit bir Console projesi üzerinde ele alacağız. İşte kodlarımız.

```csharp
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;

namespace SetProperties
{
  class Program
  {
    static void Main(string[] args)
    {
      Basket bskt = new Basket
      {
        Customer=new Owner
        {
          NickName="Nickname",
          Score=new Score
          {
            Point=100
          }
        },
        Products=new List<Product>
        {
          new Product {
            Title ="Karnıbahar"
          },
          new Product {
            Title ="Lahana"
          }
        }
      };

      SetPropertyValue(bskt,"ID",Guid.NewGuid());
    }
    static void SetPropertyValue(object instance,string propName,object newValue)
    {      
      if (instance == null)
        return;
      Type insType = instance.GetType();
      PropertyInfo[] properties = insType.GetProperties();
      foreach (PropertyInfo pi in properties)
      { 
        object value = pi.GetValue(instance, null);
        var elements = value as IList;
        if (elements != null)
        {
          foreach (var element in elements)
          {
            SetPropertyValue(element,propName, newValue);
          }
        }
        else
        {
          if (pi.PropertyType.Assembly == insType.Assembly)
          {
            SetPropertyValue(value,propName, newValue);
          }
          else
          {
            if (pi.Name.ToLower() == propName.ToLower())
            {
              pi.SetValue(instance,newValue);
              // Aşağıdaki satır sonuçları görmek için eklenmiştir.
              Console.WriteLine("{0}.{1}:{2}", pi.DeclaringType.Name, pi.Name, pi.GetValue(instance));
            }
          }
        }        
      }
    }
  }
  class Basket
  {
    public Guid ID { get; set; }
    public List<Product> Products { get; set; }
    public Owner Customer { get; set; }
  }
  class Product
  {
    public Guid ID { get; set; }
    public string Title { get; set; }
  }
  class Owner
  {
    public Guid ID { get; set; }
    public string NickName { get; set; }
    public Score Score { get; set; }
  }
  class Score
  {
    public Guid ID { get; set; }
    public decimal Point { get; set; }
  }
}
```

ve çalışma zamanı çıktımız.

![a0BIu9KEVrdpEL9rRW230oyXt5DNP2tLNDQgAOw==](/assets/images/2015/bir-tip-agacindaki-ayni-isimli-ozelliklere-deger-atamak-03.gif)

Dikkat edileceği üzere Basket nesne örneğinin kendisi dahil olmak üzere ağaç yapısında denk gelen ne kadar ID özelliği varsa aynı Guid ile eşleştirilmiştir.

Olayın kahramanı tahmin edebileceğiniz gibi SetPropertyValue fonksiyonudur. Bu metod Recursive kullanılmaktadır. ID özelliği dışında başka bir özelliğin kullanılma ihtimali göz önüne alınarak, aranan özelliğin ve değerinin bu metoda parametre olarak aktarımı sağlanmıştır. Elbette bir tipin çalışma zamanı özelliklerini yakalamak için Reflection kabiliyetlerinden yararlanılması kaçınılmazdır. O anki tipi elde etmek için GetType, tipe ait özelliklere ulaşmak için GetProperties, o anki nesne örneği değerini almak için GetValue, özelliğe değer vermek içinse SetValue metodlarından yararlanılmıştır. Örnekte yer alan liste tipindeki özelliklerin tespiti içinse IList arayüzüne as operatörü yardımıyla atama gerçekleştirilmektedir. Eğer as sonrası elde edilen değişken null değilse List gibi bir tiple karşılaşılmış demektir.

Pek tabi kodun siz değerli okurlarımca gözden geçirilmesinde yarar var. Hatta daha da geliştirilmesi gerekiyor. Örneğin tip ağacı içerisindeki birden fazla özelliğin farklı değerler ile set edilmeye çalışılması da sağlanabilir. Tip güvenliği (Type Safety) açısından metodun generic hale getirilmesi ve bazı kıstaslar ışığında kullanılması düşünülebilir. Kodun biraz daha performanslı çalışması adına farklı teknikler de uygulanabilir. Fonkisyonellik sadece belirli özelliklere değer vermek için değil, bir nesne hiyerarşisinin komple varlığının çekilmesi ve belirli bir alana farklı formatlarda kaydedilmesi için de değiştirilebilir (Örneğin nesne ağacının çalışma zamanındaki varlığının belirli kriterlere uyan özelliklerinin Log olarak kayıt altına alınmasını için bir takım değişiklikler olabilir)

Görüldüğü üzere ne kadar alt seviyeye indiğini bilmediğimiz bir tip ağacında Reflection ve Recursive kavramlarını işin içerisine katarak istediğimiz sonucu elde etmeyi başardık. Kısa bir yazı oldu ama elimizin altında bulunsun. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
