---
layout: post
title: "Express API Hizmetini Heroku Üzerine Taşımak"
date: 2018-04-07 19:00:00
categories:
  - Web Programlama
tags:
  - heroku
  - cloud-computing
  - paas
  - dyno
  - platform-as-a-service
  - node
  - node.js
  - npm
  - github
  - git
  - cli
  - command-line-interface
  - linux
  - ubuntu
---
Geçenlerde sevgili çalışma arkadaşlarımdan [Atahan Ceylan](https://www.linkedin.com/in/atahanceylan/) ile Node.js ve MongoDb üzerine konuşurken bana Heroku diye bir şeyden bahsetti. Daha önceden duymamış olmamın verdiği etkiyle hemen nedir ne değildir diyerek kendisinden bilgi istedim. Sonunda konuyu pekiştirmek için ninjaları bana sevimli bir şekilde hatırlatan bu ürünü incelemeye karar verdim.

![herokus_intro.gif](/assets/images/2018/herokus_intro.gif)

Heroku'unun başlangıç rehberlerinden yararlanarak bir senaryo seçtim. Amacım Node.js'de çok ilkel (amaç taşıma işlemini adımlamak olduğu için çok karmaşık olmamasında yarar var) bir REST servisi yazıp bunu Heroku üzerine taşımak. Söz konusu servisi geliştirirken express paketinden de yararlanacağız. Bu sayede bağımlı bir paketin taşınması durumunu da ele almış olacağız. Tabii öncesinde Heroku hakkında kısa bir bilgi vermekte fayda var.

## Heroku. Hiyaaaa

Geliştiriciler için kullanımı kolay bir PaaS (Platform as a Service) ürünü desek sanıyorum yeridir. Container tabanlı olarak çalışan Heroku yazının ilerleyen safhalarında kısa bir atıfta bulunacağımız Dyno adı verilen Linux temelli sanal ortamlar kullanmakta. Bunlar başlangıç kapasiteleri itibariyle oldukça hafif ve hızlı taşıyıcılar. Geliştirdiğimiz uygulamaları Heroku üzerine taşıyıp yayınlayabiliyor, ölçeklenmeleri ile ilgili yönetimsel işlemleri basitçe gerçekleştirebiliyoruz. Çok doğal olarak diğer bulut bilişim hizmetlerinde olduğu gibi sistemsel bir takım yönetimsel işlemleri düşünmemize de gerek kalmıyor.

Heroku Node.js, Ruby, Python, Go, Java, Php, Scala ve Clojure dillerine doğrudan destek veriyor. Yani bu ortamların güncellemeleri takip edildiği için her an son sürümle çalışmamız mümkün. Yazıyı hazırladığım tarih itibariyle Heroku'ya abone olduktan sonra Free Plan'ı kullanmaya başladım. 512 mb ram barındıran, 1web/1worker tipinden çalışma modeli sunan, 30 dakika etkin olmadığından uyku moduna geçen sevimli minik bir dyno ortamım oldu. Gelin şimdi bu basit ortamı kullanarak senaryomuzu gerçekleştirmeye çalışalım.

> Heroku üzerinde kullanılabilecek bir çok ek hizmet (Add-On) bulunuyor. [Şuradaki adresten](https://devcenter.heroku.com/categories/add-ons) de görebileceğiniz paketleri incelemenizi öneririm. Bu paketlerde Heroku'nun kendisi veya 3ncü parti ortakları tarafından geliştirilmiş çeşitli bileşenler, servisler ve altyapı araçları yer almakta. Belki de bir sonraki adımınız benim yapacağım gibi mLab MongoDb'yi kullanarak Node.js servisini veritabanı ile ilişkilendirmek olacaktır (Free Plan paketi bu tip araştırmalar için oldukça yeterli görünüyor)

## Ön gereksinimler

Servis, West-World üzerinde geliştirilecek. Artık aşina olduğunuz üzere West-World, Ubuntu 16.04 temelli bir Linux çekirdeğine sahip. Platform bağımsız olarak sahip olmamız gereken başka enstrümanlar da var. Node (bu senaryo özelinde), npm ve git. West-World üzerinde bunların aşağıdaki sürümleri kullanılıyor.

```bash
node -v
npm -v
git --version
```

![herokus_1.gif](/assets/images/2018/herokus_1.gif)

## Taşınacak Servis Uygulamasının Geliştirilmesi

Ben Node.js projesini oluşturmak için Visual Studio Code arabirimini kullanıyorum. Servis tarafındaki işlerimizi kolaylaştırması açısından Express paketinden yararlanabiliriz. Paket izleyen terminal komutu ile yüklenebilir.

```bash
npm install express
```

personal_board.js olarak isimlendirdiğim kod dosyasının içeriği aşağıdaki gibi geliştirilebilir.

```javascript
var express = require('express');
var app = express();
var fs = require('fs');

// HTTP Get
app.get('/api/tasks', function (request, response) {
    fs.readFile('daily_task.json', 'utf8', function (err, data) {
        console.log('%s:%s', Date(), request.url);
        response.end(data);
    });
});

var server = app.listen(process.env.PORT || 8080, function () {
    console.log('Sunucu dinlemde');
});
```

Tipik olarak tek bir HTTP Get talebine (/api/tasks) hizmet verecek bir servis söz konusu. Buraya gelen taleplere karşılık olarak daily_task.json dosyasındaki içeriği istemci tarafına göndermekteyiz. Dosya okuma işlemi için fs modülünün readFile fonskiyonundan yararlanılıyor. Ayrıca console'a talebin yapıldığı tarih ve url bilgisini basıyoruz.

Dikkatinizi çeken bir kısım mutlaka olmuştur. app.listen fonksiyonunda 8080 veya process.env.PORT ile belirtilen bir portun kullanılacağı belirtilmekte. 8080i (başka bir port da olabilir) yerel testlerde kullanacağız. Diğer parametre ise servisi heroku üzerine taşıdığımızda işe yarayacak. Heroku dünyasında mevcutta kullanılabilir port bilgisi neyse, otomatik olarak atanacak. Bu işlemi yapmadığımızda "Error R10 (Boot timeout) -> Web process failed to bind to $PORT within 60 seconds of launch" şeklinde bir hata mesajı ile karşılaşmamız söz konusu ki ben karşılaştım. Ah unutmadan. daily_taks.json dosyasını aşağıdaki haliyle kullanabilirsiniz.

```json
{
    "task1": {
        "title": "Finish front-end login control test",
        "category": "Testing",
        "status": "todo",
        "id": 22325
    },
    "task2": {
        "title": "Back button issue",
        "category": "Bug Fix",
        "status": "in progress",
        "id": 12342
    },
    "task3": {
        "title": "Connect with SSO Service",
        "category": "Service Integration Development",
        "status": "epic",
        "id": 14345
    },
    "task4": {
        "title": "Design of web app's help page",
        "category": "Front-end Development",
        "status": "todo",
        "id": 18123
    },
    "task5": {
        "title": "Complete wheter api service",
        "category": "Service API Development",
        "status": "epic",
        "id": 48545
    }
}
```

## Yerel Ortam Testleri

Kodlarımız hazır. İlk etapta söz konusu servisin West-World üzerinde çalışıp çalışmadığından emin olmakta yarar var. Siz de kendi kodunuzu test ederseniz iyi olacaktır. Test önemli bir şey:)

```bash
node personal_board.js
```

![express api hizmetini heroku uzerine tasimak 01](/assets/images/2018/express-api-hizmetini-heroku-uzerine-tasimak-01.png)

## Procfile Eklenmesi

Artık ufaktan Heroku ortamı için gerekli hazırlıkları yapmaya başlayacağız. Diğer pek çok bulut platformunda olduğu gibi, taşıma ortamına özel hazırlanan bazı dosyalara ihtiyacımız olacak. Nitekim hedef sunucunun hangi kodu nasıl çalıştıracağını, uygulama için gerekli harici paketler varsa bunların ne olduğunu ya da hangi sürümlerini yükleyeceğini bilmesi lazım. Bu genel geçer bir kural olarak karşımıza çıkıyor. Heroku için de Procfile isimli bir dosya ekleyerek devam edelim.

Procfile aslında Process anlamına gelen uzantısız bir dosya. Visual Studio Code üzerinde geliştirme yapıyorsanız dosyayı ekler eklemez Heroku logosunun dosya ile ilişkilendirileceğini de fark edeceksiniz. İçeriğini şu anda aşağıdaki tek satırla oluşturabiliriz.

```text
web: node personal_board.js
```

Bu bildirim ile single process type tanımlıyoruz. web komutu gereği node personal_board.js şeklinde bir terminal komutu çalışacak ve sonrasında oluşacak process, Heroku'nun HTTP Routing kanalına bağlanacak. Böylece Heroku üzerindeki api/tasks ve benzeri talepler Node.js process'ine yönlendirilecek (İstenirse bu dosyada birden fazla process bildirimi de yapılabiliyormuş. Örneğin bir arkaplan process'i tanımlanıp planlanmış görevlerin işletilmesi sağlanabilirmiş. Denemedim ama Heroku diyorsa doğrudur)

> Procfile dosyası aslında Heroku tarafındaki dyno ortamlarını ilgilendirir. Dyno'ların hafif birer taşıyıcı (lightweight container) olduğundan bahsetmiştik. `heroku ps:scale` gibi terminal komutları yardımıyla Dyno'ların sayısını arttırabilir ve bu şekilde ölçeklendime işlemleri gerçekleştirilebilir.

## Heroku CLI'ın Yüklenmesi ve Taşıma Operasyonu

Taşıma işlemlerini terminalden gerçekleştireceğiz. Bu nedenle bize bir Command Line Interface lazım. Tabii öncesinde eğer yoksa bir Heroku hesabının açılması da gerekiyor. Hesap açma işlemi oldukça basit. Bir email doğrulaması yeterli oluyor. Üstelik diğer bir çok bulut hizmet sağlayıcı gibi hemen kredi kartı bilgisi de istenmiyor (Hemen istemiyor en azından. Ama örneğin yazıdan sonra MongoDb için bir AddOn yüklemek istediğimde beni kredi kartı bilgimi doğrulatmam gerektiğine dair uyardı. Sandbox isimli free planı seçmiş olmama rağmen)

Hesap açma işlemini takiben terminal'den heroku ile ilgili işlemleri yaptırabilmek için Heroku CLI (Command Line Interface) arabiriminin yüklenmesi adımına geçebiliriz. Ubuntu için aşağıdaki komutlar yeterli. Pek tabii güncel komutlar için Heroku'nun resmi dokümanlarına bakmakta yarar var.

```bash
sudo add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install heroku
```

Eğer işler yolunda giderse versiyon numarasını alabiliyor olmamız gerekir. West-World şu anda Heroku CLI'ın 6.15.26-5726b6f versiyonuna sahip.

![herokus_2.gif](/assets/images/2018/herokus_2.gif)

Artık sisteme Login olabilir ve Heroku üzerinde uygulamamızı (uygulamalarımızı) taşıyacağımız projeyi oluşturabiliriz. login ve create komutları sırasıyla bu işler için.

```bash
heroku login
heroku create
```

![herokus_4.gif](/assets/images/2018/herokus_4.gif)

login sırasında, Heroku'ya kayıt olurken kullandığınız bilgiler geçerli olacaktır. Oluşan uygulama Heroku web control panel üzerinden de görülebilir. Benim yazıyı yazdığım tarih itibariyle bu oluşturduğum ikinci projeydi. İlki uyku moduna geçmiş durumda. Bunun sebebi de Freeplan'a göre söz konusu uygulamaya belli bir süre talep gelmeyince (bu zamanlar 30 dakika olarak belirlenmiş) uyku moduna geçmesi. West-World için Heroku'nun oluşturduğu projenin adı fierce-earth-61739. Siz dilerseniz kendi proje adınızı da kullanabilir veya sistemin vereceği bu tutarlı atışları değerlendirebilirsiniz.

![herokus_5.gif](/assets/images/2018/herokus_5.gif)

## Package.json Dosyasının Eklenmesi

Proje'nin package.json dosyasının içeriği Heroku açısından önemlidir. Örneğimizde dikkat edeceğiniz üzere express isimli harici bir paket kullanıldı. Heroku'nun bunu biliyor olması lazım. Üstelik uygulamamıza ait bir takım tanımlayıcı bilgileri (versiyon numarası, aramalarda değer kazanacak keyword'ler, açıklama, yazar, giriş sayfası vb) Heroku'ya söylememiz gerekiyor. Şu anda uygulamada package.json dosyası yok. Varsayılan haliyle oluşturmak için

```bash
npm init --yes
```

terminal komutundan yararlanılabilir. Sonrasında dosya içeriğini ben aşağıdaki gibi düzenledim.

```json
{
  "name": "fierce-earth-61739",
  "version": "1.0.0",
  "description": "a simple rest api for homeworks",
  "main": "personal_board.js",
  "dependencies": {
    "express": "^4.16.2"
  },
  "devDependencies": {},
  "scripts": {
    "start": "node personal_board.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "repository": {
    "type": "git",
    "url": "https://git.heroku.com/fierce-earth-61739.git"
  },
  "keywords": [
    "daily",
    "tasks",
    "scrum",
    "board",
    "node.js",
    "express",
    "rest"
  ],
  "author": "burak selim senyurt",
  "license": "ISC"
}
```

Dikkat edileceği üzere git repository bilgisinden, yazara, script'in nasıl başlatılacağından bağımlılık oluşturan express paketi ve versiyonuna kadar gerekli ne kadar bilgi varsa burada yer alıyor. Bu arada projedeki git repo bilgisinin Heroku için üretilen adres neyse ona göre güncellenmesi de önemli.

## Git Repo'sunun Oluşturulması,Commit ve Deploy

Artık git ile kaynak kod işlemlerine geçebiliriz. Öncelikle proje klasörüne gidilir ve yeni bir Git repository oluşturulur.

```bash
git init
heroku git:remote -a fierce-earth-61739
```

Sonrasında klasör içeriği repo'ya eklenir ve commit işlemi icra edilir. Artık kodlar onaylandığına göre Heroku üzerine uygulama deploy edilebilir. Terminal komutlarımız aşağıdaki gibi.

```bash
git add .
git commit -am "first deploy of personal board api service"
git push heroku master
```

> Örnek senaryomuzda CLI üzerinden Heroku Git kullanılarak bir taşıma işlemi yapılıyor. Lakin farklı metodolojileri de kullanabiliriz. Github'a bağlanarak, Dropbox'tan yararlanarak ve yine CLI üzerinden var olan bir docker imajını kullanarak söz konusu taşıma işlemleri yapılabilir.

Taşıma işlemleri sırasında olup biteni merak ediyorsanız gerek terminalden gerekse web arabiriminden sonuçları görmemiz mümkün. Söz gelimi web arabiriminde more->view logs kısmını kullandığımızda aşağıdakine benzer bir ekran görüntüsü ile karşılaşabiliriz. Eğer işler yolunda gittiyse uygulamanın da ayağa kalkmış olması beklenir.

"Sunucu dinlemede" yazan kısma dikkat;)

![herokus_6.gif](/assets/images/2018/herokus_6.gif)

Yine de taşımanın kontrol edilmesinde fayda var. İlk etapta dyno tarafı için bir ölçekleme işlemi yapılması öneriliyor. Sonrasında gelen open komutu ile local sistemde bir tarayıcı açılıyor.

```bash
heroku ps:scale web=1
heroku open
```

> Heroku'da uygulamalar Dyno adı verilen Container'lara alınır. Dyno'lar birbirlerinden izole olacak şekilde çalışan Linux tabanlı sanal taşıyıclardır ve Heroku'nun kalbinde çok önemli bir yere sahiptir (Detaylı bir bilgi olduğu için yazının güncel konusu dışında kalıyor ama [şu adresten](https://www.heroku.com/dynos/) daha fazlası öğrenilebilir)

open komutu doğrudan tarayıcı penceresini açacak ve bizi projenin giriş url'ine yönlendirecektir.

![herokus_7.gif](/assets/images/2018/herokus_7.gif)

Tahmin edeceğiniz üzere bir sonuç gelmemesi normal. Çünkü doğru HTTP Get talebini yapmış olmak gerekiyor.

`https://fierce-earth-61739.herokuapp.com/api/tasks`

gibi. Volaaaa!!!

![herokus_8.gif](/assets/images/2018/herokus_8.gif)

Bu esnada oluşan işlemleri canlı olarak takip etmek terminalde aşağıdaki komutu vererek izlemede kalabiliriz.

```bash
heroku logs --tail
```

![herokus_9.gif](/assets/images/2018/herokus_9.gif)

Çok doğal olarak bu tip test uygulamalarını işlerimizi bitirdikten sonra silmekte yarar var. Projenin ayarlar kısmında bir Delete düğmesi bulunuyor. Bu iş için kullanabiliriz.

> Küçük bir ipucu verelim. Heroku üzerinde host edilen bir servisi farklı bir domain'den çağıracağımız zaman CORS-Cross Origin Resource Sharing sorunu ile karşılaşabiliriz. Firefox özellikle bu konuda çok katı. [Şu adreste](/2017/12/29/cors-cross-origin-resource-sharing/).Net Core tarafında CORS konusunun ele alınışı var. Faydası olabilir tabii sizin kendi ortamınız için gerekli aksiyonu almanız lazım.

Sonuç itibariyle geliştireceğimiz çeşitli tipteki web uygulamalarını Heroku üzerine almak görüldüğü üzere oldukça kolay. Heroku, bizlere geliştirici dostu bir PaaS ortamı ve kullanımı sunuyor. Desteklediği diller ve platformlar düşünüldüğünde aslında startup'lar ve özellikle hackathon tarzı yarışmalar için tercih edilmesi ideal gibi görünüyor.

Bu yazımızda Node.js ile yazılmış basit bir servisi heroku üzerine nasıl alabileceğimizi adımlamaya çalıştık. Pek tabii uygulamanın daha farklı şekilde geliştirilip çalışmanın heyecanlı hale getirilmesi sağlanabilir. Örneğin mongodb gibi bir veritabanı ile çalışacak şekilde tasarlanıp Post, Put, Delete, Get ve türevi HTTP taleplerine hizmet verecek hale getirilmesi ve sonrasında Heroku'ya taşınarak kullandırılması güzel bir haftasonu çalışması olabilir. Anladınız siz:)

Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

### Kaynaklar

[Node-js Getting Started](https://github.com/heroku/node-js-getting-started)
[Getting started with node.js (Introduction)](https://devcenter.heroku.com/articles/getting-started-with-nodejs#introduction)
[Dynos](https://www.heroku.com/dynos/)
