---
layout: post
title: "Code Coverage"
date: 2019-02-05 18:00:00
categories:
  - Framework Tabanlı Programlama
tags:
  - tdd
  - test-driven-development
  - .net-core
  - code-coverage
  - devops
  - sonarqube
  - docker
  - sonarscanner
  - continuous-integration
  - continuos-inspection
  - continuous-delivery
  - continuous-deployment
---
Basketbol en sevdiğim spor dalı. Takım ayırt etmeksizin izlemeyi çok seviyorum. 40lı yaşların ortalarına doğru geliyor olsam da hala büyük bir keyifle oynuyorum da. Bazen saatlerce. En büyük rakibimse beş yaşından beri basketbol eğitim alan S (h) arp Efe. Son beş yıldır düzenli olarak idman yaptığı için kendisini epey geliştirmiş durumda. Bire birlerde acımıyor ve doğru basketbol oynamaya çalışıyor. Doğru basketbol için temellerin de doğru atılması gerekiyor. İlk koçu dahil şu an oynadığı kulüpteki koçu da Ona ve diğer çocuklara doğru alışkanlıkları öğretmeye çalışıyorlar. Çok zaman potaya şut bile atmadan tamamladıkları idmanlar vardır. Bunun yanına disiplinli çalışmayı da ekleyince çocuklar ilerleyen yaşlarında temel hareketlerde güçlü birer basketbolcu adayı haline geliyorlar.

![cdcrgkapak1.jpg](/assets/images/2019/cdcrgkapak1.jpg)

Konumuz basketbol değil ama onun çocuklar için düşünülen felsefesine yakın bir konu. Şimdi biraz geriye gidelim. 80lerin sonlarına. Eğer yazılıma ilk başladığım o yıllarda her şeyi Test Driven Development (ki NASA hariç sanırım pek çoğumuz o zamanlar bundan bihaberdi) prensiplerine göre geliştiriyor olsaydım...Şimdi ne kadar da kaliteli kodlar çıkartırdım diye düşünmeden edemiyorum. Çocuk değildim belki ama programlamaya ilk başladığım yıllardı ve işte o yıllarda temelleri de iyi atmak gerekiyordu.

Yeni yazılımcı adaylarının işte bu noktayı gözden kaçırmaması gerekiyor. Bugün yazılım geliştiren bir çok firma var. Ancak ürün kalitesi ile öne çıkanlar, pazara çok çabuk değer katan özellikler sunanlar diğerlerinden sürekli bir adım önde oluyorlar. Peki bunu nasıl oluyor da başarıyorlar!? En başından sonuna kadar sürekli olarak kendini iyileştiren, geri bildirimler ile devamlı beslenen, pek çok işin otomatikleştirildiği, yazılımcılar ile operasyon arasındaki bariyerlerin ortadan kaldırıldığı, çevik metodolojilere göre hareket edildiği kültür ile. Bu kültürün bir çok dayanak noktası var. Birisi de kodun ne kadar güvenilir ya da itibarının ne kadar yüksek olduğuyla alakalı. Bu genellikle statik ve dinamik kod analizleri ile mümkün kılınabilen bir senaryo.

Kaliteli kodun önemli belirtilerinden birisi de test edilmiş olmasıdır. Satır satır, fonksiyon fonksiyon ne kadarının test edilmiş olduğu onun itibarını doğrudan etkileyen bir faktördür. Bütünüyle testten geçirilmiş bir kod parçası takdir edersiniz ki kabus görmemizi engeller ve geceleri rahat bir uyku çekmemizi sağlar. Peki bir kodun ne kadarının test edilmiş olduğunu nasıl ölçebiliriz? Terminolojide Code Coverage olarak da adlandırılan bu durum Continuous Integration hattı için de büyük öneme sahiptir. Nitekim kodun %99.9 testten geçmiş olmasını bir kalite kriteri olarak kabul edebilir ve CI Server'ın buna göre deployment süreçlerini yürütmesini sağlayabiliriz.

> Esasında test güdümlü geliştirme (test driven development) esaslarına bağlı kalarak uygulama geliştirirsek kodun yazılan her fonksiyonunu test ederek ilerliyoruz demektir. Bu, doğal olarak Code Coverage değerinin yüksek çıkmasını sağlayacaktır.

