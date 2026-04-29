---
layout: post
title: "Metot Overloading Üzerine Düşünceler"
date: 2026-05-01 09:00:00
tags:
    - csharp
    - rust
    - ocaml
    - zig
    - programming
    - method-overloading
    - comparison
categories:
    - Programlama Dilleri
---
Profesyonl olarak mesleki hayatımın neredeyse tamamında C# programlama dilini kullanarak geliştirme yaptım. Çoğunlukla bir arayüzün *(Web veya Windows)* bir iş sürecini tetiklediği ve bunun arkasında dönen yazılım yaşam döngüsünün bir parçası oldum. C#, Java, Go, Python vb birçok dil bu tip geliştirmeleri hızlandıracak türlü yeteneğe, kütüphane desteğine sahipler. Bununla birlikte uzun zamandır farklı programlama dillerini de öğrenmeye çalışıyorum ve çok uzun zamandır kafamı kurcalayan şeyler var. Bir programlama dilini tam olarak öğrenmek ne demektir?

İş hayatının gereksinimleri düşünüldüğünde bir programlama dilinin, örneğin C#'ın tüm yeteneklerini kullanmıyoruz ve hatta yüzdesel olarak kimisini çok kimisini az ele alıyoruz. Bu yüzden farklı dillerdeki ilginç yaklaşımları görünce şaşırıyoruz *(Şahsen ben öyle hissediyorum)*. Örneğin, **OCaml** ile yazılmış bir ifadenin derlenirken matematiksel karşılığının ispatlanması, **Zig**' in **comptime** diye sadece derleme zamanında bilinen türleri desteklemesi, **Rust**'ın bellek yönetimindeki hassasiyeti vs Arada ince bir çizgi var belkide. Bilgisayar bilimlerinin akademik yanı ile saha yazılımcısı olmanın arasındaki çizgi olabilir bu. İş hayatına yönelik süreç bazlı, belli bir ekonomiyi çevreleyen çözümlere baktığımızda **Java**, **C#**, **Go**, **Python** vb dillerin epeyce öne çıktığını görüyoruz. Eğer bu alanlarda iş yapacaksak bu dillerin etkin kullanımını öğrenmek önemli ama en derin noktalarına kadar gerekli mi tartışılır.

Diğer yandan bir programlama dilinin genetiğini anlamak, felsefesini kavramak, yeteneklerini sorgulamak denince iş epeyce değişiyor. Zira başka programlama dillerinden etkilenen dillerin genetik koduna işleyen birçok kalıtımsal özellik öğrenmeye değer. Bir diğer öğrenmeye değer konuysa birisinde olan bir özelliğin diğer dilde neden olmayışını araştırmak.

İşte bu karman çorman düşünceler arasında gelelim bugünkü konumuza; metotların aşırı yüklenmesi *(Method Overloading)* Baştan söyleyeyim bu yazıda "o dil bu dilden daha iyidir" gibi bir amacım yok, sadece merak ettiğim bir sorunun cevabını arayıp çıkarımlar elde etmeye çalışacağım.

## C# Bakış Açısından Method Overloading

**C#** dilini ilk öğrenmeye başladığımızda her dilde olduğu gibi bir **Hello World** uygulaması yazılır ve kuvvetle muhtemel **Console** sınıfının statik olarak çağırılabilen **WriteLine** metodu kullanılır. Sonralarında bu metodun aslında aynı isimle 20 farklı sürümünün olduğu üzerinde de durulur ve bu kavram **Method Overloading** olarak adlandırılır.

![MethOverload_00.png](/assets/images/2026/MethOverload_00.png)

Gayet güzel bir özellik değil mi? Geliştirici olarak sadece **WriteLine** metodunu biliriz ve bu bilgi zihnimizde yer eder. Aşırı yüklenmiş diğer versiyonlar da aynı isimde olduğundan farklı parametrelere çalışan hallerini bilmemize de gerek yoktur. Sezgisel olarak farklı veri türleri ile çalışabileceğini de biliriz. Bu yaklaşımın **Syntatic Sugar** olarak ifade edildiğine de rastlanır.

Normal metotlar gibi yapıcı metotlar da *(Constructors)* aşırı yüklenebilirler. Metodun imzasını oluşturan parametre sayısı ve argüman tipleri ayrıştırıcıdır. Yani aynı tip ve sayıda parametre kullanamayız. Aşağıdaki örnek kod parçasında basit bir örnek yer almaktadır.

