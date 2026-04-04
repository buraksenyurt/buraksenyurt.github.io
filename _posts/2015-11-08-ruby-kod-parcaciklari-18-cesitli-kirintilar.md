---
layout: post
title: "Ruby Kod Parçacıkları 18 - Çeşitli Kırıntılar"
date: 2015-11-08 13:00:00
tags:
  - ruby-lang
categories:
  - Programlama Dilleri
---
Takip edenlerin bildiği üzere bir süredir [Ruby](https://www.buraksenyurt.com/category/Ruby) programlama dili üzerinde çalışmaktayım. İlerledikçe öğrendiklerimi kod parçacıkları halinde paylaşmaya çalışıyorum. Ne kadar faydalı oluyor bilemiyorum ama arada sırada takip ettiğim kaynaklardan geriye dönerek acaba atladığım bir şeyler var mıdır diye de bakıyorum. İşte bu düşünceler ışığında çıktım yola ve gerçekten de atladığım bir çok şey fark ettim. Bu kod parçacığında kısaca bu konulara değinmeye çalışacağım. Önce kod parçamızı ele alalım.

Dikkat edileceği üzere bu kez if __FILE__==$0 şeklinde bir kullanım tercih etmedim. Kod bu şekliyle de işliyor olacak. Uygulamanın çalışma zamanına ait ekran çıktısı aşağıdaki gibi.

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-18-cesitli-kirintilar-01.jpg)

Gelelim uygulamada neler olup bittiğine.

```ruby
# encoding: ISO-8859-9
=begin
Geride Kalan Bazı Kırıntılar
Ruby öğrenirken geçmiş dönemde üzerinden geçtiğim konular içerisinde kıyıda köşede kalmış olanlardan bazılarını
aşağıdaki maddeler halinde işlemeye çalıştım.
? nin metodlarda ne anlama geldiği
En basit anlamda Regex ifadesi ile veri kontrolü yapmak
Bir metoda değişken Sayıda argüman yollamak *
Metodlarda alias(takma isim) kullanımı
Global Constats(Genel Sabitler) kullanımı
Monkey Patching (Sınıfları genişletirken dikkatli olmak gerekiyor)
BEGIN ve END kullanımı
Ufacıktan Meta-Programming çalışması
=end

def topla(*sayilar) # Variable-Length arguments kullanımı #0
	toplam=0
	sayilar.each{|s| toplam+=s}
	return toplam
end

#1
def emailAdresimi?(icerik) #? kullanımı. Metod her zaman true veya false dönmelidir.
	icerik=~/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i #basit regex ile email adresi kontrolü
end

#2
def girisMesaji(mesaj="'Bugün aklına bir mesaj gelmedi mi?'") #Default argument kullanımı
	"\n'#{mesaj}'"
end

#3
def writeRubyWorld
	puts "\n"
	puts "Ruby version : #{RUBY_VERSION}"
	puts "Release date : #{RUBY_RELEASE_DATE}"
	puts "Platform : #{RUBY_PLATFORM}"
	puts "Copyright : #{RUBY_COPYRIGHT}"
	puts "Descriptin : #{RUBY_DESCRIPTION}"
	puts "Engine : #{RUBY_ENGINE}"
	puts "Patch Level : #{RUBY_PATCHLEVEL}"
	puts "Version : #{RUBY_VERSION}"
	#puts "Environment Variable : #{ENV.inspect}"
	puts "\n"
end

#4 Monkey Patching denemeleri
class Fixnum
	def +(x)
		self*2)-x
	end
end

class String
	def downcase
		self.reverse
	end
end

#7
BEGIN { puts "Uygulama #{Time.now.to_s} saatinde başladı"}
END { puts "Uygulama #{Time.now.to_s} saatinde sonlandı"}

puts topla 1,2,3,4,5
puts topla 4,5,2
email="selim@buraksenyurt.com"
puts emailAdresimi?(email) ? "#{email} geçerlidir" : "#{email} geçerli değildir"
email="brksnyrt.com"
puts emailAdresimi?(email) ? "#{email} geçerlidir" : "#{email} geçerli değildir"
puts girisMesaji
puts girisMesaji("Ne güzel bir gündü")
alias msg girisMesaji #Metodlara takma ad verilmesi
puts msg("Yağmur yağınca mis gibi toprak koktu")
sleep 3 #3 saniye boyunca uygulamayı duraksatacaktır
x,y=4,5
puts "\n#{x}+#{y}=#{x+y}" #5
puts "BURKI".reverse #6
writeRubyWorld
#8
rakam=3.1415
puts rakam.class
#puts rakam.methods
rounded=rakam.method(:round).call
puts rounded
#9
class Utility
	def method_missing(method_name,*args,&block)
		if method_name== :getPassword
			puts "getPassword isimli metod çağırıldı. Bunun için bir şeyler yapılabilir."
		else
			puts "#{method_name} isimli metod #{args} parametreleri ile çağırıldı."
		end
	end
	def calculate
	end
end
einstein=Utility.new
einstein.getPassword
einstein.showPassword "@#$½ğ123|!?","Rijndael"
einstein.calculate
```

