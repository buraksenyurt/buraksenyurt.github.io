---
layout: post
title: "Scala ile Tanışmak"
date: 2019-02-28 18:00:00
categories:
  - Programlama Dilleri
tags:
  - scala
  - programming-languages
  - object-oriented-programming
  - functional-programming
  - repl
  - java
  - jvm
  - bytecode
  - pattern-matching
  - case-class
  - Immutable-Types
  - methods
  - anonymous-function
  - trait
  - object
---
Yazılım geliştirmek için kullanabileceğimiz bir çok programlama dili var. Hatta bir ürünün geliştirilmesi demek farklı platformların bir araya getirilmesi anlamına da geldiği için, bir firmanın kendi ekosisteminde çeşitli dilleri bir arada kullandığını görmek mümkün. [Scala](https://docs.scala-lang.org/tour/tour-of-scala.html)'da bu çark içerisinde kendisine yer edinmiş ve son zamanlarda dikkatimi çeken programlama dillerden birisi. Bunun en büyük sebebi daha önceden çalıştığım turuncu bankanın Hollanda kanadında servis odaklı süreçlerin orkestrasyonu için onu backend tarafında kullanıyor (veya deneyimliyor) olması. Hatta [şuradaki github adresinden](https://github.com/ing-bank/baker) açık kaynak olan Baker isimli ürünü inceleme şansımız da var. Scala ve Java kullanılarak yazılmış bir çatı.

![learn_scala_0.gif](/assets/images/2019/learn_scala_0.gif)

Bunu bir konuşma sırasında öğrenmiştim ancak inceleme fırsatını bir türlü bulamamıştım. O vaktiler süreç akışlarının yönetimi için.Net ve Tibco işbirliğinden yararlanılıyordu. Hollanda neden daha farklı bir yol izlemişti? Scala'yı tercih etme sebepleri neydi? Hatta Scala programcıları aradıklarına dair iş ilanları var. Bu sorular bir süre kafamı meşgul etmişti. Derken zaman geçti, hayatlar değişti, teknolojiler farklılaştı ve araştırılacak konu listesinde sıra ona geldi. Bir bakalım neymiş bu Scala dedikleri programlama dili.

Scala 2001 yılında Martin Odersky tarafından geliştirilmeye başlanmış ve resmi olarak 2004'te yayınlanmış. Java dilinin bir uzantısı gibi görünüyor ama kesinlikle değil. Scala ile yazılan kodlar Java Bytecode'a dönüştürülüp JVM üzerinde çalıştırılabiliyor ama aynı zamanda REPL modeline göre yorumlatılarak da yürütülebiliyorlar. Hal böyle olunca Java kütüphanelerinin kullanılabilir olduğunu söylemek şaşırtıcı olmaz sanıyorum ki. Dolayısıyla Scala içinden Java kullanımı ve tam tersi durum mümkün. Esasında onu Java ile birlikte sıklıkla anıyorlar. Java ile yapılan işlerin aynısını daha az kod satırı ile halledebileceğimizi söylüyorlar. Söz gelimi Java ile yazılmış Vehicle isimli aşağıdaki sınıfı düşünelim.

```java
public class Vehicle{
   private final String title;
   public Vehicle(String title){
      this.title=title;
   }
   public String getTitle(){
      return title;
   }
}
```

Bunu Scala tarafında şu haliyle yazmamız mümkün.

```scala
case class Vehicle(title: String)
```

Scala ile ilgili övgüler bununla sınırlı değil tabii. Çok zarif bir şekilde nesne yönelimlilik (Object Oriented) ve fonksiyonel programlama paradigmalarını bir araya getirdiği belirtiliyor. Yani nesne yönelimli ilerlerken fonksiyonel olmanın kolaylıklarını da ele abiliriz gibime geliyor. Bu sebeptendir ki Scala'daki her şey birer nesnedir. Buna sayılar gibi tipler haricinde fonksiyonlar da dahildir. Genel amaçlı bu dilin pek çok fanatiği var. Söz gelimi Twitter'ın [şu adreste yayınlanmış repo'larında](https://github.com/twitter?language=scala) Scala sıklıkla geçiyor.

> Eğer yeni mezunsanız veya halen öğrenciyseniz ve yeni bir programlama dili öğrenmek istiyorsanız size "Scala'yı mutlaka öğrenin" diyemem. Size C#'ı yutun, Java'da efsane olun da diyemem. Ancak size sıklıkla kullandığınız Facebook, Twitter, Instagram, Linkedin, Netflix, Spotify gibi devlerin Github repolarına bir bakın derim. Neyi çözmek için hangi ürünlerinde neleri kullanmışlar, sizlere birçok fikir verecektir. Asla tek bir dilin veya platformun fanatiği olmamak lazım. Bunların hepsi birer araç. Aşağıdaki görselde yazıyı hazırladığım tarih itibariyle baker projesinin içerisindeki dil kullanım oranlarını görüyorsunuz. Scala ve Java bir arada ele alınarak geliştirilmiş bir çatı.

![learn_scala_1.gif](/assets/images/2019/learn_scala_1.gif)

Benim şu anki amacım dili temel özellikleri ile tanımaya çalışmak, bir kaç satır kod yazıp el alışkanlığı kazanmak. Java ile yazılım geliştirenler için öğrenirken yazım stiline alışmakta zorluk yaşandığına dair söylentiler var. Java ile yıllardır uğraşmamış bir.Net geliştiricisi olarak beni de epey zorlayacak diye düşünüyorum. Haydi gelin West-World'de (Ubuntu 16.04'ün 64 Bit sürümü olduğunu biliyorsunuzdur artık), Visual Studio Code kullanarak dili tanımaya çalışalım. İşe terminalden bağzı kurulumları yaparak başlamak gerekiyor elbette. Öncelikle sistemde JDK 8 (v 1.8 olarak da biliniyor) yüklü olmalı. West-World'de yüklüydü ki bunu versiyonu kontrol ederek teyid ettim. Sonrasında Scala'nın kurulumunu yaptım. İşte kullanabileceğimiz terminal komutları.

```bash
## Java SDK Kurulumu
sudo apt-get update
sudo apt-get install default-jdk

## Scala Runtime Kurulumu
sudo apt-get remove scala-library scala
sudo wget http://scala-lang.org/files/archive/scala-2.12.6.deb
sudo dpkg -i scala-2.12.6.deb
sudo apt-get update
sudo apt-get install scala
```

Muhtemelen sisteminizde JDK yüklüdür ama her ihtimale karşı genel bir güncelleme ve sonrasında JDK kurulumu ile işe başlanabilir. Ardından var olan bir scala sürümü varsa bunu kaldırmanızı öneririm. Öğrenmeye başlarken son stabil sürüm ile ilerlemekte yarar var. deb paketini indirdikten sonra bunu açıp kuruyoruz. Bu işlemler başarılı bir şekilde gerçekleştiyse terminalden scala yazarak yeni bir ufka doğru yelken açmaya başlayabiliriz. Örneğin aşağıdaki ifadeleri deneyebiliriz.

```scala
scala
nickname="persival"
var nickname="persival"
nickname
nickname="perZival"
nickname
val default_point=50,45
val default_point=50.45
default_point
default_point=60.50
```

Scala arabirimine ulaştıktan sonra ilk önce bir değişken tanımlayayım istedim. Tür belirtmeden bodoslama yazdım. Tabii ki hata aldım. Bunun üzerine en başta yapmam gereken şeyi yaptım. Dokümanı okumaya başladım. Sonrasında var ile val şeklinde bir kullanıma rastladım. var ile değeri değiştirilebilir (mutable) bir değişken tanımlanabildiğini anladım. val komutuyla da değeri değiştirilemeyen (immutable) değişkenlerin tanımlanabileceğini öğrendim ki default_point'in değerini bu sebeple değiştiremedim. Aralarda ufak yazım hatalarım da oldu. double bir değişken için virgül kullanımı hata verdi örneğin. Genel olarak ilk sonuçlar aşağıdaki ekran görüntüsündeki gibi oldu.

![learn_scala_2.gif](/assets/images/2019/learn_scala_2.gif)

İlerlemeye devam ettim ve değişken tanımlarken kullanılabilen def ifadesiyle karşılaştım. Önce mutable bir değişkenle, sonradan immutable bir tanesiyle denedim.

```scala
var city="istanbul"
def label_city=city
label_city
city="Istanbul"
label_city
label_city="istanbul"
```

Burada dikkat çekici bir nokta var. city isimli değişken için def ile bir başka değişken tanımlanıyor. Ancak label_city değişkeninin içeriği o çağrılana kadar alınmıyor. Bir başka deyişle değer ataması çağrım yapıldığı zaman gerçekleştiriliyor (Oysa ki yukarıdaki var ve val kullanımlarında atama yapılır yapılmaz değişkenler atanan değerlerine sahip olmuşlardı) Bunun henüz ne işe yarayacağını bilemiyorum ancak dili tasarlayanların mutlaka bir amacı vardır. Ayrıca city değişkeninin değerinde yapılacak değişiklikler label_city'yi de etkiliyor. Aynı referansa bakan değişkenler olduklarını ifade edebiliriz. Nitekim label_city değişkenine değer ataması yapamıyoruz.

![learn_scala_3.gif](/assets/images/2019/learn_scala_3.gif)

Bu birkaç kod parçasında String ve Double tipleri ile tanışmış oldum. Elbette başka tipler de mevcut. Boolean, Byte, Short, Int, Long, Float, Char diğer veri tiplerinden. Aslında tip ağacının tepesinde Any yer alıyor. Any'den türeyen AnyVal ve AnyRef isimli iki ana alt tip daha var. Tüm tiplerin bu ikisinden türediğini söyleyebiliriz. AnyVal değer türleri için AnyRef ise referans türleri için ata tip olarak ele alınmakta. Yeri gelmişken Scala'nın case-sensitive bir dil olduğunu belirtelim. Şunları bir deneyin mesela;

```scala
var isExist=true
isExist=False
VAR name="what"
val point:int=40
val point:Int=40
```

![learn_scala_4.gif](/assets/images/2019/learn_scala_4.gif)

> Komut satırından Scala dilinin özelliklerini öğrenmeye çalışırken ekranı temizlemek için CTRL+L tuş kombinasyonundan yararlanabileceğimizi öğrendim. Ayrıca:help ile kullanabileceğimiz önemli terminal komutlarını da görebiliriz. Söz gelimi:reset ile o ana kadar ki tüm REPL işlemlerini sıfırlamış olur ve başlangıç konumuna döneriz.

Diğer dillerde olduğu gibi Scala içerisinde de if-else if-else kullanımları mevcut. Nam-ı diğer koşullu ifadeler. Ancak bunun yerine aşağıdaki kod parçasına baksak daha güzel olur.

```scala
def isEven(number:Int) = if (number%2==0) "Yes" else "No"
```

Burada isEven isimli bir değişken tanımlanmış durumda ki aslen kendisi bir metod ve eşitliğin sağ tarafındaki ifadenin sonucunu taşıyor. Bu örneği daha çok Scala'da ternary (?:) operatörünün olmayışına karşılık gösteriyorlar. Yukarıdaki fonksiyona ait örnek bir kullanımı aşağıdaki ekran görüntüsünde bulabilirsiniz.

![learn_scala_5.gif](/assets/images/2019/learn_scala_5.gif)

Tabii if-else if-else kullanımını görünce insan switch case gibi bir bloğu da arıyor. Tam olarak aynı isimde olmasa da Pattern Matching özelliği kullanılarak bu mümkün kılınabiliyor. Bir anlamda bir değeri bir desenle kıyaslayıp kod akışını yönlendiriyoruz. Örneğin şu kod parçasında olduğu gibi.

```scala
def gradeValue(point:Int):String = point match {
     case 1 => "A"
     case 2 => "B"
     case 3 => "C"
     case _ => "you should work more"
     }
gradeValue(1)
gradeValue(3)
gradeValue(5)
```

gradeValue fonksiyonu için Pattern Matching kullanılıyor. point değişkeninin değerine göre case ifadelerinden birisi çalışıyor. case _ kısmı, Alternatives olarak isimlendirilen bölüm. point değişkeninin 1,2 ve 3 dışındaki tüm değerleri için çalışıyor.

![learn_scala_6.gif](/assets/images/2019/learn_scala_6.gif)

Ancak dahası var. Sınıflar ile birlikte kullanıldığı bir senaryo. Bu senaryoyu denemek için terminali terketmek gerektiğini düşünüyorum. Visual Studio Code ile ilerlemek daha doğru olacaktır. O zaman burada kısa bir es verelim derim. Visual Studio Code'da scala kodu nasıl yazılabilir öğrenelim isterim. Öncelikle bugün ve sonrası için West-World üzerinde bir klasör açtım. Sonrasında scala uzantılı HelloWorld isimli aşağıdaki kod içeriğine sahip dosyayı oluşturdum. Code dosyayı tanıyarak bana hemen bir uzantı (extension) önerdi. Onu yükleyerek devam ettim ve aşağıdaki içeriği oluşturdum.

```scala
object HelloWorld {
  def main(args: Array[String]) {
    println("Hello from Scala")
  }
}
```

Sonrasında aşağıdaki terminal komutları ile kod dosyasını derleyip çalıştırdım!

```bash
scalac HelloWorld.scala
scala -classpath . HelloWorld
```

![learn_scala_7.gif](/assets/images/2019/learn_scala_7.gif)

Aslında burada Scala kodunun derlenerek çalıştırılması söz konusu. Zaten kod içeriğine bakılacak olursa C#,C, C++ ve Java gibi dünyalardan pekala aşina olduğumuz main metodumuz var. Ekrandan parametre alabilen ve bunları bir String dizi üzerinden içeriye alan bu metod program çalıştırıldığındaki giriş noktası görevini üstleniyor. Scala'nın aynı zamanda yorumlamalı olarak da çalışabileceğinden bahsetmiştik. Yani aşağıdaki gibi bir kullanım da söz konusu olabilir.

```scala
println("Merhaba benim adım Burak")
println("Bugün",java.time.LocalDate.now)
val pi=3.14
var r=2
var result=pi*r*r
println(result)
```

Tutorial_1.scala ismiyle kaydettiğim dosyayı çalıştırmak için,

```bash
scala Tutorial_1.scala
```

terminal komutunu vermek yeterliydi. Kod içeriği yorumlanarak çalıştırılacaktı.

![learn_scala_8.gif](/assets/images/2019/learn_scala_8.gif)

Satır satır yorumlanarak kodun çalıştırıldığını görüyoruz. İstersek derleyerek, istersek yorumlatarak çalışabileceğimizi görmüş olduk. Hımmm. Etkileyici;)

