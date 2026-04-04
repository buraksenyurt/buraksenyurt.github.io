---
layout: post
title: "GoLang - Basit HTTP Web Server Yapımı"
date: 2017-02-20 18:00:00
categories:
  - Programlama Dilleri
tags:
  - golang
  - rest-api
  - http
  - html
  - http-get
  - func
  - fmt
  - time
  - net/http
  - json
  - strings
---
Go dili ile ilgili maceralarım devam ediyor. Dilin temel özelliklerini anlamaya çalışmak bir yana, aralarda merak ettiğim farklı konuları da incelemeye çalışıyorum. Uygulamalı örnekler üzerinden gitmek de bir programlama dilini öğrenirken tercih ettiğim yollardan birisi. Size de tavsiye ederim.

![gorest_6.gif](/assets/images/2017/gorest_6.gif)

Geçtiğimiz günlerde [REST (Representational State Transfer)](https://tr.wikipedia.org/wiki/REST) servislerinin nasıl yazıldığına bakarken bir kaç yeni şey daha öğrendim. Amacım HTTP Get metodu ile basit REST servis talebi yapmak ve örneğin bir ürün listesini [JSON (JavaScript Object Notation)](https://tr.wikipedia.org/wiki/JSON) formatında istemciye döndürmekti (Daha önceden [Ruby](/2016/02/09/ruby-kod-parcaciklari-20-rest-servis-gelistirmek-ve-dotnet-tarafindan-tuketmek/) ve [Python](/2016/09/22/python-ve-flask-ile-rest-tabanli-servis-gelistirmek/)'da REST servislerin nasıl yazılabileceğine de bakmıştım) Go tarafındaki durumu araştırırken HTTP olarak gelecek talepleri nasıl karşılayabileceğimi de gördüm.

Dilerseniz vakit kaybetmeden örneğimize ait kodlara geçelim. Programımız wsrv.go isimli bir dosyadan oluşmakta. İçerisinde ürünler için bir struct ve diğer işlemler için gerekli temel fonksiyonları bulunacak.

## Uygulama Kodu

wsrv.go dosya içeriği;

```golang
package main

import (
    "fmt"
    "log"
    "net/http"
	"time"
	"strings"
	"encoding/json"
)

var products [4]Product
	
func homePage(writer http.ResponseWriter, request *http.Request){
    fmt.Printf("[%s]\t%s:%s\n",request.Method,time.Now(),request.URL)
	//gelen istege karsilik dosya varsa gosterir. yoksa http 404 verir
	http.ServeFile(writer, request, request.URL.Path[1:]) 
}

func getProduct(writer http.ResponseWriter, request *http.Request) {
	fmt.Printf("[%s]\t%s:%s\n",request.Method,time.Now(),request.URL)
	var url string=request.URL.Path
	var result []Product
	parts:=strings.Split(url,"/")
	
	for _, p := range products {
		if(strings.EqualFold(p.Category,parts[2])) {
			result=append(result,p)
		}
	}
	if len(result)==0{
		http.Error(writer, http.StatusText(404), 404)
	}else{
		json.NewEncoder(writer).Encode(result)
	}
}

func getProducts(writer http.ResponseWriter, request *http.Request){ 	
    fmt.Printf("[%s]\t%s:%s\n",request.Method,time.Now(),request.URL)
    json.NewEncoder(writer).Encode(products)
}

func main() {
	products[0]=Product{Id:9001,Title: "intel core i5", Category: "CPU", UnitPrice: 150.90}
	products[1]=Product{Id:9021,Title: "intel core i7", Category: "CPU", UnitPrice: 200.35}
	products[2]=Product{Id:7800,Title: "google mouse", Category: "OEM", UnitPrice: 44.35}
	products[3]=Product{Id:1450,Title: "Logitech Wireless Keyboard", Category: "OEM", UnitPrice: 18.98}
	
	http.HandleFunc("/", homePage)
	http.HandleFunc("/products/", getProduct)
	http.HandleFunc("/products", getProducts)
	log.Fatal(http.ListenAndServe(":8084", nil))
}

type Product struct {
    Id int "json:\"ID\""
	Title string "json:\"Title\""
	Category string "json:\"Category\""
    UnitPrice float32 "json:\"UnitPrice\""
}
```

Örnekte Home.html isimli bir giriş sayfası da kullanıyoruz. İçeriği aşağıdaki gibi.

```html
<html>
<html>
  <head>
	  <title>AZON Tools and Products</title>
  </head>
  <body>
	  <b>All Tools</b>
	  <br/>
	  <i>Whatever you want...We ara solution</i>
	  <br/>
	  <a href="http://localhost:8084/products">All Products</a>
  </body>
</html>
```

## Peki Neler Oluyor?

Tahmin edeceğiniz üzere main fonksiyonu içerisinde bazı yönlendirmeler mevcut. HTTP ile gelen Get taleplerini dinliyor ve basit bir route sistemi kullanıyoruz. Gerekli paketler import ile bildirilmiş durumda.

| Paket Adı | Kullanım Amacı |
| --- | --- |
| encoding/json | Çıktıları JSON formatında verebilmek için gerekli fonksiyonellikleri içerir. |
| http | En kilit paketimiz. HTTP taleplerini dinlemek ve çıktı üretmek için gerekli operasyonları içerir. |
| strings | products/OEM şeklindeki kategori bazlı ürünleri çekmek için gelen URL bilgisini / işaretine göre ayrıştırmaya çalışıyoruz. Burada kullandığımız Split fonksiyonu Strings paketinde yer alıyor. Tabii strings paketinde bir sürü ama bir sürü işe yarar fonksiyon var. İnceleyin. |
| log | Log basmak için kullandığımız paket. Filmimizde oldukça küçük bir role sahip. |
| fmt | Gelen talebin ne olduğu, hangi zamanda yapıldığı ve HTTP Metodunun adını ekrana basarken standart Printf gibi fonksiyonlara başvuruyoruz. Bu fonksiyonu içeren paket. |
| time | İşlem zamanını yakalamak için kullandığımız Now fonksiyonunu içeren paket. |

main fonksiyonu içerisinde kobay dizimiz olan products'a bir kaç Product nesne örneği ekliyoruz. Product tipi bir Struct. Sembolik olarak ürünün benzersiz numarasını (Id), adını (Title), liste fiyatını (UnitPrice) ve bulunduğu kategori (Category) bilgisini içeren değerler taşımakta. main içerisindeki diğer satırlar ise yazımızın kilit noktasını oluşturuyor. [HandleFunc](https://golang.org/pkg/net/http/#HandleFunc) iki parametre almakta. İlki ele alınacak talebe ait adres bilgisi. İkincisi ise bu tip bir talep geldiğinde çalıştırılacak olan fonksiyon. Örneğin / için homePage, /products/ için getProduct, /products için getProducts fonksiyonları çağırılacak.

HandleFunc yönlendirmelerinin yapıldığı fonksiyonların ortak özelliği geriye değer döndürmeyip iki parametre almaları (ki bu bir tesadüf değil). İlk parametre ResponseWriter ikinci parametre ise Request tipi için bir Pointer olmalı. Bu fonksiyonlar içerisinde ResponseWriter örneğini kullanarak HTTP talebine cevap olacak çıktıları üretiyoruz. *http.Request işaretçisi üzerinden talep ile ilgili bir çok bilgiye ulaşabilmekteyiz. HTTP metodu ve URL bilgisi gibi. HandleFunc http paketi içerisinde aşağıdaki şekilde tanımlanmış bir fonksiyondur.

```golang
func HandleFunc(pattern string, handler func(ResponseWriter, *Request))
```

İlk parametrede deseni veriyoruz. Örneğimizde REST adresleri gibi düşündük. İkinci parametrede bir fonksiyon ataması söz konusu. Hatırlayacağınız gibi Go dilinde fonksiyonları, fonksiyonlara parametre olarak geçirebilmemiz mümkün. handler'ın tanımı ise paketle ilgili dokümana göre aşağıdaki gibi.

```golang
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request)
```

> Go dilinin C# veya Java tarafında kodlama yapan birisine enteresan gelebilecek pek çok yanı var. Bu nedenle paketlerin içeriklerine bakmanızda ve özellikle fonksiyon tanımlamalarını incelemenizde yarar var.

homePage fonksiyonunun çalışma prensibi oldukça basit. İstemci tarafına üçüncü parametre ile gelen içeriği sunmakla görevli. Yani index.html isimli bir talep gelirse ve bu sunucunun dinleme yaptığı bir klasörde mevcutsa, istemci tarafına parse ediliyor. Çıktıyı ServerFile fonksiyonu gerçekleştirmekte. Elbette olmayan bir dosya talebi de gelebilir. Bu durumda HTTP 404 fırlatılır.

getProducts fonksiyonu nispeten daha basit. Tek yaptığı products dizisinin içeriğini JSON formatında sunmak. NewEncoder ve Encode fonksiyonlarını bu iş için kullanıyoruz. Product tipine ait üyelerin JSON çıktısında nasıl isimlendirileceği de yapı tanımı içerisinde yer alıyor. Burada JSON çıktısı içerisindeki alan adlarını değiştirerek kullanmamız mümkün. Bazen domain içerisinde kullanılan niteliklerin, servis olarak sunulduğu kaynaklara farklı isimlerde gösterilmesi tercih edilebilir.

getProduct fonksiyonu temel olarak belli bir kategorideki ürünlerin çıktısını JSON formatında vermek üzere tasarlandı. Çok ilkel bir yapısı var. Gelen adresteki kategori adını basit string ayrıştırma işlemleri ile yakalamaya çalışıyoruz. Tüm ürün listesini dolaşırken talep edilen kategori altında olanları ise yeni bir dizide topluyoruz. Son olarak bu diziyi JSON formatında sunuyoruz (Bir gerçek hayat örneğinde REST Api geliştirmek için tercih edilebilecek Go paketlerini kullanmanızı öneririm)

Bu arada main fonksiyonunun son satırında yer alan ListenAndServe çağrımı kodun çalıştığı makinenin 8084 adresi üzerinden HTTP dinlemesi yapılacağını belirtmekte. Örnekte `http://localhost:8084` şeklinde bir adresin dinlenmesi söz konusu. İstediğiniz serbest bir Portu tercih edebilirsiniz tabii ki. Hatta bu tip n sayıda uygulamayı farklı portlar üzerinden hizmet verecek şekilde kullanıma açabilirsiniz de. N sayıda microservice'in kendi alanları ile ilgili izole edilmiş halde çalıştığını düşünün.

## Çalışma Zamanı Testleri

Sırada testlerimiz var. Öncelikle uygulamamızı çalıştırmamız gerekiyor. Program 8084 adresine gelecek tüm talepleri Console penceresine de loglamakta. Bu mekanizmayı daha da geliştirebiliriz. Biz şimdilik HTTP metodunun tipini, talep edilen adresi ve zamanı bastık. Şimdi tek tek denemeler yapalım.

`http://localhost:8084/home.html`

![gorest_1.gif](/assets/images/2017/gorest_1.gif)

Görüldüğü gibi tasarladığımız HTML sayfasını elde ettik. Burada çok daha şık bir sayfa sunulabilir. CSS kullanarak içeriği zenginleştirebilirsiniz. Biz basit bir HTML içeriğinin görüntülenebileceğini ifade ettik. All Products linki bizi ürün listesini alabileceğimiz sayfaya yönlendirecektir.

`http://localhost:8084/products`

![IhJ94qGxwouZdMgAnkJAG3lhOJ1PiCm9A4cxjnW8pJ6lwWE2AClgRYnCwR8Q1MgAnYQYDFyQ7qXCcTYAKWBFicLBHxDUyACdhBgMXJDupcJxNgApYEWJwsEfENTIAJ2EGAxckO6lwnE2AClgRYnCwR8Q1MgAnYQYAPYdpBnetkAkzAkgCHr1gi4huYABOwgwCLkx3UuU4mwAQsCbA4WSLiG5gAE7CDAIuTHdS5TibABCwJsDhZIuIbmAATsIMAi5Md1LlOJsAELAmwOFki4huYABOwgwCLkx3UuU4mwAQsCfwfJPgZbOJApaQAAAAASUVORK5CYII=](/assets/images/2017/golang-basit-http-web-server-yapimi-01.png)

Bu sefer tüm ürün listesini elde ettik. Hem deeee JSON formatındaaaa. Peki ya belli bir kategori altındaki ürünleri nasıl yakalayabiliriz? Örneğin OEM grubundaki ürünleri almak istersek aşağıdaki gibi bir talepte bulunmamız gerekir.

`http://localhost:8084/products/oem`

![gorest_3.gif](/assets/images/2017/gorest_3.gif)

Bu sefer de OEM kategorisindeki ürün listesini çektiğimizi görebilirsiniz. Tabii olmayan bir kategori girilirse istemci tarafına HTTP 404 fırlatmayı da ihmal etmedik. getProduct fonksiyonu içerisinde ilgili kategoriye bağlı ürün/ürünler yoksa Error fonksiyonundan yararlanrak 404 Not Found durumunu fırlatıyoruz. Bu nedenle aşağıdaki gibi bir talebin sonucu 404 olacaktır.

`http://localhost:8084/products/yokki`

![gorest_4.gif](/assets/images/2017/gorest_4.gif)

Yaptığımız tüm işlemleri sunucu uygulamasına ait console penceresinde izleyebiliriz. Basit detaylar koyduğumuzu fark etmişsinizdir. HTTP metodu, çağrı zamanı ve çağrı yapılan adres bilgisi. Çok daha fazla detay sunulabilir tabii. Geriye dönecek olan cevap, HTTP durum bilgisi, talep yapan istemciye ait bir takım bilgiler (IP gibi) yakalanabilir. Hatta log'lar bir araç ile farklı bir kaynağa da atılabilir. Örneğin bir dosyaya yazdırabiliriz. Bu yazımıza konu olan örnek içinse aşağıdaki çıktılar yeterli görünüyor.

![gorest_5.gif](/assets/images/2017/gorest_5.gif)

## Eksikler

Bu örnekte http paketini basit bir uygulama üzerinden az da olsa tanımış olduk. Ancak routing sistemi çok da kabiliyetli değil. Söz gelimi HandleFunc içerisinde {category} gibi bir yer tutucu kullanamıyor ve bunu ilgili fonksiyon içerisinde kolay bir şekilde ele alamıyoruz. Yani MVC tarafından aşina olduğumuz products/{category} gibi bir bildirimi yapabilmek güzel olurdu. Kullandığımız / işaretine göre ayrıştırma tekniği oldukça riskli ve ilkel. Dolayısıyla ya bir router yazmalıyız ya da hazır olan açık kaynaklardan birisini kullanmalıyız.

Diğer yandan örneğimizde HTTP'nin Post, Put ve Delete gibi diğer metodlarını ele almadık. Örneğin ürün listesine yeni bir ürünü nasıl ekleyebiliriz veya silebiliriz bunu keşfetmemiz gerekiyor. Veri deposu olarak kullandığımız ürün listesi için tercih ettiğimiz dizi de iyi bir seçim değil. Bunun yerine MySQL, Oracle, MongoDB, File veya daha farklı bir sistem tercih edebiliriz. Bu konuların araştırmasını siz değerli okurlarıma bırakıyorum. Eğer fırsatım olursa ben de bu konulara bakacağım zaten. Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
