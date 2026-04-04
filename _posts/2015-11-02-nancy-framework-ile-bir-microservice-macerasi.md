---
layout: post
title: "Nancy Framework ile Bir MicroService Macerası"
date: 2015-11-02 10:00:00
categories:
  - Servis Tabanlı Geliştirme
tags:
  - nancy-framework
  - microservice
  - IoT
  - mvc
  - asp.net
  - rest-api
  - NancyHost
  - http
  - get
  - post
  - put
  - delete
---
Son yılların popüler trendleri arasında MicroService ve IoT (Internet of Things) nin yer aldığını ifade edebiliriz. Akıllı cihazlar ile micro servislerin yan yana gelmesi size biraz şaşırtıcı gelmiş olabilir. Aslında birbirleri ile oldukça ilişkililer. Sonuç olarak IoT dünyasına dahil olan cihazlar birbirleri ile haberleşmek için hafif donatılmış servislerden yararlanabilirler.

![nancy framework ile bir microservice macerasi 01](/assets/images/2015/nancy-framework-ile-bir-microservice-macerasi-01.png)

Bu tip servislerin kolayca geliştirilebilmesi için pek çok Framework söz konusu. Nancy bu çatılardan sadece bir tanesi. Nancy Framework ile REST tabanlı servislerin kolay bir şekilde geliştirilmesi mümkün. Kendisi aynı zamanda bir Service Framework olarak da düşünülebilir. Bu yüzden kendi başına host edilebilen bir servis motoru da içermektedir. Hatta WCF, OWIN ve Asp.Net MVC üzerinde de host edilbilen bir yapıya sahiptir.

Nancy'yi yandaki resimde görülen etkileyici logosu dışınca çekici kılan bir çok özelliği var. Örneğin IoC (Inversion of Control) ilkesine göre geliştirilmiş modüler bir yapıya sahip. Bu yüzden plug-in stilinde servis içeriğinin genişletilmesi son derece kolay. IoC sayesinde çalışma zamanına modüller zahmetsizce bağlanabilmekte. Karmaşık Route tanımlamalarının basitçe yapılmasına izin veriyor. JSON (JavaScript Object Notation) formatıyla oldukça dostane bir ilişkisi var (Elbette XML desteği de bulunuyor ama dünyadaki trend JSON yönünde).

Ancak tüm bunlar bir yana belki de en önemli özelliği, üretilen exe ve dll'lerin Mono destekli Linux ortamlarına atıldıktan sonra da sorunsuz çalışıyor olması (Bunu test etme fırsatım olmadı maalesef) Dolayısıyla Windows sistemi üzerinde yazılan REST servislerini, Linux platformuna taşıyarak çalıştırmak da son derece kolay. (Araştırma yaptığım kaynaklara göre IoT denince ilk akla gelen Arduino ve Raspberry PI sistemleri ile de sorunsuz bir şekilde çalıştığı ifade ediliyor)

Şimdi bu özellikleri ile siz değerli okurlarımda heyecan uyandıran framework ile ilişkili basit bir örnek yapalım.

