---
layout: post
title: "Xml Web Servisleri - 5 (Mimarinin Temelleri - DISCO)"
date: 2004-10-07 12:00:00
tags:
  - xml-web-service
  - disco
  - discovery
categories:
  - Servis Tabanlı Geliştirme
---
Disco, Microsoft tarafından geliştirilmiş bir keşif mekanizmasıdır. Web servislerinin kullanılması ile ilgili en önemli sorun, istemci uygulamaları geliştiren yazılımcıların, ne tip web servisleri olduğundan ve bunları nasıl kullanacaklarından haberdar olamamasıdır. Bu amaçla, web servislerini yayınlayanlar, bu servislere ait erişim bilgilerini e-mail veya başka iletişim yolları ile istemcileri geliştiren yazılım tarafına gönderebilirler. Ancak Microsoft bu işin daha kolay yapılabilmesini sağlamak amacıyla, web servislerinin keşfedilmelerine kolaylık getiren teknikler geliştirmiştir. Bu tekniklerden birisi disco tekniğidir. Disco tekniğinin kilit noktası, disco uzantılı XML tabanlı dosyalardır. Daha önceki makalelerimizde, Visual Studio .NET ile geliştirdiğimiz istemci uygulamayı göz önüne aldığımızda, GeoMat.disco isimli bir dosyanın da yer aldığını görürüz.

![mk102_1.gif](/assets/images/2004/mk102_1.gif)

Şekil 1. Disco Dosyamız.

Bu dosyanın içeriği XML tabanlı olup aşağıdaki gibidir.

```xml
<?xml version="1.0" encoding="utf-8"?>
<discovery xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.xmlsoap.org/disco/">
  <contractRef ref="http://localhost/GeoWebServis/GeoMat.asmx?wsdl" docRef="http://localhost/GeoWebServis/GeoMat.asmx" xmlns="http://schemas.xmlsoap.org/disco/scl/" />
  <soap address="http://localhost/GeoWebServis/GeoMat.asmx" xmlns:q1="http://ilk/servis/" binding="q1:Geometrik_x0020_HesaplamalarSoap" xmlns="http://schemas.xmlsoap.org/disco/soap/" /></discovery>
```

Bu doküman, kullanılan web servisine nasıl erişileceğine ve özellikle WSDL dokümanının nasıl isteneceğine dair önemli bilgileri barındırır.
Bu bilgilere sahip olan bir disco dokümanı sayesinde, kullanılmak istenen web servisine nasıl erişileceği bilinebilir. Disco uzantılı bu XML dosyalarının web servislerinin keşfine asıl katkısı, .NET Framework ile gelen disco aracının kullanımında ortaya çıkmaktadır. Bu durumu daha iyi anlayabilmek için şu senaryoyu göz önüne almakta yarar var: Birçok web servisi barındıran bir web sitemiz olduğunu düşünelim. Web servisleri, IIS gibi sunucularda geliştirildiklerinden, yazılmış olan web servislerini sayfamızı kullanan istemcilere yayınlamak isteriz. Başka bir deyişle web servislerimizden haberdar olunmasını isteriz. Disco tekniğini bu yayınlama işlemi için kullanabiliriz. İlk olarak, geliştirdiğimiz tüm web servisleri için birer disco dokümanı oluşturmalıyız. Daha sonra sitemizin açılış sayfasında ufak bir değişiklik ile bu disco dokümanlarına disco aracı yardımıyla erişilmesini sağlamalıyız. Bu noktadan sonra, istemci uygulamaları geliştirecek olan yazılımcıların tek yapması gereken başlangıç sayfamızın bulunduğu URL bilgisini parametre olarak disco aracına bildirmek olacaktır. Şimdi bu senaryoyu gerçeğe çevirecek bir çalışma yapalım.
Örneğin yerel sunucumuzda (localhost) iki web servisimiz olduğunu düşünelim. Şu aşamada bu servislerin nasıl yazıldığının fazla bir önemi yoktur. Şimdi bu servislere ait disco dokümanlarını oluşturmamız gerekiyor. Bir disco dokümanını herhangi bir metin editöründe yazabiliriz. Ancak XML içeriğini oluşturmak zor gelebilir. Bunun için ASP.NET'in imkânlarından faydalanabiliriz. ASP.NET, bir web servisine ait disco dosyasını talep ettiğimizde bu dosyayı tarayıcıda otomatik olarak üretecektir. Bu, bir web servisi için WSDL dokümanının istenme şekli ile aynı prensiplere dayanır ve aşağıdaki gibi gerçekleştirilir.

