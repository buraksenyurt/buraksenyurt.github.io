---
layout: post
title: "Docker Üzerinde .Net Core Uygulaması Çalıştırmak"
date: 2017-11-10 06:01:00
categories:
  - Framework Tabanlı Programlama
tags:
  - .net-core
  - docker
  - container
  - linux
  - virtulization
  - sanallaştırma
---
Biliyorum epeyce geriden geliyorum yeni nesil konularda ama işler güçler derken ancak zaman bulabiliyorum. Önceki yazılarımdan da hatırlayacağınız üzere evdeki emektar dizüstü bilgisayarıma Ubuntu'nun 64bitlik sürümünü yüklemiştim (Makineye West-World adını verdim) Üzerinde ilk.Net Core denemelerimi de gerçekleştirdim. Ancak merak ettiğim konulardan birisi de Docker üzerinde bir.Net Core uygulamasının nasıl çalıştırılabileceğiydi. Bu iş sandığımdan daha zor olacaktı. Yarım yamalak bilgimle Docker'ın ne olduğunu az çok biliyordum ama tam anlamıyla da hakim değildim. En azından biraz daha fikir sahibi olmalı, kurulumunu gerçekleştirmeli ve sonrasında örnek bir.Net Core uygulamasını Dockerize ederek taze bir imaj (image) üzerinde ayağa kaldırabilmeliydim.

![core_docker_9.gif](/assets/images/2017/core_docker_9.gif)