Artık scala terminalini terk etmenin zamanı gelmişti. Dili öğrenmek için Visual Studio Code arabiriminden devam edebilirdim. Tekrar Pattern Matching konusuna döndüm ve bu kez aşağıdaki kod içeriğini yazdım.

```scala
abstract class Messenger

case class Human(to: String, title: String, message: String) extends Messenger
case class Computer(to: String, message: String) extends Messenger
case class Broadcast(message: String) extends Messenger

def sendAlert(messenger: Messenger): String = {
  messenger match {
    case Human(to, title, message) =>
      s"This message for you dear $to. Title : $title. Message : $message"
    case Computer(to, message) =>
      s"This message for you dear $to. Message : $message"
    case Broadcast(message) =>
      s"To all units '$message'"
  }
}
val jordi = Human("Peter", "Dude. What's up?","I am going to go there next weekend body :)")
val microServiceCenter = Computer("Sam", "The CPU service is not responding at this moment")
var westWorldCon=Broadcast("Emergency drop. Delete everything")

println(sendAlert(jordi))
println(sendAlert(microServiceCenter))
println(sendAlert(westWorldCon))
```

Messenger soyut bir sınıf ve diğer üç case class bu tipten türüyor. Tipik bir kalıtım söz konusu diyebiliriz sanırım. Human, Computer ve Broadcast sınıfları pek normal sınıf formatında değiller aslında değil mi? Dikkat ederseniz case class bildirimi ile tanımlanmış durumdalar ve hatta doğrudan parametre alıyorlar. Bakmayın ben direkt sınıf olduklarını ifade ettim. sendAlert isimli metod parametre olarak Messenger tipinden bir değişken alıyor. Buna göre ilgili metod Human, Computer ve Broadcast tipleri ile çalışabilir ki çok biçimli (Polymorphism) bir yapıda olduğunu ifade etsek yanlış olmaz. Eşitliğin sağ tarafına göre metod String değer dönürecek. Metodun kullanımı sırasında case class'lara ait birer değişkenin parametre olarak verildiğini görebilirsiniz. jordi, microServiceCenter ve westWorldCon bu kod parçasındaki kahramanlarımız. sendAlert metodu kendisine gelen case class kimse eşleşmeye göre ona ait kod bloğu çalıştırılmakta. s ile çift tırnaklı ifadeyi formatlıyoruz ve $ ile başlayan değişken adları aslında parametreleri işaret ediyor.

