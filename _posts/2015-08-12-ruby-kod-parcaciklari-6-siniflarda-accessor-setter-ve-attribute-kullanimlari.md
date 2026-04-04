---
layout: post
title: "Ruby Kod Parçacıkları - 6 (Sınıflarda Accessor, Setter ve Attribute Kullanımları)"
date: 2015-08-12 12:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - accessor
  - setter
  - attribute
---
Nesne yönelimli dillerde sınıfların birer varlık (Entity) olarak düşünüldüğüne sıklıkla şahit oluruz. Bu sayede bir Domain'e özgü gerçek dünya varlıklarının tasarlanması ve örneklenerek kullanılması mümkün hale gelir. Üstelik Domain içinde dolaşımda olacak anlamlı nesneler ortaya çıkar. Çok doğal olarak her bir varlığın karakteristik özellikleri bulunur. Nitelik (attribute) olarak da düşünebileceğimiz bu özellikler ilgili varlığın çalışma zamanı (Runtime) durumu hakkında bilgiler taşır. Aslında.Netçi gözüyle bakıldığında sınıf ve özelliklerinden bahsettiğimizi anlamışsınızdır.

Ruby dili içinde sınıf ve özellikler söz konusudur. Aslında özellik (property) şeklinde bir kavram yerine Java'dakine benzer metod kullanımları yer alır. Şimdi dilerseniz bir sınıfın varlığını tanımlayan değerlerini nasıl tanımlayabileceğimize bakalım. Aşağıdaki kod parçacığını bu anlamda ele alabiliriz.

```ruby
class ZoneV1

	def title #1 Accessor Method
		@title
	end

	def capacity=(value) #3 Setter Method
		@capacity=value
	end

	def capacity #2 Accessor Method
		@capacity
	end

	def initialize(title,color,capacity) #0
		@title=title
		@color=color
		@capacity=capacity
	end

	def to_s
		"#{@title}(#{@color}-#{@capacity})"
	end

end

class ZoneV2
	attr_reader :title #5
	attr_writer :color  #6
	attr_accessor :capacity  #7
	def initialize(title,color)
		@title=title
		@color=color
	end

	def to_s
		"#{@title}(#{@color}-#{@capacity})"
	end
end

if __FILE__==$0
	monsterPark=ZoneV1.new("Monster of Universe","Black",180)
	puts monsterPark.to_s
	monsterPark.capacity=200 #4
	puts "New Capacity #{monsterPark.capacity}"
	southPark=ZoneV2.new("South park","Gold")
	puts southPark.to_s
	southPark.capacity=15
	puts "New Capacity #{southPark.capacity}"
	southPark.color="Red"
	puts southPark.to_s
end
```

![9k=](/assets/images/2015/ruby-kod-parcaciklari-6-siniflarda-accessor-setter-ve-attribute-kullanimlari-01.jpg)

Örnekte ZoneV1 ve ZoneV2 isimli iki sınıf (Class) tanımı söz konusudur. Her iki sınıfta temel olarak title, color ve capacity isimli özelliklere sahiptir. Ancak tanımlanma şekilleri nitelik (attribute) kavramını aktarabilmek adına farklıdır. Şimdi bunları maddeler halinde inceleyelim.

- Aslında her iki sınıfın veri taşıyan asıl değişkenleri birer Instance Variable'dır. ZoneV1 sınıfında @title, @color ve @capacity değişkenlerine yapıcı metod (initialize) içerisinden ilk değer ataması söz konusudur (#0da bu durumu görebiliriz) @title ve @capacity değerlerini ZoneV1 nesne örneğinden dışarıya sunmak için #1 ve #2 deki Accessor metodlarından yararlanılır. title ve capacity'yi sadece okunabilir (read-only) bir özellik olarak düşünebiliriz. Yani sadece nesne örneklenirken ilk değerini almış, dışarıdan ulaşılabilir ama dışarıdan değeri değiştirilemez.
- Diğer yandan #3' de capacity isimli bir Setter metod tanımı daha görülmektedir. Bu metod ile @capacity Instance Variable'ına nesne örneği üzerinden değer ataması işlemi gerçekleştirilebilir. #4 satırındaki gibi. Dolayısıyla capacity değişkeninin hem okunabilir hem de yazılabilir bir nitelik olduğunu ifade edebiliriz.
- ZoneV2 isimli sınıfa bakıldığında attr_reader, attr_wirter ve attr_accessor isimli 3 nitelik tanımı olduğu görülür. (#5,#6,#7 ile başlayan satırlar) Bu tanımlamalara göre title sadece okunabilir bir nitelik olarak tanımlanmıştır. color sadece yazılabilir, capacity ise hem okunabilir hem yazılabilirdir. Dikkat edilmesi gereken nokta bunların birer symbol olarak tanımlanmış olmalarıdır. Buna göre ilgili nitelikler aslında sınıf için gerekli olan Instance Variable'ları otomatik olarak işaret ederler.
- Daha önceki kod parçacıklarında bahsettiğimiz üzere her iki sınıfın to_s metodları ezilmiştir (override)
- Tabi her iki sınıf arasındaki en önemli fark ilkinde Accessor ve Setter metodlarının kullanılması ikincisinde ise sadece niteliklerden (attributes) yararlanılmasıdır. Neden? attribute'lar içsel olarak Instance Variable'ları otomatik olarak kullanır ve işaret ederler. Ancak özellik değerlerine veri atanması veya okunması işlemleri sırasında başka işlemlerin de icra edilmesi isteniyorsa metod blokları ile ele alınmaları gerekir.

Böylece geldik bir kod parçacığının daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
