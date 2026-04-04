---
layout: post
title: "Mocha'nızı Node.js ile Alır mıydınız?"
date: 2018-06-07 18:00:00
categories:
  - Web Programlama
tags:
  - node.js
  - javascript
  - test-driven-development
  - bdd
  - mocha
  - fluent-interface
  - fluent-api
  - method-chain
  - assert
  - assertion
  - custom-assertion
  - testing-framework
  - unit-test
  - tdd
  - unpkg
---
Çalışmakta olduğum şirketin bizlere sunduğu güzel imkanlardan birisi de Pluralsight aboneliği. Hesabım açılır açılmaz ilk yol haritamı da çıkarıverdim. Kendime göre verimli olacağını düşündüğüm bir zaman planlaması yaptım. Sabah saat 07:15 sularında şirkete vardıktan sonra, kapıdaki görevliye sıcak bir tebessümle 'Günaydın'de, mutfaktan geçerken bir bardak kahve al, masana otur ve sonrasında kaldığın yerden devam et... Şu sıralar Node.js yol haritamın merkezinde yer alıyor. Mesai başlangıç saatimiz olan 07:45'e kadar izleyebildiğim ve uygulayabildiğim kadarıyla ilerliyorum. Yer yer videoyu durduruyor, örnek kod parçalarını satır satır yazıyor, gerektiği yerlerde notlar alıyorum. Amacım şu an için sadece ve sadece Node.js'i tanımak, biraz daha iyi anlamak. Sonuçta node.js konusunda uzman olabilmem için yüzlerce saat gerçek hayat projelerinde çalışmam gerekiyor.

![mocha_1.gif](/assets/images/2018/mocha_1.gif)

