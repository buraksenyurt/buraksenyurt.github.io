---
layout: post
title: "Ruby Kod Parçacıkları - 9 (Operator Overloading)"
date: 2015-08-17 09:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - operator-overloading
---
Neredeyse her programlama dilinin öğrenilirken çalışana sıkıcı gelen bölümleri muhakkak vardır. Sanıyorum o dildeki operatörler bunların başında gelir. Ancak nesne yönelimli bir dil öğreniyorsak, kullanıcı tanımlı tipler için operatörlerin yeniden programlanması gerektiğini de er geç fark ederiz. Bu nedenle operatorlerin kendi tiplerimiz (User Defined Class) olması halinde yeniden nasıl yükleneceğini bilmemiz gerekir.

Ruby dilinde de aynı.Net tarafında olduğu gibi operatörleri yeniden yükleme imkanımız bulunmaktadır (Operator Overloading). Yani dört işlemde kullanılan operatörler ve diğerlerinin kendi tiplerimize ait nesne örnekleri üzerinde kullanılmaları halinde çalışma zamanın nasıl davranış sergileyeceğini belirleyebiliriz.

Aşağıdaki kod parçacığında Location isimli sınıf için bazı operatörlerin yeniden yüklenmesi işlemine yer verilmiştir.

```ruby
class Location
	def initialize(x,y,z) # Constructor
		@x,@y,@z=x,y,z# Coklu atama ifadesi
	end
	def x
		@x
	end
	def y
		@y
	end
	def z
		@z
	end
	def *(n) # Carpma islemi icin overloading
		if n.is_a?(Numeric)
			Location.new(@x*n,@y*n,@z*n)
		elsif n.is_a?(Location)
			Location.new(@x*n.x , @y*n.y , @z*n.z)
		end
	end
	def +(n) # Toplama islemi icin overloading
		if n.is_a?(Numeric)
			Location.new(@x+n,@y+n,@z+n)
		elsif n.is_a?(Location)
			Location.new(@x+n.x, @y+n.y , @z+n.z)
		end
	end
	def -@ # - isareti icin overloading
		Location.new(-@x,-@y,-@z)
	end
	def <=>(l) # <=> karsilastirma operatoru icin overloading
		if l.is_a?(Location)
			if @x==l.x && @y==l.y && @z==l.z
				0
			elsif @x>l.x && @y>l.y && @z>l.z
				1
			elsif @x<l.x && @y<l.y && @z<l.z
				-1
			else
				-99 #ivit burasi biraz anlamsiz oldu
			end
		end
	end
	def to_s #Overriding
		"#{@x};#{@y};#{@z}"
	end
end
if __FILE__==$0
	loc1=Location.new 10,10,20
	puts loc1.to_s
	loc2=loc1*3
	puts loc2.to_s
	loc3=loc1*loc2
	puts loc3.to_s
	loc4=Location.new 5,5,10
	puts loc4.to_s
	loc5=-loc4
	puts loc5.to_s
	loc6=Location.new -1,-5,0
	puts loc6.to_s
	loc7=loc6+Location.new(5,8,15) #metodlarda istenirse parantez kullanılabilir ama zorunluluk degildir
	puts loc7.to_s
	puts "loc7<=>loc6:"+(loc7<=>loc6).to_s
	loc8=Location.new 1,1,1
	loc9=Location.new 1,1,1
	puts "loc8<=>loc9:"+(loc8<=>loc9).to_s
end
```

ilk olarak çalışma zamanı çıktısına bir bakalım.

![9k=](/assets/images/2015/ruby-kod-parcaciklari-9-operator-overloading-01.jpg)

ve kısa notlarımız...

- Location sınıfı x,y,z koordinatlarını tutan bir varlık (Entity) olarak tasarlanmıştır. Yapıcı metod ile uzaydaki üç noktaya değer ataması gerçekleştirilir. Ayrıca tüm noktalar için birer Accessor metoda sahiptir.
- to_s metodu bilginin kolay okunması amacıyla ezilmiştir.
- Örnekte *, +, negatifleştirme (-) ve <=> karşılaştırma operatörünün yeniden yüklenmesi ele alınmıştır. Özellikle çarpma ve toplama operatörlerinde parametrenin Numeric veya Location tipinden olup olmamasına göre ilerlenilmiştir. Her iki tip kontrolü için is_a? metodundan yararlanılır. is_a? metoduna parametre olarak tip adlarının verildiğine dikkat edelim.
- <=> dışındaki operatörlerde geriye yeni bir Location örneği döndürüldüğü görülebilir. Ancak <=> bir karşılaştırma operatörüdür. Normal şartlarda iki operand birbirine eşitse 0, ilk operand ikincisinden büyükse 1, ilk operand ikincisinden küçükse -1 döndürmektedir. Biz örneğimizde iki Location nesne örneğinin x,y,z değerlerini birbirleri ile kıyaslayarak karar verdik lakin buradaki mantık böyle olmak zorunda değil.

Görüldüğü üzere kullanıcı tanımlı tipler için var olan Ruby operatörlerinin yeniden yüklenmesi mümkün ve oldukça basittir. Böylece geldik bir kod parçacığımızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