> Nancy Framework ile ilgili olarak [bu adreste](https://nancyfx.org/) daha fazla bilgi alabilirsiniz.

## Hello World

Nancy'i kullanarak geliştireceğimiz örnek basit bir Console uygulaması olacak (Her zamanki gibi) Hem self-hosted application server görevi üstlenecek hem de tarayıcı üzerinden belli bir adrese gelen isteklere cevap verecek. Yani tarayıcı üzerinden yollayacağımız Get ve Post gibi HTTP taleplerine cevap verecek bir servis geliştireceğiz. Tabii ilk yapılması gereken iş projeye Nancy ve Nancy.Hosting.Self paketlerinin NuGet üzerinden yüklemek olmalı. İlgili paketler yüklendikten sonra uygulama kodlarımızı aşağıdaki gibi yazmaya başlayabiliriz (Keyif alacağınızı garanti ediyorum)

```csharp
using Nancy;
using Nancy.Hosting.Self;
using Nancy.ModelBinding; // this.Bind<T> kullanımı için gereklidir.
using System;
using System.Linq;
using System.Collections.Generic;

namespace HelloNancyFX
{
  public class Program
  {
    static void Main(string[] args)
    {
      Uri hostUrl = new Uri("http://127.0.0.1:5555");
      using (NancyHost server = new NancyHost(hostUrl))
      {
        server.Start();
        Console.WriteLine("Nancy {0} adresinden dinlemede!", hostUrl.ToString());
        Console.WriteLine("Kapatmak için bir tuşa basın...");
        Console.ReadLine();
        server.Stop();
      }
    }
  }

  public class Routes
    : NancyModule
  {
    static List<Product> products;
    private static void FillProducts()
    {
      products = new List<Product>
      {
        new Product { ProductID=1001, Title="HP Compaq LE2002x Monitor", ListPrice=150 },
        new Product { ProductID=2005, Title="Dell Latitude E7240", ListPrice=1500},
        new Product { ProductID=1041, Title="Dell Latitude F4590", ListPrice=3580},
        new Product { ProductID=3020, Title="Vestel Venus 550", ListPrice=650}
      };
    }

    static Routes()
    {
      FillProducts();
    }
    public Routes()
    {
      Get["/"] = p =>
      {
        return "<b><h1>Nancy's</p>World</h1></b>";
      };
      Get["products"] = AllProducts;
      Get["product/{ID}"] = FindByID;
      Post["add"] = AddProduct;
    }

    dynamic FindByID(dynamic parameters)
    {
      var product = products.Where(p => p.ProductID == parameters.ID).FirstOrDefault();
      return Response.AsXml(product);
    }
    dynamic AllProducts(dynamic parameters)
    {
      return Response.AsJson(products);
    }
    dynamic AddProduct(dynamic parameters)
    {
      Product newProduct = this.Bind<Product>();
      products.Add(newProduct);
      return string.Format("{0}[{1} - {2}] eklendi"
        , newProduct.ProductID
        , newProduct.Title
        , newProduct.ListPrice);
    }
  }

  public class Product
  {
    public int ProductID { get; set; }
    public string Title { get; set; }
    public decimal ListPrice { get; set; }
  }
}
```

## Kodda Neler Oluyor?

Dilerseniz uygulamada neler yaptığımıza kısaca bakalım ve ardından testlerimize geçelim.

Main metodu içerisinde http://127.0.0.1:5555 adresi üzerinden istekleri kabul edecek şekilde bir sunucu bağlantısı oluşturuyoruz. Bunun için NancyHost sınıfına ait bir nesne örneğinden yararlanılıyor. Sunucuyu açmak ve kapatmak son derece basit. Start ve Stop metodlarını bu iki iş için kullanmaktayız. Peki sunucuya gelecek olan HTTP isteklerini nasıl karşılayacağız? İşin gizemli tarafı da burada başlıyor.

Çalışmakta olan Nancy sunucusu o anki uygulama örneğinde yer alan NancyModule türevlerini otomatik olarak değerlendirebilmekte (Sizce nasıl yapıyor olabilir?). Bu yüzden örnek HTTP taleplerine ait route tanımlamalarını içeren bir modül sınıfı söz konusu. NancyModule türevli olan Routes sınıfı içerisinde sembolik olarak bir ürün listesi bulunuyor. Product sınıfı tipinden olan bu ürün listesini static yapıcı metod (static constructor) içerisinde doldurmaktayız. Elbette gerçek hayat örneklerinde bu veri kümeleri farklı kaynaklardan da besleniyor olabilir. (Örneğin fiziki bir dosyadan, ilişkisel veritabanı sisteminden, NoSQL'den, hatta Cloud üzerinde duran bir Repository'den...)

> Bu arada Module sınıflarının public tanımlanması gerektiğini belirtmek isterim. Aksi takdirde ilgili tip çalışma zamanı ortamına bağlanamıyor. Bu yüzden HTTP talepleri sonuçsuz kalıp Nancy' nin o meşhur kocaman patlak gözlü, yeşil renkli ve göbekli kahramı ile karşılaşılıyor.

Gelelim Routes sınıfının varsayılan yapıcı metoduna (Default Constructor). Bu metod içerisinde iki farklı HTTP talebi ele alınmakta (Get ve Post). Kabaca aşağıdaki gibi bir durum söz konusu diyebiliriz.

| HTTP Talebi | Açıklama |
| --- | --- |
| Get["/"] | http://localhost:1234/ adresi talep edildiğinde devreye giren metodu işaret eder. Bunu servisin varsayılan giriş sayfası olarak düşünebiliriz. Tamamen HTML içeriği söz konusudur ve hatta bir View ile ilişkilendirilebilir. |
| Get["products"] | http://localhost:1234/products adresi talep edildiğinde devreye girecek olan AllProducts metodunu işaret eder. Tüm ürün listesini elde ederken kullanılabilecek harika bir url'dir. |
| Get["product/{ID}"] | http://localhost:1234/product/1001 gibi bir talebe karşılık işletilecek olan FindByID metodunu işaret eder. Tahmin edileceği üzere {ID} parçası FindByID metodunda gelen dynamic değişken üzerinden elde edilir ve LINQ (Language INtegrated Query) sorgusunda kullanılır. |
| Post["add] | http://localhost:1234/add gibi bir adrese karşılık gelecek metodu işaret eder. Tabi burada Post tipinden bir HTTP talebi söz konusu olduğundan yeni eklenecek ürünün değerleri servis tarafına bir şekilde gönderilmelidir. Bunu test ederken Fiddler gibi bir Web Debugger aracından yararlanabiliriz. Ya da Nancy'nin gelişmiş Test alt yapısındaki nesneleri kullanabiliriz. |

Son üç bağlama operasyonunda birer metodun işaret edildiğinde dikkat edelim. Bu biz zorunluluk değil. Nitekim Get["/"] satırında doğrudan isimsiz metod (Anonymous Metod) kullanıyoruz. Diğer metodların en belirgin özelliği ise dönüş ve parametre tipi olarak dynamic anahtar kelimesini kullanıyor olmaları.

AllProducts ve FindByID metodları dışarıya JSON ve XML formatında çıktı üretiyorlar. Bu üretimi gerçekleştirmek aslında oldukça basit. IResponseFormatter arayüzü türevli nesne örneğini işaret eden Response özelliğinin AsJson ve AsXml metodları ilgili içeriği üretmek için kullanılmakta. Hepsi bu kadar...

## Testler

Şimdi dilerseniz testlerimizi yapalım. İlk oarak HTTP Get metodlu taleplerin çıktılarına bir bakalım.

`http://127.0.0.1:5555/` için

![nancy framework ile bir microservice macerasi 02](/assets/images/2015/nancy-framework-ile-bir-microservice-macerasi-02.gif)

Direkt olarak kök adrese gittiğimizde bu şekilde bir içerikle karşılaşıyoruz.

`http://127.0.0.1:5555/products` için,

![nancy framework ile bir microservice macerasi 03](/assets/images/2015/nancy-framework-ile-bir-microservice-macerasi-03.gif)

Görüldüğü gibi ürün listesini JSON formatında elde etmiş bulunmaktayız.

`http://127.0.0.1:5555/product/1001` için,

![nancy framework ile bir microservice macerasi 04](/assets/images/2015/nancy-framework-ile-bir-microservice-macerasi-04.gif)

Bu sefer 1041 ProductID değerli ürünün içeriğini XML formatında elde ediyoruz.

Add metodunun testi içinse Fiddler'dan destek alıyoruz.([Fidd](http://www.telerik.com/fiddler)l[er'ı buradan indirebi](http://www.telerik.com/fiddler)l[irsiniz](http://www.telerik.com/fiddler)) Aynen aşağıdaki ekran çıktısında görüldüğü gibi.

![nancy framework ile bir microservice macerasi 05](/assets/images/2015/nancy-framework-ile-bir-microservice-macerasi-05.gif)

Dikkat edileceği üzere POST ile gönderilen yeni Product örneği, ürün listesine de başarılı bir şekilde eklenmiş ve `http://127.0.0.1:5555/products` talebi sonrası gelen JSON çıktısında yerini almıştır.

Tabii herhangi bir Route karşılığı olmayan talep gönderildiğinde biraz önce bahsettiğimiz sevimli arkadaşımız ile göz göze geliriz.

![nancy framework ile bir microservice macerasi 06](/assets/images/2015/nancy-framework-ile-bir-microservice-macerasi-06.gif)

Bu makalemizde Nancy Framework'ünü kullanarak REST tabanlı servislerin basitçe nasıl geliştirilebileceğini incelemeye çalıştık. Örnektekine benzer self-hosted uygulamaları ayrı sunucular üzerinde barındırarak birer MicroService haline getirmemiz mümkün. Belirli bir amaca hizmet edecek şekilde tasarlanmış, hafif yapılı servisler...

Bu arada sizin için bu Framework içerisine gizlenmiş ve keşfedilmeyi bekleyen bir çok konu da var.

- Örneğin nasıl oluyor da Main metodu içerisinde çalıştırdığımız sunucu, NancyModule içerisindeki Get, Post bildirimlerini otomatik olarak tanıyor, biliyor, işletiyor?
- Ya da nasıl oluyor da POST ile gönderdiğimiz içeriklerdeki değerler biz set etmediğimiz halde o anda oluşturulan bir Product nesne örneğinin özellikerine atanıyor?
- Peki ya neden dynamic anahtar kelimesine ihtiyaç duyuluyor?

> Bu sorulara cevap bulmaya çalışmanızı öneririm. Gerekirse [github üzerinde konuşandırılmış](https://github.com/NancyFx)açık kaynak kodara da bakabilirsiniz. Hatta bakınız.
Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse...