İşte bu tempoyu devam ettirdiğim sabahlardan birisinde işlediğim modülde test kodları yazılması üzerine faydalanılan iki paketten bahsedildi. Modülü çalışırken çok güzel şeyler öğrendiğimi fark ettim. Hafiften behavioral driven development (BDD) yaklaşımına yönlendiren, kullanımı kolay ve eğlenceli bir test ortamının nasıl oluşturulabileceği gözler önüne seriliyordu (Aslında şu güdümlü geliştirme konsepti bağlamında sevgili dostum Görkem Özdoğan'ın [şuradaki yazısını okumanızı](http://gorkemozdogan.net/dv/data-vinci-32-x-driven-development/) şiddetle tavsiye ederim) Modülde Mocha ve Should isimli iki çatıdan (framework) bahsediliyordu. Öğrendiklerimi pekiştirmek için bir yerlere yazmam gerektiğini gayet iyi biliyordum.

Her zaman ki gibi en basit örneğimi hazırladım, konuyu yalın haliyle benimsemeye çalıştım ve işte burada karşınızdayım. Dilerseniz vakit kaybetmeden konumuza başlayalım.

Modülde bahsedilen Mocha bir test çatısı (testing framework) olarak düşünülebilir. Test yazmayı keyifli hale getirdiği belirtilmekte. Ancak onu Should.js çatısı ile birlikte kullanınca çok daha eğlenceli bir ortam oluştuğunu şimdiden söyleyebilirim. Günlük konuşma dilimizdeki ifadeleri bir araya getirerek test iddalarını oluşturabiliyoruz. Ne demek istediğimi anlatabilmek için örnek üzerinden gitmemizde yarar var.

> Yazılımcı olarak kulak arkası etmememiz gereken ve bize düşen önemli görevlerden birisi de geliştirdiğimiz en ilkel fonksiyonelliklerin bile olası test senaryolarından başarılı şekilde geçmiş olması. Bu nedenle harfiyen uygulayamıyor olsak bile Test Driven Development'a göz kırpamkta yarar var. Önce sınıfları ve fonksinelliklerini geliştirmek yerine, test senaryolarımıza göre bunları yazmak daha sağlam temellerin atılmasına neden olan bir metodolojidir diye düşünüyorum. Örneğimizde kulağımızı tersten tutuyoruz. Amacımız mocha ve should çatılarının temel olarak nasıl kullanıldıklarını kavramak olduğu için...

Ben klasik olarak her cumartesi gecesi yaptığım gibi West-World'de tatildeyim. Kısa süre önce buraya Node.js'i getirmiştim. Visual Studio Code ve terminal pencerem her zaman olduğu gibi hazır. Kasabanın en meşhur müzik lokalinde Lissie, Rae Moris, Ane Brun ve Katie Melua arka arkaya en popüler şarkılarını canlı olarak seslendiriyorlar. Kahvemden küçük bir yudum alıyor ve klavyemde kodları yazmaya başlıyorum.

## Gerekli Kurulumlar

Örnek kod parçasında mocha ve should çatıları kullanıldığı için tahmin edeceğiniz gibi bu paketleri sisteme yüklemek gerekiyor. npm aracını kullanarak ilgili yükleme işlemlerini yapıyorum (Bu paragrafı daha uzun planlamıştım ama...Niye böyle oldu ki:S)

```bash
npm install mocha
npm install should
```

## Test Edilecek Kod Parçası

mathForKids.js isimli bir modülümüz olacak. Bu modül içerisinden sum isimli ve iki sayıyı toplayan çok basit bir fonksiyonellik sunuyoruz. sum isimli metodun senkron çalışan bir versiyonu da mevcut (Bu cümle garibinize gitmemiş olmalı. Malum node.js doğası gereği asenkron çalışma prensiplerini benimsiyor. Senkronluk ikinci planda) mathForKids isimli dosyanın içeriğini aşağıdaki gibi geliştirebiliriz.

```javascript
var maxTime = 1000;

var sum = function (x, y, callback) {
    var waitTime = Math.floor(Math.random() * (maxTime + 1));

    if (x < 0 || y < 0) {
        setTimeout(function () {
            callback(new Error('be positive!'));
        }, waitTime);
    } else {
        setTimeout(function () {
            callback(null, x + y, waitTime);
        }, waitTime);
    }
};

var sumSync = function (x, y) {
    if (x < 0 || y < 0) {
        throw (new Error("be positive!"));
    } else {
        return (x + y);
    }
};

module.exports.sum = sum;
module.exports.sumSync = sumSync;
module.exports.description = "Math is fun";
```

Kodda neler oluyor bir bakalım değil mi? sum ve sumSync isimli iki metod söz konusu. sum metodu rastgele bir geciktirme süresi esas alınaraktan asenkron çalışma senaryosunu gerçekleştiriyor. Bunun için setTimeout fonksiyonundan nasıl yararlandığımıza dikkat edin lütfen. Çocuklar için toplama işlemi yapan bir fonksiyon söz konusu ki şimdilik onların negatif sayılar dünyasına girmesini istemiyoruz (Gülmeyin cidden ilk bir kaç sene hayatlarında sadece pozitif doğal sayılar var) Bu nedenle her iki fonksiyonumuz içerisinde x ve y değerlerinin 0 dan küçük olma halleri kontrol edilmekte. Eğer bir ihlal söz konusuysa ortama hata mesajı fırlatılmasını sağlamaktayız. Modülümüzdeki fonksiyonellikleri exports bildirimi ile dışarıya sunmayı da ihmal etmiyoruz tabii. Matematik eğlencelidir mesajımızı da gizliden bilinçaltınıza işleteyim:P

## Test Dosyası

Test senaryolarını içerek kod dosyasını genel kabul görmüş klasör mantığına göre test isimli dizin altına alabiliriz (Hatta aslında uygulama kodlarını app isimli bir klasörde tutmak da önerilmekte) Mocha bu durumda test dosyasının adını belirtmemize gerek kalmadan test klasöründe ne var ne yok çalıştırabilir.

```javascript
var fermat=require('../mathForKids');
var assert=require('assert');

describe('Math for kids',function(){
    describe('#Synchronous test',function(){
        it('should return 4 when the x=2 and y=2',function(){
            assert.equal(fermat.sumSync(2,2),4);
        });
        it('should throw exception when all values are negative',function(){
            assert.throws(function(){
                fermat.sumSync(-1,3);       
            },/positive/);  
        })
    });
    describe('#Asynchronous test',function(){
        it('should return 4 when the x=2 and y=2',function(completed){
            fermat.sum(2,2,function(err,result){
                assert.equal(result,4);
                completed();
            });
        });
    });
});
```

Temel olarak bu senaryoda 3 test vakamız var. Bunlar iki ana başlık altında toplanıyor. Nitekim bu iki ana başlık da aslında bir program koduna ait. describe fonksiyonunun kullanımına dikkat edelim. İçiçe basit bir ağaç modeli söz konusu. Node.js veya javascript'çilerin aşina olduğu üzere biraz da Christmas Tree probleminin oluşmasına neden olabilecek türde bir yazım söz konusu belki ama üç seviyede tamamlandığını ifade edebiliriz. describe metodu ile bir test tanımı yapıyor ve içerisinde uygulanacak fonksiyonelliği bildiriyoruz (İkinci parametrelere dikkat)

Uygulamayı iki test dalına kırdık. Biri senkron diğeri asenkron fonksiyon testleri için. it fonksiyon bildirimi ile başlayan kısımlar ise "eğer böyle böyle ise şöyle bir şey olmasını bekliyorum" tadındaki açıklamalar ile başlıyor. Tahmin edeceğiniz üzere describe ve it fonksiyonlarındaki ilk parametreler arayüze yansıyacaklar.

Gelelim test iddialarımızı nasıl uyguladığımıza. İlk örneğimizde Node.js ile birlikte gelen (built-in) assert modülünü kullanarak ilerledik. İlk test maddesinde 2 ve 2nin toplamını 4 olarak beklediğimizi ifade ediyoruz. İkinci test iddiamız ise x veya y değerlerinden herhangi birinin negatif olması halinde içerisinde 'positive'kelimesi geçen bir hata mesajı almayı beklediğimiz yönünde.

Son test iddiamız da yine 2 ile 2nin toplamının 4 olduğu üzerine. Lakin burada asenkron çalışan sum metodunun bir test vakasında nasıl kullanılacağı ele alınmakta. Dikkat edileceği üzere senkron metod kullanımından farklı olarak önce asenkron fonksiyonun çağırılması ve ilgili iddianın callback fonksiyonu içerisinde değerlendirilmesi söz konusu. Malum bu asenkron çalışan bir fonksiyonellik olduğundan, ürettiği çıktıları ancak callback fonksiyonunun devreye girdiği yerde test edebiliriz.

Şimdi testimizi çalıştıralım. Tek yapmamız gereken terminalden aşağıdaki komutu işletmek.

```bash
node node_modules/.bin/mocha
```

![mocha nizi nodejs ile alir miydiniz 01](/assets/images/2018/mocha-nizi-nodejs-ile-alir-miydiniz-01.png)

,

Test sonuçlarına dikkat edecek olursak describe fonksiyonlarındaki girinti yapısına göre bir sıralama yapıldığını, it fonksiyonlarının da başarılı veya başarısız olduklarına dair işaretlendiklerini görebilirsiniz. Bence gayet hoş bir görüntü (Tabii Visual Studio'nun yıllardır kullandığımız Test penceresi ve kolaylıkları düşünüldüğünde biraz yavan kalıyor olabilir)

Bu arada testi çalıştırmak için kullandığımız komut biraz uzun. Linux gibi bir platformda bu şekilde yürütülebiliyor. Ancak daha şık bir çalıştırma tekniği de var. Öncelikle bir package.json dosyasını üretmemiz ve içerisindeki test niteliğinin değerini mocha olarak belirlememiz gerekiyor. package.json üretimi için

```bash
npm init
```

terminal komutundan yararlanabiliriz. Bu komutu çalıştırdığımızda bir kaç soru ile karşılaşacağız. Ben sorulara verdiğim cevaplar sonrasında aşağıdaki package.json içeriğinin üretilmesini sağladım. Uygulamanın adı, versiyonu, kısaca ne yaptığı, giriş kod dosyası, içerdiği klasörler, var olan bağımlılıklar, betikler vs...

```json
{
  "name": "testing",
  "version": "1.0.0",
  "description": "testing with mocha and should",
  "main": "mathForKids.js",
  "directories": {
    "test": "test"
  },
  "dependencies": {
    "should": "^13.2.1"
  },
  "devDependencies": {
    "mocha": "^5.0.5"
  },
  "scripts": {
    "test": "mocha"
  },
  "keywords": [
    "testing",
    "mocha",
    "should"
  ],
  "author": "burak selim senyurt",
  "license": "ISC"
}
```

Konumuz gereği buradaki en önemli kısım test niteliğinin değeri aslında. Bu niteliğe atanan mocha değerine göre artık uygulama testlerini aşağıdaki basit komut ile çalıştırabiliriz.

```bash
npm test
```

Should İşleri Eğlenceli Hale Getiriyor

Şimdi should çatısını işin içerisine katalım ve test kodlarını daha eğlenceli hale getirelim. Çok seveceksiniz. Ben bayıldım:) Nitekim baya baya konuşur gibi test senaryolarımızı yazmamız mümküm. Bağlaçlar ve fiiller ile bir cümleyi test iddiası olarak sunabiliyoruz. Nasıl mı? İşte test kodlarımızın yeni hali.

```javascript
var fermat=require('../mathForKids');
var should=require('should');
//var assert=require('assert');

describe('Math for kids',function(){
    describe('#Synchronous test',function(){
        it('should return 4 when the x=2 and y=2',function(){
            var result=fermat.sumSync(2,2);
            result.should.equal(4);
        });
        it('should throw exception when all values are negative',function(completed){
            fermat.sum(1,-3,function(err,result){
                should.exist(err);
                should.not.exist(result);
                completed();
            });
        })
    });
    describe('#Asynchronous test',function(){
        it('should return 4 when the x=2 and y=2',function(completed){
            fermat.sum(2,2,function(err,result){
                should.not.exist(err);
                (4).should.equal(4);
                completed();
            });
        });
        it('should return 8 and be a number',function(completed){
            fermat.sum(3,5,function(err,result){
                result.should.be.exactly(8).and.be.a.Number();
            });
            completed();            
        });
    });
});
```

Görüldüğü üzere her şey should emri ile başlıyor. should çağrısını bir nesneye uygulamaya başladığımız yerden itibaren çeşitli fonksiyon zincirleri oluşturarak test kabullerimizi geliştirebiliyoruz. Söz gelimi ilk test vakamızda sonucun 4 olmasına yönelik beklentimizi should.equal söz cümlesi ile belirtmekteyiz (Evet evet ne dediğinizi duyar gibiyim. "assert.equal ile aynı şey yahu bu") Takip eden diğer test metodunda arka arkaya iki cümle söz konusu. Buradaki senaryo eksi bir değer olması halinde hata fırlatılmasını bekliyor. İlk olarak err nesnesinin var olduğunu, sonrasında ise bir sonuç döndürülmemesini beklediğimizi should.exist ve should.not.exist cümleleri ile belirtmekteyiz. Asenkron fonksiyon testlerimizde de benzer cümleler söz konusu. Özellikle son test vakasında ki cümle gerçekten kayda değer. "sonuç kesinlikle 8 ve bir sayı olmalı" gibisinden bir ifade söz konusu. Test kodumuzu bu şekilde çalıştırdığımızda aşağıdaki ekran görüntüsünde yer alan sonuçları elde ettiğimizi görebiliriz.

Should çatısında daha pek çok yardımcı bağlaç var. Bunlar arasında.an,.of,.a,.and,.be,.have,.with,.is,.which gibi fonksiyonellikler yer alıyor.

![mocha nizi nodejs ile alir miydiniz 02](/assets/images/2018/mocha-nizi-nodejs-ile-alir-miydiniz-02.png)

> Size tavsiyem Fluent Interface vb terimleri araştırarak bu tip bir fonksiyon zincirini nasıl yazabileceğinize bir bakmanız. Hazır çatıları kullanmak elbette işin kolay kısmı ve amaç test senaryolarını işletmekse tekerleği yeniden keşfetmeye gerek yok. Ancak işin aslı, "bu adamlar bunu nasıl yapıyor yahu?" diyerek incelemenin de bireysel gelişim anlamında çok değerli bir katkısı olacağı.

## Ya Kendi Assertion Fonksiyonumuzu Eklemek İstersek

Bu noktada da should çatısı güzel bir genişleyebilirlik sunmakta. Aşağıdaki kod parçasını ele alalım.

```javascript
var fermat = require('../mathForKids');
var should = require('should');

should.Assertion.add('odd', function () {
    this.params = { operator: 'is a odd number', expected: true };
    ((this.obj % 2) == 1).should.exactly(true);
});

describe('Math for kids', function () {
    describe('#custom Assertions', function () {
        it('sum should be a odd number for result 5', function () {
            var result=fermat.sumSync(1,4);
            result.should.be.a.odd();
        });
        it('sum should be a odd number for result 6', function () {
            var result=fermat.sumSync(2,4);
            result.should.be.a.odd();
        });
        it('sum should not be a odd number for result 6', function () {
            var result=fermat.sumSync(2,4);
            result.should.not.be.a.odd();
        });
    });
});
```

![mocha_4.gif](/assets/images/2018/mocha_4.gif)

İlk olarak should.Assertion.add fonksiyonu ile yeni bir tanımlama ekliyoruz. odd isimli fonksiyonu bir sayının tek olup olmadığını anlamak istediğimiz durumlar için kullanacağız. params ile test çalışma zamanı ortamına bir takım bilgiler bırakabiliyoruz. Açıklama ve beklenen sonuç gibi. Fonksiyon içerisinde this.object kullanarak gerçekleştirdiğimiz bir kontrol söz konusu. Dikkat edeceğiniz üzere burada da should fonksiyonundan yararlanıyor ve savımızın beklediğimiz sonucunu kontrol ediyoruz. 3 durumu test ettik. Tek sayı olma hali, tek sayı beklediğimiz halde tek sayı olmama hali, tek sayı beklemediğimiz bir çift sayı olma hali ve olmak ya da olmamak...Ehm...Pardon:) Sonuçta kendi assertion fonksiyonumuzu should çatısına nasıl ekleyebileceğimiz gördük. Hatta burada odd yerine tekSayi gibi kendi dilimizde ifadeler de ekleyebiliriz diye düşünüyorum (Şimdi Seleniumcuları daha iyi anlamaya başladım)

