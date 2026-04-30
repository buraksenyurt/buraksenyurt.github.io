---
layout: post
title: "Method Overloading Üzerine Düşünceler"
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
Profesyonel olarak mesleki hayatımın neredeyse tamamında **C#** programlama dilini kullanarak geliştirme yaptım. Çoğunlukla bir arayüzün *(Web veya Windows)* bir iş sürecini tetiklediği ve bunun arkasında dönen yazılım yaşam döngüsünün bir parçası oldum. **C#**, **Java**, **Go**, **Python** vb. birçok dil bu tip geliştirmeleri hızlandıracak türlü yeteneğe ve kütüphane desteğine sahip. Bununla birlikte uzun zamandır farklı programlama dillerini de öğrenmeye çalışıyorum ve çok uzun zamandır kafamı kurcalayan şeyler var. Bir programlama dilini tam olarak öğrenmek ne demektir?

İş hayatının gereksinimleri düşünüldüğünde bir programlama dilinin, örneğin **C#**'ın tüm yeteneklerini kullanmıyoruz ve hatta yüzdesel olarak kimisini çok kimisini az ele alıyoruz. Bu yüzden farklı dillerdeki ilginç yaklaşımları görünce şaşırıyoruz *(Şahsen ben öyle hissediyorum)*. Örneğin, **OCaml** ile yazılmış bir ifadenin derlenirken matematiksel karşılığının ispatlanması, **Zig**'in **comptime** diye sadece derleme zamanında bilinen türleri desteklemesi, **Rust**'ın bellek yönetimindeki hassasiyeti vs. Arada ince bir çizgi var belki de. Bilgisayar bilimlerinin akademik yanı ile saha yazılımcısı olmanın arasındaki çizgi olabilir bu. İş hayatına yönelik süreç bazlı, belli bir ekonomiyi çevreleyen çözümlere baktığımızda **Java**, **C#**, **Go**, **Python** vb. dillerin epeyce öne çıktığını görüyoruz. Eğer bu alanlarda iş yapacaksak bu dillerin etkin kullanımını öğrenmek önemli ama en derin noktalarına kadar gerekli mi, tartışılır.

Diğer yandan bir programlama dilinin genetiğini anlamak, felsefesini kavramak, yeteneklerini sorgulamak denince iş epeyce değişiyor. Zira başka programlama dillerinden etkilenen dillerin genetik koduna işleyen birçok kalıtımsal özellik öğrenmeye değer. Bir diğer öğrenmeye değer konuysa birisinde olan bir özelliğin diğer dilde neden olmayışını araştırmak.

İşte bu karman çorman düşünceler arasında gelelim bugünkü konumuza; metotların aşırı yüklenmesi *(Method Overloading)*. Baştan söyleyeyim, bu yazıda "o dil bu dilden daha iyidir" gibi bir amacım yok; sadece merak ettiğim bir sorunun cevabını arayıp çıkarımlar elde etmeye çalışacağım.

## C# Bakış Açısından Method Overloading

**C#** dilini ilk öğrenmeye başladığımızda her dilde olduğu gibi bir **Hello World** uygulaması yazılır ve kuvvetle muhtemel **Console** sınıfının statik olarak çağırılabilen **WriteLine** metodu kullanılır. Sonralarında bu metodun aslında aynı isimle yirmi farklı sürümünün olduğu üzerinde de durulur ve bu kavram **Method Overloading** olarak adlandırılır.

![MethOverload_00.png](/assets/images/2026/MethOverload_00.png)

Gayet güzel bir özellik değil mi? Geliştirici olarak sadece **WriteLine** metodunu biliriz ve bu bilgi zihnimizde yer eder. Aşırı yüklenmiş diğer versiyonlar da aynı isimde olduğundan farklı parametrelerle çalışan hallerini bilmemize de gerek yoktur. Sezgisel olarak farklı veri türleri ile çalışabileceğini de biliriz. Bu yaklaşımın **Syntactic Sugar** olarak ifade edildiğine de rastlanır.

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

Kobay olarak kullandığımız **SubscriberFilter** isimli sınıf içerisinde **Find** isimli metodun görüldüğü üzere üç farklı versiyonu yer alıyor. Parametre sayıları aynı olsa da tipleri farklı olduğu için herhangi bir derleme zamanı hatası da almayız. Üstelik **Find** metodunu kullandığımız yerde diğer varyasyonları da kolayca görebiliriz.

