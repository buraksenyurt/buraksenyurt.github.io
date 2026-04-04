---
layout: post
title: "Ruby Kod Parçacıkları 17 - (YAML ve Binary Serileştirme)"
date: 2015-10-11 04:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - yaml
  - serialization
  - binary-serialization
---
Bir önceki kod parçacığında geliştirici tanımlı bir sınıf koleksiyonunun JSON formatından nasıl serileştirilebileceğini incelemiştik. Ruby dilinde dahili (built-in) olarak gelen serileştirme kütüphaneleri de vardır (YAML ve Binary) Tahmin edeceğiniz üzere duruma göre bu serileştirme çeşitlerinden birisinin kullanılması tercih edilebilir. Aşağıdaki örnek kod parçacığında bu biçimdeki serileştirme ve ters-serileştirme işlemlerinin nasıl yapıldığı ele alınmaktadır.

```ruby
# encoding: ISO-8859-9
require 'yaml'
=begin
YAML(Yet Another Markup Language) ve Binary Serileştirme
=end

class Product
	attr_accessor :ID
	attr_accessor :Title
	attr_accessor :Price
	attr_accessor :Measurement

	def initialize(id,title,price,measure)
		@id,@title,@price,@measure=id,title,price,measure
	end

	def to_s
		"#{@id}-#{@title}(#{@price})#{@measure.to_s}"
	end
end

class Measurement
	attr_accessor :Type
	attr_accessor :Unit

	def initialize(type,unit)
		@type,@unit=type,unit
	end

	def to_s
		"[#{@type}:#{@unit}]"
	end
end

if __FILE__==$0
	pcMeasurement=Measurement.new "adet",1
	pc=Product.new 1001,"EyçPi Pavilyon 2000",1500,pcMeasurement
	mouseMeasurement=Measurement.new "adet",1
	mouse=Product.new 2002,"Mikropsoft Wireless Mouse",50,mouseMeasurement
	lgoMeasurement=Measurement.new "parça",845
	lgo=Product.new 3045,"Lego Siti - Betmen",150,lgoMeasurement
	basket=[pc,mouse,lgo]
	yamlS=YAML::dump(basket)
	yamlFile=File.new("Products.yaml","w")
	yamlFile.syswrite yamlS
	puts yamlS
	yamlDs=YAML::load(yamlS)
	puts "YAML Deserialized object's class type: #{yamlDs.class}"
	puts yamlDs[2].to_s
	binaryS=Marshal::dump(basket)
	binaryFile=File.new("Products.bin","w")
	binaryFile.syswrite binaryS
	puts binaryS
	binaryDs=Marshal::load(binaryS)
	puts "Binary Deserialized object's class type: #{binaryDs.class}"
	puts binaryDs[1].to_s
end
```

Uygulama içerisinde iki sınıf kullanılmaktadır. Product ve Measurement. Measurement sınıfı aynı zamanda Product sınıfı içerisindeki niteliklerden birisidir. Uygulama basit olarak Product tipinden bir diziyi ve elamanlarını, sırasıyla YAML ve Binary serileştirmeye tabii tutmaktadır. Sonuçlar Products.yaml ve Products.bin olarak aynı klasöre yazılmaktadır. Tamin edileceği üzere yaml uzantılı dosya içerisinde dizinin YAML formatında serileştirilmiş versiyonu bulunmaktadır. Bin uzantılı dosyada ise binary serileştirilmiş versiyonu. Programın çalışma zamanı çıktıları aşağıdaki gibidir.

![Z](/assets/images/2015/ruby-kod-parcaciklari-17-yaml-ve-binary-serilestirme-01.jpg)

Serileştirilen dosya içerikleri ise aşağıdaki gibidir.

Önce yaml içeriği

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-17-yaml-ve-binary-serilestirme-02.jpg)

ve Binary versiyonu

![Z](/assets/images/2015/ruby-kod-parcaciklari-17-yaml-ve-binary-serilestirme-03.jpg)

Uygulamanın iki temel noktası vardır. YAML ve Binary tipteki serileştirme işlemleri Ruby içerisinde var olan modüllerden yararlanılarak gerçekleştirilir. Bu işlemler için YAML ve Marshal modüllerinden faydalanılmaktadır. Aslında serileştirme işlemi son derece basittir. Bunun için dump fonksiyonu kullanılır. Parametre olarak serileştirilmek istenen nesne örneği verilir. Ters serileştirme operasyonu içinse load metodundan yararlanılmaktadır. load metoduna serileştirilmiş içeriğin verilmesi yeterlidir.

Örnekte ters serileştirme operasyonu doğrudan serileştirilmiş tipler üzerinden yapılmıştır. (İlgilenen arkadaşlarımız isterlerse dosyalar içerisine serileştirilmiş içerikleri, yine dosyadan okuma suretiyle ters serileştirme işlemine tabi tutabilirler. Güzel bir antrenman olur)

Son iki yazıda ele aldığımız serileştirme teknikleri büyük çaplı projelerde oldukça önemlidir. Verilerin kalıcı olarak saklanması noktasında, nesnel içeriklerin insan gözüyle okunabilir olarak veya performans kriterleri gibi sebeplerden daha az yer tutacak şekilde saklayabilmek gerektiği noktalarda serileştirme vazgeçilmezlerdendir.

Üstelik JSON ve YAML gibi formatlar kürsel standartlardandır. Ön yüzlerde, servisler arası iletişimlerde, RESTFull modeldeki web sayfalarında ve pek çok noSql sisteminde JSON'un yeri vardır. Burada unutulan noktalardan birisi de XML serileştirmedir. Acaba Ruby ile bir nesne içeriğinin XML formatında serileştirilmesi mümkün müdür? Şu anda merak ettiğim bu konuyu ilerleyen zamanlarda araştırıyor olacağım. Böylece geldik bir kod parçacığımızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümküse.

**Kaynaklar**

YAML Hakkında: [https://en.wikipedia.org/wiki/YAML](https://en.wikipedia.org/wiki/YAML) ve [http://www.yaml.org/](http://www.yaml.org/)