## Sizin için

Yazıyı sonlandırmadan önce aşağıdaki ekran görüntüsüne bir bakalım istiyorum.

![mocha_5.gif](/assets/images/2018/mocha_5.gif)

Dikkatinizi çeken bir şeyler mutlaka var değil mi? Her şeynde önce orada küçük bir uçak figürü var. Ayrıca "1 pending" şeklinde bir ifade de bulunuyor. İşin aslı mocha paketi içerisine testi eğlenceli hale getirmek için konulmuş bir düzeneğin sonucu olarak bir uçak figürü var. Hatta uçak figürünün olduğu yer uçak pistimiz:) Peki bu nasıl mümkün oldu? Peki uçağın rengi neden kırmızı. Acaba tüm testler yeşil ışık yakarsa rengi değişecek mi? İşte size güzel biraz araştırma konusu. Uçağın nasıl çıktığna dair bir ipucu fotoğrafta var. Onu nereye yazacağınızı da bulmanız gerekiyor tabii. "1 pending" ise geçici süreliğine atlanan bir test durumu için oluştu. Bunun için de it metodunun arkasından gelebilecek fonksiyonellikleri araştırmakta yarar var. Haydi kolay gelsin.

Test Sonuçlarını Tarayıcıda Göstermek

Şimdi aşağıdaki ekran görüntüsüne bakmanızı rica ediyorum.

