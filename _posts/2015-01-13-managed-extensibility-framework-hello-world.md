---
layout: post
title: "Managed Extensibility Framework - Hello World"
date: 2015-01-13 15:00:00
tags:
  - mef
  - managed-extensibility-framework
  - csharp
  - .net-framework
  - IoC
  - dependency-injection
  - modul-based-development
  - windows-api
  - .net-runtime
categories:
  - Framework Tabanlı Programlama
---
Günümüzde uygulamaların genişletilebilir olması önemli bir konu. Modüler olarak da nitelendirebileceğimiz bu felsefe ile bir uygulamanın kullanıcıları tarafından kolayca genişletilebilmesi amaçlanır. Hatta akıllı uygulamaların kendilerini bu şekilde genişletmesi de mümkündür.

![managed extensibility framework hello world 01](/assets/images/2015/managed-extensibility-framework-hello-world-01.jpg)

Modülerliği kazandırmak için kullanabileceğimiz farklı yöntemler vardır. Bunlardan belki de en basiti Interface tiplerini ve Reflection'ı kullanarak uygulamanın standart fonksiyonelliklerini genişletilebilir şekilde dışarıya açmaktır. Basittir ancak geliştiricinin iyi tasarlamasını gerekitir ve kod maliyeti yükselebilir.

Pek tabii Plug-In tabanlı bir yaklaşım için IoC (Inversion of Control) Container'larından da yararlanılabilir. Ninject, Windsor Castle, Unity gibi pek çok IoC Container bu noktada devreye girer. Ne var ki.Net cephesinde modülerlik adına Framework 4.0 sürümünden beri gündemde yer alan MEF alt yapısı ile de bu iş gerçekleştirilebilir.(ki benim Hello World demem epey zamanımı almıştır)

Örnekler

Konuyu iyi analiz edebilmek adına gerçek hayat örneklerine bakmamızda da yarar var. Modüler uygulamalara günümüzde pek çok örnek verebiliriz aslında. Plug-In veya Extension desteği olan ürünlerin tamamında modüler bir tasarım olduğundan bahsedebiliriz. Photoshop'a kullanıcı bazlı efektlerin yüklenmesinden Warcraft'a yeni oyuncların ilave edilmesine, Winamp'da yeni bir Skin'in yüklenmesinden Visual Studio'da yazılım takımının geliştirdiği bir TFS Policy'sinin entegre edilmesine kadar pek çok örnek verebiliriz.

MEF Nedir?

Uygulamalarımızın modüler olması için.Net tarafında kullanabileceğimiz alt kütüphane topluluklarından birisidir..Net'in bir parçası olduğu için.Net ile birlikte her yerde kullanılabilir.

İşin gerçeği kurumsal uygulamalarda IoC Container'ların kullanıldığı ama n sayıda nesnenin Bind edilme ihtiyacının bulunduğu senaryolarda MEF kullanımı düşünülebilir.
MEF'in Avantajı

Aslında.Net ile geliştirilmiş ürünlerde MEF kullanımının avantajını dile getirmeden önce Late Binding ve Early Binding kavramlarının bir uygulama yaşam döngüsü açısından ne anlama geldiğine bakmamızda yar var. Aşağıdaki amatör çizim bu konuda biraz fikir verebilir.

![managed extensibility framework hello world 02](/assets/images/2015/managed-extensibility-framework-hello-world-02.jpg)

Şimdi duruma bir bakalım. Modüler olarak düşünülen bir API tasarımı Windows tarafında başlatıldığında derleyici başlangıçta gerekli olan ne kadar kod varsa yükleyecektir. En azından bu şekilde düşünebiliriz. Bu durumda gerekli kod parçalarına Compiler'ın erken bağlandığından bahsedebiliriz.

Diğer yandan kullanıcı veya uygulamanın kendi seçimlerine göre çalışma zamanında yüklenmesi istenen modüller varsa bunlar geç bağlama (Late Binding) tekniği ile ortama dahil edilebilirler. Bu tip bir sürecin sağladığı pek çok avantaj vardır. Söz gelimi uygulama başlangıçta minimum gereksinim ile belleğe açılır ve yaşamı boyunca kullanıcı seçimine bağlı olarak ek modüllerin yüklenmesi için tekrardan başlatılmasına gerek kalmaz. İşte MEF için bu sürecin.Net API versiyonu olduğunu ifade edebiliriz.(Yani Late Binding desteği olan bir yapı)

