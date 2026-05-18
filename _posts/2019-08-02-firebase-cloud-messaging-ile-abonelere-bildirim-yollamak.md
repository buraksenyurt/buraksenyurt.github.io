---
layout: post
title: "Firebase Cloud Messaging ile Abonelere Bildirim Yollamak"
date: 2019-08-02 17:48:00
tags:
  - google-cloud-platform
  - progressive-web-app
  - pwa
  - push-notification
  - node
  - node.js
  - express
  - rest-api
  - fcm
  - fcm-node
  - service-worker
  - javascript
  - npm
categories:
  - Bulut Bilişim
---
Servis kapısı açıldığında gözlerini herkesten kaçırıp araca binerken heyecanlı ses tonuyla "Günaydın" diyerek en arka koltuğa geçen kadının ruh hali her yönüyle tanıdık geliyordu. Bir buçuk yıl kadar önce yine bu servise bindiğim ilk gün bende benzer kaygıları hissetmiştim. Oysa hayatımda ilk kez servis binmiyordum.

![friendship.png](/assets/images/2019/friendship.png)

Ama işte o ilk biniş sırasında söylenen "Günaydın" kelimesi ardından ben ve şoförümüz İhsan Bey dışında kimsenin karşılık vermediği ve onun gözlerini aradığım sırada geçen kısa zaman diliminde aklından geçenleri tahmin ettiğim anlar, en arka koltuğa oturduğunu gördükten sonra toplum psikolojisine ayak uydurup önüme doğru bakmamla son bulmuştu.

Servis şirkete vardıktan sonra her birimiz fabrikanın farklı noktalarına doğru yürümeye başladık. Bizim binamız yolun karşı tarafında kalıyordu ve can güvenliği nedeniyle bir üst geçitten geçilerek ulaşılabiliyordu. Merdivenleri çıkarken onun ne durumda olduğunu bile unutmuşum. Tesadüfen arkamı dönüp baktığımda tek başına ve biraz da şaşkın bir şekilde ne yöne gideceğini anlamaya çalıştığını fark ettim. Yanlış yöne gittiği apaçık ortadaydı. Çelimsizliğinden, gencecik yüzünden ve taşıdığı not defterinden üniversite talebesi olan bir stajyer olduğu biraz da olsa anlaşılıyordu. Geçen yılın aynı vakitlerinde de benzer manzaralar fabrikanın çeşitli sabahlarında yaşanmıştı.

Merdivenleri tekrar indim ve arkasından ona yetişerek "Merhaba...Yeni başladınız sanırım. Nereye gidecektiniz?" dedim. Aynı günün akşamında koltuğuma oturmuş hareket saatini beklerken kapıda yine o tedirgin duruşuyla beliriverdi. İlk adımını attığında yüzündeki gerginlik az da olsa okunabiliyordu. Aklından geçen "iyi akşamlar diyeceğim ve sanırım kimse sallamayacak" düşüncesi bir bulut olup kafasının üzerinden belirmişti. Ama o sabah ki yardımın etkisinde olsa gerek bu kez yüzümü aradı ve görünce hafif bir tebessümle "iyi akşamlar" dedi. "İyi akşamlar. Eee ilk günün nasıl geçti bakalım..." diye karşılık verince bir yanımdaki koltuğa oturdu. Artık daha iyi hissediyordu.

Biraz sonraki derlemeye nasıl giriş yapacağımı bilemediğim günlerden birindeyiz anlayacağınız üzere. O yüzden yakın zamanda başıma gelen bir olayı sizinle paylaşarak başlamak istedim. Kıssadan hisse herkesin kendisine pay çıkaracağını düşünüyorum. Hepimiz stayjer olduk. Onların daha çok farkına varmamız gerektiği konusunda ufak bir hatırlatmam olsun burada.

...