![mocha nizi nodejs ile alir miydiniz 03](/assets/images/2018/mocha-nizi-nodejs-ile-alir-miydiniz-03.png)

Bu görüntü komut satırındaki test çıktılarına göre daha hoş değil mi? Peki nasıl oluştu merak ediyor musunuz? Haydi gelin anlatayım. Mocha ve Should dokümanları arasında gidip gelirken Chai isimli alternatif bir BDD çatısının da kullanılabileceğini öğrendim. Chai çatısı için verilen örnekte test sonuçlarının tarayıcı penceresine yansıtıldığına dair bir kod parçası da bulunuyordu. Bense Should çatısını kullanarak bu işi yapmak istiyordum. Ancak denemelerimi yaparken oluşturduğum test klasörü bir şekilde beni CORS hatasına doğru sürükleyip duruyordu. Umutsuzluğa kapılmaya başlamıştım. Sonunda pes edip tüm dosyaların aynı klasörde yer aldığı yeni bir örnek üzerinde çalışmaya karar verdim.

```text
mathForKids.js
mathForKids.test.js
index.html (Biraz sonra değineceğiz)
```

Yine mathForKids.js içeriğini kullanıyordum ancak bu kez en sonda yer alan module.exports bildirimlerinin tamamını kaldırarak ilerlemeyi tercih ettim. Sonrasında test dosyasını yine aynı klasörde olacak şekilde mathForKids.test olarak değiştirdim ve içeriğini güncelledim. Buna göre tüm require bildirimlerini ve fermat nesnesini kaldırdım. Module ile test dosyası aynı klasörde yer aldıklarından dosya adı formatına göre test dosyası içerisinden sum ve sumSync fonksiyonları doğrudan kullanılabilirlerdi. Sonuç olarak yeni örnek test dosyası içeriğim şuna benziyordu.

