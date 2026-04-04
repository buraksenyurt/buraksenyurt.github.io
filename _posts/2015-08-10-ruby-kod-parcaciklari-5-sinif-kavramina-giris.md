---
layout: post
title: "Ruby Kod Parçacıkları - 5 (Sınıf Kavramına Giriş)"
date: 2015-08-10 19:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - class
  - object-oriented-programming
---
Bilindiği üzere Ruby nesne yönelimli bir programlama dilidir. Bu yüzden Ruby dilinde her şey bir nesne olarak düşünülür. Dolayısıyla OOP dillerin Kalıtım (Inheritance), Encapsulation (Kapsülleme), Çok Biçimlilik (Polymorphism) gibi temel özelliklerini bünyesinde barındırır. Elbette en küçük yapı taşı sınıflardır (Class). İzleyen kod parçacığında basit olarak bir sınıfın nasıl tanımlandığına yer verilmektedir. Bu anlamda değişken türlerinden (Instance,Class ve Global Variable), sınıf yapıcılarından (initialize), nesne örnekleme operasyonlarından (new), standart sınıf içi metod tanımlamalarından (def) ve metod ezme (overriding) gibi işlemlerden kısaca bahsedilmektedir.

> Ruby Kod Parçacıkları serisi

```bash
#1
$levelLimit=200 #Global Variable
#2
class LevelController
def increaseLevel(value)
$levelLimit=$levelLimit+value
end

def decreaseLevel(value)
$levelLimit=$levelLimit-value
end

end

#3
class Player
	@@playerCount=0#4 Class Variable
	def initialize(name,level)#5 Yapıcı metod
		@name=name
		@level=level
		@@playerCount+=1
	end

	def name
		@name#6 Instance Variable
	end

	def level
		@level#Instance Variable
	end

	def currentPlayerCount
		@@playerCount
	end

	def isUnderLevel
		@level<$levelLimit
	end

	def run()
		puts "Run #{@name} runn!"
	end

	#7 Overriding
	def to_s()
		"#{@name}(#{@level})"
	end
end

if __FILE__==$0
	burki=Player.new("burki",350)#8 Create Instance
	puts burki.to_s+" created"
	puts "Current player count#{burki.currentPlayerCount}"
	tubi=Player.new("Tubi",400)
	puts tubi.to_s+" created"
	puts "Current player count#{tubi.currentPlayerCount}"
	halilo=Player.new("Halilo",150)
	puts halilo.to_s+" created"
	puts "Current player count#{halilo.currentPlayerCount}"
	putsburki.name #9
		burki.run
	puts burki.inspect
	puts tubi.inspect
	puts halilo.inspect
	puts "halilo is under level"if halilo.isUnderLevel#10 Conditional Statement
	lvl=LevelController.new()#11 Default Constructor
	lvl.decreaseLevel(100)
	puts "new level is#{$levelLimit}"
	puts "halilo is under level"if halilo.isUnderLevel
end
```

![9k=](/assets/images/2015/ruby-kod-parcaciklari-5-sinif-kavramina-giris-01.jpg)

- #1 numaralı satırda bir Global Variable tanımlaması söz konusudur. Sınıflar arasında ve sınıf sınırları dışında kalan metodlarda bu değişkenlere erişilebilinir. Global Variable'lar dolar işareti ile başlar.
- #2 ve #3 de LevelController ve Player isimli iki sınıf tanımlaması yapıldığı görülebilir. LevelControllersınıfında $levelLimit isimli global değişkene erişen iki fonksiyon yer almaktadır. Bu fonksiyonlarıLevelController nesne örnekleri üzerinden kullanabiliriz ki #12de bu işlem icra edilir.
- Player sınıfı içerisinde ise daha farklı üyeler yer almaktadır. @@playerCount bir Class Variable'dır. Bu değişkenlere aynı sınıfın farklı nesne örnekleri üzerinden ulaşabiliriz. Değişkene ilk değer olarak 0 verilse de, initialize isimli metod içerisindeki artım tüm Player nesne örnekleri için ortaktır. Bu yüzden Playernesneleri üretildikçe initialize metodundaki çağrı sebebi ile oyuncu sayısı 1er artış göstermektedir.
- #5de yer alan initialize metodu ile Player sınıfına ait bir nesne örneklenirken ilk değer atamaları gerçekleştirilir. name ve level isimli parametre değerleri metod gövdesinde @name ve @level isimliInstance Variable'larına atanır. Instance Variable'lar @ işareti ile başlarlar ve bir sınıf içindeki herhangi bir konumdan kullanılabilirler. Bu yüzden initialize metodu içerisinde değerleri atanan Instance Variable'lar, name ve level isimli metod bloklarında (#6) kullanılabilmişlerdir.
- name ve level isimli metodlar ile bir Player nesne örneğinin o anki isim ve seviye bilgisine ulaşabiliriz. Bunun için ilgili metodların bloklarında yer alan @name ve @level değişkenlerinin geri döndürülmesi yeterlidir (#9daki erişime bakalım).
- Bu arada güncel oyuncu sayısını işaret eden @@playerCount isimli Global Variable değerinincurrentPlayerCount isimli metod ile geriye döndürüldüğüne dikkat edelim.
- Ruby dilinde de üst sınıflardan gelen metodların ezilmesi de mümkündür. Bu #7 nolu satırda örneklenmektedir. Standart olarak kullanılan to_s metodunun ezilmesi işlemi gerçekleştirilmiştir.(C# çılar için; Object tipinden gelen ToString () metodunun override edilmesi işlemi olarak düşünülebilinir)
- Bir sınıfa ait nesne örneğinin oluşturulmasında #8deki gibi new metoduna başvurulur. new metodu aslında sınıfın initialize metoduna parametre göndermektedir.
- Elbette bir sınıf örneğini varsaylan yapıcı metod ile (C#çı olduğum için Default Constructor olarak yorumluyorum) oluşturabiliriz. #11 de new metodunun buna istinaden bir kullanımı söz konusudur.
- Çalışma zamanı çıktılarına bakıldığında özellikle inspect çağrısı sonucu üretilen Player örneklerindeki hexadecimal değerlere dikkat edilmelidir. Burada her Player nesne örneği için ayrı birer değer üretildiği gözden kaçmamalıdır.
- #10 numaralı satırda halilo isimli Player örneğinin isUnderLevel değerinin bir Statement Modifier ile kullanıldığına dikkat edelim.
- name, level ve currentPlayerCount gibi metod bloklarında diğer dillerden aşina olduğumuz returnanahtar kelimesinin kullanılmadığına dikka edilmelidir.(Aslında kullanılabilir de)

Böylece geldik bir Ruby Kod Parçacığı bölümün daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.