---
layout: post
title: "TCP Bazlı Soket Haberleşmesinde Sertifika Kullanımı"
date: 2015-11-09 21:00:00
categories:
  - Programlama Dilleri
tags:
  - tcp
  - soap
  - microservice
  - rest-api
  - http
  - makecert
  - SampleSslSocketCertificate
  - x-509-certificate
  - extension-methods
  - sesecurity
  - cryptography
---
Günümüzde geliştirilen yazılım ürünleri çoğunlukla farklı uygulamalar ile de konuşmak durumunda. Sistemler sürekli birbirleri ile konuşan parçalar bütünü halinde genişlemeye devam ediyor. Akıllı cihazlar büyük ölçekli sistemlerin birer parçası olup çeşitli iş süreçlerinin işletilmesinde rol alıyor. Bu iletişimde servislerin de yeri var.

![tcp bazli soket haberlesmesinde sertifika kullanimi 01](/assets/images/2015/tcp-bazli-soket-haberlesmesinde-sertifika-kullanimi-01.gif)


Artık yeni nesil servisler daha popüler. REST tabanlı çalışan HTTP servisleri, SOAP protokolünü benimseyen servisler ve daha bir çoğu ön planda. MicroService mimarisi gibi yaklaşımlar reveçta. Ne varki daha alt seviye iletişimin kurulduğu miras sistemler de söz konusu. Öyleki bu sistemlerden bazıları TCP protokolü üzerinden socket haberleşmesi yaparak çalışmakta. Aslında TCP bazlı socket iletişimi gerek performans gerek güvenlik açısından düşünüldüğünde tercih edilen yöntemlerden birisi. Sadece bu tip uygulamaların geliştirilme ve bakım maliyetleri biraaz daha yüksek.

Bir süre önce kurumumuz tarafında geliştirilen projede, özel iştirak bir sisteme bağlanmak için bu tip TCP bazlı haberleşme çözümüne ihtiyaç duyduk. Tabi kurumlar arası bir haberleşme söz konusu olduğu için işin içerisine yazılım ve ağ seviyesinde güvenlik de girdi. Servis dünyasını göz önüne aldığımızda.Net Framework gibi çatıların güvenlik ayarları son derece kolay bir şekilde yapılıyor. Örneğin WCF servisleri, W3C tarafından kabul gören ne kadar protokol varsa (WS-* standartları) desteklediğini biliyoruz. Ancak TCP bazlı soket haberleşmesi akla gelince işler biraz daha zorlaşabiliyor. İşte bu yazımızda sertifikalandırılmış, TCP bazlı bir client-server haberleşmesinin temelde nasıl yapılabileceğini incelemeye çalışacağız.

## Sertifika Üretimi

Örneğimiz temel olarak dinleyici rolünü üstlenen bir sunucudan ve istemciden oluşacak. Ayrıca her iki uygulamanın da bağzı genel ihtiyaçları için bir sınıf kütüphanesi (Class Library) içerecek. Aradaki iletişimde sertifika kullanımı en önemli konu. Sistemde yüklü bir sertifika kullanılabilir. Ancak biz örneğimizde ilgili sertifikayı kendimiz üreteceğiz.

Bu işlem için Visual Studio 2013 Developer Command Prompt üzerinden Makecert aracını aşağıdaki ekran görüntüsünde olduğu gibi kullanmamız gerekiyor. (Sertifika üretimleri konusunda elbette kurumlar farklı stratejiler izleyebilirler. Eğer benim gibi kurumsal çapta işler geliştiren bir şirkette çalışıyorsanız mutlaka bu tip sertifika üretimleri/kullanımları ile ilgilenen sistem yöneticisi çalışma arkadaşlarınız vardır. Konu hakkında onlardan da destek alabilirsiniz)

Makecert -r -pe -n "CN=SampleSslSocketCertificate" -b 06/06/2015 -e 06/06/2016 -sk exchange -ss my

![tcp bazli soket haberlesmesinde sertifika kullanimi 02](/assets/images/2015/tcp-bazli-soket-haberlesmesinde-sertifika-kullanimi-02.gif)

Eğer gerçekleştirilen üretim başarılı olduysa SampleSslSocketCertificate'in başarılı bir şekilde Personel sertifikalarına eklenmiş olduğu görülebilir. Sertifika üretimi de gerçekleştirildikten sonra sırasıyla sunucu ve istemci tarafı ile ortak kütüphaneyi yazmaya başlayabiliriz.