![MethOverload_01.png](/assets/images/2026/MethOverload_01.png)

Gayet şık duruyor. Peki öyleyse neden bazı dillerde metot aşırı yükleme gibi bir özellik bulunmaz? Örneğin **Golang ([Şurada bir FAQ açıklaması vardır](https://go.dev/doc/faq#overloading))** ya da **Rust** bunu desteklemez. Bu konudaki söylemlerden biri konunun **C++** diline dayanmasıdır. **C++** method overloading'i destekler ancak derleyici **name mangling** olarak da bilinen bir taktik uygular ve metot adlarını değiştirir. Bunun derleyici çıktısı açısından verimsiz olduğu iddia edilir. Bir derleyici tasarımcısı olmadığım için söyleyecek sözüm yok ancak olayı bir **C++** kodu ile deneyebiliriz.

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

Burada ilk kısım tahmin edeceğiniz gibi ilgili sembolün bellek adresini ifade ediyor. Öğrendiğim kadarıyla **T** harfi global olarak erişilebilen fonksiyonları işaret etmekte. Dolayısıyla **C++** dilinde aşırı yüklenen metotlar gerçekten de bahsedildiği gibi derlenen binary içerisinde isimleri değiştirilmiş semboller olarak tutuluyorlar. Metot aşırı yükleme yeteneğini kullanmayan dillerin bir argümanı, **name mangling** mevzusunun başka dillerle olan iletişim sırasında *(FFI - Foreign Function Interface)* sorun çıkardığı görüşü. Öyleyse bu durumu ele almaya çalışalım.

## FFI Mevzusu

Farklı dillerin birbirlerini kullanabilmesinin yollarından biri **FFI**. Buna göre örneğin **C#** tarafında yazılmış bir kütüphaneyi **C++** tarafında kullanmamız mümkün *(ya da tam tersi)*. Birçok dilin bu özelliği bulunuyor. **Rust** içinden **Python** fonksiyonu çağırabiliyorsak bu, **FFI** standardı sayesinde mümkün. Ancak metotların aşırı yüklendiği senaryolarda bu ne kadar sorun çıkarabilir? Yazımızın girizgah kısmında yazdığımız **C#** kodunu bir kere daha masaya yatırmak isterim. Ancak bu sefer üretilen ara dil koduna *(IL - Intermediate Language)* odaklanalım. Aşağıdaki ekran görüntüsünde **ILSpy** eklentisi ile elde edilmiş **decompile edilmiş** çıktıyı görebilirsiniz.

![MethOverload_02.png](/assets/images/2026/MethOverload_02.png)

Dikkat edileceği üzere **C#** metot adlarını hiç bozmadan **IL** tarafına almıştır. **C++** tarafındaki **name mangling** semptomu burada görülmemektedir. Kafaları biraz daha karıştıralım öyleyse. **C#** ile yazdığımız ve **Native AOT** *(Ahead-of-Time)* şeklinde derlediğimiz bir kütüphaneyi velev ki **C++** ile yazılmış bir kodda kullanmak istiyoruz *(İşte bunlar iş dünyasındaki uygulamalarda pek de yapmadığımız şeyler :D)*

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
    public static void ExportProcessPayment(double amount) => ProcessPayment((decimal)amount);

    [UnmanagedCallersOnly(EntryPoint = "ProcessPayment")]
    public static void ExportProcessPayment(int bonus) => ProcessPayment(bonus);
}
```

Artık kütüphaneyi **publish** modunda yayınlayabiliriz ki sorunu görebilmek adına bu gerekli. Ben **Windows 11** platformunda çalıştığım için kütüphaneyi aşağıdaki komutlarla önce derledim, sonra da bir çıktı almaya çalıştım.

```bash
# Sorunsuz build
dotnet build 
# ama
dotnet publish -r win-x64 -c Release
```

![MethOverload_04.png](/assets/images/2026/MethOverload_04.png)

Haydaaaa! Program kodu başarılı şekilde derlense bile üretime çıkılan binary hatalı *(Benim makinemde çalışıyor hocam :D)*. E, çok normal. Bu kütüphane **C++** tarafında kullanılacak ve orada metotlar aşırı yüklenirken aynı isimler kullanılsa bile derlenen sembollerde farklı isimlerin olması zorunlu. Bunu aslında size hatayı göstermek için ekledim. Normalde metotlarımızda farklı **EntryPoint** değerleri kullanmamız gerekir.

```csharp
[UnmanagedCallersOnly(EntryPoint = "ProcessPayment_WithAmount")]
public static void ExportProcessPayment(double amount) => ProcessPayment((decimal)amount);

[UnmanagedCallersOnly(EntryPoint = "ProcessPayment_WithBonus")]
public static void ExportProcessPayment(int bonus) => ProcessPayment(bonus);
```

> C# tarafındaki decimal veri tipini C++ tarafına açılan ProcessPayment_WithAmount metodunda double olarak tanımladık zira veri uyuşmazlığı nedeniyle C++ tarafında hata alırdık.

Bu düzenleme sonrası kütüphanenin **C++** tarafında kullanılabilir doğal çıktısının başarılı şekilde oluştuğunu görebiliriz.

![MethOverload_05.png](/assets/images/2026/MethOverload_05.png)

## Buraya Kadar Getirdik Madem C++ Tarafından da Çağıralım

Son örnekteki kodun bir **C++** programı üzerinden nasıl çağrılacağını merak etmiş olabilirsiniz. Hemen yeri gelmişken bunu da örnekleyelim.

```cpp
#include <iostream>
#include <windows.h>

typedef void (*PaymentWithAmountFunc)(double);
typedef void (*PaymentWithBonusFunc)(int);

int main()
{
    HINSTANCE hInstLibrary = LoadLibrary(TEXT("FinanceLib.dll"));
    if (!hInstLibrary)
    {
        std::cout << "DLL could not be loaded!" << std::endl;
        return 1;
    }

    PaymentWithAmountFunc pwAmount = (PaymentWithAmountFunc)GetProcAddress(hInstLibrary, "ProcessPayment_WithAmount");
    PaymentWithBonusFunc pwBonus = (PaymentWithBonusFunc)GetProcAddress(hInstLibrary, "ProcessPayment_WithBonus");

    if (pwAmount && pwBonus)
    {
        std::cout << "Calling C# functions...\n";

        pwAmount(99.99);
        pwBonus(10);
    }
    else
    {
        std::cout << "Functions not found in DLL." << std::endl;
    }

    FreeLibrary(hInstLibrary);
    return 0;
}
```

Dosya başında gerekli kütüphane bildirimleri yapıldıktan sonra **C#** tarafındaki metotlar için gerekli tip tanımlamaları yapılıyor. Bu tanımlamalar ile ilgili fonksiyonların imzaları referans ediliyor diye düşünebiliriz. **LoadLibrary** metodu ile az önce publish edilmiş olan .NET kütüphanesini yüklüyoruz. Böylece **GetProcAddress** fonksiyonu üzerinden bu **binary** referansını vererek .NET fonksiyonlarının bellek adreslerine erişmemiz mümkün. Yani fonksiyon işaretçilerine ulaşmış oluyoruz. Dikkat ederseniz ikinci parametrede verilen isimler, **UnmanagedCallersOnly** niteliğinde kullandığımız **EntryPoint** isimleri. Programı aşağıdaki terminal komutları ile önce derleyip sonrasında çalıştıralım.

```bash
g++ -o ffi_sample .\ffi_sample.cpp

.\ffi_sample.exe
```

![MethOverload_06.png](/assets/images/2026/MethOverload_06.png)

Geldiğimiz nokta itibariyle metotların aşırı yüklenmesi sırasında dilin derleyicisinin **name mangling** gibi bir yaklaşımı varsa bu farklı dillerle yapılan entegrasyonlarda *(FFI türünden tabii ki)* soruna yol açabilir. Ancak buna rağmen geliştiricinin işini kolaylaştıran yazım stili ile metotların aşırı yüklenmesi güzel bir yetenek gibi durmakta. Ancak enteresan bir durum daha var. Gelin inceleyelim.

## HTTP Yönlendirmelerinde Method Overloading

Özellikle **C#** tarafında geliştirme yapan birçok arkadaşım öyle ya da böyle **Web API** projeleri yazmış veya kullanmıştır. İş süreçlerimizi **HTTP** standartlarında dış dünyaya açmak için sıklıkla tercih ettiğimiz bir yoldur. Şimdi bu olayı metotların aşırı yüklenebilme kabiliyeti açısından ele alalım. Yeni bir proje oluşturarak araştırmamıza devam edelim.

```bash
dotnet new webapi -n OverloadApi
```

Controllers isimli bir klasör açıp içerisine aşağıdaki sınıfı ekleyelim.

```csharp
using Microsoft.AspNetCore.Mvc;

namespace OverloadApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SubscriberController : ControllerBase
{
    [HttpGet("find")]
    public IActionResult Find([FromQuery] int id)
    {
        return Ok(new { Message = $"Finding subscriber with id: {id}" });
    }
}

public record SocialSecurityNumber(string Value)
{
    public bool IsValid()
    {
        return !string.IsNullOrEmpty(Value) && Value.Length == 11 && Value[3] == '-' && Value[6] == '-';
    }
}
```

Bu yazıdaki örnekleri deneyenler için program sınıfının içeriğini de paylaşmak isterim.

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
builder.Services.AddControllers();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
app.UseHttpsRedirection();
app.MapControllers();

await app.RunAsync();
```

Tamamen deneysel amaçlı bu projeyi çalıştırıp örneğin `https://localhost:7036/api/Subscriber/find?id=42` adresine *(sizde port numarası farklı olabilir)* bir **HTTP GET** talebi yaptığımızda **HTTP 200** cevabı almamız son derece doğaldır.

```bash
curl "https://localhost:7036/api/Subscriber/find?id=42"
```

![MethOverload_07.png](/assets/images/2026/MethOverload_07.png)

Peki ya metotların aşırı yüklenmesi ile buranın ne alakası var? **SubscriberController** sınıfının kodlarını aşağıdaki gibi değiştirelim.

```csharp
[ApiController]
[Route("api/[controller]")]
public class SubscriberController : ControllerBase
{
    [HttpGet("find")]
    public IActionResult Find([FromQuery] int id)
    {
        return Ok(new { Message = $"Finding subscriber with id: {id}" });
    }
    [HttpGet("find")]
    public IActionResult Find([FromQuery] string email)
    {
        return Ok(new { Message = $"Finding subscriber with email: {email}" });
    }
    [HttpGet("find")]
    public IActionResult Find([FromQuery] SocialSecurityNumber ssn)
    {
        return Ok(new { Message = $"Finding subscriber with SSN: {ssn.Value}" });
    }
}
```

**Find** metodunun aşırı yüklenmiş üç versiyonunu yazdık. Aslında **endpoint** üzerinden sunmak istediğimiz fonksiyonellik **find**. Bunu da **HttpGet** niteliğinde her üç metot için de aynı şekilde belirledik. Kod derlenecektir ancak az önce başarılı şekilde kullanabildiğimiz **curl** çağrısı bu sefer hata verecektir.

![MethOverload_08.png](/assets/images/2026/MethOverload_08.png)

Aslında çalışma zamanını beklemeye gerek yoktur. Visual Studio arabirimi **Action Route** ihlali ile ilgili bizi uyarır.

![MethOverload_09.png](/assets/images/2026/MethOverload_09.png)

Aslında **router** isimlendirmesinin benzersiz olmasının beklenmesi bana kalırsa son derece normal. Amaç, **endpoint** üzerinden sunulan bir fonksiyonelliğin parametre yapısına göre değil, ismine bakarak anlaşılabilmesini sağlamak olmalı. Zira **OpenAPI** standardı da metot imzalarını değil, **URL** yollarını anlayacak şekilde tasarlanmıştır. Yukarıdaki senaryoda çözüm olarak kullanabileceğim yollardan biri bu isimlendirmeleri farklılaştırmak olabilir.

```csharp
[HttpGet("find-by-email")]
public IActionResult Find([FromQuery] string email)
{
    return Ok(new { Message = $"Finding subscriber with email: {email}" });
}
[HttpGet("find-by-ssn")]
public IActionResult Find([FromQuery] SocialSecurityNumber ssn)
{
    return Ok(new { Message = $"Finding subscriber with SSN: {ssn.Value}" });
}
```

Metotların aşırı yüklenmesi yeteneğinin kullanan taraf açısından ergonomi sağladığı aşikar. Sadece tek bir metot yazarız ve örneğin IDE bizim için en doğru olanı bulur. Ayrıca bu tip metotları türeyen sınıflarda ezmek *(override)* mümkün olabilir. Böylece aşırı yüklenmiş metotları türetme mantığı ile genişletebiliriz belki de *(Bunu ben söyledim diye inanmayın, bir deneyin derim :D)*

Diğer yandan yukarıda analiz etmeye çalıştığım ve farklı yapıların kullanımı sırasında ortaya çıkan uyumsuzluk problemine ek olarak bir tipin metot bazında fazlaca şişmesi de istenmeyen bir durum olabilir... Olabilir mi acaba? Geliştiriciler **.NET** içerisine yirmi farklı versiyonu olan **WriteLine** metodunu koymuş mesela. İşte tam bu noktada **method overloading** kavramını reddeden dillerden biri olan **Rust** tarafından da olaya yaklaşalım derim.

## Method Overloading Sevmem Diyen Rust

Bu sefer senaryomuzu şöyle farklılaştıralım. İlk başta değindiğimiz **SubscriberFoundation** sınıfında **UniqueNickname** isimli yeni bir alan ile de arama seçeneği eklemek istediğimizi düşünelim. **Find** metodunun aşırı yüklenmiş yeni bir versiyonunu ekleyemeyeceğiz *(Elbette aynı metot içinde if else blokları, switch ifadeleri ile de çözülebilir ama konumuz metotların aşırı yüklenmesi)*

![MethOverload_10.png](/assets/images/2026/MethOverload_10.png)

Bu son derece doğal. Zira parametre sayısı ve tipi aynı olan iki metodun aynı isimde olması sadece derleyiciyi değil bizi de şaşırtır. Buradaki arama senaryosunu eğer **Rust** dilini kullanarak yazmak istesek, kuvvetle muhtemel tasarımı değiştirip şöyle ilerleriz.

```rust
fn main() {
    let _subscriber = SubscriberFoundation.find(SubscriberSearchType::Id(1195));
    let _subscriber = SubscriberFoundation.find(SubscriberSearchType::Email("bss@none".to_string()));
    let _subscriber =
        SubscriberFoundation.find(SubscriberSearchType::UniqueNickname(uuid::Uuid::new_v4()));
    let _subscriber = SubscriberFoundation.find(SubscriberSearchType::Ssn("123-45-6789".to_string()));
}

struct Subscriber {}

enum SubscriberSearchType {
    Id(i32),
    Email(String),
    UniqueNickname(uuid::Uuid),
    Ssn(String),
}

struct SubscriberFoundation;

impl SubscriberFoundation {
    fn find(&self, search_type: SubscriberSearchType) -> Option<Subscriber> {
        match search_type {
            SubscriberSearchType::Id(id) => {
                println!("search by id: {}", id);
                None
            }
            SubscriberSearchType::Email(email) => {
                println!("search by email: {}", email);
                None
            }
            SubscriberSearchType::UniqueNickname(unique_nick_name) => {
                println!("search by unique nick name: {}", unique_nick_name);

                None
            }
            SubscriberSearchType::Ssn(ssn) => {
                println!("search by ssn: {}", ssn);
                None
            }
        }
    }
}
```

> Örnekte Guid üretimi için uuid isimli bir crate kullanılıyor. Konumuzla çok alakası yok ama `cargo add uuid -F v4` ile projeye eklenebilir.

Eğer **Rust** gibi bir dil metotların aşırı yüklenmesi yeteneğini kullanmıyorsa mutlaka daha şık bir çözüme ve bakış açısına sahip olduğu içindir diye kişisel yorumumu yapmak isterim. Program kodunda dikkat edileceği üzere **C#** örneğinde aşırı yüklediğimiz metotlarda kullandığımız argümanlar bir **enum** veri yapısı içerisinde toplanmışlardır. İsimler anlamlı ve ne amaçla kullanıldığını ifade edecek türdendir. Tek bir **find** metodu söz konusudur ve parametre olarak gelen arama kriteri bir **enum** olduğundan olası tüm değerlerinin ele alınması zorunludur. Bu sayede derleyici güvenliği de sağlanır. Örneğin yeni bir arama kriteri eklendiğinde **find** metodundaki **pattern match** ifadesinde bu durum ele alınmazsa kod derlenmeyecektir. Diğer yandan aynı veri türü ile arama da eklenebilmiştir. Zira **String** türü **Email** ve **UniqueNickname** varyantlarınca sarmalanmaktadır.

Tüm bunlar ışığında belki de şöyle bir yorum yapabiliriz: Söz konusu senaryoda **Rust** eylem yerine veriye odaklanmaktadır. Zira varyasyonları fonksiyonlarda değil, **enum** olarak eklenmiş veri modelinde barındırıyor. Buna göre **find** metodu sadece sorguyu işleten bir yardımcı.

Elbette birtakım eksiler de yok değil. Söz gelimi bazı metot çağrılarının parametre yapısı çok uzun olabilir. **Find(1195)** şeklinde bir çağrı yapabilecekken **find(SubscriberSearchType::Id(1195))** şeklinde uzun bir kullanım söz konusudur. Okunurluk açısından sıkıntı olabilir. Tabii bir diğer ve önemli dezavantaj da benim gibi yıllarını nesne yönelimli dillerde geçirmiş insanlar için geçerlidir. Bizim için metotları aşırı yüklemek yerine, argümanları birer veri olarak düşünüp önce **enum** tasarlamak kavramsal olarak da ters gelebilir. En azından benim için başlarda böyle olmuştu.

## Bir de Zig Diyelim

**Zig** programlama dili de metotların aşırı yüklenmesine izin vermez. Bu dil gizli kontrol akışlarına, gizli bellek tahsislerine veya derleyicinin bizim yerimize karar verdiği durumlara tamamen karşıdır. Her şeyin açık bir şekilde tariflenmesi gerektiğine inanır. Bu yüzden **C** programlama dilinin daha güvenli ve modern bir varyantı olarak da lanse edilmektedir. Buna göre fonksiyon adlarını ya açıkça yazmamız gerekir ya da... Şimdi burada durup aşağıdaki kod parçasını ele alalım derim.

```zig
const std = @import("std");

const Subscriber = struct {};

const Id = struct { value: i32 };
const Email = struct { value: []const u8 };
const Ssn = struct { value: []const u8 };
const Uuid = struct { value: []const u8 };

const SubscriberFoundation = struct {
    pub fn find(self: *const SubscriberFoundation, search_param: anytype) ?Subscriber {
        _ = self;

        switch (comptime @TypeOf(search_param)) {
            Id => {
                std.debug.print("search by id: {d}\n", .{search_param.value});
            },
            Email => {
                std.debug.print("search by email: {s}\n", .{search_param.value});
            },
            Ssn => {
                std.debug.print("search by ssn: {s}\n", .{search_param.value});
            },
            Uuid => {
                std.debug.print("search by unique nick name: {s}\n", .{search_param.value});
            },
            else => {
                @compileError("Unsupported search type for Subscriber");
            },
        }

        return null;
    }
};

pub fn main() void {
    const foundation = SubscriberFoundation{};

    _ = foundation.find(Id{ .value = 1195 });
    _ = foundation.find(Email{ .value = "bss@none" });
    _ = foundation.find(Uuid{ .value = "550e8400-e29b-41d4-a716-446655440000" });
    _ = foundation.find(Ssn{ .value = "123-45-6789" });

    // Aşağıdaki şekilde kullanamayız. Tipin belli olması gerekir.
    // _ = foundation.find(1195);
}
```

Önce kodu anlatmaya çalışayım :D **Rust** ile yazdığımız kurguya benzer görünüyor ama burada bir enum veri yapısı yok tabii ki. Yine de farklı arama seçeneklerini değişmez veri yapıları *(const struct)* olarak tanımlıyoruz. Aslında odaklanmamız gereken nokta yine **find** isimli fonksiyonun ikinci parametresi olan ve **anytype** türünden tanımlanmış **search_param**. Bunun **switch** bloğu içerisindeki kullanımına dikkat edersek **comptime** isimli bir anahtar kelime görüyoruz. **Zig** programlama dilinin en güçlü özelliklerinden biri **comptime** türevleri. **const** ve **var** ile tanımlı her enstrümana adapte edilebiliyor. Özelliği ise şu; bu türler sadece derleme aşamasında kullanılır, çalışma zamanına aktarılmazlar ve dolayısıyla bellek tahsisleri söz konusu olmaz. Yani çalışma zamanı için sıfır maliyet anlamına gelen bir kullanım şeklidir. Kodlar makine koduna dönüştüğünde büyük ihtimalle her tip için spesifik bir fonksiyon üretilir *(Monomorphization)*. Bu açıdan gayet **idiomatic** yazdığımız **Rust** koduna göre avantaj da sağlar. Zira **Rust** enum türleri için bellekte etiket tutar. Yani verinin **Id** mi yoksa **Email** mi olduğunu çalışma zamanında anlamak için fazladan bayt tutar.

Lakin senaryoda rol oynayan **anytype** avantajlı ama tehlikeli bir enstrümandır. Yani koda şöyle uzaktan bir bakarsak tam olarak ne olduğunu anlayamayabiliriz. **search_param: anytype** kullanımında `search_param`'ın alabileceği değerler kod içerisindeki **switch** bloğundan yakalanabilir *(Hoş bu durum **Rust** tarafı için de geçerli :D)*. Bununla birlikte **Zig** kodu derlendiğinde her bir **const** için ayrı ayrı makine kodu fonksiyonları oluşturacaktır. Bu da **Rust** tarafındaki **enum** ve **pattern match** yaklaşımını düşündüğümüzde dezavantajdır. Zig kodunu aşağıdaki gibi doğrudan çalıştırabiliriz.

```bash
# Doğrudan çalıştırmak için
zig run .\app.zig
```

Ancak biz şöyle ilerleyelim. Kodu derleyelim ve sonra üretilen binary içeriğini bir dosyaya çıkıp inceleyelim.

```bash
# Kodu derleyelim
zig build-exe .\app.zig

# Assembly çıktısını app.s isimli bir dosyaya yazar
zig build-exe .\app.zig -femit-asm
```

Bu dosya tabii oldukça büyük olacak. Satır satır okuyun... Şaka şaka :D **find** fonksiyonlarını bulmaya çalışacağız. Bunun için **main:** ifadesini aratabiliriz. Bu bizi **main** fonksiyonu için üretilen **assembly** kodlarına götürür. Kendi sistemimde aşağıdaki içerikle karşılaştım.

![MethOverload_11.png](/assets/images/2026/MethOverload_11.png)

Tahmin edileceği üzere sarı kutular içerisine alınmış dört çağrı *(call)*; **id**, **email**, **uniqueNickname** ve **ssn** kullanımlarına ait. Örneğin **find_anon_26103** çağrımını aratırsak ilgili fonksiyonun iç yapısına da ulaşabiliriz. **Assembly** bilgim o kadar iyi seviyede olmasa da bu benim için bir ispat niteliğinde. **C++** üretimlerinde derleyicinin aşırı yüklediği metotları nispeten daha anlamlı isimlendirdiğine de şahit olmuştuk. Bu durum, **Zig**'in isimlendirmeden ziyade performans odaklı olarak bellek yerleşimine odaklanıyor olmasından da kaynaklanabilir. Nereden nereye geldik değil mi?

Yazının şu an için geldiğim bu noktasında dillerin aşırı yüklenmiş metotları destekleme ve desteklememe konusunda kendimce biraz fikir sahibi oldum diyebilirim. Benim için yorucu olan bu araştırmayı burada noktalarken ortaya başka bir soru bırakıp kaçmayı tercih edeceğim; **Rust** tarafından desteklenmeyen **variadic arguments** kabiliyeti **C#** dilinde mevcuttur *(params kullanımı)*. Peki ya **Rust** tarafında bu işlevsellik nasıl sağlanır?

Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[Çalışmada ele aldığımız örnek kodlara GitHub reposundan ulaşabilirsiniz](https://github.com/buraksenyurt/friday-night-programmer/tree/main/src/MethodOverloading)