Browser'da yazdığımız bu URL'den sonra web servisimize ait disco dokümanı bilgilerini aşağıdaki gibi elde ederiz.
![mk102_2.gif](/assets/images/2004/mk102_2.gif)
Şekil 2. Disco bilgilerinin tarayıcı penceresinden elde edilmesi.
Şimdi tek yapmamız gereken bu XML içeriğini disco uzantılı bir dosya hâlinde, localhost'a yani inetpub\wwwroot\ klasörü altına kopyalamak olacaktır. Burada dikkat etmemiz gereken bir nokta vardır. Browser'dan elde ettiğimiz XML içeriğini bir disco dosyasına kopyalarken `-` işaretlerini kaldırmayı unutmamalıyız. Aksi takdirde disco aracını kullanırken hata mesajları ile karşılaşırız. Örneğimizde bu ilk disco dokümanını localhost'a GeoMat.disco ismi ile kaydedelim. Aynı işlemi sunucumuzda yer alan tüm web servisleri için gerçekleştirebiliriz. Bu işlemlerin ardından, localhost'un açılış sayfası olan localstart.asp dosyasını herhangi bir editörde açalım. Burada Head tagları arasına aşağıdaki eklemeleri yapmamız gerekiyor.

Şimdi burada ufak bir işlem daha yapmamız gerekiyor. Head tagında yer alan bu satırdan sadece bir tane tanımlayabiliriz. Normalde aşağıdaki gibi bir tanımlama yapıldığında, belirtilen iki disco dosyasının da ele alınacağı ve istemcide çalıştırılan disco aracı sayesinde indirilebileceğini düşünebiliriz.

Ancak sanılanın aksine, disco aracı belirtilen sayfadaki link taglarından sadece ilkini çalıştırır ve bu link ile belirtilen disco dokümanını ve buna bağlı WSDL dokümanını indirir. Bu sorunu halletmek için, ilk olarak belirttiğimiz GeoMat.disco dosyasında

DiscoveryRef boğumu ile, GeoMat.disco dosyasının referans edebileceği başka disco dosyalarını belirtmiş oluruz. Dolayısıyla, başlangıç sayfasının bulunduğu adres disco aracı için parametre olduğunda, bu adresteki link tagında yer alan disco dosyasının yanında bu dosyanın referans ettiği diğer disco dokümanları da ele alınabilecektir. Açıkçası küçük bir hile yapmış oluyoruz. Şimdi tek yapmamız gereken istemci bilgisayarın komut satırında aşağıdaki ifadeyi çalıştırmak olacaktır.

![mk102_3.gif](/assets/images/2004/mk102_3.gif)
Şekil 3. Yerel sunucudaki disco ve WSDL dokümanlarının elde edilmesi.
Bu işlemin ardından, deneme isimli klasöre bakıldığında, GeoMat ve PerSor web servislerini kullanabilmemiz için gerekli proxy sınıflarını oluşturmakta kullanacağımız WSDL dokümanlarının disco dokümanları ile birlikte indirildiğini ve kaydedildiğini görürüz.
![mk102_4.gif](/assets/images/2004/mk102_4.gif)
Şekil 4. İndirilen disco ve WSDL dokümanları.
Artık bu noktadan sonra yapmamız gerekenler sadece WSDL dokümanları yardımıyla proxy sınıfımızı oluşturmak ve kullanmak olacaktır. Bir sonraki makalemizde görüşünceye dek hepinize mutlu günler dilerim.