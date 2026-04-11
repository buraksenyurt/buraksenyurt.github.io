---
layout: post
title: "Single File Assembly ve Multiple-File Assembly Kavramları"
date: 2004-04-27 12:00:00
tags:
  - Framework
  - assembly
  - clr
  - common-language-runtime
categories:
  - Programlama Dilleri
---
Bir önceki makalemizde, assembly'ları erişilebilirliklerine göre özel (private) ve paylaştırılmış (shared) olmak üzere iki kategoriye ayırabileceğimizi incelemiştik. Assembly'ları ayrıca, tek dosya (single file) ve çoklu dosya (multiple-file) olmak üzere iki farklı kategoriye daha ayırabiliriz. Bu makalemizde assembly'ların bu tiplerini incelemeye çalışacağız.

Çoğunlukla .NET ile uygulama geliştirirken, gerçekleştirmiş olduğumuz uygulamalar tek bir assembly'dan oluşurlar. Bu varsayılan olarak da böyledir. İşte bu assembly'lar single file (tek dosya) assembly olarak adlandırılır. Bir multiple-file assembly uygulaması ise, birden fazla assembly'dan oluşabilir. Öyle ki tüm bu assembly'lar farklı .NET dillerince yazılmış uygulama parçaları olabilir. Tüm bunların bir araya getirilerek PE (portable executable) olarak kullanılacak tek bir assembly altında birleştirilmesi ile, multiple-file assembly mimarisi elde edilmiş olur.

Örneğin, VB.NET module'lerinden, J# kütüphanelerinden oluşan bir uygulamada, giriş noktasına sahip olan uygulamanın yani Main metodunu içeren uygulamanın C# ile yazılmış olduğunu ve bu dosyadan diğer module ve kütüphanelere ait elemanların kullanıldığını düşünelim. Burada PE'ye (portable executable) ait manifesto bilgisi, giriş noktasına sahip olan assembly için oluşturulacaktır. Bir assembly manifestosu, uygulamanın başvurduğu diğer assembly'lara ait bilgileri, assembly'da kullanılan tür bilgilerini, assembly'a ait dosyalara ait bilgileri, izin bilgilerini vb. içerir. Dolayısıyla multiple-file assembly'a ait manifesto içerisinde, multiple-file assembly'ı oluşturan diğer module'lere, kütüphanelere ait bilgiler de yer alacaktır. Böylece yalın bir tabirle elimizde, birkaç .NET dili ile yazılmış parçalardan oluşan ve tek bir assembly altında birleştirilen bir uygulama olacaktır. Bu, bizim farklı .NET dilleri ile yazılmış uygulama parçalarını tek bir assembly altında birleştirerek kullanabilmemizi ve uygulamamızı yapılandırabilmemizi sağlar.

Örnekler üzerinden gittiğimizde bu konuyu daha iyi kavrayacağınızı düşünüyorum. İlk olarak çok basit bir single-file assembly oluşturacak ve yapısını, .NET araçlarından ildasm (Intermediate Language DisAssembly) ile inceleyeceğiz. Aşağıda C# dili ile yazılmış basit bir assembly görüyorsunuz.

```csharp
using System;

public class Giris
{
    public static void Main(string[] args)
    {
        int a, b;
        a = 5;
        b = 6;
        int sonuc = Topla(a, b);

        Console.WriteLine("Single File Assembly");
        Console.WriteLine("Toplam {0}", sonuc.ToString());
    }

    public static int Topla(int birinci, int ikinci)
    {
        return birinci + ikinci;
    }
}
```

Bu kodu aşağıdaki şekilde görüldüğü gibi derlediğimizde, Merhaba.exe assembly'ının oluşturulduğunu görürüz. Bu assembly'ımız bir Main metodu içerdiğinden ve biz bu assembly'ı exe olarak derleyip ortaya bir PE çıkarttığımızdan, bu assembly'e ait manifesto bilgileri de buna göre olacaktır.

![mk65_1.gif](/assets/images/2004/mk65_1.gif)

Şekil 1. Single Assembly

Şimdi ildasm aracını kullanarak, oluşturmuş olduğumuz bu assembly'ın içeriğine bakalım.

![mk65_2.gif](/assets/images/2004/mk65_2.gif)

Şekil 2. Giris.exe assembly'ının içeriği.

Burada görüldüğü gibi, assembly'ımıza ait manifesto bilgisinde PE olduğuna dair en büyük işareti gösteren entry point bilgisinin yer aldığı Main metodu görülmektedir. Daha önceden belirtiğimiz gibi bu manifesto içerisinde, Merhaba.exe assembly'ının kullanıdığı başka assembly'lara ait referans bilgileri, assembly'a ait module bilgisi, hashcode bilgiler vb. bulunur. Tüm bu manifesto bilgileri metadata verisi olarak Merhaba.exe assembly'ı içerisinde tutulmaktadır. Bu assembly bir PE (portable executable) olduğu için single assembly olarak değerlendirilir. Merhaba.exe assembly'ımızın manifesto bilgileri aşağıdaki gibidir.

