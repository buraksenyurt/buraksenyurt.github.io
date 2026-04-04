---
layout: post
title: "Ruby Kod Parçacıkları - 8 (Kalıtım/Inheritance)"
date: 2015-08-16 09:00:00
tags:
  - ruby-lang
  - inheritance
  - object-oriented-programming
categories:
  - Programlama Dilleri
---
Ruby, nesne yönelimli (Object Oriented) bir dil olduğu için kalıtım (Inheritance) ilkesi karakteristiklerini de taşımaktadır. En temel haliyle var olan bir tipin özelliklerini ve fonksiyonelliklerini alt sınıflara taşıyabildiğimiz (alt sınıfta kullanabildiğimiz ve hatta gerekirse ezebildiğimiz) kalıtım ilkesinin Ruby tarafındaki uygulanış biçimi oldukça kolaydır. Gelin basit bir kod parçacığı ile konuyu anlamaya çalışalım. Aşağıdaki kod parçasında Figure isimli sınıftan türetme yoluyla oluşturulan Human ve Alien isimli varlıklar yer almaktadır. Ayrıca Zork isimli Alien sınıfından türeyen bir varlık daha söz konusudur.

```ruby
class Figure

	def initialize(code,nickName) #constructor
		@code,@nickName=code,nickName #0
	end

	def code #accessor method
		@code
	end

	def nickName #accessor method
		@nickName
	end

	def move(direction,stepSize) #instance method
		"moving to #{direction} with #{stepSize} steps"
	end

	def to_s #1
		"Code: #{@code}, NickName: #{@nickName}"
	end

end

class Human < Figure #2

	def initialize(ability,nickName)
		super(-1,nickName) #3
		@ability=ability
	end

	def to_s #overriding
		"Code: #{@code}, NickName: #{@nickName}, Abilitiy: #{@ability}" #4
	end

end

class Alien < Figure #2

	def initialize(mask,code,nickName)
		super(code,nickName) #3
		@mask=mask
	end

	def to_s #overriding 
		super + " Mask: #{@mask}" #5
	end

	def move(direction,stepSize) #6
		"#{stepSize} steps to #{direction}"
	end
end

class Zork < Alien #9

	def hire
		@hire
	end

	def initialize(hire,code,nickName,mask) #10
		super(mask,code,nickName)
		@hire=hire
	end

	def to_s
		super+" #{@hire}" 
	end

	def getFigures #11
		@code+" "+@nickName
	end

end

if __FILE__==$0

	baseFigure=Figure.new("someCode","some NickName")
	#puts baseFigure.inspect
	nucox=Alien.new("Red","ALN101","nu-cox")
	puts nucox.to_s
	puts nucox.move("left",10) #7
	halilo=Human.new(1002,"Halilo")
	puts halilo.to_s
	puts halilo.move("downside",5) #8
	bettleJuice=Zork.new("Numinice di reye tuba kitaa","ZRK-76","Bettle Juice","Zen")
	puts bettleJuice.to_s
	puts bettleJuice.getFigures #12

end
```

ve tabii çalışma zamanı sonuçlarımız.

![9k=](/assets/images/2015/ruby-kod-parcaciklari-8-kalitim-inheritance-01.jpg)

Gelelim kod parçacığımız ile ilgili kısa notlarımıza.

- Figure, diğerleri için bir super class olarak tasarlanmıştır (.Netçiler için base class diyelim) Yapıcı metodu içerisinde parametre olarak gelen code ve nickName değerleri, Instance Variable'lara atanmıştır (#0) Çoklu atama işlemine dikkat edelim. (Çık gizel değil mi?:))
- Figure sınıfı code ve nickName değerlerini dışarıya Accessor metodlar yardımıyla sunmaktadır. to_s metodu ezilmiş olup (#1), move isimli bir fonksiyonellik sunmaktadır. Bu fonksiyonellik tahmin edileceği üzere türeyen sınıf örnekleri üzerinden kullanılabilir (Ama ezilebilirde;))
- İlk seviye türetmeler #2 nolu kod satırlarında icra edilmektedir. Human ve Alien sınıfları, Figure sınıfından türetilmiştir (Derived Class)
- Hem Human hem de Alien sınıflarının yapıcı metodlarında super anahtar kelimesinin kullanımı gözden kaçmamalıdır. (#3) super ile o anda bulunulan metodun üst sınıftaki karşılığı çağırılmaktadır. Dolayısıya bir sınfın yapıcı metodundan bir üst sınıfınkine ulaşılabilir. Bu durumda Human ve Alien üst sınıfta tanımlı code ve nickName değerlerine de sahiptir. Human sınıfı ability, Alien sınıfı ise mask nitelikleri ile üst sınıftan farklılaşmaktadırlar.
- Human ve Alien sınıfları kendi içlerinde to_s metodunu ezmişlerdir. Her iki metod için de farklı kullanımlar söz konusudur. Human sınıfına ait to_s metodu içerisinde dikkat edileceği üzere super tipin niteliklerine erişilmektedir.(#4) Alien sınıfında ezilen to_s metodunda ise super anahtar kelimesi kullanılmıştır. Bu durumda bir üst sınıfın (Figure) to_s metodunun çağırıldığını ifade edebiliriz.
- Alien sınıfının farklı yanlarından birisi de üst sınıfta tanımlı olan move isimli fonksiyonelliği ezmiş olmasıdır. (#6) Bu nedenle #7 numaralı satırın çağırılması halinde Alien sınıfı içerisindeki move metodu işletilmiştir. #8 numaralı satırda ise Figure isimli üst sınıfın move fonksiyonelliği devreye girmiştir. Yani üst sınıfta tanımlı operasyonlar alt sınıfta ezildiklerinde, nesne örneği üzerinden çağırılan operasyon tanımlı olduğu sınıfa ait olmaktadır.
- #9 numaralı satırda Alien sınıfından türeyen Zork isimli bir sınıf söz konusudur. hire isimli ayrı bir niteliği vardır. Zork sınıfı Alien sınıfından, Alien sınıfı ise Figure sınıfından türemiştir. Bu nedenle #10 numaralı satırda yer alan kullanım şekli dikkate değerdir. Nitekim super ile çağırılan metod bir üst sınıfın (Alien) yapıcısıdır. Alien sınıf içindeki yapıcı da bir üst sınıfın (Figure) yapıcısını çağırmaktadır. Dolayısıyla en alt seviyeden en üst seviyeye kadar parametre taşıması mümkün hale gelmiştir. #11 numaralı satırda yapılan tanımlama bu anlamda kayda değerdir. Nitekim en üst sınıfta yer alan code ve nickName niteliklerine erişilmektedir (#12nci satırın çalışma zamanı çıktısına bakın)

Olan olayları aşağıdaki şema yardımıyla biraz daha net anlayabiliriz.(Accessor'lar ve move metodları grafiğin kolay okunabilmesi amacıyla çıkartılmışlardır)

![9k=](/assets/images/2015/ruby-kod-parcaciklari-8-kalitim-inheritance-02.jpg)

Bu kod parçacığı ile Ruby programlama dilinde kalıtım konusunun nasıl değerlendiriliği temel seviyede değerlendirmeye çalıştık. Elbette daha ileri seviye konular da var. Bunları ilerleyen zamanlarda değerlendireceğiz. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