![learn_scala_9.gif](/assets/images/2019/learn_scala_9.gif)

İşler büyümeye başladı değil mi? if-else if-else derken pattern matching gibi değişik bir konuya denk geldik. Üstelik Pattern Matching bu kadarla da sınırlı değil. Guard, sealed class denilen kavramlar söz konusu. Hele ki case class olgusu. Normal sınıf olarak düşünebileceğimiz case class'lar aslında immutable veri tiplerinin modellenmesinde kullanılmak üzere düşünülmüşler. Onu da merak edip devam etmek istiyorum ancak oraya gelmek için başka şeyleri de öğrenmem gerekiyor. Mixin, trait, case class vs Sakin olmanın tam sırası. Böylesine ciddi bir dil çat diye öğrenilemez. Basit adımlarla dili tanımaya devam etmem lazım. Nitekim gözden kaçırdığım detaylar var. Söz gelimi fonksiyon ve metod aslında iki ayrı kavram. Aşağıdaki kod parçasını göz önüne alarak ilerleyelim.

```scala
var sayHello= (name:String) => println(s"Merhaba $name")
sayHello("Burak")

val sum = (x:Int,y:Int) => x+y
println(sum(4,5))

def diff(a:Int,b:Int):Int = a-b
println(diff(6,7))

def writeAndCombine(name:String)(message:String):String = {
    var output=s"$name! Sana bir mesaj var. '$message'"
    return output
}

println(writeAndCombine("Persival")("Bugün nasılsın?"))

def getState: String = "All is well"
var state=getState
println(state)
```