Temelde IoC container'lar ile MEF arasında benzerlik olduğu düşünülebilir. Ancak temel bir fark vardır. Neredeyse tüm IoC Container'lar Early Binding tekniğine benzer bir şekilde yüklenirler ve genellikle X nesnesinin sadece bir örneğinin bağlanmasına izin verirler. MEF ise birden fazla nesnenin bağlanmasına olanak sunar.
Örnek Uygulama
Gelin basit bir örnek ile MEF kullanımına merhaba diyelim/diyeyim. Senaryomuza göre şirketteki farklı kaynaklardan, kurum müşterilerine ait bir takım verileri toplayan modüllerimiz olduğunu farz edebiliriz..Net ile geliştirilen bu modüllerin her biri farklı ortamlardan farklı şekillerde veri toplayacaktır. Toplanan verileri bir ortamda da sakladıklarını düşünebiliriz. Aslında veriyi toplama ve saklama şekilleri şu an önemli senaryo gereği çok önemli değil. Kavramamız gereken, ana uygulamanın bu modülerliğe nasıl kavuşabileceği. Yani kodu tekrar derlemeden bakması gereken yerlerdeki dll'lere ulaşarak, aynı fonksiyonelliklerin farklı işleniş şekillerini çalışma zamanı bünyesine nasıl entegre edebileceğini görmek.
Solution
İlk olarak aşağıdaki Solution yapısını oluşturarak işe başlayalım. (Unutmayın bu sadece bir Hello World uygulması, fazlası değil)

![managed extensibility framework hello world 03](/assets/images/2015/managed-extensibility-framework-hello-world-03.png)

Solution içerisinde modüler olmasını istediğimiz bir Console Application (Miner), bu uygulamaya eklemek istediğimiz modüller (Modules klasörü içindeki Class Library projeleri) ve modüllerin MEF'e expose edilmesinde kullanılan sözleşme kütüphanesi (Contracts isimli Class Library) yer almakta. Önemli olan nokta Modules altında geliştirilen sınıf kütüphanelerinin ana uygulamaya hiç bir şekilde referans edilmeden kullanılabilecek olması. Bu modüller Late Binding tekniğine göre MEF üzerinden Miner isimli uygulamada kullanılır hale gelecekler.

Contracts kütüphanesi dışındaki tüm projelerin System.ComponentModel.Compositions.dll assembly'ını referans etmesi gerektiğini ifade edelim. Bu sayede MEF alt yapısını kullanabileceğiz.

Kodlar

İlk olarak Contracts isimli Class Library içerisine IContractModule interface tipini ekleyerek yola çıkalım.

![managed extensibility framework hello world 04](/assets/images/2015/managed-extensibility-framework-hello-world-04.png)

IContractModule arayüzünü tasarlamaktaki amacımız aslında genişletilebilir modüller için ortak bir sözleşme sunmaktır. Sözleşme modüller için ortak bir kurallar bütünü sunacaktır. Bu sözleşmeyi uygulayan modüller, ana uygulama tarafından kullanılabilir hale gelecektir. Bunun içinse MEF tarafında çalışma zamanına bağlanmaları gerekmektedir. İyi ama nasıl?
Modül İçerikleri

Şimdi tüm konsantrasyonumuzu modüllerimize vereceğiz. Her bir modül bilinçli olarak ayrı birer Class Library olarak tasarlanmıştır. Gerçek hayat senaryosunda her bir kütüphanenin farklı ekiplerce farklı Solution'lar içerisinde yazılması da söz konusu olabilir. Kritik olan nokta, modüler olması istenen uygulamanın, ilgili modül kütüphanelerini bir şekilde tarayabilmesidir. Modüllere ait kodları aşağıdaki gibi geliştirerek yolumuza devam edelim.

CRMMiner Modül

![managed extensibility framework hello world 05](/assets/images/2015/managed-extensibility-framework-hello-world-05.png)

HRMiner Modül

![managed extensibility framework hello world 06](/assets/images/2015/managed-extensibility-framework-hello-world-06.png)

ve son olarak Mernis Modül

![managed extensibility framework hello world 07](/assets/images/2015/managed-extensibility-framework-hello-world-07.png)