```csharp
Console.WriteLine("Method overloading demonstration");

var finder = new SubscriberFilter();
_ = finder.Find(123);
_ = finder.Find("john.doe@azon.none");
_ = finder.Find(new SocialSecurityNumber("123-45-678"));

public record SocialSecurityNumber(string Value)
{
    public bool IsValid()
    {
        return !string.IsNullOrEmpty(Value) && Value.Length == 11 && Value[3] == '-' && Value[6] == '-';
    }
}
public class Subscriber
{
    public Guid Id { get; set; }
    public string Email { get; set; }
    public SocialSecurityNumber Ssn { get; set; }
}
public class SubscriberFilter
{
    public Subscriber? Find(int id)
    {
        Console.Write("Finding subscriber with id: " + id);
        return new Subscriber();
    }
    public Subscriber? Find(string email)
    {
        Console.Write("Finding subscriber with email: " + email);
        return new Subscriber();
    }
    public Subscriber? Find(SocialSecurityNumber ssn)
    {
        Console.Write("Finding subscriber with SSN: " + ssn.Value);
        return new Subscriber();
    }
}
```

Kobay olarak kullandığımız **SubscriberFilter** isimli sınıf içerisinde **Find** isimli metodun görüldüğü üzere üç farklı versiyonu yer alıyor. Parametre sayıları aynı olsa da tipleri farklı olduğu için herhangibir derleme zamanı hatası da almayız. Üstelik **Finde** metodunu kullandığımız yerde diğer varyasyonları da kolayca görebiliriz.

![MethOverload_01.png](/assets/images/2026/MethOverload_01.png)