Örnekte basit fonksiyon ve metod kullanımları var. Metodları def anahtar kelimesinden ayırt edebilirsiniz. sayHello ve sum birer fonksiyon olarak karşımıza çıkıyorlar. Metodlar, fonksiyonlardan farklı olarak geri dönüş değerleri varsa tipinin ne olduğunu belirtmekte. Fonksiyonlar için bu durum söz konusu değil. Ayrıca bir metodun çoklu (birden fazladan farklı bir durum) parametre listesine sahip olması da söz konusu. writeAndCombine metoduna dikkat ederseniz bu durumu göreceksiniz. Fonksiyonları var ve val kelimeleri ile tanımlayabiliyoruz. Metodlar ise mutlak suretle def ile tanımlanmalılar. Her ne kadar writeAndCombine metodunda return kelimesini kullanmış olsak da bu mecburi değil. Fonksiyonlar aslında => operatörünün sağ tarafındaki ifadenin bir değişkene atanmış hali gibi düşünülebilirler. Fonksiyonları isimsiz olarak tanımlamak da mümkün (Anonymous Function) Arada kullanım yerleri göz önüne alındığında başka farklılıklar olduğuna da eminim. Nitekim hangi durumlarda fonksiyon hangi durumlarda metod tercih edilir bilmek lazım. Bendeki çalışma zamanı çıktıları aşağıdaki gibi oldu.

