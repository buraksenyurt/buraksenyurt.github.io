---
layout: post
title: "Ruby Kod Parçacıkları - 14 (Module Kullanımı)"
date: 2015-09-10 08:00:00
tags: []
categories:
  - Programlama Dilleri
---
Module’leri sınıf değişkenleri, sınıflar, metodlar ve sabitleri (Constant) içerisinde barındırabilen isim alanları (namespace) olarak düşünebiliriz. Özellikle projelerin büyüdüğü durumlarda kullanılan tip veya metodların çakışmasını engellemek, kod tekrarlarının önüne geçmek (DRY-Don'r Repeat Yourself), bakım maliyetlerini azaltmak ve özellikle aynı iş alanına (Domain) özgü operasyonları anlamlı isim alanlarında konuşlandırabilmek maksadıyla tercih edilirler.

Bununla birlikte Ruby dilinde bir tipin n sayıda tipten aynı anda türemesine izin verilmemesi söz konusudur. Yani bir tip tek bir diğer tipten türeyebilir. Bu yüzden modüller aynı seviyede çoklu kalıtımı (Multi-Inheritance) desteklemek amacıyla Mixin olarak da değerlendirilirler.

Modüller çok doğal olarak örneklenemezler (Yani bir sınıf örneği oluşturur gibi modül örnekleri oluşturulamaz) Modüller arası kalıtım ve bu şekilde oluşan bir modül hiyerarşisi söz konusu değildir. İç içe modül geliştirilmesi ise mümkündür (Nested Modules). Modüllerin, harici modüllerde veya diğer projelerde kullanılması için include anahtar kelimesinden yararlanılır.

Aslında OOP’e ihtiyaç duyulmayan noktalarda Module kullanılmasının önerildiğine şahit oluruz. Yani belirli operasyonları gerçekleştirmek için sınıfa/sınıflara gerek olmayabilir. Sadece fonksiyonelliklerin olması yeterlidir. Bu gibi durumlarda ilgili fonksiyonellikleri içeren modüller tercih edilebilirler. Örneğin şifreleme işlerini ele alacak ve projenin genelinde kullanılacak bir kaç fonksiyonelliğe gereksinim varsa, bunun için sınıf yazılmasına gerek olmayabilir. Sadece bir Module ve içerisine konulacak bir kaç metod çoğunlukla yeterli olacaktır. Aslına bakılırsa bu operasyonların modüle olmaksızın global fonksiyon olarak tanımlanması da mümkündür. Ne var ki böyle bir oluşum sonrası aynı isimli fonksiyonların çakışması ihtimali de vardır. Ayrıca şifreleme ile ilgili operasyonların buna uygun bir isim alanı altında toplanması modülerlik açısından önemlidir.

Dilerseniz basit bir örnek ile Module kullanımını incelemeye çalışalım. Örnekte iki farklı Ruby dosyası kullanılmaktadır. UsingModules.rb isimli dosya içerisinde, Serializer.rb dosyasında yer alan Serializer modülü'de referans edilmiş ve ele alınmıştır. Kod içerikleri aşağıdaki gibidir.

Serializer.rb içeriği

```ruby
module Serializer
	def self.serialize(data)
		puts "#{data} serilestiriliyor"
	end

	def self.deserialize(data)
		puts "#{data} ters serilestiriliyor"
	end
end
```

UsingModules.rb içeriği

```ruby
$LOAD_PATH << '.'
require "Serializer"
module Grid
	DEFAULT_PROVIDER="MONGODB"
	DEFAULT_TIMEOUT=1000
	include Serializer
	
	def self.configure
		puts "ortam #{DEFAULT_PROVIDER} icin set edildi"
	end

	class Connection
		def self.connect(conStr)
			puts "#{conStr} icin baglanti saglaniyor"
		end
		
		def self.disconnect(conStr)
			puts "#{conStr} baglantisi kesiliyor"
		end
	end

	module Cloud
		def self.connectToService(url)
			puts "#{url} adresine baglanti gerceklestirilecek"
		end

		def self.send(someData)
			puts Serializer::serialize(someData)
			puts Serializer::deserialize(someData)
		end
	end
end

if __FILE__==$0
	puts Grid::DEFAULT_PROVIDER
	Grid::configure
	Grid::Cloud::connectToService("http://somedomain/someService.svc")
	Grid::Cloud::send("Bir veri")
	Grid::Connection.connect("myMongoDb connection")
	Grid::Connection.disconnect("myMongoDb connection")
end
```

![9k=](/assets/images/2015/ruby-kod-parcaciklari-14-module-kullanimi-01.jpg)

Gelelim kod parçacığımız ile ilişkili notlarımıza.

- Module içerisinde tanımlanan fonksiyonlarda self anahtar kelimesinin kullanıldığına dikkat edilmelidir. Module seviyesindeki bu operasyonlar, [sınıf metodu](/2015/08/13/ruby-kod-parcaciklari-7-object-method-class-method-public-private-protected/) olarak ele alınırlar.
- Module içerisinde tanımlanan Constant'lara (DEFAULT_PROVIDER ve DEFAULT_TIMEOUT gibi) ve sınıf metodlarına MODULE_ADI::UYEADI notasyonu ile erişilir.
- Bir Module içerisinde metod ve sabit tanımlamaları yapılabileceği gibi sınıf ve iç module bildirimleri de yer alabilir. Örnekte yer alan Grid modülü içerisinde Connection isimli bir sınıf ve Cloud isimli bir Module tanımı yer almaktadır. Bu alt modül veya sınıflara erişmek için yine MODULE_ADI::SINIF_ADI/MODULE_ADI notasyonundan yararlanılır.
- Farklı bir dosyada konuşlandırılan Module'leri bir sınıf içerisinde ya da başka bir modülün tamamında kullanmak için include MODULE_ADI ifadesinden yararlanılır. UsingModules.rb kodunun ilk iki satırında ilgili modülün yer aldığı dosyanın aynı klasörde aranması gerektiği $LOAD_PATH ile belirtilmiştir. Bir sonraki satırda yer alan require ifadesi ile de Serializer dosyası işaret edilmiştir.

Böylece geldik bir kod parçacığımızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse.
