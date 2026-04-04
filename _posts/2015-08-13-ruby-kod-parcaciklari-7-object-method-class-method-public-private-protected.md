---
layout: post
title: "Ruby Kod Parçacıkları - 7 (Object Method, Class Method, Public, Private, Protected)"
date: 2015-08-13 11:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - object-method
  - public-key-token
  - private
  - protected
  - attribute
  - accessor
---
Ruby sınıflarında farklı amaçlarla kullanılan metodlar mevcuttur. Serimiz boyunca pek çok çeşidini kullandık. Nesne örneklerini oluşturmak için initialize metodundan, sınıf varlığını String olarak yazmak için ezdiğimiz (override) to_s metodundan, sınıfa ait durum bilgisini taşıyan nitelikler (Attributes) için accessor'lardan vb...

Ağırlıklı olarak Instance method'lar kullandık. Bu metod tipinden başka Sınıf metodları (Class Methods) da mevcuttur. (Ben.Net tarafındaki static metodlara benzetiyorum) Ayrıca metodlara public, private ve protected olmak üzere üç farklı seviyede erişim kontrol kriteri verilebilir.

Varsayılan olarak tüm metodlar public tanımlanırlar. Yani kodun her seviyesinden erişilebilirler. Diğer yandan sadece sınıf içinde kullanılması istenen metodlar için private tanımlaması yapılabilir. protected erişim belirleyicisine sahip metodlara ise sadece türeyen sınıflardan erişebiliriz.(Inheritance konusunda buna da değineceğiz)

Aşağıdaki kod parçacığı ile devam edelim.

```ruby
class Vehicle
	@@vehicleCount=0 #0 Global Variable
	def codeName# Accessor method
		@codeName
	end

	def type# Accessor method
		@type
	end

	def power# Accessor method
		@power
	end

	def commander# Accessor method
		@commander
	end

	private :type, :power#1 private accessor methods
	def move(direction,value) #2 Instance Method
		"move to #{direction} with #{value} for #{@codeName}."
	end

	def fixIt
		"#{@codeName} is fixing..."
	end

	protected :fixIt#3 protected method definition

	def initialize(type,power,commander,codeName) #4 Constructor method
		@type=type
		@power=power
		@commander=commander
		@codeName=codeName
		@@vehicleCount+=1
	end

	def self.getVehicleCount#5 Class Methods
		@@vehicleCount
	end

	def to_s #6 overriding
		"#{@codeName}->Commander: #{@commander} - (#{@type}-#{@power})"
	end

end

if __FILE__==$0
	tiger=Vehicle.new("Tank",80,"Colonel Burk","Red Baron")
	puts tiger.to_s
	puts tiger.move("left",10)
	# putstiger.fixIt#7 protected method access violation

	spitfire=Vehicle.new("Fighter Plane",85,"Lieutenant Tubi","Minion Fighter")
	puts spitfire.to_s
	puts spitfire.move("backward",15)

	puts "Current vehicle count is " +Vehicle.getVehicleCount.to_s

	# putstiger.type#8 private method access violation
end
```

Kod parçasının bu haliyle çalışma zamanı çıktısı aşağıdaki gibidir.

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-7-object-method-class-method-public-private-protected-01.jpg)

Gelelim kod parçasında dikkat çeken noktalara.

- Vehicle sınıfı içerisinde bir global değişken (#0 da) tanımlanmış olup bu değişkenin artımı yapıcı metod (initialize) içerisinde gerçekleştirilmiştir (#4)
- Sınıfın codeName,type,commander,power isimli 4 niteleyicisi vardır. type ve power accessor metodları private olarak tanımlanmışlardır. Yani Vehicle sınıfı dışında erişilemezler. Tanımlama #1 numaralı satırda symbol'ler kullanılarak gerçekleştirilmiştir. Çok doğal olarak aksi belirtilmediği için commander ve codeName accessor'ları public metod'lardır.
- move ve fixIt isimli metodlar Instance metodlardır. Ancak fixIt, protected olarak işaretlenmiştir (#3 nolu kod satırı) Dolayısıyla sadece Vehicle'dan türeyen sınıflarca kullanılabilir.
- #5 numaralı satırda bir sınıf metodu tanımlaması gerçekleştirilmektedir. Sınıf metodunun self. notasyonu ile yazıldığına dikkat edelim. self ile tahmin edileceği üzere Vehicle nesnesinin o anki çalışma zamanı örneği işaret edilmektedir (Sanırım C# tarafındaki this anahtar kelimesinin görevini üstlendiğini düşünebilirim)
- Sınıf metodlarına erişirken #9 numaralı satırdaki söz dizimi kullanılır.
- Kodun #7 ve #8 numaralı satırları çalıştırıldığında ise sırasıyla aşağıdaki ekran görüntüsünde yer alan hataların alındığı görülebilir. Nitekim #7 numaralı satırda protected olarak işaretlenmiş, #8 numaralı satırda ise private olarak işaretlenmiş metod erişimleri söz konusudur. Bu geçersiz kullanımlar nedeni ile çalışma zamanında hatalar alınır.

protected erişim sonrası alınan hata

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-7-object-method-class-method-public-private-protected-02.jpg)

private erişim sonrası alınan hata

![Z](/assets/images/2015/ruby-kod-parcaciklari-7-object-method-class-method-public-private-protected-03.jpg)

Böylece geldik bir kod parçacığımızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