Her üç modül IContractModule sözleşmesini uygulayan birer sınıf içermektedir. Bu üç sınıfın en önemli özelliği ise Export niteliğini (attribute) kullanmalarıdır. Bu nitelik MEF altyapısına ilgili tipin hangi sözleşmeyi sunduğunu bildirmektedir ki bu sayede IContractModule arayüzünü uyarlayan sınıflara ait örnekler MEF tarafından değerlendirilebilsinler. Dikkat edileceği üzere Export niteliğine IContractModule arayüz tipi typeof operatörü ile parametre olarak geçilmiştir. Gelelim asıl kahramanımıza.
Ana Uygulama
Her ne kadar ana uygulama basit bir Console projesi olarak tasarlanmış olsa da içerisinde MEF kullanım şekline Hello World dememiz için yeterlidir. Tabiki ana uygulamanında System.ComponentModel.Composition.dll assembly'ını referans etmiş olması gerekmektedir. Diğer yandan modüllerin bu uygulama tarafından kolayca taranabilir bir yerde olmasında da yarar vardır. Bu amaçla ortak bir klasör kullanılabilir ve dll'lerin buraya atılması sağlanabilir.

Hatta bu modüllerin uygulamanın çeşidine göre ortak bir sunucundan indirilerek lullanılması da sağlanabilir. Nuget paket yönetim aracında olduğu gibi.
Ben örnek olarak Debug\Extensions klasörü altına Build edilen modül dll'lerini xCopy ile kopyaladım.

![managed extensibility framework hello world 08](/assets/images/2015/managed-extensibility-framework-hello-world-08.png)

Gelelim ana uygulama kodlarına. Program.cs içeriğini aşağıdaki gibi yazabiliriz.

Dikkat edilmesi gereken yer Host isimli sınıf içeriğidir. Burada IEnumerable tipinden bir değişken tanımlıdır. Söz konusu liste n adet IContractModule arayüz uyarlamasını taşıyabilir. Bu n sayıda bağlama tanımını MEF üzerinden gerçekleştirmek için alanın ImportMany niteliği ile imzalanması yeterlidir. Yapıcı metod (Constructor) içerisinden çağırılan Bootsrap isimli metod, geç bağlama işlemlerini üstlenmektedir. Nasıl mı?

İlk olarak bir modül kataloğu tanımlanır. AggregateCatalog tipinden olan bu nesne örneğine farklı klasörlerden genişletmeler yüklenebilir. Bu nedenle Catalogs isimli bir özelliği vardır ve DirectoryCatalog ile modül klasörlerine ait yer bildirimleri yapılmaktadır. N adet modülün ilgili klasör içerisinde yer alan IContractModule uyarlamaları için düzenlenmesi gerekir. Bu noktada devreye CompositionContainer tipi girer. Dikkat edileceği üzere ilgili nesne örneklenirken parametre olarak AggregateCatalog nesnesini almaktadır. Son olarak bu kompozisyon o an çalışmakta olan canlı nesne örneği ile bağlanır. ComposeParts metodunun this anahtar kelimesi ile çağırılmasının sebebi ilgili modüllerin o anki çalışma zamanı sahibine bağlanmasıdır. Gelelim çalışma zamanı sonuçlarına.

![runtime result](/assets/images/2015/managed-extensibility-framework-hello-world-09.png)

Dikkat edileceği üzere Extensions klasörü içerisinde yer alan ne kadar dll varsa içlerinde yer alan IContractModule uyarlamaları çalışma zamanına bağlanmış ve kullanılmıştır.

Bu noktada akla şöyle bir soru gelebilir. Extensions klasöründe MEF ile Import edilemeyecek assembly'lar olursa ne olur? Hiç bir şey olmaz. Sadece MEX'in Import edebileceği sözleşmeleri (Contract) uygulayabilen tipler değerlendirilir ve çalışma zamanı için bir Exception fırlatılması söz konusu olmaz. Diğer yandan Export edilen Contract ilgili klasördeki her bir tip için aranmakta mıdır ben de bilemiyorum. Bunu derinlemesine araştırmak gerekiyor. Nitekim MEF'in tüm dll'leri taraması ve Export edilen tipleri taraması ciddi bir performans kaybına neden olabilir. O halde taramamasının bir yolu var mıdır? Varsa nasıldır?;)

Bir uygulamayı MEF alt yapısını kullanarak modüler hale getirmek son derece kolaydır. İlerleyen zamanlarda MEF'i daha geniş açıdan inceleyebiliriz. [Ancak o zamana adar sevgili Arda Çetinkaya hocamızın ilgili yazılarını takip etmenizi önerebilirim.](http://www.minepla.net/tag/mef/) Ben kendime not düşmek amacıyla Hello World demek istedim. Umarım sizler için de yararlı olmuştur. Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[MEFHelloWorldV2.zip (1MB)](https://www.buraksenyurt.com/file.axd?file=%2f2015%2f01%2fMEFHelloWorldV2.zip)
