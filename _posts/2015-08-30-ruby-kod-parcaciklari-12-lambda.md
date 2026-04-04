---
layout: post
title: "Ruby Kod Parçacıkları - 12 (Lambda)"
date: 2015-08-30 07:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - block
  - procs
  - lambda-operator
---
Daha önceki kod parçacıklarımızda [Block](/2015/08/20/ruby-kod-parcaciklari-10-yield-ve-block-kullanimi/) ve [Proc](/2015/08/25/ruby-kod-parcaciklari-11-procs/) kavramlarına değinmiştik. Benzer kavramlardan üçüncüsü de Lambda'dır. Hatırlayacağınız gibi kod parçalarını Block şeklinde tanımlayıp metodlara parametre olarak geçirebiliyorduk. Bununla birlikte tekrardan kullanılabilirliğin öne çıktığı ve kod parçasının bir değişken olarak kullanılmasının istendiği durumlarda Proc örneklerinden yararlanıyoruz.

Lambda nesneleri de aslında Proc'lara oldukça benziyor. Yine bir kod parçasının nesne olarak ifade edilebilmesi ve birden çok kez yeniden kullanılabilmesi mümkün. Lakin Proc'lar ile Lambda arasında bir kaç farklılık da bulunmakta. Aşağıdaki kod parçası ile hem Lambda'nın kullanımını hem de Proc ile arasındaki temel farklılıkları incelemeye çalışalım.

```ruby
class Utility

	def justDoIt(val1,val2,someLambda) #3
		puts Time.now
		someLambda.call val1,val2
	end

	def saySomethingWithLambda #6
		lambdaZ=lambda{
			return "Do something with Lambda"
		}
		lambdaZ.call
		return "end of saySomethingWithLambda"
	end

	def saySomethingWithProc #7
		procZ=Proc.new{
			return "Do something with Proc"
		}
		procZ.call
		return "end of saySomethingWithProc" #8
	end
end

if __FILE__==$0
	einstein=Utility.new
	lambdaX=lambda{|a,b| a+b} #0
	result=lambdaX.call 5,6
	puts result
	lambdaY=->(motto){puts "Your motto is ' #{motto}'"} #1
	lambdaY.call "It's a beautiful day"
	puts "lambdaX -> #{lambdaX.class} class" #2
	puts einstein.justDoIt 3,4,lambdaX #4
	procX=Proc.new {|m| puts "Your message is '#{m}'"}
	procX.call
	#lambdaY.call #5
	puts einstein.saySomethingWithLambda
	puts einstein.saySomethingWithProc
end
```

Çalışma zamanı sonuçlarımız ilk olarak aşağıdaki gibidir.

![ruby kod parcaciklari 12 lambda 01](/assets/images/2015/ruby-kod-parcaciklari-12-lambda-01.jpg)

Kod parçamıza ait kısa notlarımıza gelince.

- #0 ve #1 numaralı satırlarda Lamda değişkenlerinin iki farklı tanımı söz konusudur. Doğrudan süslü parantez notasyonu kullanılabileceği gibi -> () notasyonu da tercih edilebilir. Her iki değişken için de parametre tanımlanmıştır. lambdaX için a ve b, lambdaY içinse motto. Aynen Proc değişkenlerinde olduğu gibi Lambda nesnelerin işaret ettiği kod parçaları call metodu yardımıyla çağırılabilir.
- Lambda'lar aslında Proc sınıfın bir örneğidir. #2 numaları satırdaki kodun ekran çıktısına dikkat edin.
- #3 numaralı kısımda başlayan justDoIt metodunun son parametresi bir Lambda değişkenidir ve #4 numaralı satırda lambdaX'in buraya gönderilmesi söz konusudur. Yine Proc kullanımındakine benzer olarak Lambda değişkeninin icrası justDoIt metodundaki call çağrısı ile gerçkleştirilmektedir.
- Lambda ile Proc arasındaki farklardan birisi #5nci satırdaki kod parçacığının icra edilmesi halinde ortaya çıkmaktadır. Bir üst satırda procX.call çağrısında dikkat edileceği üzere m parametresi boş geçilmiştir. Benzer şekilde lambdaY.call çağrısında da parametreler gönderilmemiştir. Bu durumda çalışma zamanı çıktısı aşağıdaki gibi olacaktır.
![ruby kod parcaciklari 12 lambda 02](/assets/images/2015/ruby-kod-parcaciklari-12-lambda-02.jpg)
- Bir başka deyişle Proc'lar için parametre göndermek zorunlu değilken, Lambda kullanımında bu mecburidir. Nitekim Lambda, Proc gibi kod bloğunu işaret eden bir değişken değil aslında kod bloğunu metod olarak kabul eden bir yaklaşımı kullanmaktadır. Bu nedenle çalışma zamanı hatası alınmıştır.
- #6 ve #7 numaralı satırlarda Lambda ve Proc için iki ayrı kullanım söz konusudur. Burada Proc ve Lambda arasındaki bir fark daha görülmekte. lambdaZ ve procZ tanımlamalarında return kullanıldığı görülüyor. Lambda söz konusu olduğunda return sonucu Lambda değişkenin sarmalandığı metoda dönülmektedir. Tam tersine Proc kullanıldığı durumda ise Proc bloğunun içeriği saySomethingWithProc metodunun çağırıldığı yere döndürülmüş bu yüzden #8deki satır işletilmemiştir.

Böylece geldik bir kod parçacığımızın daha sonuna. Son üç yazıda Block, Proc ve Lambda kavramlarına değindik. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
