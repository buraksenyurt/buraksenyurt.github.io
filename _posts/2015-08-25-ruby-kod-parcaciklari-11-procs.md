---
layout: post
title: "Ruby Kod Parçacıkları - 11 (Procs)"
date: 2015-08-25 08:00:00
tags:
  - ruby-lang
  - procs
categories:
  - Programlama Dilleri
---
Bir [önceki kod parçacığımızda](/2015/08/20/ruby-kod-parcaciklari-10-yield-ve-block-kullanimi/) Ruby dilinin önemli özelliklerinden birisi olan Block kavramına değinmiştik. Bu kod parçacığında ise Proc kullanımını anlamaya çalışacağız. Kod parçalarını metodlara taşımanın yollarından sadece birisi Block'lardır. Ancak block'lar bir nesne olarak ifade edilemezler. Oysa ki Ruby dilinde her şeyin bir nesne olduğu öne sürülür. İşte bu noktada devreye Proc ve Lambda enstrümanları girer.

Proc ile de bir kod bloğu işaret edilebilir. Block'dan farkı ise bu kod parçasının bir nesneye atanabiliyor olmasıdır (Yani bir kod bloğunu nesne olarak kaydedip kullanabiliriz). Bu da doğal olarak yeniden kullanılabilirliği (reusability) mümkün kılmaktadır. Bir başka deyişle bir proc nesnesi ile işaret edilen kod parçacığı program içinde farklı noktalarda tekrar tekrar kullanılabilir. Şimdi kısa bir kod parçacığı ile proc kullanımına yakından bakalım.

```ruby
class Utility
	def justDoIt(someProc)
		puts "Begin Time : "+Time.now.to_s
		someProc.call #0
		puts
		2.times {puts "."}
	end

	def calculate(x,y,someProc)
		someProc.call x,y #1
	end
end

if __FILE__==$0
	cevatKelle=Utility.new
	#2 ornek proc tanimi
	procX=Proc.new {
		[1,3,5,7].each{|x|printf "#{x*2},"}
	}
	printf "procX is a #{procX.class}\n" #3
	cevatKelle.justDoIt procX #4
	puts "Press enter to continue"
	gets
	#5
	procY=Proc.new do |x|
	total=0
	1.upto(100){|n|total+=n}
	puts "sum(1..100) = "+total.to_s
	end
	cevatKelle.justDoIt procY
	procY.call #6
	result=cevatKelle.calculate 5,4,Proc.new { |x,y| (x*2)+(y*2)} #7
	printf "\n(x*2)+(y*2)= #{result}"
end
```

Kod parçacığının çalışma zamanı çıktısı aşağıdaki gibidir.

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-11-procs-01.jpg)

Gelelim neler olup bittiğine.

- Utility sınıfı içerisinde iki metod tanımı söz konusudur. justDoIt ve calculate isimli metodların ortak özelliği someProc isimli parametreleridir. Her iki metod içinde someProc değişkeni üzerinden call metodunun çağırıldığı görülebilir. (#0 ve #1 de) someProc yerine bir kod bloğunu işaret eden Proc değişkenleri atanmakta olup çalışma zamanında atanan kod parçaları icra edilmektedir.
- #2 numaralı satırda bir Proc tanımı yapılmıştır. Proc sınıfının yapıcısı (Constructor) ile oluşturulan kod bloğu, procX isimli değişkene atanmaktadır. (Bu arada proc'lar aslında Proc tipinden birer sınıftır. #3 ün ekran çıktısına dikkat edin)
- Tanımlanan procX isimli Proc değişkeninin justDoIt metoduna taşınması #4 numaralı satırda yapılmaktadır. Bu durumda 1,3,5,7 rakamlarından oluşan sayı dizisindeki her bir elemanın iki katının ekrana yazılması işlemi justDoIt metodunda, #0 numaralı satırda geliştirilmektedir.
- #5 numaralı satırda ise procY isimli Proc nesne örneğinin do...end blokları arasında tanımlanması örneklenmiştir. Sonrasında #6 numaralı satırda ilgili Proc nesne örneğinin justDoIt metoduna aktarılması söz konusudur.
- Bir Proc nesnesi doğrudan da çağırılabilir. Yani ille bir metoda aktarılmak zorunda değildir. #7 numaralı satırda buna bir örnek verilmiştir.
- Utility sınıfında tanımlanmış olan calculate metodu Proc dışında iki farklı değişken kullanır. Aslında bu değişkenler #8 numaralı satırdaki Proc.new tanımına da parametre olarak taşınırlar. Ayrıca #8 numaralı satırda calculate metodunun 3ncü parametresine Proc.new ile bir bloğun atanması işlemi gerçekleştirilmektedir. Yani Proc nesnesi o anda tanımlanıp isimsiz olarak yollanmıştır. calculate işleminin Proc kullanımı sonucu oluşan çıktısı ise result değişkenine atanmıştır.

Proc'un örnekteki kullanımını daha iyi görebilmek için aşağıdaki grafikten de yararlanabiliriz.

![9k=](/assets/images/2015/ruby-kod-parcaciklari-11-procs-02.jpg)

Böylece geldik bir kod parçacığının daha sonuna. Bir sonraki kod parçacığında Lambda kullanımına değinmeye çalışacağız. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
