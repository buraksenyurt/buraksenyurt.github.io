---
layout: post
title: "Ruby Kod Parçacıkları - 1"
date: 2015-08-02 18:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - array
  - console
---
Bir programlama dilini öğrenmenin en iyi yolu elbetteki bol bol kod yazmaktan geçer. En azından belirli bir seviyeye gelene kadar basit IDE'ler ile mümkünse Console ekranları üzerinden çalışarak ilerlemekte yarar vardır. Hazır bu aralar Ruby ile haşır neşir iken hem basit kod parçaları paylaşayım hem de bu eğlenceli dili birlikte öğrenelim istedim. İşte ilk kod parçacığımız. Konumuz, diziler (Arrays).

> Bu kod parçasını rb uzantılı bir dosya olarak kaydettikten sonra(Örneğin Arrays.rb gibi) komut satırından Ruby aracı ile doğrudan çalıştırabiliriz. Sisteminizde Ruby yüklüdür değil mi? :)

```ruby
#Temel dizi işlemlerinden bazıları

if __FILE__ == $0
	#baziNesneler isimli bir dizi oluşturarak işe başlayalım
	baziNesneler=[1,1.3,"Burk",true,nil,-88]
	puts baziNesneler.inspect

	# << ile eleman eklemek
	baziNesneler<<"Sepet"
	puts baziNesneler.inspect

	#En sağdan herhangi bir sıradaki elemanı çekmek
	puts "Sondan 3ncu eleman "+baziNesneler[-4].to_s

	#ilk veya son elemanlara gitmek
	first=baziNesneler.first
	last=baziNesneler.last
	puts "ilk elaman #{first}\nson Eleman #{last}"

	#Kesişim kümesini bulmak
	dizi1=[1,3,5,7]
	dizi2=[3,7,11,13,15]
	dizi3=dizi1 & dizi2
	puts dizi3.inspect

	#Dizileri birleştirmek
	dizi4=dizi1+dizi2+dizi3
	puts dizi4.inspect

	#Diziden birden fazla eleman çıkartmak
	dizi5=dizi4-[3,5,7]
	puts dizi5.inspect

	#Başka işlemler için başka bir dizi tanımı
	nesneler=["kitap",1,true,nil,"parfum",Math::PI]

	#Dizinin ilk hali
	puts nesneler.inspect

	#pop ile son eleman diziden çıkartarak elde etmek
	puts nesneler.pop
	puts nesneler.inspect

	#push ile dizinin sonuna eleman/elamanla eklemek
	nesneler.push("Corap",1976,false)
	nesneler.inspect

	#shift ile ilk elemanı diziden çıkartarak almak
	puts nesneler.shift
	puts nesneler.inspect

	#unshift ile dizinin başına eleman/elemanlar eklemek
	nesneler.unshift("o zaman dans","renk")
	puts nesneler.inspect

end
```

ve çalışma zamanı çıktısı

![9k=](/assets/images/2015/ruby-kod-parcaciklari-1-01.jpg)

Şimdi kod içerisinde neler olup bittiğine bir bakalım.

- İlk olarak __File__ değişkeninin o anki dosyanın adını işaret ettiğini belirtebiliriz. $0 ise programı başlatmak için kullanılan dosyanın adıdır. Bir nevi Main metodu yazdığımızı ve script'in Programın kendisi olduğunu düşünebiliriz.(Console Application misali)

- Bir diziyi oluşturmak son derece kolaydır. Hatta görüldüğü üzere diziler herhangi bir türden eleman barındırabilir. Pek tabi tek bir tipte (örneğin Fixnum gibi) elemanlar da içerebilirler.

- Bir diziye eleman eklemek için en basit haliyle << operatörü kullanılabilir.

- Dizinin sağından itibaren geriye doğru herhangi bir elemanını almak da kolaydır. Bunun için negatif indis değeri kullanmak yeterlidir. Akıllıca değil mi?:)

- Dizi elemanlarını ekrana yan yana gelecek şekilde kolayca yazdırmak için inspect metodundan yararlanılır. Aslında inspect metodu bir nesnenin sınıf adı ve nesne değişken değerlerini insan gözüyle kolayca okunabilecek şekilde String tipte döndürmek üzere tasarlanmıştır. Kullanıcı tanımlı sınıflarda bu metod ezilebilir (Override). (Bu durum.Net tarafındaki ToString metodunun ezilmesi gibi düşünülebilir)

- to_s ile nesne değerinin String'e dönüştürülmesi sağlanır.

- Dizilerin kesişim kümelerini bulmak için $ operatörü, n sayıda diziyi birleştirmek için + operatörü, bir veya daha çok eleman çıkartmak içinse - operatörü kullanılabilir.

- pop metodu ile bir dizinin son elemanı elde edilir. Ancak aynı zamanda bu eleman diziden çıkartılır.

- push metodu ile dizinin sonuna eleman/elemanlar eklenebilir.

- shift metodu ile dizinin ilk elemanı alınabilir. Ancak aynı zamanda bu eleman diziden çıkartılır.

- unshift metodu ile dizinin başına eleman/elemanlar eklenebilir.

- Yorum satırlarının # ile başladığına dikkat edelim. Farklı yorum satırları da var. Özellikle yardım dokümanlarını otomatik hazırlayan araçlar için. Buna da yakın zamanda değineceğiz.

- Math::PI deki PI nin Math sınıfı içinde tanımlı bir Constant olduğunu da son olarak belirtelim.

Görüldüğü gibi dizilerle çalışmak son derece kolay. Tişikkirler Matz:)

Bir başka Ruby Kod Parçacığında görüşmek üzere hepinize mutlu günler dilerim.