![learn_scala_10.gif](/assets/images/2019/learn_scala_10.gif)

Aslında metodları bir sınıf içerisinde deneyimlesek güzel olabilir değil mi? O zaman bir sınıf tanımlayalım.

```scala
class ContextManager(conStr:String)
{
    def GetActorCount(query:String):Int={
        println("Sistemdeki aktor sayısı bulunacak")
        println(s"Sorgumu '$query'")
        148
    }

    def Ping():Unit = println("Pong")

    val ConnectionString = () => conStr
}

var morinyo=new ContextManager("server=manchester;db=players;u_id=admin,pwd=1234")
morinyo.Ping()
var actorCount=morinyo.GetActorCount("select * from players where state='actor'")
println(actorCount)
println(morinyo.ConnectionString())
```

ContextManager isimli bir sınıfımız var. Sınıf tanımı sırasında parametre verebildiğimizi fark etmişsinizdir. conStr aslında yapıcı metod parametresi gibi düşünülebilir. İçerideki ConnectionString fonksiyonu onu doğrudan kullanmaktadır da;) Ortada görünen bir yapıcı metod ya da parametrelerini aktardığımız özellikler yok ancak kullanabiliyoruz. Bir şeylerin basitleştirildiği kesin. GetActorCount bir metod ve parametre olarak gelen sorguyu çalıştırıp Integer bir değer dönüyor. Hayali olarak elbette. Ping isimli metodumuzun dönüş tipi ise dikkatinizi çekmiş olmalı. Unit, void gibi anlamlandırılan bir dönüş tipiymiş. Şimdilik bunu öğrendim. ContextManager sınıfına ait nesne örneği oluşturmak için new operatöründen yararlanılıyor. Sonrasında ise bildiğimiz metod ve fonksiyon çağrımları söz konusu. İşte çalışma zamanı sonuçları.