## Ortak Kütüphane

SecureSocket.Common olarak isimlendireceğimiz ortak kütüphane, sertifikanın bulunması ve özellikle iki taraf arasında hareket edecek stream içeriklerinin okunması ve yazılması gibi operasyonları üstlenecek (Ancak örnek tamamlandıktan sonra kodu refactor ederek buraya farklı operasyonları da dahil edebilirsiniz. Örneğin sertifikanın doğrulanmasını ele alan geri bildirim metodu bu kütüphane içerisine dahil edilebilir) CertificateHelper ve SocketExtensions isimli sınıfların içeriklerini aşağıdaki gibi geliştirebiliriz.

CertificateHelper sınıfı;

```csharp
using System.Security.Cryptography.X509Certificates;

namespace SecureSocket.Common
{
  public class CertificateHelper
  {
    public X509Certificate GetCertificateByName(string Name)
    {
      X509Store certStore = new X509Store(StoreName.My,StoreLocation.CurrentUser);
      certStore.Open(OpenFlags.ReadOnly);
      X509Certificate2 cert = null;
      foreach (X509Certificate2 currentCert in certStore.Certificates)
      {
        if (currentCert.IssuerName.Name!= null && currentCert.IssuerName.Name.Equals(string.Format("CN={0}",Name)))
        {
          cert = currentCert;
          break;
        }
      }
      return cert;
    }
  }
}
```

Kodda yapılan şey aslında yüklediğimiz X509 türevli sertifikayı o anki kullanıcıya ait depoda aramak. X509Store tipi üretilirken ilk parametre ile My deposunu ikinci parametre ile de hangi kullanıcı için baktığımızı belirtiyoruz. Açılan Store'da sadece sertifikaları dolaşarak metoda parametre olarak gelen isimdekini bulmaya çalışıyoruz. Bu yüzden sertifika deposunu sadece okunabilir modda açmamız yeterli. Aranan sertifikayı isimden yakalamak için CN={0} notasyonuna başvurduk.

StringExtension sınıfı;

```csharp
using System;
using System.Net.Security;

namespace SecureSocket.Common
{
  public static class SocketExtensions
  {
    public static int BufferSize = 1024;
    public static Byte[] ToByteArray(this String value)
    {
      Byte[] bytes = new Byte[value.Length * sizeof(Char)];
      Buffer.BlockCopy(value.ToCharArray(), 0, bytes, 0, bytes.Length);
      return bytes;
    }
    public static String FromByteArray(this Byte[] bytes)
    {
      Char[] characters = new Char[bytes.Length / sizeof(Char)];
      Buffer.BlockCopy(bytes, 0, characters, 0, bytes.Length);
      return new String(characters).Trim(new Char[] { (Char)0 });
    }

    public static String ReadMessage(this SslStream stream)
    {
      string response = String.Empty;
      try
      {
        Byte[] buffer = new Byte[BufferSize];
        stream.Read(buffer, 0, BufferSize);
        response= FromByteArray(buffer);
      }
      catch(Exception excp)
      {
        Console.WriteLine(excp.Message);
      }
      return response;
    }
  }
}
```

SocketExtensions sınıfı içerisinde üç genişletme metodu mevcut. String tipine uygulanan ToByteArray, Byte[] tipine uygulanan FromByteArray ve son olarak SslStream tipine uygulanan ReadMessage. Tahmin edileceği üzere SslStream üzerinden akan içeriği kolayca okuyabilmek için ReadMessage metodundan yararlanıyoruz. Bunu sunucu tarafına istemciden gelecek mesajları okumak için kullanabiliriz. Diğer yandan istemcide üretilecek mesaj içeriğinin byte dizisine çevrilmesi için ToByteArray fonksiyonundan yararlanabiliriz.

## Araya Bir Unit Test Metodu Sıkıştıralım mı?

Sunucu ve istemci tarafını yazmadan önce en azından GetCertificateByName metodunu bir test edelim. Bunun için Solution'a ekleyeceğimiz SecureSocket.Common.Test isimli Unit Test projesini kullanabiliriz. Çok doğal olarak Unit Test projesi SecureSocket.Common kütüphanesini referans etmek durumunda. Sonrasında aşağıdaki basit test metodunu yazarak ilerleyebiliriz.

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Security.Cryptography.X509Certificates;