```csharp
.assembly extern mscorlib
{
.publickeytoken = (B7 7A 5C 56 19 34 E0 89 ) // .z\V.4..
.ver 1:0:3300:0
}
.assembly Merhaba
{
// --- The following custom attribute is added automatically, do not uncomment -------
// .custom instance void [mscorlib]System.Diagnostics.DebuggableAttribute::.ctor(bool,
// bool) = ( 01 00 00 01 00 00 ) 
.hash algorithm 0x00008004
.ver 0:0:0:0
}
.module Merhaba.exe
// MVID: {C9BE521B-50BF-49DE-A9F9-F6EDB3D31941}
.imagebase 0x00400000
.subsystem 0x00000003
.file alignment 512
.corflags 0x00000001
// Image base: 0x07000000
```

Ancak bu assembly'ın bir single-file assembly olduğunun en büyük kanıtı Main metoduna ait IL kodlarında yazmaktadır.

![mk65_10.gif](/assets/images/2004/mk65_10.gif)

Şekil 3. Single-File Assembly Kanıtı.

Her .NET assembly'ında olduğu gibi burada da manifestomuz, standart olarak, mscorelib kütüphanesine bir başvuru ile başlamaktadır. Daha sonra assembly'a ait bilgiler başlar. Bir single assembly bu manifesto bilgileri dışında elbette uygulama kodlarının MSIL karşılıklarını da içermektedir. Bir single file assembly'ın temel yapısı aşağıdaki gibidir.

![mk65_3.gif](/assets/images/2004/mk65_3.gif)

Şekil 4. Single-File Assembly'ların genel yapısı.

Gelelim, multiple-file assembly'lara. Bu assembly türünü anlamanın en iyi yolu konuyu bir senaryo üzerinde düşünmektir. Uygulamamızın, VB.NET ile yazılmış bir module'ü, J# ile yazılmış bir kütüphanesi olduğunu farz edelim. Biz bu kaynaklardaki sınıfları asıl uygulamamızda yani PE olacak assembly'ımızda kullanmaya çalışacağız. Öncelikle işe, VB.NET module'ünü oluşturmak ile başlayalım.

```csharp
namespace vbdotnet
    public class vbselam
        public shared sub Selam()
            System.Console.WriteLine("Selam, burası VB.NET module")
        end sub
    end class
end namespace
```

Şimdi bu VB.NET kod dosyasını bir netmodule dosyası olarak derleyeceğiz. Bunun için aşağıdaki tekniği uygulayacağız.

![mk65_4.gif](/assets/images/2004/mk65_4.gif)

Şekil 5. VB.NET module

Lütfen, net module dosyasını vbc derleyici aracı ile nasıl oluşturduğumuza dikkat edelim. Bu module, VB.NET kodları ile yazılmış olup herhangi bir giriş noktası içermemektedir. Bu nedenle bu assembly aslında bir PE değildir. Tamamıyla başka bir PE assembly'ının kullanabilmesi için geliştirilmiştir. Bunu yazılım ekibinizin VB.NET programcılarının geliştirmiş olduğu bir module olarak düşünebilirsiniz. Bizim amacımız da, bu module'ü asıl PE assembly'ımız içerisinde kullanmak ve bir multiple-assembly meydana getirmektir. Şimdi de J# kodlarından oluşan bir kütüphane geliştirelim.

```csharp
import System;

package Araclar
{
    public class jsharpselam
    {
        public static function Selam()
        {
            System.Console.WriteLine("Selam, burasi JSharp ekibi");
        }
    }
}
```

![mk65_5.gif](/assets/images/2004/mk65_5.gif)

Şekil 6. J# ile yazılmış kütüphanemiz.

Sıra geldi tüm bu assembly'ları kullanacak olan assembly'ımızı yazmaya. Bu, C# ile yazılmış bir assembly olacak ve aynı zamanda, yukarıda yazmış olduğumuz VB.NET module'ünü ve J# kütüphanesini kullanacak.

```csharp
using System;
using Araclar;

public class Temel
{
    public static void Main(string[] args)
    {
        System.Console.WriteLine("Ana uygulama");
        jsharpselam.Selam();
        vbdotnet.vbselam.Selam();
    }
}
```

Kodumuzda, VB.NET module'ü içindeki Selam ve J# ile yazılmış kütüphane içindeki Selam metodlarına erişiyoruz. Şimdi yapmamız gereken işlem bu assembly'ı bir netmodule olarak derlemek ve ardından tüm assembly'ları tek bir assembly altında birleştirmek. PE olacak olan assembly'ımızı netmodule hâline getirmek için aşağıdaki kod satırını kullanacağız.

![mk65_6.gif](/assets/images/2004/mk65_6.gif)

Şekil 7. PE uygulamamızın netmodule olarak oluşturulması.