![learn_scala_11.gif](/assets/images/2019/learn_scala_11.gif)

Yazının bu kısmında bıraksam mı yoksa hazır sınıflara değinmişken kısaca Case Class türüne bir baksam mı düşünmeye başladım. Filtre kahvem bitmişti zaten. Yenilerken soluklanır ve sonra tam gaz dokümanlar üzerinden araştırmaya devam ederim diye düşündüm. Öyle de yaptım:) Case Class aslında adı üzerinde "Kasa sınıf" olarak düşünülmeli. Bu özel tip immutable sınıflar tanımlamamıza olanak sağlıyor. Bu sebeple de değer bazlı (Compare by Value) karşılaştırmalar söz konusu. Aslında sınıfları referans, kasa sınıflarını da değer türü gibi düşünebiliriz (class vs struct gibi. Bu dillerde ne çok birbirlerine benziyorlar değil mi?) Aşağıdaki kod parçasını kullanarak bu durumu anlamaya çalışabiliriz.

```scala
case class Dimension(x:Double,y:Double,z:Double)
class Dim(x:Double,y:Double,z:Double)

val location1=Dimension(3.4,5.2,9.1)
val location2=Dimension(3.4,5.2,9.1)

println(location1 == location2)

val loc1=new Dim(3.4,5.2,9.1)
val loc2=new Dim(3.4,5.2,9.1)

println(loc1 == loc2)
```

![learn_scala_12.gif](/assets/images/2019/learn_scala_12.gif)

Dimension bir case class. Dim ise normal bir sınıf olarak tanımlandı. location1 ve location2 birer Case Class örneği ve aynı x,y,z değerlerine sahipler. loc1 ve loc2 ise birer Dim sınıf örneği ve x,y,z bazında yine aynı değerlere sahipler. Ancak karşılaştırılma durumları farklı. Case Class'lar değer bazlı olarak karşılaştırıldığından sonuç true. Sınıflar içinse tam aksi durum söz konusu ki bu normal.