- #0 Numaralı satırda topla isimli bir metod tanımı yer alıyor. Metodun dikkat çeken özelliği ise *sayilar isimli argümanı. Value-Length olarak adlandırılan bu argüman sayesinde metoda değişken sayıda parametre gönderilmesi mümkün. Bu sayede metod içerisinde bir each kullanımı da söz konusu olmakta.
- #1 Satırında tanımlanan emailAdresimi metodunun iki önemli özelliği var. İlki? işareti ile bitiyor olması ki buna göre metodun geriye true veya false değer döndüreceğini belirtmiş oluyoruz. (Aslında? işareti dışında! işareti de var. Hatta daha önceden attribute atamalarında değindiğimiz = işareti) Metodun iç kısmında ise ilk kez Regex ifadesi kullandığımı görebilirsiniz. Basit olarak metoda gelen içeriğin geçerli bir mail adresi olup olmadığını kontrol ediyoruz. ~= ile yaptığımız karşılaştırma sonrası da geriye true veya false değer döndürüyoruz.
- #2 Satırında Default Argument kullanımı söz konusu. (Bir nevi C# tarafında kullandığımız Optional Parameters) mesaj isimli metod parametresine bir değer verilmemesi halinde varsayılan olarak 'Bugün aklına bir mesaj gelmedi mi?' ifadesinin atanmasını sağlıyoruz.
- #3 numaralı satırda yer alan writeRubyWorld isimli metod içerisinde Ruby ile built-in olarak gelen Global Constant'lara bakıyoruz. Daha pek çok sabit değer var. Ben işe yarayabileceğini düşündüğüm bir kaçına yer verdim. Bu sabitler ile ortam (Environment) değişkenlerine ulaşıp Ruby çalışma zamanı ile ilgili bilgileri ekrana yazdırmaktayız. Bu arada yorum satırı olarak bırakılmış ENV.inspect kısmını açarak denemenizi de tavsiye ederim.(Ne kadar çevre sabiti varsa görebiliriz)
- #4 numaralı satırdan itibaren yer alan Fixnum ve String sınıflarında Monkey Patching isimli bir kullanım söz konusu. Fixnum ve String isimli sınıflar bildiğiniz üzere Ruby'nin çekirdek tiplerinden. Ve şunu da biliyoruz ki Ruby'de var olan sınıfları genişletmek son derece kolay. Aynen bu örnekte görüldüğü gibi. Örneği farklı kılan unsur ise zaten var olan toplama (+) ve küçük harfe çevirme (downcase) fonksiyonelliklerinin yeniden yazılmış olmaları. Bu yüzden #5 ve #6 numaralı satırlarda yer alan kodların çalışma zamanı çıktıları olması gerektiği gibi değil.
- #7 numaralı satırda BEGIN ve END bloklarının kullanımı yer almaktadır. BEGIN bloğun program kodları çalışmaya başlamadan önce devreye girer. Dolayısıyla uygulama çalıştırılmaya başlamadan önce yapılması istenen işlemler için kullanılabilir (Bir nevi Programın yapıcı metodu gibi düşünebiliriz sanırım). END bloğunda yer alan kodlar ise tahmin edileceği üzere uygulama tamamlandıktan sonra devreye girmektedir (Bunu da programın Desctructor metoduymuş gibi düşünebiliriz sanırım)
- #8 numaralı satırda ufaktan bir meta-programming uyarlaması söz konusudur. rakam isimli değişken Float türündendir. Bunu öğrenmek için bir sonraki satırda yer alan class metodu çağırılmıştır (Bu arada class metodu ardından superclass çağırımları yaprak nil'i görene kadar ilerleyin derim. Bu şekilde bir tipin üst sınıflarını ve doğal olarak nesne hiyerarşisini öğrenebilirsiniz) İzleyen satırda yer alan methods çağırımı şu an için yorum satırı olarak bırakılmıştır. Bunu açtığımızda Float sınıfının metodlarının listelendiği görülecektir (.Net'çiler için Reflection dersek bir şeyler çağrıştırmış oluruz) Devam eden ifade ise çok daha ilginçtir. Float sınıfının round isimli metodu farklı bir şekilde çağırılmıştır. Bunun için method isimli fonksiyona çağırılmak istenen metoda ait symbol atanmıştır.
- #9 numaralı satırda ise çok daha ilginç bir Ruby özelliği vardır.(Ruby her türlü şaşırtmaya devam ediyor) Diyelim ki bir sınıfın olmayan bir metodunu çağırıyoruz. Bu durumda çalışma zamanında Undefined Method hatasını alırız. Ancak sınıf içerisine dahil edilecek ek bir fonksiyon ile bu durum kontrol altına alınabilir. Hatta çağırılan bir metod için yapılması istenen başka işlemler varsa bunları da kontrol edebiliriz. Utility sınıfı içerisinde kullanılan method_missing isimli fonksiyon bu vakayı ele almak için yazılmıştır. Görüldüğü gibi 3 parametre almaktadır. Bu parametrelerden ilk metodun adı, ikincisi aldığı argümanlar ve sonuncusu da varsa geçilen bloktur. Programda Utility sınıfına ait nesne örneği oluşturulduktan sonra getPassword ve showPassword isimli metodlar çağırılmıştır. Bu fonksiyonlar fark edileceği üzere Utility sınıfı içerisinde tanımlı değildir. Ancak getPassword metodu:getPassword isimli symbol yardımıyla if bloğunda kontrol altına alınmıştır.

Bu kod parçacığında Ruby'nin benim için incelemeyi unuttuğum kıyıda köşede kalmış ama önemli bazı yeteneklerini incelemeye çalıştık. Umarım sizler için de bilgilendirici ve faydalı olmuştur. Böylece geldik bir kod parçacığımızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim. Tabii eğer böyle bir şey mümkünse.
