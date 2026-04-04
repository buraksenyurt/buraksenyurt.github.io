---
layout: post
title: "Ruby Kod Parçacıkları - 10 (Yield ve Block Kullanımı)"
date: 2015-08-20 15:00:00
tags:
  - ruby-lang
  - yield
  - block
categories:
  - Programlama Dilleri
---
Ruby'nin güçlü olmasını sağlayan pek çok özellik vardır. block'lar bu güçlü özelliklerden birisidir. (Block'lar dışında Proc ve Lambda kavramları da mevcuttur ki bu konuları ve aralarındaki temel farklılıkları sonraki kod parçacıklarında ele alacağız)

Bir Block ile değişkene veya nesneye atayamadığımız kod parçalarını işaret edebilir ve bu isimsiz kod parçalarını metodlara parametre olarak taşıyabiliriz. Tabi burada yield anahtar kelimesinin önemli bir yeri vardır. Gelin konuyu aşağıdaki kod parçacığı ile anlamaya çalışalım. *(Henüz ispat edecek kod parçacığı mertebesine ulaşamadım)*

```ruby
class Utility
	def justDoIt
		if !block_given? then #0 yield yerine bir block gelmediyse
			puts "Block yok"
		else
			yield #1
			yield
			yield
		end
	end
	
	def repeat(count) #2
		raise 'Empty Block Error' if !block_given? #3 Exception firlatimi
		count.times { yield } #4
	end
	
	def calculate (min,max) #5
		for i in min..max do
			yield i
		end
	end
end

if __FILE__==$0
	puts "What is your motto?"
	motto=gets
	cevatKelle=Utility.new
	cevatKelle.justDoIt{ puts motto }
	cevatKelle.repeat(2) { puts "I love ruby" }
	cevatKelle.repeat(2) #4 deki exception' in firlamasina neden olacak #7
	total=0
	cevatKelle.calculate(10,20) {|x,y| total+=x}
	puts total
	min,max,e=10,20,2
	total=0
	cevatKelle.calculate(min,max) {|x,y| total+=(x*e)} #e local degiskeni kullanilmistir
	puts total
	total=0
	[1,3,5,7,9].each{ |i| total+=(i*2) } #8 each metodunda built-in block kullanimi
	puts total
	cevatKelle.justDoIt #6
end
```

Uygulamanın iki çalışma zamanı çıktısı söz konusudur. #7 deki satır kapalı iken denediğimizde aşağıdaki çıktıyı elde ederiz.

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-10-yield-ve-block-kullanimi-01.jpg)

Ancak #7 deki satırı açtığımızda çalışma zamanına hata fırlatılmasından dolayı (bunun sebebi boş blok gönderilmesi ve #3 deki raise çağırımıdır) aşağıdaki çıktıyı elde ederiz.

![9k=](/assets/images/2015/ruby-kod-parcaciklari-10-yield-ve-block-kullanimi-02.jpg)

Şimdi kod parçacığında neler olduğuna maddeler halinde kısaca bakalım.

- Utility sınıfı içerisinde justDoIt, repeat ve calculate isimli üç farklı fonksiyon yer almaktadır. Bu fonksiyonların ortak özelliği, gövdelerinde yield anahtar kelimesinin kullanılmış olmasıdır. Bu sayede metodların çağırıldığı yerlerde, süslü parantezler içerisine yazılan kod bloklarının yield olan yerlere gönderilmesi mümkün hale gelmektedir.
- #0 numaralı satırda block_given? çağrısı ile metoda bir bloğun gönderilip gönderilmediğine bakılır. Eğer gönderilen bir block varsa arka arkaya üç kez icra edilir. #1 ile başlayan yield anahtar kelimeleri sebebiyle gelen kod bloğunun arka arkaya üç kez çalıştırıması söz konusudur.
- #2 nuımaralı ve #5 numaralı satırlardaki metodlar block gönderilen fonskiyonların parametreler de alabileceğini göstermektedir.
- #3 numaralı satırda şu ana kadar ilk kez karşılaştığımız bir kod parçası söz konusudur. Aslında çalışma zamanına bir istisna (exception) fırlatılmaktadır (.Netçiler throw new Exception (""); olarak düşünebilirler) raise'den sonra gelen ifade istisna mesajı olarak düşünülebilir. Kod satırının sonunda Statement Modifier kullanıldığına dikkat edelim.
- Eğer yield kullanılan bir metoda kod bloğu gönderilmezse bu durumda herhangi bir işlem yapılmaz. Bu vaka repeat ve justDoIt metodlarında ele alınmıştır. #7 deki kod satırı açıldığında bir Exception fırlatıldığı görülür. #6 daki kod satırında ise istisna yerine ekrana "block yok" mesajı basılılır. Nitekim justDoIt metodu içerisindeki if...else...end ifadesi ile boş blok gönderilme vakası kontrollü bir şekilde ele alınmıştır.
- #8 Numaralı kod satırında built-in block kullanımına ait bir örnek verilmektedir. Daha önceden de bahsettiğimiz gibi each ve select benzeri fonksiyonlar içerisinde yield kullanımları dilin doğal yapısı gereği mevcuttur. Bu nedenle bir dizinin arkasından çağırılan each metodu için block gönderimi/kullanımı mümkün hale gelmiştir.

Konuyu biraz daha iyi anlamak adına aşağıdaki grafiğin de işe yarayacağını düşünüyorum. Görüldüğü üzere kod blokları ilgili metodlarda yield kullanılan yerlere taşınmaktadır.

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-10-yield-ve-block-kullanimi-03.jpg)

Böylece geldik bir kod parçacığının daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