```javascript
should.Assertion.add('odd', function () {
    this.params = { operator: 'is a odd number', expected: true };
    ((this.obj % 2) == 1).should.exactly(true);
});

describe('Math for kids', function () {
    describe('#custom Assertions', function () {
        it('sum should be a odd number for result 5', function () {
            var result=sumSync(1,4);
            result.should.be.a.odd();
        });
        it('sum should be a odd number for result 6', function () {
            var result=sumSync(2,4);
            result.should.be.a.odd();
        });
        it('sum should not be a odd number for result 6', function () {
            var result=sumSync(2,4);
            result.should.not.be.a.odd();
        });
    });
    describe('#Synchronous test', function () {
        it.skip('should return 4 when the x=2 and y=2', function () {
            var result = sumSync(2, 2);
            result.should.equal(4);
        });
        it('should throw exception when all values are negative', function (completed) {
            sum(1, -3, function (err, result) {
                should.exist(err);
                should.not.exist(result);
                completed();
            });
        })
    });
    describe('#Asynchronous test', function () {
        it('should return 4 when the x=2 and y=2', function (completed) {
            sum(2, 2, function (err, result) {
                should.not.exist(err);
                (4).should.equal(4);
                completed();
            });
        });
        it('should return 8 and be a number', function (completed) {
            sum(3, 5, function (err, result) {
                result.should.be.exactly(8).and.be.a.Number();
            });
            completed();
        });
    });
});
```