Cumartesi gecesi çalışmalarının [31nci örneğinde](https://github.com/buraksenyurt/saturday-night-works/tree/master/No%2031%20-%20Push%20Notifications%20on%20PWA) Firebase Cloud Messaging sistemini kullanarak uygulamalara (örnek özelinde bir PWA programına) nasıl bildirimde bulunulabileceğini anlamaya çalışmışım. Her zaman olduğu gibi örneği WestWorld (Ubuntu 18.04, 64bit) üzerinde geliştirmişim. Şimdi notların üstünden geçme, unutulanları hatırlama ve eksikleri giderme zamanı. Öyleyse gelin notlarımızı derlemeye başlayalım.

Tarayıcı üzerinde yaşayan ve çevrim dışı ya da çok düşük internet hızlarında da çalışabilme özelliğine sahip olan PWA (Progressive Web Applications) uygulamalarının en önemli kabiliyetlerinden birisi de Push Notification'dır. Bu, mobil platformlardan yapılan erişimler düşünüldüğünde oldukça önemli bir nimettir. Uygulamaya otomatik bildirim düşmesi veya arka plan veri güncellemeleri kullanıcı deneyimi açısından bakıldığında değerli bir işlevselliktir. Bu yetenekler uygulama için tekrardan submit operasyonuna gerek kalmadan güncel kalabilmeleri anlamına gelir.

Geliştireceğimiz örnek bir basketbol maçı için güncel haber bilgisinin abone olan uygulamalara gönderilmesi üzerine kurgulanmakta. Burada mesajlaşma servisi olarak Firebase Cloud Messaging altyapısını kullanacağımız için ilgi çekici bir örnek olduğunu ifade edebilirim. Şimdi hazırlıklarımıza başlayabiliriz.

## Ön Hazırlıklar

İki uygulama geliştireceğiz. Birisi çok sade HTML içeriğine sahip olan PWA uygulaması. İkinci uygulama ise bir servis. Kullanıcıların bildirim servisine abone olma ve çıkma işlemlerinin yönetimi ile bağlı olanlara bildirim yapma görevini (işte bu noktada Firebase Cloud Messaging sisteminden yararlanacak) üstlenecek. İlk olarak basketbol haberlerini takip edeceğimiz basit önyüz uygulamasını geliştirmeye başlayım. Klasör yapısını aşağıdaki terminal komutları ile oluşturabiliriz.

```text
mkdir basketkolik
cd basketkolik
touch index.html
touch sworker.js
touch main.js
touch efes_barca.html
```

Ayrıca uygulama testlerini HTTP üzerinden kolayca yapabilmek için serve isimli bir npm paketinden yararlanacağız. Kurulumu için aşağıdaki terminal komutunu kullanmak yeterli.

```bash
sudo npm install -g serve
```

Kodları yazmaya başlamadan önce Google tarafıyla haberleşme noktasında gerekli olan bir manifesto dosyasının oluşturulması gerekiyor.

## Manifesto Dosyası

Manifesto dosyası PWA'nın Firebase tarafında etkinleştirilecek Push Notification özelliği için gereklidir. İçerisinde Sender ID değerini barındırır (ilerde karşınıza çıkacak) ve önyüzün kullandığı main modülü, abonelik başlatılırken bu değeri karşı tarafa iletmekle yükümlüdür. Peki bu dosyayı nasıl üreteceğiz?

Öncelikle [Firebase](https://app-manifest.firebaseapp.com/) kontrol paneline gidilir ve PWA için metadata bilgilerini tutacak bir Web App Manifest dosyası üretilir. Ben örnekte aşağıdaki bilgileri kullandım.

![07_31_credit_1.png](/assets/images/2019/07_31_credit_1.png)

Sonrasında Zip dosyasını bilgisayara indirip proje klasörüne açmamız gerekiyor. Manifest.json dosyası ile birlikte images isimli bir klasör de gelecektir. Images klasöründe kendi eklediğimiz active.png dosyasının farklı cihazlar için standartlaştırılmış boyutları yer alır. Bu bilgiler manifest.json dosyasına da konur.

İşimiz henüz bitmedi! Uygulama için Push Notification özelliğini de etkinleştirmek gerekiyor. Bunun için [Firebase Console](https://console.firebase.google.com/) arabirimine gidip yeni bir proje oluşturmalı ve ardından proje ayarlarına (Project Overview -> Project Settings) ulaşıp Cloud Messaging sekmesine gelinmeli (Ben "basketin-cepte-project'" isimli bir proje oluşturdum:P Hayaller başka tabii ama eldeki malzeme şimdilik bu)

Bu bölümde proje için oluşturulan Server Key ve Sender ID değerleri yer alır. Az önce bahsedildiği gibi Sender ID değerinin manifest.json dosyasına eklenmesi gerekiyor (gcmsenderid yazan kısma bakınız)

## PWA Kodları

Artık basketkolik klasöründeki dosyalarımızı kodlamaya başlayabiliriz. index.html sayfası aslında haber kaynağına aboneliği başlatıp durdurabileceğimiz bir test sahası gibi. Tek dikkat edilmesi gereken nokta manifest dosyası ile bağ kurulmuş olması. Tasarım son derece aptalca yapıldı ama esas amacımız elbette şukela bir görsellik sunmanın dışında push notification kabiliyletlerini deneyimlemek. Index sayfası ile işe başlayalım.

```html
<!DOCTYPE html>
<html>
 
<head>
    <title>Basketin Cepte</title>
    <link rel="manifest" href="manifest.json">
    <!--Bunu eklemeyi unutmamak lazım-->
</head>
 
<body>
    <h3>Euroleague Haberleri</h3>
    <p><i>Düğmeye bas ve ne olacağına bakalım</i></p>
    <div id="divPush">
        <img id="buttonPush" width="50px" src="active.png" />
    </div>
    <script src="main.js"></script>
</body>
 
</html>
```

efes_barca.html isim dosya da şimdilik bildirim alındığında gösterilecek içeriği barındırıyor. Bunun dinamik olduğunu bir düşünsenize. Abone olduktan sonra yeni bir haber geldiğinde efes_barcha benzeri dinamik HTML içerikleri kullanılacak. Tüm uygulamayı tamamladıktan sonra bu tip bir özellikle örneğinizi daha da zenginleştirebilirsiniz.

```html
<!DOCTYPE html>
<html>
 
<head>
    <title>Euroleague'de Efes Farkı</title>
</head>
 
<body>
    <p>Anadolu Efes, kritik maçta Barcelona'yı kendi evinde farklı yenerek...
    </p>
</body>
 
</html>
```

Sworker modülü aslında Service Worker görevini üstlenmekte. Kodlar arasına katmaya çalıştığım yorumlarla mümkün mertebe neler olduğunu anlamaya ve anlatmaya çalıştım.

```javascript
/*
main.js içerisinde Service Worker olarak bildirimi yapılan dosyamız.
İki olay metodu içerir.
Uygulama herhangibir bildirim aldığında push metodu tetiklenir. 
Bildirim almasını sağlamak için yazdığımız PusherAPI servisine talep göndermemiz yeterlidir. http://localhost:8080/news/push gibi.
Bu metod içerisinde showNotification ile bir bildirim penceresi gösterilir.
Pencereye tıklandığındaysa notificationclick isimli olay tetiklenir.
Bu olayın ele alındığı fonksiyonda ise temsilen bir web sayfası içeriği açtırılır.
*/
 
self.addEventListener('push', function (event) {
    console.log('push olayı tetiklendi');
    var title = 'Euroleague Haberleri';
    var body = {
        'body': 'Güncel skor bilgileri için tıklayın',
        'tag': 'pwa',
        'icon': './images/48x48.png'
    };
    event.waitUntil(
        self.registration.showNotification(title, body)
    );
});
 
self.addEventListener('notificationclick', function (event) {
    //TODO: Burada statik bir sayfa içeriği gösterilmesi yerine haber bilgisini servisten alacak kodu ekleyebilirsiniz
    console.log('Şimdi bildirime ait sayfa açılacak');
    var url = './efes_barca.html';
    event.notification.close();
    event.waitUntil(clients.openWindow(url));
});
```

Bu taraf için son olarak main içeriğini de aşağıdaki gibi geliştirebiliriz.

```javascript
// load aşamasında Service Worker için register işlemi yapılır
window.addEventListener('load', e => {
    if (!('serviceWorker' in navigator)) {
        console.log('Service worker desteklenmiyor');
        return;
    }
    navigator.serviceWorker.register('sworker.js')
        .then(function () {
            console.log('Servis Worker kaydoldu');
        })
        .catch(function (err) {
            console.log('Hımm...Sanırım bir hata oluştu : ', err);
        });
});
 
// Push Notification durumunu günceller
// Aktifse active.png, değilse passive.png
function updateStatus(status) {
    divPush.dataset.checked = status; // statu bilgisini set et
    if (status) { //true ise aktif
        buttonPush.src = "./assets/active.png";
    }
    else { // değilse pasif olan ikonu göster
        buttonPush.src = "./assets/passive.png";
    }
}
 
function isPushNotifyEnabled() {
    if (Notification.permission === 'denied') {
        alert('Kullanıcı Push Notification hizmetini bloklamış');
        return;
    }
 
    if (!('PushManager' in window)) {
        alert('Üzgünüm ama Push Notification bu tarayıcı modelinde desteklenmiyor');
        return;
    }
 
    /*
    Kullanıcı Push Notification'ı engellememiş ve tarayıcı da bunu destekliyorsa
    buraya geliriz.
    Eğer Service Worker hazır ve kaydolmuşsa abonelik yönetimine başlanabilir. 
    */
    navigator.serviceWorker.ready.then(function (reg) {
        reg.pushManager.getSubscription() //abone ol
            .then(function (subs) { // abonelik durumuna göre statüleri güncelle
                if (subs) {
                    updateStatus(true);
                }
                else {
                    updateStatus(false);
                }
            })
            .catch(function (err) { // bir hata oluştuysa tarayıcı console'una hata basıyoruz.
                console.error('Bir hata oluştu : ', err);
            });
    });
}
 
// Uygulamayı Push Notification hizmetine abone etmek için
function subscribe() {
    navigator.serviceWorker.ready
        .then(function (reg) {
            if (!reg.pushManager) {
                alert('Tarayıcı Push Notification hizmetini desteklemiyor');
                return false;
            }
            reg.pushManager.subscribe(
                { userVisibleOnly: true }
            ).then(function (subs) {
                console.log('Abonelik başladı.');
                console.log(subs);
                sendSubsID(subs); // Abonelik IDsini REST servise gönderen metodu çağırdık
                updateStatus(true);
            }).catch(function (err) {
                updateStatus(false);
                console.error('Abone olma işlemi sırasında hata oluştu: ', err);
            });
        });
}
 
// Abonelikten çıkartmak için
function unsubscribe() {
    navigator.serviceWorker.ready
        .then(function (reg) {
            reg.pushManager.getSubscription()
                .then(function (subs) {
                    if (!subs) {
                        alert('Abonelikten çıkılamıyor yahu :S');
                        return;
                    }
                    subs.unsubscribe()
                        .then(function () {
                            console.log('Abonelikten çıkıldı');
                            console.log(subs);
                            deleteSubsID(subs); // Aboneliği silerken ID'yi çıkartacak olan REST servis metodunu çağırdık
                            updateStatus(false);
                        })
                        .catch(function (err) {
                            console.error(err);
                        });
                })
                .catch(function (err) {
                    console.error('Abonelikten çıkarken bir hata oluştu : ', err);
                });
        })
}
 
// Sunucuya Subscription ID bilgisini göndermek için kullanıyoruz
// Bunun için yazdığımız PusherAPI node servisini kullanıyoruz
function sendSubsID(subscription) {
    var id = subscription.endpoint.split('gcm/send/')[1];
    fetch('http://localhost:8080/subscribers', {
        method: 'post',
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ subscriptionid: id })
    });
}
 
function deleteSubsID(subscription) {
    var id = subscription.endpoint.split('gcm/send/')[1];
    fetch('http://localhost:8080/subscribers/' +
        id, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        });
}
 
// div ve button elementlerini alıyoruz
var divPush = document.getElementById('divPush');
var buttonPush = document.getElementById('buttonPush');
 
/*
div elementinde mouse ile tıklandığı zaman gerçekleşecek olayı
dinleyecek bir listener bildirimi yaptık
*/
divPush.addEventListener('click', function () {
    //console.log('Click');
    if (divPush.dataset.checked === 'true') {
        //console.log('Unsubscribe');
        unsubscribe();
    }
    else {
        //console.log('Subscribe');
        subscribe();
    }
});
 
isPushNotifyEnabled();
```

## İlk Test

Kodları tamamladıktan sonra kısa bir test ile push notification hizmetinin çalışıp çalışmadığı hemen kontrol edilebilir. Bunun için terminalden

```bash
serve
```

komutunu verip uygulamayı ayağa kaldırmamız yeterli. Eğer aşağıdaki ekran görüntülerindekine benzer sonuçlar elde edebiliyorsak REST API uygulamasını yazmaya başlayabiliriz.

![07_31_credit_2.png](/assets/images/2019/07_31_credit_2.png)

![07_31_credit_3.png](/assets/images/2019/07_31_credit_3.png)

Uygulama, Push Notification hizmeti için abone olunurken benzersiz bir ID değeri alır. Firebase Cloud Messaging sistem bu değeri kullanarak kime bildirim yapılacağını bilebilir.

## REST API Uygulamasının Yazılması

Abone olan uygulamaların ID bilgilerini yönetmek için Node.js tabanlı bir REST servisi yazabiliriz. Servis temel olarak PWA'nın FCM ile olan iletişiminde devreye girmektedir. Hem abonelik yönetimi hem de istemcilere bildirim yapılması ki bunu tek başına yapmayacaktır. Service Worker dolaylı olarak FCM üzerinden bu servisle yakın ilişki içerisindedir.

Bu servisi ayrı bir klasörde projelendirmek iyi olur. Pek tabii node.js tarafında REST Servisi yazımını kolaylaştırmak için bazı paketlerden destek alınabilir. express dışında HTTP mesajlarındaki gövdeleri kolayca ele almak için body-parser, servisin Firebase Cloud Messaging ile konuşabilmesini sağlamak amacıyla da fcm-node paketi kullanılablir. morgan modülünü ise sunucu tarafındaki HTTP trafiğini loglamak için değerlendirebiliriz. Aşağıdaki terminal komutları ile klasör ağacını oluşturup server dosyasını kodlayarak derlememize devam edelim.

```bash
mkdir PusherAPI
cd PusherAPI
touch server.js
sudo npm install express body-parser fcm-node morgan
```

server modülü

```javascript
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var FCM = require('fcm-node');
var morgan = require('morgan');
app.use(morgan('combined'));
 
// Firebase Cloud Messaging nesnesini örneklerken
// bizim için üretilen server key değerini veriyoruz
var fcm = new FCM('bu kod sizde var...');
 
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));
 
app.use(function (req, res, next) {
    // CORS problemi yaşamamak için gerekli header tanımlamaları yapılır
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');
    res.setHeader('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    next();
})
 
//abonelerin ID bilgilerini tutacağımız array. 
// Bunun yerine daha kalıcı bir repository tercih edilebilir
var subscribers = []
 
// Web uygulaması HTTP Post ile subscriptionID gönderdiğinde çalışan metod 
app.post('/subscribers/', function (req, res) {
    // Mesaj gövdesinden abonelik bilgisini almaya çalışr
    if (!req.body.hasOwnProperty('subscriptionid')) {
        res.statusCode = 400;
        res.send('Gönderilen bilgilerde eksik veya hata var');
        return;
    }
    // bulduysan diziye ekle ve başarılı olduğu bilgisini ilet
    subscribers.push(req.body.subscriptionid)
    res.statusCode = 200; //HTTP 200 Ok basıyoruz
    res.send('ID alındı');
});
 
// Web uygulaması abonelikten çıkarken HTTP Delete ile çağırdığı metod
app.delete('/subscribers/:id', function (req, res) {
    // dizideki indis değerini URLden gelen id değerine göre bul
    const index = subscribers.indexOf(req.params.id)
    // varsa diziden çıkart
    if (index !== -1) {
        subscribers.splice(index, 1)
    }
    res.statusCode = 200;
    res.send('ID silindi');
});
 
/*
    Abonelere bildirim göndermek için tetiklenen REST metodu
    localhost:8080/news/push çağrısı geldiğinde çalışır.
*/
app.get('/news/push', function (req, res) {
    // Aboneler için mesaj hazırlanır
    var message = {
        registration_ids: subscribers,
        collapse_key: 'i_love_this_game',
    };
    // Firebase Cloud Messaging üzerinden mesaj gönderilir
    fcm.send(message, function (err, response) {
        if (err) {
            console.log(err)
        } else {
            console.log("Mesaj başarılı bir şekilde gönderildi: ", response);
        }
    });
    res.sendStatus(200);
});
 
app.listen(8080);
console.log('Pusher API servisi 8080 üstünden dinlemede');
```

## Çalışma Dinamikleri

Uygulamanın çalışma dinamiklerini anlamak oldukça önemli. Index.html olarak düşündüğümüz web uygulamamız çalıştırıldığında iki aksiyonumuz var. Basketbol topuna basıp bir abonelik başlatmak veya tekrar basarak aboneliği durdurmak.

Abonelik başlatıldığında FCM benzersiz bir ID değeri üretir ve bunu PusherAPI servisi kendisine gelen çağrı ile kayıt altına alır (diziye eklediğimiz yer) Sonraki herhangi bir t zamanında PusherAPI servisinin abonelere bildirim gönderen HTTP metodu tetiklenirse, Firebase Cloud Messaging devreye girer ve dizideki ID bilgilerini kullanarak abonelerine bildirimde bulunur. Bildirimler web uygulaması tarafındaki Service Worker (sworker.js) tarafından push olayıyla yakalanır. Push olayı şimdilik sadece statik bir sayfa gösterimi yapmakta ki aslında asıl içeriği yine servis üstünden veya web aracılığıyla başka bir adresten aldırabiliriz.

## Çalışma Zamanı (Development Ortamı)

Testler için PWA ve servis tarafını ayrı ayrı çalıştırmalıyız.

```bash
serve
```

terminal komutu ile web uygulamasını

```bash
node server.js
```

ile de REST servisini başlatabiliriz. Aboneliği başlattıktan sonra `http://localhost:8080/news/push` adresine talepte bulunursak bir bildirim mesajı ile karşılaşırız (sworker daki push olayı tetiklenir) Aynen aşağıdaki ekran görüntüsünde olduğu gibi.

![07_31_credit_4.png](/assets/images/2019/07_31_credit_4.png)

Bildirim kutusuna tıklarsak statik olarak belirlediğimiz sayfa açılacaktır (yani notificationclick olayı tetiklenir)

![07_31_credit_5.png](/assets/images/2019/07_31_credit_5.png)

## PWA ve Service Uygulamalarının Firebase Hosting'e Alınması

Her iki uygulamada local geliştirme ortamında gayet güzel çalışıyor. Ancak bunu anlamlı hale getirmek için her iki ürünü de Firebase üzerine alıp genel kullanıma açmamız lazım. Web uygulamasını Firebase Hosting ile REST servisini de Firebase Function ile yayınlamalıyız. Bu işlemler için firebase-tools aracına ihtiyacımız olacak. Terminalden aşağıdaki komutu kullanarak ilgili aracı sisteme yükleyebiliriz.

```bash
sudo npm install -g firebase-tools
```

## Basketkolik'in Dağıtımı

Yeni bir dağıtım klasörü oluşturmalı, initializion işlemini gerçekleştirip basketkolik uygulama kodlarını oluşan public klasörü içerisine atmalıyız. Ardından üzerinde çalışacağımız projeyi seçip deploy işlemini yapabiliriz. Bu işlemler için aşağıdaki terminal komutlarından yararlanılabilir.

```bash
mkdir dist
cd dist
firebase init
cp -a ../basketkolik/. ./public/
firebase use --add basketin-cepte-project
firebase deploy
```

firebase init işleminde bize bazı seçenekler sunulacaktır. Burada aşağıdaki görüntüde yer alan seçimlerle ilerleyebiliriz. En azından ben öyle yaptım.

![07_31_credit_6.png](/assets/images/2019/07_31_credit_6.png)

Eğer dağıtım işlemi başarılı olursa aşağıdaki ekran görüntüsündekine benzer sonuçlar elde edilmelidir.

![07_31_credit_7.png](/assets/images/2019/07_31_credit_7.png)

## PusherAPI servisinin Dağıtımı

Hatırlanacağı üzere web uygulaması bir REST Servisi yardımıyla FCM sistemini kullanıyordu. PusherAPI isimli uygulama, Fireabase tarafı için bir Function anlamına gelmektedir (Serverless App olarak düşünelim) Ölçeklenebilirliği, HTTPS güvenliği, otomatik olarak ayağa kalkması gibi bir çok iş Google Cloud ortamı tarafından ele alınır. Şimdi aşağıdaki terminal komutu ile fonksiyon klasörünü oluşturalım (dist klasörü içerisinde çalıştığımıza dikkat edelim)

```bash
firebase init functions
```

Yine bazı seçenekler karşımıza gelecektir. Burada gelen sorulara şöyle cevaplar verebiliriz;

- Dil olarak Javascript seçelim.
- ESLint kullanımına Yes diyelim.
- npm dependency'lerin kurulmasına da Yes diyelim ki uygulamanın gereksinim duyduğu node paketleri de yüklensin.

Devam eden adımda functions klasöründeki index dosyasının içeriğini PusherAPI'deki server içeriği ile değiştirmeliyiz. Ancak bu kez express'in firebase-functions ile kullanılması gerekiyor. İhtiyacımız olan express, body-parser ve fcm-node paketlerini üzerinde çalıştığımız functions klasörü içinede de yüklemeliyiz. Son olarak dist klasöründeki firebase.json dosyasına rewrites isimli yeni bir bölüm ekleyip fonksiyonumuzu deploy edebiliriz.

```bash
cd functions
sudo npm install express body-parser fcm-node
firebase deploy
```

Yapmamız gereken bir şey daha var. Web uygulamasının kullandığı main dosyasının içeriğini, yeni eklediğimiz google functions ile uyumlu hale getirmek. Tahmin edileceği üzere gidilen servis adreslerini, oluşturulan firebase proje adresleri ile değiştirmemiz lazım (dist/public/main.js içeriğini kontrol edin) Web uygulamasındaki bu değişikliği Cloud ortamına taşımak içinse public klasöründeyken yeniden bir deploy işlemi başlatmamız yeterli olacaktır.

```bash
firebase deploy
```

## Çalışma Zamanı (Production Ortamı)

Uygulama artık `https://basketin-cepte-project.firebaseapp.com/` adresinden yayında (En azından bir süre için yayındaydı ki aşağıdaki ekran görüntüsü de bunun kanıtıdır)

![07_31_credit_8.png](/assets/images/2019/07_31_credit_8.png)

## Ben Neler Öğrendim?

Bu çalışmanın da bana kattığı bir çok şey oldu elbette. Özellikle bir uygulamaya uzak sunuculardan bildirim yollanması ve bunun abonelik temelli yapılması merak edip öğrenmek istediğim konulardan birisiydi. İşin içerisine basit bir PWA modeli de ekleyince çalışma ilgi çekici bir hal almıştı. Yapılan hazırlıklar düşünüldüğünde aslında bizi çok fazla yormayacak bir geliştirme süreci olduğunu ifade edebiliriz. Derlemeyi sonlandırmacan önce yanıma kar kalanların neler olduğunu aşağıdaki maddeler ile özetleyebilirim.

- Firebase Cloud Messaging (FCM) sisteminin kabaca ne işe yaradığını
- PWA uygulamasının FCM ile nasıl haberleşebileceğini
- Abone olan istemciye bildirimlerin nasıl gönderilebileceğini
- Service Worker üzerindeki push ve notificationclick olaylarının ne anlama geldiğini
- serve paketinin kullanımını
- firebase terminal aracı ile deployment işlemlerinin nasıl yapıldığını
- Web uygulaması ve Functions'ın Google Cloud tarafından bakıldığında farklılıklarını

Bu arada proje büyük ihtimalle Google platformundan kaldırılmıştır. Malum istenmeyen bir yüklenme sonrası yüklü bir fatura ile karşılaşmamak adına küçük bir tedbir olduğunu ifade edebilirim. O nedenle kendiniz başarmaya çalışırsanız daha kıymetli olacaktır. Konseptin basketbol olması önemli değil. Abonelerinize bildirimlerde bulunacağınız herhangi bir senaryo olması yeterli olur. Bildirim yapan servisi de planlanmış bir düzeneğe bağlayabiliriz. Söz gelimi günün belirli anlarında bir konu ile ilgili bildirimlerin yönlendirilmesi işini üstlenebilir. Böylece geldik bir [saturday-night-works](https://github.com/buraksenyurt/saturday-night-works) macerasının daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[Orijinal Kaynak](https://www.buraksenyurt.com/post/firebase-cloud-messaging-ile-abonelere-bildirim-yollamak)
