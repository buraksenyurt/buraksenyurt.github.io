---
layout: post
title: "Hackathon'dan Node.js'i Tanımaya"
date: 2018-03-12 03:00:00
tags:
  - node.js
  - javascript
  - Framework
  - script-languages
  - vs-code
  - callback
  - repl
  - asynchronous-programming
  - functional-programming
  - module
  - built-in-module
  - npm
  - linux
  - ubuntu
categories:
  - Web Programlama
---
Javascript yüzyıllardır (abartmayı severim) front-end tarafında kullanılan en güçlü yazılım geliştirme dillerinden birisi. Bir web uygulamasını onsuz düşünmek neredeyse imkansız. Her ne kadar Typescript gibi oluşumlar söz konusu olsa da, Javascript'in yeri ayrı. Javascript dilini baz alan bir çok Framework (çatı) de uzun zamandır sektörümüzde yer almakta. Hatta bazıları tamamen sunucu bazlı çalışacak şekilde tasarlanmış durumdalar. Node.js bunlardan birisi.

![nodejs_2.gif](/assets/images/2018/nodejs_2.gif)

Onunla kesişmem çalışmakta olduğum firmadaki bir kaç sevgili dostumun katılacağı [hackathon](http://hackathon.getir.com/) yarışması sayesinde oldu. Yarışmaya katılımın ön koşulu olarak bir problemin çözülmesi gerekiyordu. Katılımcılar isterlerse Node.js, MongoDb ve Heroku kullanılarak bu görevi gerçekleştirebilirlerdi. Kıt kanaat bilgi birikimimle hemen şu Node.js nedir, neler yapılabiliyordur diye bakınmaya başladım. Derken Cumartesi günü kendimi onu tanımaya çalışırken buldum. Şu an için iş yerindeki projelerimizde Node.js ile yürüyeceğimiz bir yol haritamız olmasa da, sunucu taraflı çalışan Javascript temelli bir çatı neymiş öğrenmek istedim. Örnekleri karıştırırken de benim için hızlı bir giriş niteliğinde olan aşağıdaki kod parçası ile işe başladım.

## Kurulumlar

Malum aylardır West-World'de tatildeyim. Bu dünyada Ubuntu kuralları geçerli. Dolayısıyla öncelikli olarak buraya Node.js'in kurulması gerekiyor. Her zaman ki gibi paket listesini güncellemekle işe başlamak lazım. Sonrasında node.js yüklenebilir. npm (Node Packaged Modules) okuduğum kaynaklara göre dünyanın en büyük paket merkezi konumunda. Onu da bir takım paketlerin (mesela rest servisleri için kullanmayı düşündüğüm 'express') sisteme kolayca kurulumu için kullanmayı planladım. Kurulumları başarılı bir şekilde tamamladıktan sonra -v ile versiyon bilgisini de elde edebildiğimi de gördüm. Buraya kadar sizde beni takip ettiyseniz benzer bir görüntü ile karşılaşmanız lazım.

```bash
sudo apt-get update
sudo apt-get install nodejs
sudo apt-get install npm
nodejs -v
```

![nodejs_3.gif](/assets/images/2018/nodejs_3.gif)

Kod yazımı içinse Visual Studio Code'dan yararlandım. Zaten node kod dosyasını görür görmez bir kaç eklenti önerisinde de bulundu. I love Visual Studio Code!

Bu ara bilgilendirmeden sonra aşağıdaki bir kaç kod dosyası ile devam edebiliriz.

## İlk Örnek

Visual Studio Code üzerinde aşağıdaki içeriklere sahip iki js dosyası oluşturarak ilerleyebiliriz. Öncelikle modül kavramını anlamak adına utility.js adından bir dosya oluşturalım. Tahmin edeceğiniz üzere bir modülü, içerisindeki fonksiyonellikleri dışarı açmak suretiyle ortak kütüphane olacak şekilde kullanabiliyoruz. Kaldıki npm tarafına baktığımızda bu şekilde kullanabileceğimiz yüzlerce kütüphane (ya da built-in module) olduğunu söyleyebiliriz.

```javascript
exports.reverse=function(input){
    return input.split('').reverse().join('')
}
```

utility.js içerisinde sadece bir fonksiyon yer almakta. reverse isimli fonksiyonun görevi parametre olarak gelen metni ters çevirip geriye döndürmek. Asıl iş yapan helloworld.js dosya içeriği ise şöyle.

```javascript
var http = require('http')
var url = require('url')
var fs=require('fs')
var utility = require('./utility')

http.createServer(function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.write("<h2>Wellcome to West-World</h2>");
    res.write("<b>" + Date() + "</b><br/>");
    res.write("<i>Request url " + req.url + "</i><br/>");
    var q = url.parse(req.url, true).query
    if (typeof q.nick == 'undefined') {
        console.log("[Error]:%s,URL string'de hata var",Date())
        res.write("<a href='http://localhost:5009/?nick=murdock&point=450'><p style='color:darkgreen'>Try this! ;)</p></a>")
    }
    else {
        res.write("<p style='color:darkblue'>your nickname is " + q.nick + "</p>");
        res.write("<p style='color:magenta;'>or " + utility.reverse(q.nick) + "</p>");
    }
    res.end();
}).listen(5002);

http.createServer(function (request, response) {    
    fs.readFile("intro.html", function (err, data) {
        if (err) {
            console.log("[Error]:%s,%s",Date(),err.message)
            res.status(404).send('Not found')
            response.end()
        }
        else{
            response.writeHead(200, { 'Content-Type': 'text/html' })
            console.log("[Request]:%s,intro.html",Date())
            response.write(data.toString());
            response.end();
        }
    });    
}).listen(5003);
```

Öncelikle burada neler olup bitti kısaca anlatmaya çalışayım. Kod temel olarak 5002 ve 5003 portlardan olacak şekilde iki farklı sunucu dinleme operasyonunu icra ediyor. Her iki operasyonda kullanıcıya HTML içerik döndürmekte. 5002 portu için querystring kullanımı ve HTML içeriğinin kod tarafında inşa edilişi söz konusu. response değişkeni üzerinden çeşitli fonksiyonları kullanarak bu yazma operasyonlarını icra ediyoruz. Querystring parametreleri ve utility sınıfındaki reverse fonksiyonu kullanılarak da sembolik bir içerik basılıyor. 5003 portuna gelen talepleri ise intro.html isimli statik bir HTML sayfası ile karşılamaktayız. Kodun başında diğer platformlardaki import, using gibi bildirimlerden aşina olduğumuz bir kaç tanımlama bulunuyor. Aslında kodda kullanılacak olan modüllerin bildirimi yapılıyor. Sunucu işlemleri için http, dosya okuma işlemi için fs, querystring parametreleri ile çalışmak için url ve son olarakta kendi modülümüzü kullanabilmek için utility modülleri için tanımlamalar söz konusu. Tabii örnekte güzel olan noktalardan birisi http.createServer metodlarının asenkron çalışma modelini desteklemeleri sayesinde programın aynı anda 5002 ve 5003 taleplerini işleyebilecek olması. Kodları geliştirirken bazı ifade sonlarına noktalı virgül koymadığımı mutlaka fark etmişssinizdir. Açıkçası yorumlayıcı bunu önemsemiyor. Bu arada intro.html içeriği de şu şekilde;

```html
<html>

<head>
    <title>Intro Page</title>
</head>

<body style="font-family:Cambria, Cochin, Georgia, Times, 'Times New Roman', serif">
    <h2>Node.js Introduction Tutorials</h2>
    <p style="width:400px;background-color:khaki">At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti
        quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia
        deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio.
        Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere
        possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis
        aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum
        rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus
        asperiores repellat.</p>
    <p>
        <a href="For">https://nodejs.org/en/">For more details...</a>
    </p>
</body>

</html>
```

Lorem Ipsum sitesinden aldığım metinsel bir içeriğin tarayıcıda gösterimi söz konusu. Aslında burası tamamen önyüz. İstediğiniz gibi güçlendirdiğinizde node.js ile ayağa kaldırdığınız harika bir web uygulaması ortaya koymanız mümkün. Bu arada bir node.js dosyasını çalıştırmak için terminalden aşağıdaki gibi bir komut vermek yeterli.

```bash
node helloWorld.js
```

`http://localhost:5003` talebi için sonuç

![nodejs_4.gif](/assets/images/2018/nodejs_4.gif)

`http://localhost:5002/?nick=murdock&point=450` için sonuç,

![nodejs_5.gif](/assets/images/2018/nodejs_5.gif)

ve son olarak querystring bilgisi hatalı olan `http://localhost:5002` için sonuç,

![hackathon dan nodejs i tanimaya 01](/assets/images/2018/hackathon-dan-nodejs-i-tanimaya-01.png)

Elim Node.js ile bir şeyler yazmaya çabuk alıştı diyebilirim. Bunun en büyük sebebi geçen yıl boyunca farklı dilleri ve çatıları tanımaya ve özellikle Linux platformunda bir şeyleri yeniden keşfetmeye çalışmamdır. Sizlere de bu tip bir çalışma planını disiplinli bir şekilde uygulamanızı öneririm.

## Onun Hakkında Neler Söylenebilir?

Yukarıdaki kod parçasından sonra bu çatının genel özelliklerini bilmekte de yarar olduğu kanısındayım. Her şeyden önce Javascript tabanlı bir çatı ya da geliştirme ortamı olduğunu ifade edebiliriz. Bu açıdan fonksiyonel programlama özelliklerini benimseyen ve modüler kod yazılmasını sağlayan bir ortam var. Google Chrome'un performansı oldukça yüksek olan [V8 Javascript motoru](https://developers.google.com/v8/) üzerinde çalışacak şekilde tasarlanmış. En büyük amacı özellikle I/O (non blocking modeli kullanıyor) işlemlerinin çok sık yapıldığı yüksek performans isteyen web uygulamalarının basitçe geliştirilmesi. Single Page Application modeli, Video Streaming sunucuları bunlara örnek olarak verilmekte. Olay güdümlü (Event-Driven) yaklaşımı destekleyen bu çatının ölçeklenebilirliği de güçlü özelliklerinden. Bu özellikleri itibariyle gerçek zamanlı veri sunan uygulamalar için de biçilmiş kaftan olduğunu söyeleyebiliriz. Ryan Dahl tarafından 2009 yılında geliştirildiği ifade edilen çatının [şurada güzel bir sunumu](https://www.youtube.com/watch?v=ztspvPYybIY) var. Tamamen açık kaynaklı olarak sunulan, OS X, Linux, Windows demeden platform bağımsız ele alınabilen, MIT lisanslama modelinde kullanılabilen bir çalışma zamanına sahip. Apple'dan IBM'e, Netflix'ten Paypal'a, Microsoft'tan benim çalışma odamdaki köhne West-World'e kadar pek çok kurum/kişi tarafından kullanılıyor. Tüm bunların yanından belki de en dikkat çekici yanı kendisinin tamamen asenkron programlamaya (Callback modelini mutlaka hatırlayınız) odaklanmış olmasıdır. Bunu daha net kavramak için öğretilerdeki örnek kod parçalarına baktım ve en sık kullanılan bir versiyonunu ele aldım.

```javascript
var fs=require("fs");

var loremData=fs.readFileSync('loremipsum.txt');
console.log(loremData.toString()+"\n\n");
console.log("*** Bitmeyen kod yapmışlar ***\n");
```

Standart bir dosya okuma ve ekrana bastırma işlemi söz konusu. fs modülündeki readFileSync fonksiyonu yardımıyla okunan loremipsum.txt içeriği terminal penceresine basılıyor. Bu zaten yakından bildiğimiz senkron çalışma modelinin bir örneği. Aşağıdaki ekran çıktısından da durum anlaşılabiliyor. Diğer yandan readFile fonksiyonunun sonundaki Sync son eki mutlaka dikkatinizi çekmiş olmalı. Normalde fonksiyonlarımızı asenkron tasarladığımız hallerde sonuna Async takısı ekleriz. Node.js dünyası ise her fonksiyonunu asenkron olarak çalışacak şekilde modellemeye uğraşıyor. Bu nedenle senkron fonksiyonlar için ayrı bir isimlendirme standardı konulmuş.

![nodejs_7.gif](/assets/images/2018/nodejs_7.gif)

Dikkat edileceği üzere önce dosyanın içeriği ekrana basıldı sonrasında ise kod kaldığı yerden çalışmasına devam ederek sonlandı. Oysaki Node.js tasarlanış amacı gereği aksi belirtilmedikçe fonksiyonelliklerini asenkron çalışacak şekilde sunuyor (Hatta tüm API'lerinin Callback modeline göre asenkron çalışma desteği sunduğu belirtilmekte) Aynı örneği aşağıdaki kod parçası ile denersek bunu daha net görebiliriz.

```javascript
var fs = require("fs");

fs.readFile('loremipsum.txt', function (err, data) {
    if (err) return console.error(err);
    console.log(data.toString() + "\n\n");
});
console.log("### Program sonu ###\n");
```

![nodejs_8.gif](/assets/images/2018/nodejs_8.gif)

Dikkat edileceği üzere ilk olarak dosya okuma satırından sonraki kod parçası çalıştı. Tipik bir asenkron çalışma modeli yaklaşımı. Bu tip asenkron çalışan fonskiyonlarda Callback desteği olduğunu da belirtelim. Hatta bu geri bildirim fonksiyonu örneğimizde readFile metoduna ikinci parametre olarak verilmiş durumda. Yani dosya okuma işleyişi tamamlandığında devreye girecek fonksiyon parametre olarak tanımlanıyor. İstersek bu fonksiyonu dışarıda da tanımlayabiliriz. Aşağıdaki örnek kod parçası ile ne demek istediğimi sanırım daha iyi anlatabilirim.

```javascript
var fs = require("fs");

var readCallback = function (err, content) {
    if (err) {
        console.log(err.message);
        return;
    }
    var lines = content.toString().split("\n");
    lines.forEach(l => {
        console.log(l);
    });
}

fs.readFile('cats.txt', readCallback);
console.log("### Program sonu ###\n");
```

readFile fonksiyonunun ikinci parametresi olan callback metodu readCallback isimli değişken olarak tanımlanmış durumda. cats.txt isimli içeriğin okunması tamamlandığında bu geri bildirim fonksiyonu devreye giriyor.

![nodejs_12.gif](/assets/images/2018/nodejs_12.gif)

## Terminal Penceresinden

Node.js'i öğrenmeye başlarken ille de js uzantılı dosyalar oluşturmaya gerek olmadığını da öğrendim. Meşhur REPL (Read Eval Print Loop) modelinin desteklendiği bir ortamdan söz konusu. Yani terminalden node arayüzü ile konuşmak mümkün. Sadece node demek yeterli. İşte bir kaç örnek kullanım.

```bash
var name='nodi'
console.log('merhaba %s',name)
4+5

for(var i=0;i<5;i++){
   console.log(i)
}

Date()
Math.random()

var sum=function(x,y){
   return x+y
}
sum(5,1.23)

.help
.exit
```

![hackathon dan nodejs i tanimaya 02](/assets/images/2018/hackathon-dan-nodejs-i-tanimaya-02.png)

- name isimli bir değişken kullanımı
- terminale bir şeyler yazdırma
- for döngüsü
- anından matematiksel işlem yaptırma
- günün tarihini yazdırma
- rastgele sayı ürettirme
- bir fonksiyon tanımlayıp onu çağırma

gibi işlemler söz konusu. Dolayısıyla dili tanımak için bu ortamı kullanabiliriz. Terminal'de açılan node ortamından çıkmak için.exit yazmak yeterli. Nokta ile başlayan farklı komutlar da var. Söz gelimi yazdığımız ve üç nokta ile devam eden bir ifadeden vazgeçmek istediğimizde.break yazabiliriz. Ya da kullanılabilecek kısayolları görmek için.help ifadesini kullanabiliriz. Bunları bir deneyin.

## Express ile Sonlandıralım

Sonuç olarak Node.js'i SPA tipinden uygulamalarda, JSON bazlı REST API'lerinin geliştirilmesinde, veri-hassas ve gerçek zamanlı akış sunan programlarda tercih edebiliriz. Hatta ilk örnekten yola çıkarsak domain bazında bölünmüş REST servislerinin ayrı ayrı sunulmasında pekala rahatlıkla kullanılabilir. Söz gelimi müşteri modülünüzü ve alt modüllerini farklı portlardan tek bir node.js sunucusundan, muhasebe modülü ve alt modüllerini farklı port aralığından sunan bir diğer node.js sunucusundan vb... şeklinde bir kurgu pekala gerçeklenebilir. Bunun ölçeklenmesi de microservice yaklaşımında kendine yer edinmesi de oldukça mümkün. REST tarafı için önceden de belirttiğim üzere express paketinden yararlanmak mantıklı görünüyor. Hadi gelin yazımızı sonlandırmadan önce onunla ilgili çok basit bir örnek yapalım. Ön hazırlık olarak express ve body-parser paketlerini sisteme dahil etmek gerekiyor. Visual Studio Code ortamından çıkmadan kendi terminalini kullanarak bu kurulumlar kolayca yapılabilir.

```bash
npm install express
npm install body-parser
```

Ardından aşağıdaki kodlarla devam edebiliriz.

```javascript
/*
Ön gereksinimler
npm install express
npm install body-parser
*/

var express = require('express');
var app = express();
var bodyparser = require('body-parser');
var fs = require('fs');
app.use(bodyparser.json());

// HTTP Get
app.get('/api/jobs', function (request, response) {
    fs.readFile('jobs.json', 'utf8', function (err, data) {
        console.log('%s:%s', Date(), request.url);
        response.end(data);
    });
});

app.get('/api/jobs/:jobId', function (request, response) {
    console.log('%s:Requested job id %s',Date(),request.params.jobId);
    response.status(200);
    // Bu kısım sizde :)
    response.end();
});

// HTTP Post
app.post('/api/addJob', function (request, response) {
    console.log('%s:%s', Date(), request.url);
    console.log(request.body);
    response.status(200).send('Job has been added');
     // Bu kısım sizde :)
    response.end();  
});

// HTTP Delete Burası da sizde
// HTTP Update Burası da sizde

var server = app.listen(5006, function () {
    console.log('Sunucu dinlemde');
});
```

5006 numaralı port üzerinden gelen talepleri dinleyen bir servis sunucusu söz konusu. /api/jobs ve /api/jobs/3 gibi HTTP Get talepleri dışında yeni bir işin eklenmesi için HTTP Post talebini ele alan fonksiyonlar var. Hepsi app nesnesi üzerinden çağırılan asenkron metodlar. İstemcilere REST modelinde bir API sunulduğunu rahatlıkla görebilirsiniz. Tabii size düşen bir takım görevleri de yorum satırı olarak bulabilirsiniz (Onları ihmal etmeyin yapın) Örnekte job içeriklerinin tutulduğu bir json dosyası da var. O da şöyle bir içeriğe sahip.

```json
{
    "job1": {
        "title": "just read",
        "duration": "4 books per month",
        "id": 12
    },
    "job2": {
        "title": "be smile",
        "duration": "to everyone",
        "id": 23
    },
    "job3": {
        "title": "learn node.js",
        "duration": "in 30 days",
        "id": 35
    },
    "job4": {
        "title": "play basketball",
        "duration": "2 times per week",
        "id": 35
    }
}
```

Ben Postman üzerinden yaptığım denemelerle aşağıdaki sonuçları elde etmeyi başardım.

`http://localhost:5006/api/jobs` talebi için tüm json içeriğini elde edebildim.

![nodejs_9.gif](/assets/images/2018/nodejs_9.gif)

`http://localhost:5006/api/addJob` adresinden yaptığım HTTP Post talebi ile de ekleme işlemi için gerekli operasyonun tetiklendiğini gördüm.

![nodejs_10.gif](/assets/images/2018/nodejs_10.gif)

Kodları dikkatlice incelemenizi öneririm. Örneğin api/jobs/3 teki 3 değerini nasıl alıyoruz, body-parser hangi aşamada devreye giriyor, fonksiyon parametresi olarak geçen fonksiyonlar bize nasıl bir avantaj sağlıyor, response.end'in tam olarak görevi ne ve kullanmak zorunda mıyız vb şekilde soru cevaplar ile konuyu pekiştirebileceğinizi düşünüyorum. Node.js dünyası takdirimi kazandı. Onu Docker ile bir arada kullanmak ya da Heroku üzerinde konuşlandırmak gibi araştırmalar yapmayı da planlıyorum. Hatta MongoDb ile nasıl kullanabiliyoruz bu da merak ettiğim konuların başında geliyor. Belki de şu az önce bahsettiğim ölçeklenebilir ayrık microservice'leri baz alan bir model üzerinde de çalışabilirim. Bir süre dinlendikten sonra. Şimdilik West-World'ten bu kadar. Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

Örnek kod ve yardımcı dosyaları [Github üzerinden](https://github.com/buraksenyurt/nodejs-tutorials/tree/master/Day01) alabilirsiniz

### Kaynaklar

[Node.js Official Site](https://nodejs.org/en/)[W3 School](https://www.w3schools.com/nodejs/default.asp)[Code for Geek](https://codeforgeek.com/category/nodejs/)[Tutorials Point](https://www.tutorialspoint.com/nodejs/index.htm)