Internet üzerinde Docker ile ilgili pek çok bilgi ve kaynağa ulaştım. Ama özellikle [Asiye Yiğit'in Linkedin üzerinden paylaştığı yazılar](https://tr.linkedin.com/pulse/docker-asiye-yigit) önemli bilgiler edinmemi sağladılar. Bunun haricinde DevOps tarafında oldukça yetenekli olan arkadaşım (ki hemen solumda oturur) Alpay Bilgiç, beni aydınlatan bilgiler verdi. Ne sorsam cevapladı. Çıkarttığım notlardan yararlanarak konuyu kavramak için şekilleri tekrardan ele aldım. Öncelikle ilgili notları bu blog yazısı aracılığıyla temize çekeceğim ki yarın öbür gün nasıl oluyordu bu iş dediğimde dönüp bakabileyim. Sonrasında Ubuntu üzerine Docker kuracağım. Ardından.Net Core 2.0 için basit bir Console uygulaması yazacağım. Son adımda ise bu uygulamayı Docker üzerinde ayağa kaldıracağım. Haydi gelin başlayalım.

## Docker'dan Anladığım

Aslında her şey farklı platformlarda çalışabilecek uygulamaların ölçek büyüdükçe daha çok makineye ve kuruluma ihtiyaç duyması sonrasında başlamış gibi duruyor. Yeni makine demek, yeni kurulumlar, yeni lisans ücretleri, yeni yönetim sorumlulukları, yeni dağıtım süreçleri, yeni elemanlar demek. Durum böyle olunca maliyetlerin artması da kaçınılmaz hale gelmiş. Benim üniversite yıllarında da tanık olduğum o eski yaklaşım kabaca aşağıdaki şekilde görüldüğü gibiydi.

![docker uzerinde dotnet core uygulamasi calistirmak 01](/assets/images/2017/docker-uzerinde-dotnet-core-uygulamasi-calistirmak-01.png)

İlk dünya yukarıdaki gibiydi. Sonrasında ise Hyper-V (Fiziki bir makinede birden fazla sunucu rolünü bağımsız sanal roller içerisinde çalıştırımamızı sağlayan Microsoft ürünü de diyebiliriz) gibi isimler duymaya başladık. Bir başka deyişle sanallaştırma kavramları ile içli dışlı olmaya başladık.

![core_docker_2.gif](/assets/images/2017/core_docker_2.gif)

Sanallaştırma sayesinde tek bir fiziki sunucu üzerinde farklı işletim sistemlerini konuşlandırabilmekte. Bu teknikle özellikle dağıtım süreçlerinin hızlandığını ve yeni fiziksel sunucular almak zorudan kalmadığımız için maliyet avantajları sağlandığını ifade edebiliriz. Pek tabii ölçekleme maliyetleri de azalıyor. Ancak her ziyaretçi işletim sistemi (Guest OS) için ayı bir işletim sistemi barındırmak durumunda da kalıyoruz ki bu negatif bir özellik olarak karşımıza çıkıyor. Diğer yandan uygulamalarının taşınabilirliği yeteri kadar esnek olmuyor. Diğer bir dezavantaj.

Derken karşımıza Docker diye bir şey çıktı. Go dili ile geliştirildiği söylenen bu yeni yaklaşımın özeti kabaca aşağıdaki şekilde görüldüğü gibi.

![core_docker_3.gif](/assets/images/2017/core_docker_3.gif)

Docker gibi Container araçları sayesinde uygulamalarımızı sadece ihtiyaç duydukları kütüphaneler (paketler) ile birlikte birbirlerinden izole olacak şekilde çalışabilir halde sunabiliyoruz. Dağıtımın kolaylaşması dışında taşınabilirlik de kolaylaşıyor. En önemli artılarından birisi ise uygulamalara has çalışma zamanlarının birbirlerinden tam anlamıyla izole edilebiliyor olması.

Aşağıdaki şekil Docker'ın temel çalışma mimarisi özetlenmeye çalışılmakta.

![core_docker_4.gif](/assets/images/2017/core_docker_4.gif)

Docker temel olarak istemci-sunucu mimarisine uygun olarak geliştirilmiştir. GO dili ile yazıldığını sanıyorum belirtmiştik. Kullanıcılar esas itibariyle Docker Client üzerinden Demaon ile iletişim kuruyorlar. Build, Pull ve Run gibi komutlar Docker Client aracılığıyla, Deamon üzerinden işletilmekteler. Docker Demaon devamlı olarak çalışan bir Process (Sanırım Windows Service'e benzetebiliriz) Container’lar aslında birer çalışma zamanı nesnesi ve uygulamaların yürütülmesi için gerekli ne varsa (betikler, paketler vs) barındırıyorlar. Image öğeleri de Container’ların oluşturulması için kullanılan yalnızca okunabilir şablonlar olarak tasarlanmışlar. Şekilde Build, Pull ve Run operasyonlarının temel çalışma prensiplerini görebiliriz (Okların renklerine dikkat edelim)

## Özetleyecek olursak

- Docker Store: Güvenilir ve kurumsal seviyedeki imajların kayıt altına alındığı yer.
- Docker Client: Deamon ile iletişim kuran komut satırı aracı.
- Docker Deamon: Container'ların inşa edilmesi, çalıştırılması, dağıtılması gibi operasyonları üstlenen arka plan servisi.
- Image: Uygulamalar için gerekli konfigurasyon ve dosya sistemi ayarlarını taşıyan ve Container'ların oluşturulması için kullanılan nesneler. Docker dünyasında base,child,official ve user tipinden imajlar bulunuyor. base tipindekiler tahmin edileceği üzere linux,macos,windows gibi OS imajları.child imajlar base'lerden türetilip zenginleştiriliyor. Docker'ın official imajları (pyhton, alpine, nginx vb) dışında kullanıcıların depoya aldığı docleağrulanmış imajlarda söz konusu.
- Container: Image'ların çalışan birer nesne örneği. Bir Container çalışan uygulama için gerekli tüm bağımlılıkları bünyesinde barındırır. Kendi çekirdeğini (Kernel) diğer Container'lar ile de paylaşır. Tamamen izole edilmiş process üzerinde çalışır.

## Docker'ın Kurulumu

Kurulum işlemlerinde halen tam olarak anlamadığım adımlar olsa da benim için önemli olan West-World'e Docker'ın başarılı bir şekilde yüklenmesiydi. Aşağıdaki adımları izleyerek bu işlemi gerçekleştirdim.

Her ihtimale karşı işe başlarken paket indeksini güncellemek gerekiyor.

```bash
sudo apt-get update
```

Sonrasında https üzerinden repository kullanımı için gerekli paket ilavelerinin yapılması lazım (Ben önceden yapmışım o yüzden yeni bir şey eklemedi)

```bash
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
```

Bu işlerin ardından Docker'ın (GNU Privacy Guard-gpg) anahtarının sisteme eklenmesi gerekiyor.

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Docker dökümanına göre anahtarın kontrol edilmesinde yarar var. Harfiyen dediklerine uyuyorum ve FingerPrint bilgisinin son 8 değerine bakıyorum.

```bash
sudo apt-key fingerprint 0EBFCD88
```

Bilgi doğrulanıyor. Artık Repository'yi ekleyebilirim. West-World, Ubuntu'nun Xenail türevli işletim sistemine sahip. Bu sebeple uygun repo seçimi yapılmalı. Siz sisteminiz için uygun olan sürümü yüklemelisiniz (Diğer yandan production ortamlarında sürüm numarası belirterek de yükleme yapılabiliyor)

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

Kurulum öncesi yine paket indeksini güncellemekte yarar var. Nitekim docker repository paketleri yüklenecek.

```bash
sudo apt-get update
```

Bu ön hazırlıklardan sonra docker'ın kurulumuna başladım. Aşağıdaki komut ile sisteme Community Edition sürümü yüklendi.

```bash
sudo apt-get install docker-ce
```

Kurulumdan emin olmanın yolu standart bir imajı test etmekten geçiyor. Bunun için hello-world imajını kullanmamız öneriliyor.

```bash
sudo docker run hello-world
```

Tabii Docker yeni kurulduğu için hello-world imajı sistemde bulunmuyor. Bu yüzden run komutu sonrası ilgili paketin son sürümü indirilecek ve sonrasında da çalıştırılacaktır. "Hello from Docker!" cümlesini görmek yeterli.

![core_docker_5.gif](/assets/images/2017/core_docker_5.gif)

Eğer adımlara dikkat edilecek olursa yukarıdaki çalışma şeklinde bahsedilen işlemlerin yapıldığı da görülebilir. İlk olarak Docker Client, Docker Deamon'a bağlanıyor. Sonrasında Deamon, hello-world imajını Hub'dan çekiyor ([Hub'da sayısız imaj olduğunu belirtelim](https://hub.docker.com/explore/)) İmaj çekildikten sonra bir Container oluşturulup çalıştırılıyor. Sonuçlar da istemciye sunuluyor. Artık West-World'de Docker kurulmuş vaziyette. Terminalde docker kullanımı ile ilgili daha fazla bili almak için --help anahtarını da kullanabiliriz.

```bash
docker --help

docker pull --help
```

gibi

## Basit Bir .Net Core Console Application

Docker üzerinde host etmek için deneme amaçlı bir Console uygulaması yazarak devam etmeliyim. Terminalden aşağıdaki komutu kullanarak şanslı sayı üretmesini planladığım uygulamayı oluşturdum.

```bash
dotnet new console -o LuckyNum
```

Ardından Program.cs içeriğini aşağıdaki gibi değiştirdim.

```csharp
using System;

namespace LuckyNum
{
    class Program
    {
        static void Main(string[] args)
        {
            Random randomizer=new Random();
            var num=randomizer.Next(1,100);
            Console.WriteLine("Merhaba\nBugünkü şanslı numaran\n{0}",num);
        }
    }
}
```

Program çalıştırıldığında bizim için rastgele bir sayı üretiyor. İçeriği aslında çok da önemli değil. Amacım uygulamayı Docker üzerinden yürütmek. İlerlemeden önce programın çalıştığından emin olmakta yarar var tabii.

![core_docker_6.gif](/assets/images/2017/core_docker_6.gif)

Sıradaki adımsa uygulamanın publish edilmesi. Terminalden aşağıdaki komutu kullanarak bu işlem gerçekleştirilebilir.

```bash
dotnet publish
```

Sonuçta LuckyNum.dll ve diğer gerekli dosyalar bin/debug/netcoreapp2.0/publish klasörü altına gelmiş olmalı.

![core_docker_7.gif](/assets/images/2017/core_docker_7.gif)

## Console Uygulamasını Docker'a Almak

Nihayet son adıma geldim. Kodların olduğu klasöre gidip Dockerfile isimli bir dosya oluşturmak gerekiyor (Uzantısı olmayan bir dosya. DockerFile gibi değil Dockerfile şeklinde olmalı. Nitekim docker bunu ele alırken Case-sensitive hassasiyeti gösterdi. Epey bir deneme yapmak zorunda kaldım) Dosya içerisinde bir takım komutlar olacak. Bu komutlar aslında Linux temelli.

```yaml
FROM microsoft/dotnet:2.0-sdk
WORKDIR /app

COPY /bin/Debug/netcoreapp2.0/publish/ .

ENTRYPOINT ["dotnet", "LuckyNum.dll"]
```

Bütün Dockerfile içerikleri mutlaka FROM komutu ile başlar. Burada base image bilgisini veriyoruz ki örnekte bu microsoft hesabına ait dotnet:2.0-sdk oluyor. Dosyayı oluşturduktan sonra bir build işlemi gerçekleştirmek ve imajı inşa etmek lazım.

```bash
sudo docker build -t lucky .
```

Bu komutla Deamon Hub üzerinden microsoft/dotnet:2.0-sdk imajı indirilmeye başlanacak. Dockerfile içerisindeki ilk satırda bunu ifade ediyoruz. Sonrasında basit dosya kopyalama işlemi yapılacak ve çalışam zamanındaki giriş noktası gösterilecek.

> DotNet Tarafı için kullanılabilecek Docker Image listesine [buradan](https://hub.docker.com/r/microsoft/dotnet/) ulaşabilirsiniz. Hem Linux hem Windows Container'ları için gerekli bilgiler yer alıyor.

Artık elimde lucky isimli bir imaj var. Bu imajı doğrudan çalıştırabileceğimiz gibi bu imajdan başka bir tane çıkartıp onu da yürütebiliriz. Aşağıdaki kodda bu işlem gerçekleştirilmekte. Tabii luckynumber'ın kalıcı olması için commit işlemi uygulanması da gerekebilir. Docker'ın komutları ve neler yapılabileceği şimdilik yazının dışında kalıyor ama ara ara bakmaya çalışacağım.

> Bu arada oluşturulan imajları isterseniz cloud.docker.com adresinden kendi hesabınızla da ilişkilendirebilirsiniz. [Şu adresteki](https://github.com/docker/labs/blob/master/beginner/chapters/webapps.md) python örneğini adım adım yapın derim;)

```bash
sudo docker run --name luckynumber lucky
```

![core_docker_8.gif](/assets/images/2017/core_docker_8.gif)

Ben yazıyı hazırlarken bir kaç deneme yaptığım için Docker build işleminin çıktısı sizinkinden farklı olabilir. Nitekim dotnetcore imajının indirilmesi ile ilgili adımlar da yer almaktaydı. Sisteme yüklü olan imajların listesini de görebiliriz. Hatta kaldırmak istediklerimiz olursa rm veya rmi komutlarını da kullanabiliriz. Bunlar örneğe çalışırken işime yarayan komutlardı.

> Docker'ın çalışma prensiplerini daha iyi kavramak ve örneklerle uygulamalı olarak onun felsefesini anlamak için [GitHub üzerindeki şu adrese](https://github.com/docker/labs/blob/master/beginner/chapters/alpine.md) uğramanızı tavsiye ederim.

West-World şimdi biraz daha mutlu. Çünkü.Net Core 2.0 ile yazılmış bir programı dockerize etmenin nasıl bir şey olduğunu öğrendi. Ben de tabii. Elbette docker'ın gücünü anlamak için farklı açılardan da bakmak gerekli. Söz gelimi official imajlardan olan python'un çekip üretilen container üzerinde doğrudan python ile kodlama yapmaya başlayabiliriz. Aşağıdaki ekran görüntüsüne dikkat edin. Sistem python yüklememize gerek yok. pyhton çalışmak için gerekli herşeyin yer aldığı bir imajı çekip başlatılan container üzerinden kodlama yapabiliriz.

![core_docker_11.gif](/assets/images/2017/core_docker_11.gif)

Docker,.Net Core gibi konular önümüzdeki yıllarda geliştiricilerin iyi şekilde hakim olması gereken konular arasında yer alıyor. Vakit ayırıp planlı bir şekilde çalışmak lazım. Böylece geldik bir yazımızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