namespace SecureSocket.Common.Test
{
  [TestClass]
  public class CommonTests
  {
    [TestMethod]
    public void SampleCertificateIsFoundTest()
    {
      X509Certificate cert = null;
      CertificateHelper helper = new CertificateHelper();
      cert=helper.GetCertificateByName("SampleSslSocketCertificate");
      Assert.AreNotEqual(null, cert);
    }
  }
}
```

Test sonucunda aşağıdaki gibi yeşil tik aldıysak yola devam edebiliriz.

![tcp bazli soket haberlesmesinde sertifika kullanimi 03](/assets/images/2015/tcp-bazli-soket-haberlesmesinde-sertifika-kullanimi-03.gif)

## Sunucu Uygulama

Şimdi sunucu tarafını geliştirmeye başlayabiliriz. Console uygulaması şeklinde yazacağımız sunucu tarafının kodları oldukça basit.

```csharp
using SecureSocket.Common;
using System;
using System.Net;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;

namespace SecureSocket.Server
{
  class Program
  {
    static void Main(string[] args)
    {
      CertificateHelper helper = new CertificateHelper();
      X509Certificate serverCert = helper.GetCertificateByName("SampleSslSocketCertificate");
      TcpListener tcpServer = new TcpListener(IPAddress.Any, 4555);
      tcpServer.Start();
      Console.WriteLine("Sunucu dinlemede.{0}",DateTime.Now);
      while (true)
      {
        using (TcpClient client = tcpServer.AcceptTcpClient())
        {
          using (SslStream sslStream = new SslStream(client.GetStream(), false, ValidateCertificate))
          {
            sslStream.AuthenticateAsServer(serverCert, true, SslProtocols.Tls12, false);
            string incomingMsg=sslStream.ReadMessage();
            Console.WriteLine("[Client({0})] {1}",DateTime.Now, incomingMsg);
          }
        }
      }
    }

    static bool ValidateCertificate(Object sender,X509Certificate certificate, X509Chain chain,SslPolicyErrors sslPolicyErrors)
    {
      return true;
      // Sembolik olarak true döndürüyoruz. Normalde sertifika ile ilgili bir takım kontroller eklenmesi gerekir.
    }
  }
}
```

Kabaca kodda neler yaptığımız bir bakalım. Sonuçta burası sunucu uygulama olduğu için belli bir IP adresi ve port üzerinden kendisine mesaj gönderen istemcileri sürekli dinlemek durumunda. Sonsuz döngünün sebebi de bu diyebiliriz. Öncelikle sertifikanın bulunması gerekiyor. CertificateHelper sınıfının GetCertificateByName metodu burada devreye girmekte.

TCP tabanlı dinleyici için TcpListener nesne örneği oluşturuluyor. Bu nesne, programın çalıştığı makinedeki herhangibir IP adresini 4555 numaralı port için kullanacak. Tabi bu bir zorunluluk değil. Belli bir IP adresini de kullanabiliriz (Bunu nasıl yapabileceğinizi keşfetmeye çalışmanızı öneririm) Dinleme operasyonu Start metoduna yapılan çağrı ile başlıyor. Aslında iletişim kanalını açtığımızı ifade edebiliriz. AcceptTcpClient metodu request atan istemciyi yakalıyor ve sonrasında bir SSL stream açılıyor.

Stream açılırken sertifika doğrulaması için ValidateCertificate metodunu işaret ettiğimize dikkat edelim. Şu anda bir test uygulamasında olduğumuz için ValidateCertificate metodu her durumda true döndürmekte. Ancak gerçek hayat senaryosunda, yüklenen sertifikanın geçerli bir tarih aralığında bulunması, yayıncısının doğrulanması gibi çeşitli kontrol işlemlerine tabi tutmak için doldurulması önemli. Ayrıca gerçek bir sertifika ile deneme yapılıp canlı ortama bu şekilde atılmasında yarar var. Kısacası true döndüğüne siz bakmayın. Burada sadece senaryoyu test ediyoruz.

Eğer sunucu tarafından ilgili sertifika doğrulanırsa ReadMessage genişletme metodunu kullanarak istemciden gelen içeriği okumaya çalışıyoruz. Sonrasında ise okunan içeriği ekrana basıyoruz.

## İstemci Uygulama

Gelelim istemci tarafına. İstemci tarafının görevi de ilgili sunucya bağlanarak mesaj göndermek.

```csharp
using SecureSocket.Common;
using System;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;

