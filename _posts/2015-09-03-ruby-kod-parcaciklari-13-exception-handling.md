---
layout: post
title: "Ruby Kod Parçacıkları - 13 (Exception Handling)"
date: 2015-09-03 05:00:00
tags:
  - ruby-lang
  - exception-handling
  - error-handling
categories:
  - Programlama Dilleri
---
Malumunuz hata yönetimi (Error Handling) oldukça önemli bir konu. Bu amaçla.Net/Java gibi çalışma zamanı motoru olan ortamlarda genellikle Exception yönetim mekanizmaları kullanılmakta. Benzer durum Ruby programlama dili için de söz konusu. Aşağıdaki kod parçacığında hata yönetiminin Ruby tarafında nasıl ele alındığını temel anlamda incelemeye çalışıyoruz (Aslında beni benden alan rescue, retry ve ensure kullanımlarıdır. Söylemeden geçmek istemedim.)

```ruby
class Utility
	def sampleOne(x,y)
		begin
			result=x/y
			puts "#{x} / #{y} = #{result}"
		rescue ZeroDivisionError=>e
			puts "Sifira bolme hatasi olustu.\nDetay : #{e.message}( #{e.class} )"
		else
			puts "Kodda herhangi bir hata bulunamadi. Mikemmel :)"   
		end
	end
		
	def sampleTwo(conStr)
		begin
			puts "Baglanti kuruluyor"
			raise ThreadError
			puts "kod devam ediyor"
		rescue
			puts "Baglanti hatasi"
		ensure
			puts "Her durumda calisak"
		end
	end

	def sampleThree(userName,password)
		if userName=="burki" && password=="1234."
			puts "Merhaba #{@userName}"
		else
			raise CredentialError.new(userName)
		end
	end

	def sampleFour(url)
		tryCount=1
		begin
			puts "#{url} icin baglanti denenecek"
			raise StandardError.new,"Hata : Baglanti gerceklestirilemedi"
		rescue Exception=>e
			puts "#{e.message}. TryCount #{tryCount}"
			tryCount+=1
		retry if tryCount<=3
		end
	end
end

class CredentialError<StandardError
	attr_reader :userName
	attr_reader :attemptTime
	
	def initialize(userName)
		@userName=userName
		@attemptTime=Time.now
	end
	
	def message
		"Login error for #{@userName} at #{@attemptTime}"
	end
end

if __FILE__==$0
	begin
		jack=Utility.new
		jack.sampleOne 1,0
		puts
		jack.sampleOne 4,2
		puts
		jack.sampleTwo("remote haddop connection")
		puts
		jack.sampleFour "http://www.google.com.tr"
		puts
		jack.sampleThree("burki","1291")
		puts
	rescue Exception=>e
		puts e.message
	rescue CredentialError=>e
		puts e.message
	end
end
```

![9k=](/assets/images/2015/ruby-kod-parcaciklari-13-exception-handling-01.jpg)

Temel olarak hata yönetimi kontrolu altına alınmak istenen kod bloklarının begin, end arasında yazıldığını ifade edebiliriz. Utility sınıfı içerisindeki metodlarda begin...end bloklarının farklı kullanımlarına yer verilmektedir. Şimdi kod parçacığımıza ait maddeleri kısaca gözden geçirelim.

- sampleOne isimli metod içerisinde hata yönetimine ait temel bir kullanım söz konusudur. rescue satırında belirtilen ZeroDivisionError, çalışma zamanında oluşabilecek sıfıra bölme hatasını işaret etmektedir. =>e ile yapılan atama sonrası devam eden satırda message ve class isimli niteliklere ulaşılarak ekrana ek bilgiler yazdırılması sağlanmıştır. begin ve rescue arasındaki kod parçasında oluşabilecek bir sıfıra bölme hatası bu şekilde kontrol altına alınmaktadır. else bloğu ise begin...rescue arasındaki satırlarda hata oluşmaması durumunda devreye girmektedir.
- sampleTwo isimli metod içerisinde sembolik olarak bir veritabanı bağlantısı açma işlemi gerçekleştirilir. Bu blokta önemli olan ensure kullanımıdır. Ensure kısmını try...catch...finally bloklarındaki finally kısmına benzetebiliriz. Yani hata olsa da olmasa da devreye girecek olan kod bloğudur.
- rescue anahtar kelimesinden sonra bir istisna veya hata tipi belirtilmek zorunda değildir. Bu durumda en genel seviyede istisna tipinin ele alındığını ifade edebiliriz.
- sampleFour isimli metod da benim en çok hoşuma giden kullanımlardan birisi yer almaktadır; retry kullanımı. Oluşan bir hata sonrası ilgili kod parçacığının bir kaç kere daha denenmesi istenirse bu anahtar kelimeden yararlanılabilir. Örnekte yine sembolik olarak bir url adresine gidilmeye çalışılmış ve bir hata mesajı fırlatılmıştır. Önemli olan kısım rescue bloğu içerisinde Statement Modifier kullanılarak retry işleminin icra edilmesidir. Buna göre ilgili url'e üç kere bağlantı kurulmaya çalışılacaktır.
- Ruby dilinde kalıtsal olarak türeyen hata sınıfları söz konusudur. Bu built-in tipler doğrudan kullanılabileceği gibi kendi hata sınıflarımızı da yazabiliriz. sampleThree isimli metod içerisinde sembolik olarak bir kullanıcı doğrulama operasyonu örneklenmeye çalışılmaktadır. Kodun önemli olan kısmı ise else bloğundaki raise ifadesidir. Bu satırda StandardError tipinden türettiğimiz CredentialError hata nesnesi örneklenmektedir. Tahmin edileceği üzere bu hata örneğinin bir rescue bloğu tarafında yakalanması beklenmektedir ki #1 numaralı satırda bu işlem gerçekleşir.
- CredentialError sınıfı StandardError tipinden türetilmiştir. userName ve attemptTime isimli iki niteliğe sahiptir. Yapıcı metod (Constructor) içerisinde bu nitelikler set edilir. Ayrıca üst sınıftan gelen message metodunun ezildiğine de dikkat edelim.
- Ruby dilindeki istsina mekanizmasına ait hiyerarşi genel olarak aşağıdaki şekilde görüldüğü gibidir (Sürümler ilerledikçe değişiklikler olabilir bu yüzden en güncel tip ağacına bakmanızda yarar var)
![9k=](/assets/images/2015/ruby-kod-parcaciklari-13-exception-handling-02.jpg)
Kaynak: [http://ruby-doc.org/core-2.2.2/Exception.html](http://ruby-doc.org/core-2.2.2/Exception.html)

Görüldüğü üzere çok fazla hata sınıfı yoktur ancak detay seviyede kullanıcı tarafından oluşturulacak yeni sınıflar ile bu hiyerarşi genişletilebilir.

Bu kod parçacığında temel seviyede hata yönetimi ve kontrol mekanizmalarını incelemeye çalıştık. Elbette atladığım ve henüz değinemediğim ileri seviye konular söz konusu olabilir. Örneğin Ruby tarafında try, catch kullanımı söz konusudur ancak biraz daha farklı anlamda ele alınmaktadır. [Şu adresi](http://www.tutorialspoint.com/ruby/ruby_exceptions.htm) incelemenizi önerebilirim.

Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse.
