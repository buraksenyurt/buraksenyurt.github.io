---
layout: post
title: "NoSQL Maceraları - Couchbase İle Hello World"
date: 2015-11-07 20:00:00
tags:
  - nosql
  - nancy-framework
  - IoT
  - Internet-of-Things
  - Couchbase
  - json
  - captain-slow
  - n1ql
categories:
  - Veritabanı
---
Uzun süredir NoSQL ürünleri ile ilgilenmediğimi fark ettim ve bu haftanın araştırma konusu olarak kendime bir NoSQL sistemi seçmeye karar verdim. Aslında aklımda bir alan vardı. Özellikle Nancy Framework'ü incelediğim sırada karşıma çıkan IoT (Internet of Things) ve NoSQL ilişkisi dikkat çekiciydi. Burada geçerli olan ve kullanılan veritabanı sistemlerinden bağzılarına baktım.

![nosql maceralari couchbase ile hello world 01](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-01.gif)

En popülerleri arasında Couchbase yer alıyor. Özellike Mobile ve IoT ortamları için geliştirilen Native sürümü, verilerin Couchbase sunucusu ile senkronizasyonunun sağlanması noktasında önem arz ediyor. Pek tabi çok daha fazla özelliği olan bir ürün.

Bu yazımızda diğer [NoSQL](https://www.buraksenyurt.com/category/NoSQL) makalelerimizde olduğu gibi.Net dünyasından bir Hello World demeye çalışacağız. Dilerseniz ilk olarak Couchbase'in genel karakteristik özelliklerine bir bakalım.

- Her şeyden önce doküman odaklı bir veritabanı sistemi olduğunu ifade edebiliriz. Dokümanlar JSON (JavaScriptObjectNotation) formatında tutulmakta ve istenirse key-value yapısına da izin vermektedir.
- CAP (Consistency,Avaiability,Partition Tolerance) ilkesinin CA kısmını karşılamaktadır. Bildiğiniz üzere dağıtık sistemlerin CAP teoreminde belirtilen üç ilkeyi aynı anda sağlaması mümkün değildir. [Detaylar için buraya bakabilirsiniz.](https://en.wikipedia.org/wiki/CAP_theorem) Kısacası Couchbase, Consistency ve Availability ilkerini karşılayabilmektedir.
- Özellikle büyük ölçekli, eş zamanlı işlem sayılarının yüksek olduğu dağıtık sistemlerde yüksek arama performansı sunan bir veritabanı sistemidir.
- N1QL (nikel Query Language) adı verilen ve SQL söz dizimine uygun bir sorgulama dili içermektedir. Ayrıca.Net tarafında LINQ provider desteği de söz konusudur.
- Düşük gecikme zamanı ve yüksek kalıcı verimliliği sunan bir üründür.
- Client Library desteği oldukça geniştir. Java,.Net, PHP, Ruby (Olley be!), Python, C, Node.js.
- Esnek veri modeli sunar ama dikkat çekici yanı şema yapılarının dinamik olmasıdır. Yani çalışma zamanında dinamik olarak nesne ve özellikler eklenebilir ve şema yapısının değiştirilmesi sağlanabilir. Burada dikkat edilmesi gereken husus eklenecek nesnelerin tip yapısının önceden belirli olmaması ama çalışma zamanında karşılanabilmesidir..Net tarafında dynamic anahtar kelimesi bu ihtiyacı gerçekleştirmekte önemli rol oynar.
- Replication ve Sharding built-in desteklenen özellikleridir. Doğal olarak ucuz makineler kullanılarak kolayca ve verimli bir şekilde ölçeklemeye izin verir. Veri otomatik olarak Cluster üzerinde konuşlandırılmış Node'lara dağıtılabilinir. Böylece veritabanı yatay olarak genişleyebilir ve RAM, CPU gibi donanımsal çözümler verimli bir şekilde kullanılabilir. Üstelik bunlar gerçekleşirken yönetim maliyetleri de oldukça düşüktür. Bu başarıda işlemlerin asenkron olarak yapılmasının ve I/O operasyonlarının bloklanmamasının payı büyüktür.
- Ürün C/C++ ve Earlang (Cluster yapısı için) kullanılarak geliştirilmiştir. Peer to Peer ve Full Consistency tipinden Replication desteği vardır. Replication otomatik olarak gerçekleşir ve bu yüzden yönetimi kolaydır.
- CISCO, AOL, LinkedIn, Zynga gibi önemli kullanıcıları vardır.
- Elastik arama desteği bulunur.
- Aslında bu ürün Memcahced projesinin bir kaç ekip üyesi tarafından geliştirilmiştir. Bu nedenle Membased olarak da adlandırılır. Kısacası Memcached'in genişletilmiş bir sürümü olduğunu düşünebiliriz.
- ve tabii son olarak açık kaynak bir ürün olduğunu ifade edebiliriz. ([Tarihçe ve diğer detaylar için şu adrese bakabilirsiniz](https://tr.wikipedia.org/wiki/Couchbase_Server))

Gelelim örnek uygulamamıza. Her şeyden önce geliştireceğimiz.Net tabanlı uygulama bir Couchbase Server istemcisi olacak. Bu nedenle bir Couchbase sunucusu tedarik etmeliyiz. Onsuz olmaz. İlgili sürümü [şu adresten](http://www.couchbase.com/nosql-databases/downloads?gtmRefId=FixedCTA-Download) indirip kurabilirsiniz. Ben Community versiyonunu kullanıyorum. Eğer kurulum başarılı ise aşağıdaki gibi bir Setup ekranı ile karşılaşmamız gerekiyor.

![nosql maceralari couchbase ile hello world 02](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-02.gif)

Setup kısmında pek çok ayarlama basit bir şekilde gerçekleştirilebilir. Örneğin varsayılan olarak 127.0.0.1 adresinden yayın yapan sunucu adresi Hostname bilgisinden değiştirilebilir. Yeni bir Cluster oluşturulabilir veya var olan bir Cluster'a katılabilinir (Join). Hangi servislerin açılacağı belirlenebilir. Fiziki disk saklama yerleri, çekirdek kullanımları, RAM değerleri değiştirilebilir. Adımlarda ilerlendikçe kurulumun ne kadar basit olduğuna şahit olunur. Veri içeren örnek kümeler bile vardır (beer-sample, gamesim-sample, trave-sample). Yönetimin bu kadar kolay olması biraz önce bahsettiğimiz gibi verinin sisteme yeni sunucular eklenerek basitçe dağıtılmasında önemlidir. Her şey yolunda giderse aşağıdaki gibi bir Admin ekranı ile karşılaşırız.

![nosql maceralari couchbase ile hello world 03](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-03.gif)

Kurulum tamamlandıktan sonra basit bir Console Application açarak yolumuza devam edebiliriz. Bir diğer ihtiyacımız da tahmin edeceğiniz üzere.Net Client kütüphanesidir. Artık.Net geliştiricilerinin hayatını inanılmaz derecede kolayaştıran NuGet paket yöneticisini kullanarak aşağıdaki paketi yüklememiz yeterlidir.

![nosql maceralari couchbase ile hello world 04](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-04.gif)

Pek tabi paketin bağımlı olduğu diğer paketlerde beraberinde yüklenecektir.(Örneğin ürün JSON tabanlı bir doküman sistemi olduğu için de NewtonSoft.Json)

Artık ilk kodlarımızı yazmaya başlayabiliriz.

```csharp
using Couchbase;
using System;
using System.Collections.Generic;

namespace HelloCouchbase
{
  class Program
  {
    static Cluster smallCluster;
    static void Main(string[] args)
    {
      smallCluster = new Cluster();
      using(var smallBucket=smallCluster.OpenBucket())
      {
        var newDoc = new Document<List<Product>>
        {
          Id = "Doc1001",
          Content = new List<Product>
          {
            new Product{ ID=1, Title="Fi", Price=20},
            new Product{ID=2, Title="Çi", Price=15},
            new Product{ID=3, Title="Pi", Price=30},
            new Product{ID=4, Title="Ruby on Rails", Price=40},
            new Product{ID=5, Title="C# Advanced",Price=45}
          }
        };

        var result = smallBucket.Upsert(newDoc);
        if(result.Success)
        {
          Console.WriteLine("{0} ile eklendi",newDoc.Id);
          var doc=smallBucket.GetDocument<List<Product>>("Doc1001");
          var document=doc.Document;
          Console.WriteLine(document.Id);
          foreach (var product in document.Content)
          {
            Console.WriteLine("{0}:{1}[{2}]"
              ,product.ID
              ,product.Title
              ,product.Price.ToString("C2")
              );
          }
        }
      }
    }
  }

  public class Product
  {
    public int ID { get; set; }
    public string Title { get; set; }
    public decimal Price { get; set; }
  }
}
```

Uygulamada neler yaptığımıza kısaca bir bakalım.

Öncelikli olarak bir Cluster eklenmesi gerekiyor. Bu nesne örneği sayesinde Bucket'lara (Kova diyelim) erişmek ve onları üretmek gibi yönetsel işlemler mümkün hale gelmekte. Üretilen Cluster nesne örneği üzerinden OpenBucket metodunu kullanarak varsayılan Bucket'ı kullanım için açmaktayız. Elbette kod üzerinden veya web tabanlı yönetim panaelinden yeni veri kovaları (Data Bucket) açılabilir. Biz daha çok çok acemi olduğumuzdan varsayılan kovayı kullanmayı tercih ediyoruz.

![nosql maceralari couchbase ile hello world 05](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-05.gif)

Kovayı açtıktan sonra ise bir doküman oluşturmaktayız. Document sınıfı generic tiple çalışmakta. Bu yüzden parametre olarak Content özelliğinde yer almasını istediğimiz tipi vermeliyiz. Örnekte Product tipinden nesne örneklerini taşıyacak olan bir List kullanmaktayız. Document tipinin önemli özelliklerinden birisi de tabii ki Id değeri. Üretilen dokümanı açılan kovaya eklemek için Upsert metodundan yararlanıyoruz. Aslında Insert metodundan da yararlanabiliriz ancak var olan doküman üzerine yazmak istersek çalışma zamanı hatası alırız. O yüzden UPdateInSERT birleşimini kullanıyoruz. Buna göre doküman zaten varsa içeriğin güncellenmesi sağlanacak. Bucket nesneleri Dispose edilebilir nesneler. Bu yüzden using bloğu ile kullanarak kapatılmalarını ayrıca düşünmek zorunda değiliz. Eğer içerik başarılı bir şekilde eklendiyse (result.Success kısmı) Doc1001 Id'li doküman içeriğini Cluster üzerinden çekip elemanlarını ekrana yazdırmaya çalışıyoruz. Burada GetDocument metodunun generic tipine dikkat edelim. List bildirimi ile az önce eklenen ürün listesine ulaşmaktayız. Kodun çalışma zamanı çıktısı aşağıdaki gibidir.

![nosql maceralari couchbase ile hello world 06](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-06.gif)

İşin güzel yanı eklediğimiz dokümanı ve JSON formatındaki içeriğini web yönetim paneli üzerinden de görebiliriz. Eğer varsayılan kurulum işlemi gerçekleştiyse [şu adresten](http://localhost:8091/index.html#sec=documents&viewsBucket=default&documentsPageNumber=0&docId=Doc1001) ilgili içeriği görebilirsiniz.

![nosql maceralari couchbase ile hello world 07](/assets/images/2015/nosql-maceralari-couchbase-ile-hello-world-07.gif)

Dikkat edileceği üzere Product listesinin içeriği Doc1001 içerisine JSON formatında yazılmıştır. Admin ekranında biraz daha dolaşmanızı ve detayları incelemenizi öneririm. Ayrıca Couchbase oldukça geniş bir içeriğe sahip. Biz sadece basit anlamda Merhaba dedik. Daha fazlası ve detaylı kullanımı için [bu adresteki](http://docs.couchbase.com/developer/dotnet-2.0/getting-started.html) dokümanı incelemenizi ve örnekleri yapmaya çalışmanızı öneririm. Söz gelimi dynamic kullanımına bakabilir, yeni Bucket'ları isimle oluşturmayı deneyebilir, N1QL ile veri üzerinde sorgulama yapmaya çalışabilir, biraz daha ileri giderek Elastichsearch yeteneklerini işin içerisine katmayı deneyebilirsiniz. Bir diğer tavsiyem de Mobile sürümü indirip akıllı telefonlarda Couchebase'i kullanmaya çalışmanız olacaktır. Bu antrenmanlar sizlere oldukça kıymetli deneyimler kazandıracaktır. Tembellik etmeyin uğraşın.

Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse.