Test sonuçlarını tarayıcıda göstermek için basit bir HTML sayfası oluşturulması yeterliydi. Sadece onu çalıştırdığımızda gerekli testleri yapacak ve sonuçları tarayıcıya basacak şekilde güdümlemek gerekiyordu. Bu dosyanın şablon yapısı mocha dokümantasyonunda belirtildiği gibi oluşuturulsa bu mümkündü. Bir kaç deneme ve yanılma sonrası aşağıdaki index.html içeriğinin yeterli olduğunu keşfetmeyi başardım.

```html
<meta charset="utf-8">
<title>Mocha Tests</title>
<link href="https://unpkg.com/mocha@4.0.1/mocha.css" rel="stylesheet" />
</head>

<body>
    <div id="mocha"></div>

    <script src="https://unpkg.com/should@13.2.1/should.js"></script>
    <script src="https://unpkg.com/mocha@4.0.1/mocha.js"></script>

    <script>mocha.setup('bdd')</script>
    <script src="mathForKids.js"></script>
    <script src="mathForKids.test.js"></script>

    <script>
        mocha.checkLeaks();
        mocha.run();
    </script>
</body>

</html>
```

Sayfada dikkat çekici noktalardan birisi [unpkg](https://unpkg.com/#/) adresine yapılan bağlantılar aslında. CSS, Mocha ve Should paketleri için benzer formatta tanımlamalar mevcut. unpkg'nin çok basit bir kullanımı var. Npm'de yüklü olan her paket için internetten kullanılabilecek bir adres desteği sunduğunu ifade edebiliriz. Bunun için kendi lokal dosyamızda unpkg.com/:package@:version/:file şeklindeki formatı kullanmak yeterli. should ve mocha paketlerine ait javascript bağlantılarının nasıl verildiğine bu anlamda dikkat edelim. Tabii bir kaç başlangıç ayarı yapmak da gerekiyor. Örneğin setup çağrımı ile BDD modeline göre bir çalışma zamanı ortamı hazırlanacağını belirtiyoruz. Sonrasında mathForKids ve mathForKids.test dosyalarının bildirimi yapılıyor ki bu sayede hangi test içeriğinin çalıştırılacağı ve o test içeriğinde kullanılan ek modüller varsa onların neler olduğunu belirtmiş oluyoruz. Bu HTML dosyasını tarayıcıda açtığımızdaysa son script bloğunda yer alan kodlar işletiyor ve test, başlatılıyor. Hepsi bu:)

Pek tabii mevzu benim burada anlattığım kadar yalın değil. Yapılabilecek bir çok şey var. Tabii hangi çatı olursa olsun test yazma alışkanlığı kazanmak da mühim bir mesele bana kalırsa. Bu dediğimi lütfen dikkate alın. Hem siz hem de sizden sonra o pozisyonda görev alacak insanlar zorlanmasınlar;) Böylece geldik bir makalemizin daha sonuna. Pluralsight'tan bakalım bana ne kadar ekmek çıkacak. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

### Kaynaklar

[https://github.com/shouldjs/should.js/](https://github.com/shouldjs/should.js/)

[https://mochajs.org/](https://mochajs.org/)
