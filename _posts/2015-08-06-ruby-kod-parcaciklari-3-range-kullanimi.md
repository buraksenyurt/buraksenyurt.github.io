---
layout: post
title: "Ruby Kod Parçacıkları - 3 (Range Kullanımı)"
date: 2015-08-06 09:30:00
tags:
  - ruby-lang
  - range
categories:
  - Programlama Dilleri
---
Range sınıfı ile başlangıç ve bitiş değerleri belli olan aralıklar tanımlanabilir. Bu aralığa ait değerler sayısal veya metinsel olabileceği gibi kullanıcı tanımlı sınıf örnekleri de olabilir (Bu benim için de henüz ileri seviye bir konu olduğundan ilerleyen günlerde değinmeye çalışacağım) Gelin bu aralıkların Ruby programlama dilinde nasıl kullanıldığına kısaca bakalım.

```ruby
if __FILE__==$0
 
    #.. ile ... farki
    harfler1=('a'..'j').to_a
    harfler2=('a'...'j').to_a
 
    puts harfler1.inspect
    puts harfler2.inspect
 
    # Range' in her bir elemani uzerinde islem uygulamak
    toplam=0
    (1..100).each{|n|toplam+=n}
    puts toplam
 
    # Negatif sayi araliginda calismak
    (-100..-1).each{|n|printf "#{n},"}
 
    # Baslangic ve bitis degerleri ile ornegin sondan n sayida elemani cekmek
    sayilar=Range.new(0,189)
    puts "\nIlk eleman:#{sayilar.begin}\nSon eleman:#{sayilar.end}"
    puts "son 5 sayi #{sayilar.last(5)}"
 
    # Sayi araliginda belirli adim degerlerinde atlayarak ilerlemek
    puts "Baslangic sayisi"
    baslangic=gets.to_i
    puts "Bitis sayisi"
    bitis=gets.to_i
    sayilar2=Range.new(baslangic,bitis)
    puts sayilar2.step(3){|n|printf "#{n},"}
 
    # case kosullu ifadesinde Range kullanmak
    puts "\nKac puan aldiniz"
    puan=gets
    case puan.to_i
        when 1..20 then puts "Basarisiz"
        when 20..50 then puts "Daha cok calismali"
        when 20..75 then puts "Basarili"
        when 75..100 then puts "Tebrikler! Ustun basari"
    end
end
````

![ruby kod parcaciklari 3 range kullanimi 01](/assets/images/2015/ruby-kod-parcaciklari-3-range-kullanimi-01.jpg)

ve her zaman olduğu gibi kod parçacığımıza ait kısa notlarımızı paylaşalım.

- harfler1 ve harfler2 isimli Range'lerin üretim biçimleri arasında sadece bir nokta farkı vardır. İki nokta kullanıldığında son yazılan değer de aralığa dahil edilir. Üç nokta kullanıldığında ise son değer aralığa dahil edilmez.
- Range sınfına ait each metodundan yararlanarak tek bir ifade ile tüm aralık değerleri üzerinde işlem uygulanabilir. 1den 100e kadar (100 dahil) değerlerin toplamını bulmak için each metodundan yararlanılmıştır.
- Bir sonraki each metodu kullanımında ise -100den -1e kadar ki sayıları içeren bir değer aralığı oluşturulmuştur. Yani negatif sayılardan oluşan değer aralıkları da belirlenebilir. Pek tabi ondalıklı değer aralıkları da söz konusu olabilir. Bunu bir deneyin;)
- Bir aralığın alt ve üst değerlerini öğrenmek için begin ve end metodlarından yararlanılır.
- Eğer bir aralığın son n değeri elde edilmek istenirse last metodundan yararlanılabilir. Metodun parametresi en sağdan geriye doğru kaç eleman alınacağını belirtir.
- Bir aralığı oluşturmak için nokta notasyonu dışında yapıcı metod da kullanılabilir. new ile erişilen initialize metodu parametre olarak değer aralığının başlangıç ve bitiş değerlerini alır.
- Eğer bir aralığın elemanlarında belirli adım değerleri ile ilerlenmek isteniyorsa step metodunu kullanabiliriz.
- Aralıkların faydalı bir şekilde kullanıldığı alanlardan birisi de case koşul ifadeleridir. puan hesaplamasındaki kullanıma dikkat edelim.

Böylece geldik bir kod parçacığının daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.