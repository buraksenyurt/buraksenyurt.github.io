---
layout: post
title: "Ruby Kod Parçacıkları 16 - (JSON Serileştirme)"
date: 2015-09-22 03:30:00
tags:
  - ruby-lang
  - serialization
  - binary
  - binary-serialization
  - json
  - json-serialization
categories:
  - Programlama Dilleri
---
Aslında bu kod parçasında temel dosya giriş çıkış işlemlerini (IO operasyonları diyelim) ele almayı planlamıştım. Ancak konuyu araştırırken dosya içerisine ne yazabilirim sorusuna denk geldiğimde, bir nesne koleksiyonunu aktarmanın uygun olacağını düşündüm. Hal böyle olunca ortaya "hangi fortmatta?" sorusu çıktı.

Malum nesne yönelimli bir dünyada geliştirme yapıyoruz. Domain içerisinde dolaşan nesne örnekleri mevcut. Çok doğal olarak bu nesne örneklerine ait dizi veya koleksiyonların zaman zaman kalıcı olarak saklanması gerekiyor. Depolama alanları veritabanı olabileceği gibi basit metin tabanlı dosyalar dahi olabiliyor. Hatta ilişkisel bir veritabanı sistemi (Relational Database Management System - RDBMS) olabileceği gibi son yılların popüler oyuncusu NoSQL de olabilir. Veri, kalıcı olarak uygulama ile aynı lokasyonda bir yerlere yazılabileceği gibi, servisler arasında dolaşabilir de...

Sözü fazla uzatmadan ben bu kod parçacığımızın temel konusuna geleyim. Amacımız bir sınıfa ait nesne dizisi içeriğini JSON (Javascript Object Notation) formatına dönüştürüp fiziki bir dosyaya yazmak ve dosyadan okuma yapıp aynı içeriği nesne olarak çalışma zamanında kullanmak.

İlk olarak kod parçalarımızı aşağıdaki gibi yazalım.

```ruby
# encoding: ISO-8859-9
require 'json'
=begin
Aşağıdaki kod parçasında kullanıcı tanımlı bir tipe ait
dizinin JSON formatına serileştirilmesi, fiziki bir dosyaya yazılması
ve dosyadan okunan string içeriğin(JSON tipinde) tekrar nesnel
hale getirilmesi işlemleri ele alınmaktadır.
=end
class Person
	attr_accessor :name,:salary,:position
	def initialize(name,salary,position)
		@name=name
		@salary=salary
		@position=position
	end
	def to_json(*a)
		{
		"json_class" => self.class.name,
		"data"    => {"name" => @name, "salary" => @salary,"position" => @position}
		}.to_json(*a)
	end
	def self.json_create(object)
		new(object["data"]["name"], object["data"]["salary"], object["data"]["position"])
	end
	def to_s
		"#{@name}-(#{@salary}K),#{@position}"
	end
end

if __FILE__==$0
	burk=Person.new("burk",1000,"Developer")
	tubi=Person.new("tubi",2000,"CEO")
	matz=Person.new("metz",5500,"Compoany Owner")
	employees=[burk,tubi,matz]
	jsonContent = employees.to_json
	puts jsonContent
	employeeFile=File.new("Person.json","w")
	employeeFile.syswrite jsonContent
	fileConent=File.read("Person.json")
	incomingArray=JSON.load(fileConent)
	puts incomingArray.class
	puts incomingArray[0].to_s
	puts "#{incomingArray[1].name}-#{incomingArray[1].position}"
end
```

Örneğin çalışma zamanı çıktısı aşağıdaki gibidir.

![ruby kod parcaciklari 16 json serilestirme 01](/assets/images/2015/ruby-kod-parcaciklari-16-json-serilestirme-01.jpg)

Dikkat edileceği üzere Person nesne örneklerinden oluşan dizi, JSON formatına dönüştürülebilmiş ve hatta ilgili formattan tekrar nesne olarak ayağa kaldırılabilmiştir. Uygulamanın en kritik özelliklerinden birisi ürettiği JSON içeriğidir. Eğer jsonviewer.stack.hu gibi online bir siteden sonuçlara bakarsak aşağıdaki gibi bir içeriğin üretildiğini görebiliriz.

![ruby kod parcaciklari 16 json serilestirme 02](/assets/images/2015/ruby-kod-parcaciklari-16-json-serilestirme-02.jpg)