Gayet şık duruyor. Peki öyleyse neden bazı dillerde metot aşırı yükleme gibi bir özellik bulunmaz. Örneğin **Golang ([Şurada bir FAQ açıklaması vardır](https://go.dev/doc/faq#overloading))** ya da **Rust** bunu desteklemez. Bu konudaki söylemlerden birisi konunun **C++** diline dayanmasıdır. C++ method overloading' i destekler ancak derleyici **name mangling** olarak da bilinen bir taktik uygular ve metot adlarını değiştirir. Bunu derleyici çıktısı açısından verimsiz olduğu iddia edilir. Bir derleyici tasarımcısı olmadığı için söyleyecek sözüm yok ancak olayı bir **C++** kodu ile deneyebiliriz.

## C++ Tarafında Method Overloading ve Name Mangling

Tabii onlarca yıldır hayatımızda yer alan bir dil olduğu için bu konuda örnek bulmak oldukça kolay. Genellikle aşağıdakine benzer bir kod parçası ele alınıyor. Bunu **.cpp** uzantılı bir dosya olarak kaydedip araştırmamıza devam edelim.

```cpp
#include <iostream>

float add(float a, float b) {
    return a + b;
}

int add(int a, int b) {
    return a + b;
}

int main() {
    int result_1 = add(1, 2);
    float result_2 = add(3.14f, 3.14f);

    std::cout << "Total of 1 and 2: " << result_1 << std::endl;
    std::cout << "Total of 3.14 and 3.14: " << result_2 << std::endl;

    return 0;
}
```

**add** metodunun iki farklı versiyonu bulunuyor. Parametre sayıları aynı olmasına rağmen tipleri farklı. Program kodunu **exe** olarak derleyip binary içerisine alınan sembolleri inceleyebiliriz.

```bash
# Program kodunu derlemek için
g++ -o overloading .\overloading.cpp

# ve oluşan exe içerisindeki sembolleri *(symbols)* görmek için
nm overloading.exe
```

Kısa bir kod parçası olsa da uzun bir içerik üretildiğini söyleyebilirim ve uzun bir aramadan sonra **add** metodunun **_Z3addff** ve **_Z3addii** şeklinde isimlendirilmiş iki farklı tanımının olduğunu görebildim. Aynen aşağıda görüldüğü gibi :D

![MethOverload_03.png](/assets/images/2026/MethOverload_03.png)

Burada ilk kısım tahmin edeceğiniz ilgili sembolün bellek adresini ifade ediyor. Öğrendiğim kadarıyla **T** harfi global olarak erişilebilen fonksiyonları işaret etmekte. Dolayısıyla **C++** dilinde aşırı yüklenen metotlar gerçekten de bahsedildiği gibi derlenen binary içerisinde isimleri değiştirilmiş semboller olarak tutuluyorlar. Metot aşırı yükleme yeteneğini kullanmayan dillerin bir argümanı **name mangling** mevzusunun başka dillerle olan iletişim sırasında *(FFI - Foreign Function Interface)* sorun çıkarttığı görüşü. Öyleyse bu durumu bir ele almaya çalışalım.

## FFI Mevzusu

Farklı dillerin birbirlerini kullanabilmesini yollarından birisi **FFI**. Buna göre örneğin **C#** tarafında yazılmış bir kütüphaneyi **C++** tarafında kullanmamız mümkün *(ya da tam tersi)* Birçok dilin bu özelliği bulunuyor. **Rust** içinden **Python** fonksiyonu çağırabiliyorsak bu **FFI** standardı sayesinde mümkün. Ancak metotların aşırı yüklendiği senaryolar da bu ne kadar sorun çıkartabilir? Yazımızın girizgah kısmında yazdığımız **C#** kodunu bir kere daha masa yatırmak isterim. Ancak bu sefer üretilen ara dil koduna *(IL - Intermediate Languege)* odaklanalım. Aşağıdaki ekran görüntüsünde **ILSpy** eklentisi ile elde edilmiş **decompile** çıktısını görebilirsiniz.

![MethOverload_02.png](/assets/images/2026/MethOverload_02.png)

Dikkat edileceği üzere **C#** metot adlarını hiç bozmadan **IL** tarafına almıştır. **C++** tarafındaki **name mangling** semptomu burada görülmemektedir. Kafaları biraz daha karıştıralım öyleyse. **C#** ile yazdığımız ve **Native AOT-*(Ahead-of-Time)*** şeklinde derlediğimiz bir kütüphaneyi velev ki **C++** ile yazılmış bir kodda kullanmak istiyoruz *(İşte bunlar iş dünyasındaki uygulamalarda pek de yapmadığımız şeyler :D )*

Öncelikle bir **class library** projesi oluşturalım.

```bash
dotnet new classlib -n FinanceLib
```

Sonrasında proje dosyasının içeriğini aşağıdaki gibi değiştirelim.

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <PublishAot>true</PublishAot>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
  </PropertyGroup>
</Project>
```

Burada iki önemli ek var. **PublishAot** ve **AllowUnsafeBlocks** kısımları. Bu sayede publish edilecek olan kodun **Native AOT** olarak üretileceğini ve doğrudan **C++** tarafında kullanılabileceğini belirtiyoruz. Ek olarak **pointer** ve bellek işlemleri yapılma ihtimali olduğundan **AllowUnsafeBlocks** özelliğini de açıyoruz.

**PaymentFoundation** isimli kobay sınıf kodlarını aşağıdaki gibi düzenleyerek devam edelim.

```csharp
using System.Runtime.InteropServices;

namespace FinanceLib;

public class PaymentFoundation
{
    public static void ProcessPayment(decimal amount)
    {
        Console.WriteLine($"Processing payment of {amount:C}");
    }

    public static void ProcessPayment(int bonus)
    {
        Console.WriteLine($"Processing payment of {bonus} bonus points");
    }

    [UnmanagedCallersOnly(EntryPoint = "ProcessPayment")]
    public static void ExportProcessPayment(decimal amount) => ProcessPayment(amount);

    [UnmanagedCallersOnly(EntryPoint = "ProcessPayment")]
    public static void ExportProcessPayment(int bonus) => ProcessPayment(bonus);
}
```

Artık kütüphaneyi **publish** modunda çıkartabiliriz ki sorunu görebilmek adına bu gerekli. Ben **Windows 11** platformunda çalıştığım için kütüphaneyi aşağıdaki komutlarla önce derledim sonra da bir çıktı almaya çalıştım.

```bash
# Sorunsuz build
dotnet build 
# ama
dotnet publish -r win-x64 -c Release
```

![MethOverload_04.png](/assets/images/2026/MethOverload_04.png)

Haydaaaa! Program kodu başarılı şekilde derlense bile üretime çıkılan binary hatalı *(Benim makinede çalışıyor hocam :D)* E çok normal. Bu kütüphane **C++** tarafında kullanılacak ve orada metotlar aşırı yüklenirken aynı isimler kullanılsa bile derlenen sembollerde farklı isimlerin olması zorunlu. Bunu aslında size hatayı göstermek için ekledim. Normalda metotlarımızdaki **EntryPoint** değerlerinde farklı **EntryPoint** değerleri kullanmamız gerekir.

```csharp
[UnmanagedCallersOnly(EntryPoint = "ProcessPayment_WithAmount")]
public static void ExportProcessPayment(decimal amount) => ProcessPayment(amount);

[UnmanagedCallersOnly(EntryPoint = "ProcessPayment_WithBonus")]
public static void ExportProcessPayment(int bonus) => ProcessPayment(bonus);
```

Bu düzenleme sonrası kütüphanenin **C++** tarafında kullanılabilir doğal çıktısının başarılı şekilde oluştuğunu görebiliriz.

![MethOverload_05.png](/assets/images/2026/MethOverload_05.png)

## Buraya Kadar Getirdik Madem C++ Tarafından da Çağıralım

DEVAM EDECEK
