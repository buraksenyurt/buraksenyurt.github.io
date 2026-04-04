---
layout: post
title: "Tek Fotoluk İpucu 154 - C# 7.0 out İyileştirmesi"
date: 2017-03-19 18:00:00
tags:
  - csharp
  - out-variables
  - tryparse
  - out
categories:
  - Foto İpucu
---
Henüz C# 6.0'ın nimetlerini şirket projelerinde deneyimleme fırsatı bulamamışken yakın zamanda çıkan Visual Studio 2017 ile birlikte gündeme oturan C# 7.0 kabiliyetlerini yeni yeni keşfetmeye başlıyorum. C# 7.0 tarafında da epey yenilik var. Bunlardan birisi de özellikle out anahtar kelimesinin kullanımına yönelik. En yaygın senaryo string bir içeriğin sayısal tipe dönüştürülmesi sırasında TryParse fonksiyonunun kullanılması. Normal şartlarda aşağıdaki kod parçasındaki gibi gerçekleştirdiğimiz bir operasyon bu.

```csharp
using System;

namespace Classics
{
    class Program
    {
        static void Main(string[] args)
        {
            string input=string.Empty;
            while((input = Console.ReadLine()).ToUpper()!="X")
            {            
                int number;
                if (Int32.TryParse(input, out number))
                {
                    Console.WriteLine("\t{0}",number);
                }
                else
                {
                    Console.WriteLine("Parse error!");
                }
            };
        }
    }
}
```

![tfi154_1.gif](/assets/images/2017/tfi154_1.gif)

Örnekte Int32 tipinin TryParse metodu ile bir dönüştürme işlemi yapılmakta. TryParse bilindiği üzere string olarak gelen ilk parametreyi uygulandığı tipe dönüştürebilirse ikinci parametrede çıktı olarak veriyor. Bu teknikte out ile dışarıya verilecek değişkenin de önceden tanımlanmış olması gerekiyor. C# 7.0 da bu zorunluluk kaldırılmış durumda. Ne yazık ki şirket bilgisayarıma Visual Studio 2017'yi henüz yükletemedim. Güvenliğin önce bir bakması gerkiyormuşmuş. Ama çaresiz değiliz.[Bu adresteki online derleyici](https://dotnetfiddle.net/) pekala iş görüyor. Üzerindeki Rosyln derleyicisi sayesinde yeni dil özelliklerini deneme fırsatım oldu. Şimdi out kullanımına ilişkin bir kaç örnek yapalım.

![tfi154_3.gif](/assets/images/2017/tfi154_3.gif)

Calculate fonksiyonu iki sayının toplamını ve farkını hesap edip out parametresi olarak geriye döndürmekte. Main metodundaki kullanım dikkatinizi çekmiştir. total ve dif isimli değişkenleri çağrım öncesi tanımlamış değiliz. Daha yaygın bir örnekle devam edelim.

![tek fotoluk ipucu 154 csharp 7 0 out iyilestirmesi 01](/assets/images/2017/tek-fotoluk-ipucu-154-csharp-7-0-out-iyilestirmesi-01.png)

TryParse metodunda out değişkenini kullanırken yine number isimli değişkeni önceden tanımlamadığımızı fark etmişsinizdir. Aslında out kullanımı sırasında değişken tipini belirtmek zorunda değiliz. Yani var tipinde bir tanımlama da mümkün. Aşağıdaki ekran görüntüsünde olduğu gibi.

![tfi154_5.gif](/assets/images/2017/tfi154_5.gif)

Son olarak bir if bloğu içerisinde out şeklinde belirtilen değişkeni blok dışında da kullanabileceğimizi ifade edelim.

![tfi154_6.gif](/assets/images/2017/tfi154_6.gif)

Böylece geldik bir ipucumuzun daha sonuna. Diğer C# 7.0 özelliklerini de öğrendikçe paylaşmaya çalışacağım. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.