Code Coverage ölçümlemesi için bir çok araçtan yararlanmamız mümkün. Örneğin platform bağımsız olarak çalışan ve.Net core desteği de bulunan Coverlet paketi bunlardan birisi. Bu yazımızda da Coverlet'ten yararlanarak söz konusu ölçümlemeleri nasıl yapabileceğimizi basitçe incelemeye çalışacağız. Hatta sonlara doğru statik kod analiz araçlarının en iyilerinden diyebileceğimiz SonarQube üzerine sonuçları aktarmaya çalışacağız. Örneklerimizi West-World (Ubuntu 16.04) üzerinde ve Visual Studio Code kullanarak geliştireceğiz. Haydi başlayalım.

Öncelikli olarak örnek solution kurgusunu oluşturarak işe başlamakta yarar var. West-World'de bunun için aşağıdaki komutlardan yararlanabiliriz.

```bash
mkdir CodeCoverage
cd CodeCoverage
dotnet new sln
mkdir MathService
cd MathService
dotnet new classlib
cd ..
dotnet sln add MathService/MathService.csproj
mkdir MathService.Tests
cd MathService.Tests
dotnet new mstest
dotnet add reference ../MathService/MathService.csproj
cd ..
dotnet sln add MathService.Tests/MathService.Tests.csproj
dotnet build
```

Şu haliyle aşağıdaki şekilde görülen klasör yapısına sahibiz.

![codecov_1.gif](/assets/images/2019/codecov_1.gif)

Bize tabii ki bir demet C# ve bir tutam da test kodu gerekiyor. MathService ve MathService.Tests projelerine aşağıdaki kod parçalarını serpiştirebiliriz. Buradaki temel hedefimiz Code Coverage için Visual Studio Code tarafında neler yapabileceğimize bakmak olduğundan basit bir iki deneme metodu yeterli olacaktır. MathService projesindeki Fundamental projesinde dörtgen çevresini bulmak için yararlanabileceğimiz bir fonksiyon yer alıyor.

```csharp
using System;

namespace MathService
{
    public class Fundamental
    {
        public double SquarePerimeter(double a,double b)
        {
            if(a==b)
                return 4*a;
            else
                return 2*(a+b);
        }
    }
}
```

MathService.Tests projesinde de FundamentalTests isimli bir test sınıfımız olacak.

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MathService.Tests
{
    [TestClass]
    public class FundamentalTests
    {
        private Fundamental _service;

        public FundamentalTests()
        {
            _service=new Fundamental();
        }
        [TestMethod]
        public void Should_Square_Area_Is_8_For_2()
        {
            var excepted=8;
            var result=_service.SquarePerimeter(2,2);
            Assert.AreEqual(excepted,result);

        }
        [TestMethod]
        public void Should_Rectangle_Area_Is_14_For_2_and_5()
        {
            var excepted=14;
            var result=_service.SquarePerimeter(2,5);
            Assert.AreEqual(excepted,result);
        }
    }
}
```

Şu anda iki test kabulümüz var. İlkinde kare ikincisinde de dikdörtgen için beklediğimiz değerler var. Şimdi Code Coverage işini kolaylaştırmak için Coverlet kütüphanesini test projemize eklemeliyiz. Bunun için test projesinin olduğu klasörde aşağıdaki terminal komutunu çalıştırmamız yeterli.

```bash
dotnet add package coverlet.msbuild
```

Coverlet destekli olacak şekilde test kodlarımızı çalıştırmak için root klasördeyken aşağıdaki komutla devam etmemiz gerekiyor.

```bash
dotnet test MathService.Tests/MathService.Tests.csproj /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

Bu durumda çalışma zamanının tepkisi aşağıdaki ekran görüntüsündeki gibi olacaktır.

![codeco_2.gif](/assets/images/2019/codeco_2.gif)

İki test başarılı şekilde çalışmış görünüyor. Bunun dışında kodlarımız satır, branch ve metod bazında yüzde yüz sigortalanmış durumda diyebiliriz. Söz konusu veri çıktıları bu örnek için CodeCoverage.opencover.xml isimli dosyaya da yansıtılmış durumdadır. Şimdi Fundamental sınıfına yeni bir fonksiyon daha ekleyelim.