namespace SecureSocket.Client
{
  class Program
  {
    static void Main(string[] args)
    {
      string certName = "SampleSslSocketCertificate";
      string hostName = "localhost";
      int port = 4555;
      CertificateHelper helper = new CertificateHelper();
      X509Certificate clientCertificate = helper.GetCertificateByName(certName);
      X509CertificateCollection clientCertificates = new
       X509CertificateCollection(
        new X509Certificate[]
        {
          clientCertificate
        }
        );

      for (; ;)
      {
        using (TcpClient client = new TcpClient(hostName, port))
        {
          using (SslStream stream = new SslStream(client.GetStream(), false, ValidateCertificate))
          {
            stream.AuthenticateAsClient(certName, clientCertificates, SslProtocols.Tls12, false);
            string message = Console.ReadLine();
            stream.Write(message.ToByteArray());
            Console.WriteLine("({0}):{1}",DateTime.Now, message);
          }
        }
      }
    }

    static bool ValidateCertificate(Object sender,X509Certificate certificate, X509Chain chain,SslPolicyErrors sslPolicyErrors)
    {
      if (sslPolicyErrors == SslPolicyErrors.None||
       sslPolicyErrors==SslPolicyErrors.RemoteCertificateChainErrors)
        return true;
      return false;
    }
  }
}
```

Sunucu tarafındakine benzer şekilde bir TcpClient nesne kullanımı söz konusu. Örneğimizi aynı makine üzerinde geliştirdiğimiz için localhost ve 4555 numaralı portu işaret ederek nesneyi oluşturuyoruz. SslStream ile stream nesnesini üretirken yine bir sertifika doğrulama adımı söz konusu. Bu kez istemci olarak sertifikanın doğrulandığını kontrol ediyor ve sonrasında mesaj gönderme adımlarına geçiyroruz. String sınıfı için yazdığımız ToByteArray isimli genişletme metodu burada devreye giriyor.

Bu arada gerek sunucu gerek istemci uygulamaların [TLS 1.2 standardını](https://www.ietf.org/rfc/rfc5246.txt) kullandığına lütfen dikkat edelim.

## Testler

İşte işin en heyecanlı kısmı. Testler... Bakalım bir sunucu ve bir kaç istemci çalıştırınca neler olacak? Ben test için sunucu haricinde istemci programdan üç adet çalıştırdım. Dikkat edilmesi gereken noktalardan birisi, istemcilerin sunucuya sırasıyla mesaj gönderebileceği. Yani sunucu, kendisine bir istemci bağlıyken ondan mesaj bekler konumda kalacak. Gelen mesajı takiben sıradaki istemcinin talebini değerlendirebilir olacak.

![tcp bazli soket haberlesmesinde sertifika kullanimi 04](/assets/images/2015/tcp-bazli-soket-haberlesmesinde-sertifika-kullanimi-04.gif)

Görüldüğü gibi TCP bazlı soket haberleşmesinde sertifika kullanımı oldukça basit. Canlı ortam söz konusu olduğunda sertifikanın doğrulanma adımlarına dikkat edilmelidir. Diğer yandan örnekte geliştirdiğimiz pek çok fonksiyonellik için Unit Test metodlarını atlamış bulunuyorum. (Hani nerede Test Driven Development. Oldu mu şimdi? Olmadı...) Bunları tamamlamak sizin için iyi bir antrenman olabilir.

Ek olarak çalışma zamanında ortaya çıkması beklenen bir kaç istisna (Exception) da olabilir. Söz gelimi sunucu uygulama, istemciler açıkken kapatılırsa ne olur? Peki ya birden fazla sunucu uygulamayı aynı anda çalıştırabilir miyiz? Ya da sunucu açık ve bir istemciden mesaj bekler konumdayken kapatılırsa istemcilerin akibeti ne olur? Bu konuları da göz önünde bulundurarak uygulama içeriğini genişletmeye çalışmanızı öneririm. Kurumumuzda kullandığımız harici uygulamada sertifika bazlı bir haberleşme olduğunu ve istemci olarak gönderdiğimiz soket mesajlarına karşılık cevaplar aldığımızı ve bunları işlediğimizi vurgulamak da isterim.

Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.