Şimdi kod parçasında neler olduğuna bir bakalım.(Bu örneğimizde daha önceden değinmediğimiz kısımlar da bulunmakta)

- Kodda Person isimli bir entity kullanılmaktadır. name, salary ve position isimli üç niteliği vardır. Bu niteliklere değer yazabilir ve değerlerini Person nesne örnekleri üzerinden okuyabiliriz. Bunun için attr_acceossor tanımlamaları yapılmıştır.
- Uygulama içerisinde Türkçe karakterler kullanılmaktadır. Normal şartlarda Encoding sorunu yaşanacağından dosyanın başında Türkçe karakter seti kullanılacağı ifade edilmiştir (#0)
- Bazen uygulama içerisine birden fazla satırdan oluşan yorum parçaları eklenmesi gerekebilir. Bu satırlar özellikle teknik dokümantasyonu çıkartan üçüncü parti uygulamalar açısından da önemlidir. Ruby'de bu tip kullanımlar için #2 de başlayan =begin ve =end blokları kullanılır.
- Kodun en kritik virajı JSON serileştirmedir. Serileştirme ve ters serileştirme işlemleri için json modülü kullanılır. Bu yüzden #1 numaralı kısımda require ile kullanılacak module bildirimi yapılmıştır.
- Serileştirme işleminde kilit nokta Person tipinin veri içeriğinin JSON formatında nasıl değerlendirilebileceğidir. Çalışma zamanı bunu nasıl bilecektir.(Burada biraz efor sarfedilmesi gerekiyor) Belki bir Newtonsoft Nuget paketinin rahatlığı olmayabilir ama yapılması gerekenler çok zor değil. #3 nolu kısımda tanımlanan to_json metodu nesne içeriğinin JSON formatına dönüştürülmesinde devreye girer. #4 numarada yer alan json_create fonksiyonu ise, bir JSON içeriğinden gerekli nesne örneğinin inşa edilmesinde kulanılmaktadır. Bu iki metodun yazılması sayesinde #5 ve #6 numaralı satırlardaki işlemler gerçekleştirilebilmektedir.
- #5 numaralı satırda employees isimli array'in JSON formatına dönüştürülmesi işlemi ele alınmıştır.
- #6 numaralı satırda ise person.json dosyasından okunan içeriğin load metodu ile tekrardan Array haline getirilmesi işlemi söz konusudur.
- Pek tabi bu içeriğin yazıldığı ve okunduğu yer fiziki disk üzerinde yer alan bir dosyadır. Dosya yazma işlemleri için File sınıfının new metodundan yararlanılır. new metodunun kullanımı oldukça kolaydır. İlk parametre dosya adı ikinci parametre ise işlem modudur. Örnekte yer alan w (write) anlamına gelmektedir. Yani dosya yazma modunda açılarak oluşturulmuştur. Buna göre json içeriğinin dosyaya yazılması işlemi #8 numaralı satırdaki syswrite metodu ile gerçekleştirilir.

Diğer dosya modlarını şu şekilde özetleyebiliriz.

- r İşaretçi dosya başına konumlandırılmak suretiyle sadece okunabilir mod.
- r+ İşaretçi dosya başında konumlandırılmak suretiyle okuma ve yazma modu.
- w Sadece yazma modu. Eğer dosya varsa üzerine yazılır, yoksa yeni bir tane oluşur.
- w+ Okuma yazma modu. Dosya varsa üzerine yazılır. Eğer yoksa yeni bir tane hem okuma hem yazma modunda açılır.
- a Sadece yazma amaçlı ekleme (Append) modu. Dosya mevcut ise işaretçi dosyanın sonuna konumlandırılır. Yani dosyaya ardışıl olarak içerikler eklenebilir.
- a+ Ekleme (Append) modunun okunabilir ve yazılabilir versiyonu. Dosya yoksa yeni bir tane oluşturulur. Dosya varsa işaretçi dosya sonuna konumlandırılır. Dosya içeriğinin okunması da oldukça kolaydır. #9 numaralı satırda File sınıfının read metodu ile person.json içeriği fileContent isimli değişkene atanmıştır.
- JSON tipinden olan içeriğin ters serileştirilmesi sonucu elde edilen örnek Array sınıfına aittir. #10 daki çalışma zamanı çıktısı bunu göstermektedir.

Böylece geldik bir kod parçacığımızın sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse.
