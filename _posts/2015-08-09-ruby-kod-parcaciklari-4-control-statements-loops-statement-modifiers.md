---
layout: post
title: "Ruby Kod Parçacıkları - 4 (Control Statements, Loops, Statement Modifiers)"
date: 2015-08-09 10:00:00
tags:
  - ruby-lang
  - control-statements
  - loops
  - statement-modifiers
categories:
  - Programlama Dilleri
---
Her programlama dilinde olduğu gibi Ruby içinde kontrol ifadeleri (Control Statements) ve döngüler (Loops) söz konusudur. Tabi Ruby dili özellikle yazımsal kolaylık açısından pek çok geliştiriciyi gülümseten betiklere de sahiptir. İlerleyen kod parçasında bu konudaki en temel kullanımları inceliyoruz.

```ruby
if __FILE__==$0
	puts "Nickname?"
	nickName=gets

	#1 Bilinen if kullanimi
	if nickName.length==0
		puts "Lutfen bir nickname giriniz"
	elsif nickName.length>8
		puts "Cok uzun. 8 karakteri gecmemeli"
	else
		puts "ivit. Simdi oldu.\nMiraba #{nickName}"
	end

	#2 Bilinen case kullanimi
	networkStatus="Busy"
	url=case networkStatus
		when "Available"
			"http://deploysrv01/"
		when "Busy"
			"http://deploysrv02/"
		when "TooBusy"
			"http://deploysrv03/"
		when "Fuzzy"
			"http://deploysrv04/"
		else
			"http://masterserver/errorpage.html"
	end
	puts url

	#3 Bazi dongu kullanimlari
	lastValue=48
	for i in 0..lastValue
		puts i if i%6==0 #Statement Modifier
	end

	#4
	for i in 1..3
		for j in 1..5
			printf "(#{i},#{j})\t"
		end
		puts
	end

	#5
	total=0
	1.upto(100){ |n| total+=n}
	puts total

	#6
	5.times do |n|
		printf "#{n+3} "
	end
	puts

	#7
	5.times{|n| printf "#{n+3} "}
	puts

	#8
	x=0
	while x<100
		printf "#{x}," if x%7==0 #Statement Modifier
		x+=1
	end
	puts

	#9
	nbr=0
	puts nbr=nbr+3 while nbr<10 #Statement Modifier

	#10
	while 1
		puts "\nLutfen sifrenizi giriniz"
		password = gets.chomp
		break if password=="P@ssw0rd" #Statement Modifier
	end
	puts "Buenos Diyas\n"

	#11
	i=1
	total=0
	loop do
		break if i>100 #Statement Modifier
		total+=i
		i+=1
	end
	puts "1den 100e sayi toplami #{total}\n"

	#12
	matchPoint=3
	puts "Tam puan degil" unless matchPoint>10 #Statement Modifier   
end
```

![9k=](/assets/images/2015/ruby-kod-parcaciklari-4-control-statements-loops-statement-modifiers-01.jpg)

> [Ruby Kod Parçacıkları serisi](https://www.buraksenyurt.com/category/Ruby) daha önceden farklı programlama dilleri ile geliştirme yapmış arkadaşlar içindir. OOP veya fonksiyonel dil kökenli yazılımcıların anlayacağı şekilde klavyeye alınmışlardır.

Her zaman olduğu gibi betik içerisinde neler yaptığımızı maddeler halinde özetleyelim. (Bu kez kod içerisindeki kısımları daha kolay takip edebilmek için #numara şeklinde yorum satırları ekledim. Umarım daha açıklayıcı olur)

- 1nci bölümde klasik bir if...elsif...else yapısı kullanıldığını görebiliriz. Dikkat edilmesi geeken nokta ise elseif değil elsif olması:) elsif olduğun fark edene kadar bir süre vakit geçtiğini ifade etmek isterim.
- 2nci bölümde ise bir case...when kullanımı söz konusudur. Burada case ifadesinin doğrudan url isimli bir değişkene atandığına dikkat edilmelidir. Benim hoşuma giden kullanımlardan birisidir.(Ama sabredin ilerleyen satırlarda daha enteresan kullanımlar da söz konusu) Basit olarak networkStatus değerine göre url değişkenine bir değer atanması işlemi koşullu olarak gerçekleştirilmiştir.
- 3ncü bölümde basit bir for döngüsü yazılmıştır. Ancak dikkat edilmesi gereken iki nokta vardır. İlki 0..lastValue kullanımıdır. Diğeri ise blok içindeki ifade sonunda if kullanılmasıdır. (Bu Statement Modifier olarak isimlendiriliyor) Yani bir ifadenin sonunda if,case,while gibi koşullar kullanılabilir.
- 4ncü bölümde yer alan kod parçasında iç içe bir döngü kullanımı ile ekrana 3X4lük bir matriks kullanımı söz konusudur.
- 5nci bölümdeki kullanımda upto metodu ele alınmıştır. Aslında 1 sayısal değerinin Fixnum olduğu düşündüğümüzde upto isimli bir sınıf metodunun icra edildiğini ifade edebiliriz. upto sonrası gelen blok içerisinde ise (süslü parantezler arası kısım) 1den 100e kadar olan sayıların toplamı hesap edilmiştir.
- 6ncı bölümde ise yine Fixnum üzerinden times metoduna erişilerek ardışıl işlem yapıldığı söylenebilir. do ve end bloğu içerisinde 0dan başlamak suretiyle 5e kadar olan sayıların 3er eklenerek toplanması söz konusudur. Burada n isimli değişkenin 0 ile 5 arasındaki (5 dahil değil) sayıları işaret etmektedir.
- 7nci bölümde 6ncı bölümdekine benzer bir kullanım söz konusudur. Sadece do...end bloğu yerine süslü parantez bloğu kullanılmıştır.
- 8nci bölümde klasik while döngü kullanımına örnek verilmiş ve 0 ile 100 arasındaki sayılardan 7 ile bölünebilenler printf fonksiyonu yardımıyla ekrana formatlı bir şekilde yazdırılmıştır. (if'in Statement Modifier olarak kullanıldığına dikkat edelim)
- 9ncu bölümde yine bir Statement Modifier kullanımı söz konusudur. Bu kez ifade sonunda while kullanılmıştır.
- 10ncu bölümde yer alan kod parçasında sonsuz döngü yer almaktadır. while 1 her zaman true dönecektir. Çıkış için doğru şifrenin girilmesi şarttır ve döngüden çıkabilmek için break anahtar kelimesinden yararlanılır.(break kullanılan yerde if'in Statement Modifier olarak değerlendirildiğine dikkat edelim)
- 11nci bölümde loop isimli döngü kullanımı söz konusudur. Aslında bir koşul barındırmayan ve çıkmak için break kullanımının gerçekleştirildiği bir enstrüman olarak düşünebiliriz. Örnekte 1den 100e kadar olan sayıların toplamı hesaplanmaktadır.(Klasik döngü örneği)
- Son olarak 12nci bölümde unless kullanımı gerçekleştirilmiştir. matchPoint değişkeni 10dan büyük olmadığı sürece "Tam puan degil" yazılması söz konusudur.

Böylece bir kod parçacığımızın daha sonuna geldik. Terkrardan görüşünceye dek hepinize mutlu günler dilerim.