Bu komut satırında, PE olacak assembly'ımızı netmodule hâline getirirken, kullandığımız J# kütüphanesini nasıl referans ettiğimize ayrıca VB.NET module'ünü nasıl eklediğimize dikkat edelim. Sıra, tüm bu assembly'ları tek bir çatı altında toplayıp multiple-assembly'ımızı oluşturmaya geldi. Bu işi gerçekleştirmek amacıyla, AL (assembly linker) aracını kullanacağız. Bu araç yardımıyla, yazmış olduğumuz üç assembly'ı da tek bir assembly içinde toplayacak ve multiple-assembly yapımızı gerçekleştirmiş olacağız.

![mk65_7.gif](/assets/images/2004/mk65_7.gif)

Şekil 8. al (assembly linker) yardımıyla multiple-assembly çatısının oluşturulması.

Burada dikkat etmemiz gereken nokta main parametresi ile bildirdiğimiz yerdir. Burada, PE'ımızın çalışmaya başlayacağı yerin, Temel isimli assembly'ımız içindeki Main yordamı olduğunu belirtmiş oluyoruz. Elbette main parametresi, herhangi bir assembly içindeki Main yordamını belirtmek zorundadır. PE dosyamıza ayrıca, diğer kullanacağı assembly'ları da bağlamış olduk. Şimdi Uygulama.exe assembly'ımızın yapısını ildasm ile yakından inceleyelim.

Öncelikle ilk dikkati çeken nokta, entry point'in eklenmiş olmasıdır. Yazmış olduğumuz diğer assembly'lardan ne VB.NET module assembly'ımız ne J# kodlu kütüphane assembly'ımız ne de PE'ımızı oluşturan C# netmodule assembly'ımız, Main metodunu içermesine rağmen, herhangi bir entry point içermemekteydi. Ancak AL (assembly linker) aracı ile tüm bu assembly'ları tek bir assembly altında birleştirirken, entry point'imizi de Temel.netmodule assembly'ı içindeki Main yordamı olarak işaretlemiş olduk.

![mk65_8.gif](/assets/images/2004/mk65_8.gif)

Şekil 9. PE olan assembly'ımızın içeriği.

Gelelim içeriğe. İlk dikkat çeken nokta diğer assembly'ların başvuru bilgilerinin eklenmiş olmasıdır. Başvuruların olduğu assembly'lar extern anahtar kelimesini içeren satırlardır. Extern anahtar kelimesi, bu assembly'ların PE tarafından erişilen ve kullanılan assembly'lar olduğunu gösterir. Bunun dışındaki tüm satırları ve bilgileri ile birlikte bu assembly aslında bir single-file assembly'dan farksızdır. Ancak kullandığı diğer assembly'lar düşünüldüğünde ortaya bir multiple-file assembly çıkmıştır.

```csharp
.module extern Temel.netmodule
.assembly extern mscorlib
{
.publickeytoken = (B7 7A 5C 56 19 34 E0 89 ) // .z\V.4..
.hash = (4E FE C2 93 5B 46 10 72 20 30 9A 9C 31 21 D0 2F // N...[F.r 0..1!./
9B 84 AF 0E ) 
.ver 1:0:3300:0
}
.assembly extern Microsoft.VisualBasic
{
.publickeytoken = (B0 3F 5F 7F 11 D5 0A 3A ) // .?_....:
.ver 7:0:3300:0
}
.assembly extern jsharpselam
{
.hash = (FA 10 B8 EE 98 5A F7 81 4F 0D 91 80 38 9D FB 78 // .....Z..O...8..x
04 14 A0 83 ) 
.ver 0:0:0:0
}
.assembly Uygulama
{
// --- The following custom attribute is added automatically, do not uncomment -------
// .custom instance void [mscorlib]System.Diagnostics.DebuggableAttribute::.ctor(bool,
// bool) = ( 01 00 00 01 00 00 ) 
.hash algorithm 0x00008004
.ver 0:0:0:0
}
.file vbselam.netmodule
.hash = (85 65 08 DF 98 6C 95 7F 61 47 8F 6C 02 DA 04 64 // .e...l..aG.l...d
B6 AC A2 F9 ) 
.file Temel.netmodule
.hash = (89 B4 FA 26 C6 7C 59 23 DB 92 6F 3A 29 5E 31 C7 // ...&.|Y#..o:)^1.
E7 37 35 AF ) // .75.
.class extern public vbdotnet.vbselam
{
.file vbselam.netmodule
.class 0x02000002
}
.class extern public Temel
{
.file Temel.netmodule
.class 0x02000002
}
.module Uygulama.exe
// MVID: {2F568429-2D83-4AA8-9558-46FB59574BBB}
.imagebase 0x00400000
.subsystem 0x00000003
.file alignment 512
.corflags 0x00000001
// Image base: 0x07000000
```

Uygulamamızı çalıştırdığımızda aşağıdaki sonucu elde ederiz.

![mk65_9.gif](/assets/images/2004/mk65_9.gif)

Şekil 10. Uygulamanın çalışmasının sonucu.

Böylece geldik bir makalemizin daha sonuna. Umuyorum ki assembly'ları bu yönleri ile incelemek siz değerli okurlarımızın işine yarıyordur. Bir sonraki makalemizde görüşmek dileğiyle hepinize mutlu günler dilerim.