Scala'yı anlamak için bulduğum dokümanları kurcalarken dilin temel özellikleri içerisindeki Object ve Trait kavramları da ilgimi çekti. Bir sınıfın sadece tek bir nesne örneğine sahip olmasını istiyorsak Object tipinden yararlanabiliriz. Çalışma zamanı ona ihtiyaç duyulduğu yerde oluşturacaktır (Lazy creation) Bir nevi Singleton nesne tanımlamak için kullanılan basit bir tip olarak düşünebiliriz. Aşağıdaki kod parçasında object tipinin kullanımına ilişkin basit bir deneme var.

```scala
object Listener {
  def Start:Boolean = { 
    println("listening...") 
    true
    }
  def Stop:Boolean = { 
    println("stoped!") 
    true
    }
}

Listener.Start
Listener.Stop
```

![learn_scala_13.gif](/assets/images/2019/learn_scala_13.gif)

Pek tabii Singleton nesnelere ihtiyaç duyulan senaryolara bakmak lazım buradaki durumu anlamak için. Şu anda sadece yazım stili ve kavramsal olarak farkındalık sahibi oldum diyebilirim. Gelin birde şu Trait mevzusuna bakalım. Trait'ler belirlenmiş alan ve metodları taşıyorlar. Örneklenemeyen bir tür ancak başka sınıf veya nesneleri genişletmekte kullanılabiliyorlar. Java 8 tarafındaki Interface tipine benzetiliyorlar (İnceleyince çok uzun zamandır C# tarafında var olan interface'lerden ne farkı var anlayamadım tabii ama Scala çalıştıkça fark edeceğim diye düşünüyorum) Generic tipleri de Trait'ler ile değerlendirmek mümkün. Aşağıdaki kod parçası onun kullanımı ile ilgili bana temel bir fikir verdi aslında.

```scala
trait Capability {
    def Walk(stepCont:Int)
    def Stop:Boolean
    def Turn(location:String)
}

class Truck(title:String) extends Capability{
    override def Walk(stepCount:Int) = println(s"$stepCount walk")
    override def Stop:Boolean=true
    override def Turn(location:String) = println(s"go to $location")
}

trait SpecialCapability extends Capability{
    def Fire(target:String):Boolean
}

val v40=new Truck("Volvi v40")
v40.Walk(10)
v40.Turn("Montreal")
```

![scala ile tanismak 01](/assets/images/2019/scala-ile-tanismak-01.png)

Capability içerisinde Walk, Stop, Turn isimli metod tanımlamaları var. Capability'den genişletilen Truck sınıfı bu metodları uygulamak zorunda. Diğer yandan SpecialCapability isimli Trait ek bir metod tanımı daha getiriyor. Yani Capability Trait'ini genişletmiş olduk.

Scala dili tabii ki birkaç sayfada anlatılamaz. Ben merak ettiğim için bu dili incelemeye çalışıyorum. Daha fazla hakim olmak için gerçek hayat senaryolarında kullanmak ve en azından bir kurumsal çaplı projede değerlendirmek lazım. Yine de ilk yazı için onun hakkında bir takım fikirler elde edebildiğimi düşünüyorum. Başlarda da belirtiğim üzere büyük oyuncularının dikkatini çeken ve ürünlerinde kullandıkları bir programlama dili olarak karşımıza çıkıyor. Scala ile ilgili yeni veya ilginç şeyler öğrendikçe buradan paylaşmaya devam etmeyi düşünüyorum. Scala'yı çalışmak için ilk kaynak olarak [resmi sitesinden](https://docs.scala-lang.org/tour/tour-of-scala.html) yararlanıyorum ancak Doğuş Teknoloji sağolsun Pluralsight eğitimleri de epey yardımcı oluyor. Ayrıca [Martin Odersky'nin Programming in Scala](https://www.amazon.com/Programming-Scala-Updated-2-12/dp/0981531687/ref=sr_1_1?s=books&ie=UTF8&qid=1535901044&sr=1-1&keywords=scala+cookbook) kitabını da şiddetle tavsiye ederim. Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