```csharp
public double Average(params double[] numbers)
{
    double total=0;
    for(int i=0;i<numbers.Length;i++){
        total+=numbers[i];
    }
    return total/numbers.Length;
}
```

n sayılı bir dizinin ortalama değerini bulan bir fonksiyon söz konusu. Ancak bu kez ilgili fonksiyon için herhangi bir test yazmayalım ve testimizi yeniden başlatalım.

![codecov_3.gif](/assets/images/2019/codecov_3.gif)

Hımmm...Güzelllll...Sonuçlar değişti. Satır, branch ve metod bazında MathService projesinin bir kısmına güvenebileceğimizi söyleyebiliriz. Nitekim kodun neredeyse %50si testten geçirilmemiş ve kontrol edilmemiş durumda. Peki test metodlarından en az birisinin hatalı sonlandığı bir durum söz konusuysa ne olur? Bunun için şöyle bir test metodunu ekleyerek ilerleyelim.

```csharp
[TestMethod]
public void Should_Average_Is_2_For_Some_Array()
{
    var excepted=2;
    Assert.AreEqual(excepted,_service.Average(1,2,5,7,19));
}
```

Tekrar testimizi çalıştırırsak aşağıdaki sonuçlarla karşılaşırız.

![codecov_4.gif](/assets/images/2019/codecov_4.gif)

Code Coverage adımına geçemedik bile sanki:)) Zaten testlerinden en az birisi hatalı sonuçlanan kodun güvenilirliği de tartışılır ve Continuous Integration sunucusunda çalışan SonarQube gibi statik kod analiz araçları bu durumu affetmeyecektir. Genellikle bu gibi durumlarda build edilen parçaların dağıtım adımına geçirilmemesi söz konusudur. SonarQube demişken...Aslında uygulama ile ilgili CodeCoverage sonuçlarını gözlemlemek için SonarQube'dan da yararlanabiliriz. Coverlet'in ürettiği çıktılar SonarQube ile de uyumludur. West-World üzerinde SonraQube yüklü değil ancak docker imajından yararlanabilirim. Bunun için terminalden aşağıdaki komutu vermek yeterli.

```bash
sudo docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube
```

Coverlet sonuçlarını SonarQube'a alabilmek için SonarScanner aracına da ihtiyacımız olacak. Bunu West-World'e kurmak için aşağıdaki terminal komutundan yararlandım.

```bash
sudo dotnet tool install --global dotnet-sonarscanner
```

Artık uygulamıza ait Code Coverage değerlerini toplamak ve SonarQube üzerinden analiz etmek için hazırız. Yine terminalden aşağıdaki komutları kullanarak ilerlememiz yeterli (Tabii öncesinde tüm testleri yeşile çekmeyi ihmal etmemek lazım)

```bash
dotnet test MathService.Tests/MathService.Tests.csproj /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
dotnet sonarscanner begin /k:"ProjectCodeCoverage"
dotnet build
dotnet sonarscanner end
```

Komutlar işletildikten sonra docker üzerinden çalışan ve localhost:9000 nolu porttan hizmet veren SonarQube servisine gidebiliriz. Bu durumda aşağıdakine benzer bir ekran görüntüsü ile karşılaşmamız gerekir.

![codecov_5.gif](/assets/images/2019/codecov_5.gif)

Tek kelime ile A kalite bir ürün söz konusu:P Ama tabii gerçek hayat pek de böyle olmuyor. Özellikle yaşlı ve aceleyle geliştirilmiş,acele geliştirildiği için de stratejik olarak teknik borçlanılmış ürünler söz konusu olduğunda tablo aşağıdaki grafikte görüldüğü gibi de olabilir. FAILED!!!

![code coverage 01](/assets/images/2019/code-coverage-01.png)

Kaliteli kod geliştirmek elimizde. Bunun için test odaklı düşünmeli ve kodun tepeden tırnağa her parçasının çalışır olduğundan emin olmalıyız. Statik kod analizi yapan araçlara güvenmeli ve uyarılarını dikkate almalıyız. CI/CD (Continuous Integration/Continuous Delivery,Continuous Deployment) hatlarını doğru kurgulayıp sağlam ve emin adımlarla ilerlemeliyiz. En başında birey olarak temellerimizi sağlam atmalıyız. Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
