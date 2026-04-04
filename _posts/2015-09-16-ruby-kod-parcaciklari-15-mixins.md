---
layout: post
title: "Ruby Kod Parçacıkları - 15 (Mixins)"
date: 2015-09-16 15:00:00
categories:
  - Programlama Dilleri
tags:
  - mixin
  - ruby-lang
  - object-oriented-programming
---
Ruby tam anlamıyla nesne yönelimli (Object Oriented) bir dildir. Bunu her fırsatta vurguluyoruz. Bu nedenle bünyesinde temel OOP özelliklerini taşır. Kalıtım (Inheritance) bunlardan birisidir. Ancak Ruby dilinde bir sınıfın aynı seviyede birden fazla sınıftan türemesine izin verilmez (Single Inheritance söz konusudur).

Bir başka deyişle çoklu kalıtım (Multi-Inheritance) desteği bulunmamaktadır. Bunu karşılamak için Module'lerden yararlanılır. Module seviyesindeki fonksiyonellikler Instance veya Class metodları olarak sınıflar içerisine dahil edilerek çoklu kalıtımın karşılanması sağlanır. Bu durum Mixin olarak adlandırılır. Mixin, sınıflara dışarıdan fonksiyonellikler katmanın bir yolu olarak da düşünülebilir.

> Kaynaklardan öğrendiğim kadarı ile Mixin, PHP dilinde kullanılan Trait bileşenine benzetilmektedir.

Şimdi basit bir örnek ile Mixin kullanımını anlamaya çalışalım.

```ruby
module Common
	def getLength(content)
		puts "calculate content length"
	end
	def getBytes(content)
		puts "content's byte array"
	end
	end

module Zip
	def gzip(content,zipAlgo)
		puts "zipping"
	end
	def gunzip(content,zipAlgo)
		puts "unzipping"
	end
end

module Encryption
	def sign(signature,content)
		puts "file sign operation"
	end
	def encrypt(algo,content)
		puts "encrypting"
	end
	def decrypt(algo,content)
		puts "encrypting"
	end
end

class CaseFile
	include Zip
	include Encryption
	include Common
	
	def readFile(path)
		puts "Read File"
	end
end

class Message
	extend Zip
	extend Encryption
end

if __FILE__==$0
	#include (Instance Methods)
	fl=CaseFile.new()
	fl.getLength("some content")
	fl.gzip("winrar","somecontent")
	fl.gunzip("winrar","somecontent")
	fl.sign("X509","somecontent")
	fl.encrypt("Rijndael","some other content")
	fl.decrypt("Rijndael","some other content")
	fl.readFile("c:\someFile.txt")
	puts
	#extend (Class Methods)
	Message.gzip("winrar","somecontent")
	Message.gunzip("winrar","somecontent")
	Message.sign("X509","somecontent")
end
```

Kodun çalışma zamanı çıktısı aşağıdaki gibidir.

![ruby kod parcaciklari 15 mixins 01](/assets/images/2015/ruby-kod-parcaciklari-15-mixins-01.jpg)

Kod parçasında üç Module kullanıldığı görülmektedir. Common, Zip ve Encryption. Her bir modülün kendine has bazı fonksiyonellikleri vardır. Önemli olan nokta CaseFile ve Message isimli sınıflara bu Module'lerin nasıl ilave edildiğidir.

CaseFile içinde include ile bir enjekte söz konusu iken Message sınıfında extend anahtar kelimesinden yararlanılmıştır. Aradaki fark aslında basittir. Include kullanıldığı durumlarda Module fonksiyonelliklerinin kullanılabilmesi için ilgili sınıfa ait nesne örneğinin oluşturulması gerekir. Örnekte, fl değişkeni üzerinden File sınıfının bünyesine dahil ettiği Common, Encryption ve Zip modül operasyonları kullanılabilir. extends kullanıldığı durumda ise sınıfa ait nesne örneği oluşturulmasına gerek yoktur. ClassName.ModuleMethodName notasyonu ile ilgili modül fonksiyonelliği çağırılabilir. Bu nedenle gzip, gunzip ve sign operasyonlarına Message sınıfı üzerinden direkt olarak ulaşılabilinir. Aslında örnekteki bileşenler arası ilişkileri belki de aşağıdaki şekilde görüldüğü gibi ifade edebiliriz.

![ruby kod parcaciklari 15 mixins 02](/assets/images/2015/ruby-kod-parcaciklari-15-mixins-02.jpg)

Mixin esas itibariyle ortak fonksiyonelliklerin farklı sınıflar arasında paylaştırılmasında rol oynamaktadır. Aynı operasyonları ve kod parçalarını tekrarlamak yerine gruplandırıp bir modül içerisine almak ve Context bazında ayrıştırarak ihtiyaç duyan sınıflar içerisine yerleştirmek için tercih edilen bir kullanım şeklidir.

Böylece geldik bir Ruby Kod Parçacığının daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse.
