---
layout: post
title: "Ruby Kod Parçacıkları - 2 (Hashes)"
date: 2015-08-04 18:00:00
categories:
  - Programlama Dilleri
tags:
  - ruby-lang
  - hashes
  - data-structures
---
Ruby programlama dilinde de veri yapıları (Data Structures) oluşturmak için kullanılan tiper vardır. Dictionary benzeri koleksiyon olarak kabul edebileceğimiz Hash sınıfı bunlardan birisidir. Benzersiz anahtar (key) ve değer (value) çiftlerinden oluşan Hash nesne örneklerinin kullanımı oldukça kolaydır.

Aşağıdaki Ruby Kod Parçacığı ile Hash tipinden koleksiyonları kısaca tanımaya çalışalım. [Bir önceki kod parçacığında](/2015/08/02/ruby-kod-parcaciklari-1/) olduğu gibi bu betiği de rb uzantılı bir dosya (örneğin Hashes.rb) olarak kaydedip komut satırından Ruby aracı ile çalıştırabiliriz.

```ruby
class Person

        attr_reader :name,:age
       
        def initialize(personName,personAge)
               @name=personName
               @age=personAge     
        end        
end

if __FILE__==$0
       
        planes={
            PLN1001:"F-14 Tomcat",
            PLN1034:"F-22 Raptor",
            PLN9283:"F-4 Phantom"               
        }        
        puts planes.inspect
 
        puts planes[:PLN1034]
        puts planes.keys
        p planes.values
       
        oldPlanes=Hash.new
        oldPlanes["OPLN109"]="Messerschmitt 109"
        oldPlanes["OPLN100"]="Spitfire"
 
        oldPlanes.each{ |k,v| puts "#{k} = #{v}"}
        puts oldPlanes["OPLN109"]

        weapons=Hash[:arms1,"Sword",:arms2,"Boken",:arms3,"Canon Ball"]       
        p weapons
       
        playerPoints={
            Rogu1:90,
            Black:120,
            Silver:80,
            Burki:40,
            Strangers_in_the_night:800,
            Avanger:300,
            Hulk:1200
        }       
        loosers=playerPoints.select{|name,point| point<200}
        p loosers
 
        burki=Person.new "Burak Selim Senyurt",39
        ruki=Person.new "Ru Yu Ki",36
        persons={
            person1:burki,
            person2:ruki
        }
        p persons.inspect
end
```

![2Q==](/assets/images/2015/ruby-kod-parcaciklari-2-hashes-01.jpg)

Şimdi kod parçacığında neler yaptık maddeler halinde özetleyelim.

- Person bir sınıf olarak tanımlanmıştır ve name,ageisimli sadece okunabilir (readonly) iki niteliğe (attribute) sahiptir. Bu niteliklere Person sınıf örnekleri üzerinden ulaşılır. Tahmin edileceği üzere initialize metodu sınıfın yapıcısıdır (constructor olarak düşünebiliriz) @name ve @age ile nesne örneği değişkenleri (Instance Variables) ifade edilir ve initialize metoduna gelen parametreler bu değişkenlere atanır. @ ile başlayan değişkenlere Person sınıfı içerisindeki diğer metodlardan da ulaşabiliriz.
- Bir Hash aslında key ve value çiftlerinden oluşur. Bu açıdan Dictionary olarak da düşünülebilir. Eğer String olarak özellikle belirtilmesse key'ler birer symbol olarak işaretlenir (symbol'leri ilerleyen zamanlarda derinlemesine inceleyeceğiz)
- Bir Dictionary içerisindeki key'lere [] operatörü ile ulaşabiliriz. Eğer key bir symbol ise: işareti ile erişmek gerekir.
- İstenirse bir Dictionary'nin tüm anahtarlarına keys metodu üzerinden ulaşabiliriz. Benzer durum değerler (values) için de geçerlidir.
- Dictionary nesneleri Hash sınıfı üzerinden new metodu ile de oluşturulabilir. Sonrasında eleman ekleme işlemleri yine [] operatörü ile gerçekleştirilir. oldPlanes koleksiyonunun oluşturulmasında indis operatörü içerisinde String türünden anahtar ifadeleri kullanılmıştır.
- each metodu sayesinde Dictionary'lerin anahtar-değer (key-value) kolayca gezilebilir.
- oldPlanes koleksiyonunda symbol yerine String tipten anahtarlar kullanılmıştır. Bu yüzden OPLN109 anahtarının değerine erişmek için:OPLN109 şeklinde bir kullanım söz konusu değildir.
- Dictionary'ler oluşturulurken [,,] notasyonu da kullanılabilir. weapons değişkeninin oluşturulması bu şekilde gerçekleştirilmiştir. Önce bir symbol sonrasında ise bir değer (value) ve bu sıra ile eleman çiftleri eklenmeye devam edilmiştir.
- Dictionary nesneleri üzerinden aynen.Net'de olduğu gibi LINQ benzeri sorgular çalıştırılabilir. select metodu bu amaçla kullanılır. loosers isimli Array puanı 200ün altında olan oyuncuları taşımaktadır.(LINQvari bişi bu:))
- Kullanıcı tanımlı sınıf örnekleri new metodu ile kolayca oluşturulabilir. burki ve ruki nesnelerinin örneklenmesi sırasında new metodundan yararlanılmıştır.(Parantez kullanılmadığına dikkat edilmelidir)
- Bir Dictonary'de istenirse kullanıcı tanımlı sınıflara ait nesne örnekleri de pekala kullanılabilir. persons isimli Dictionary'de value olarak burki ve ruki isimli nesne örneklerine yer verilmiştir.
- persons üzerinden inspect metodu çalıştırıldığında Person sınıf örnekleri için varsayılan inspect metodu çalıştırılmış ve bu nedenle nesnelerin hash, name ve age niteliklerinin değerleri farklı bir formatta elde edilip sonrasında ekrana basılmıştır.

Böylece geldik bir kod parçacığının daha sonuna:) Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
