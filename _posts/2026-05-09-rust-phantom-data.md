---
layout: post
title: "Rust Dilinde Phantom Type Kullanımı: PhantomData"
date: 2026-05-09 09:00:00
tags:
    - rust
    - programming
    - phantomdata
    - zero-sized-types
    - type-safety
categories:
    - Programlama Dilleri
---
Bazı durumlarda bir tipe ekstra bilgiler dahil ederken bu bilgilerin çalışma zamanında *(runtime)* gerçekten de saklanmasını istemeyiz. Kulağa garip gelen bir cümle olduğunun farkındayım. Bir örnek üzerinden ilerlersek daha anlaşılır olacaktır ama öncesinde temel bilgileri ele alalım. **Rust** programlama dilinde `PhantomData<T>` şeklinde generic bir yapı bulunuyor. **PhantomData** yapısı ile tanımlanan bir veri çalışma zamanında saklanmaz ama derleyici bu türün kullanıldığını bilir ve buna bağlı olarak **ownership**, **borrowing**, **lifetimes** gibi kuralları işletebilir. Zaten bu türe **phantom** yani "hayalet" denmesinin bir sebebi de budur; çalışma zamanında var olmayan ama derleyici tarafından bilinen bir tür olarak ifade edilebilir.

**PhantomData** türünün en büyük avantajı boyutunun sıfır olmasıdır. Dolayısıyla çalışma zamanında **T** türü için herhangi bir bellek tahsisi yapılmaz ve performans açısından herhangi bir ek yük oluşmaz. Bu elbette akıllara `O zaman, ne gibi senaryolarda ve hangi amaçlarla kullanırız?` sorusunu getirir. Temel olarak derleme zamanında bazı doğrulamaların garanti altına alınmasının istendiği senaryoları örnek gösterebiliriz.

## Zero-Sized Types (ZST) Durumu

Devam etmeden önce **Zero-Sized Types *(ZST)*** kavramına bir açıklık getirelim. Gerçekten de hiçbir öğe içermeyen bir veri yapısı sıfır boyutlu olarak kabul edilebilir mi? Bunun için aşağıdaki kod parçasını göz önüne alabiliriz.

```rust
struct SomeData;

fn main() {
    let _data = SomeData;
    println!("Size of SomeData: {}", std::mem::size_of_val(&_data));
}
```

Bu örnekte SomeData isimli bir **Empty Struct** tanımı yapılmıştır. Program çalıştırıldığında **SomeData** yapısının boyutunun sıfır olduğunu görürüz.

![PhantomData00.png](/assets/images/2026/PhantomData00.png)

Çünkü bu yapı herhangi bir veri içermez. Rust derleyicisi bu tür yapılar için bellek tahsisi yapmaz ve bu nedenle boyutları sıfır olarak kabul edilir. İşte **PhantomData** da benzer şekilde çalışma zamanında veri içermeyen ancak derleyici tarafından tür bilgisi olarak kullanılan bir yapıdır.

## Hello PhantomData

Şimdi çok basit bir örnekle devam edelim. Çeşitli kategorileri ifade eden bir `Identity` yapısı oluşturmak istediğimizi düşünelim. Bu veri türünde kategorileri bir **PhantomData** ile ifade edebiliriz.

```rust
struct FirstPersonShooter;
struct RealTimeStrategy;
struct RolePlayingGame;

struct Identity<T> {
    value: u64,
    marker: PhantomData<T>,
}

fn main() {
    let _data = SomeData;
    println!("Size of SomeData: {}", std::mem::size_of_val(&_data));

    let fps_id = Identity::<FirstPersonShooter> {
        value: 1001,
        marker: PhantomData,
    };

    let rts_id = Identity::<RealTimeStrategy> {
        value: 1002,
        marker: PhantomData,
    };

    let rpg_id = Identity::<RolePlayingGame> {
        value: 1003,
        marker: PhantomData,
    };

    let number = 42u64;
    println!(
        "Number(u64): {} and the size of number is {}",
        number,
        std::mem::size_of_val(&number)
    );

    println!(
        "FPS ID: {} and the size of struct is {}",
        fps_id.value,
        std::mem::size_of_val(&fps_id)
    );
    println!(
        "RTS ID: {} and the size of struct is {}",
        rts_id.value,
        std::mem::size_of_val(&rts_id)
    );
    println!(
        "RPG ID: {} and the size of struct is {}",
        rpg_id.value,
        std::mem::size_of_val(&rpg_id)
    );
}
```

Generic **T** türüyle tanımlı **Identity** veri yapısı, **PhantomData** ile tür bilgisini tutar. Örnekte oyun kategorilerini ifade eden birkaç struct tanımı da vardır. Bir **Identity** nesnesi tanımlanırken kullanılan struct bilgileri çalışma zamanında saklanmaz. Aşağıdaki çalışma zamanı görüntüsünden de anlaşılacağı üzere **Identity** yapısının boyutu sadece **u64** türündeki **value** alanının boyutu kadardır. Bu, bir nevi **PhantomData** için çalışma zamanında yer tahsisi yapılmadığının ispatıdır.

![PhantomData01.png](/assets/images/2026/PhantomData01.png)

Bazen **PhantomData** kullanımı ile **trait** kullanımı birbirine karıştırılabilir. `trait`'lerde çeşitli türden nesnelerle çalışacak şekilde soyutlamalar *(abstractions)* yapabilir ve fonksiyonlar yazabiliriz. Ancak `trait`'ler çalışma zamanında da rol oynayabilir ve **dynamic dispatch** gibi mekanizmaların getirdiği performans maliyetleri bulunur. Eğer `trait`'lerle çalışırken türlerin karışması gibi bir durumun önüne geçmek istiyorsak ve bu tür bilgisi çalışma zamanında kullanılmayacaksa **PhantomData** kullanmayı düşünebiliriz. Kısacası, derleme zamanında **type-safe** bir yaklaşım sağlarken runtime'a taşımamıza gerek olmayan tür bilgileri için **PhantomData** kullanışlıdır. `Ne zaman trait, ne zaman PhantomData?` sorusu ile ilgili güzel bir cümleyi olduğu gibi paylaşmak isterim:

> Trait'ler **What you can do with a type** sorusuna cevap verirken, PhantomData **What kind of thing it is** sorusuna cevap verir.

Özetle **PhantomData** türü ile ilgili aşağıdaki noktaları vurgulayabiliriz;

- Çalışma zamanı verilerini doğrulamazlar.
- Sadece derleme zamanında tür seviyesinde kuralların uygulanmasını sağlarlar.
- Boyutları sıfırdır, dolayısıyla çalışma zamanında herhangi bir bellek tahsisi yapılmaz.
- Örneğe göre söz gelimi "Button" ifadesinin gerçekten bir Button türü olduğunu kontrol etmezler. Sadece derleyiciye bu türün kullanıldığını bildirirler.

## PhantomData ile Tür Güvenliği Sağlama

**PhantomData** kullanımını biraz daha pekiştirmek için farklı bir örnekle devam edelim. Bu örnekte farklı platformlara render edilebilecek birtakım UI bileşenlerini ele alıyoruz. Bir `Component`'in türü **PhantomData** ile belirtilirken derleme zamanında tür güvenliği sağlanıyor ve yanlış türde bileşenlerin kullanılmasının önüne geçiliyor. Çalışma zamanında ise bu tür bilgisi saklanmıyor.

```rust
use std::marker::PhantomData;

fn main() {
    let post_button = create_button("Submit");
    let name_label = create_label("Name:");
    let input_field = create_text_field("Enter your name");
    let desktop_button = create_button_linux("Click Me");

    println!(
        "Created a '{}' with content: '{}'",
        post_button.get_type(),
        post_button.content
    );
    println!(
        "Created a '{}' with content: '{}'",
        name_label.get_type(),
        name_label.content
    );
    println!(
        "Created a '{}' with content: '{}'",
        input_field.get_type(),
        input_field.content
    );
    println!(
        "Created a '{}' with content: '{}'",
        desktop_button.get_type(),
        desktop_button.content
    );

    /*
    Aşağıdaki kullanım, derleme zamanında aşağıdaki gibi bir hatanın üretilmesine sebep olur.

    error[E0308]: mismatched types
    --> src\main.rs:38:19
    |
    38 |     render_button(&input_field);
    |     ------------- ^^^^^^^^^^^^ expected `&Component<Html>`, found `&Component<MobileIos>`
    |     |
    |     arguments to this function are incorrect
    |
    = note: expected reference `&Component<Html>`
                found reference `&Component<MobileIos>`
    */
    // render_button(&input_field);

    render_button(&post_button); // Geçerli Kullanım
}

fn render_button(button: &Component<Html>) {
    println!(
        "Rendering a button into HTML for content: {}",
        button.content
    );
}

struct Html;
struct LinuxDesktop;
struct MobileIos;

struct Component<Render> {
    content: String,
    marker: PhantomData<Render>,
}

impl Component<Html> {
    fn get_type(&self) -> &str {
        "HTML Component"
    }
}

impl Component<LinuxDesktop> {
    fn get_type(&self) -> &str {
        "Linux Desktop Component"
    }
}

impl Component<MobileIos> {
    fn get_type(&self) -> &str {
        "Mobile iOS Component"
    }
}

/*
    Aşağıdaki fonksiyonlar farklı render tipleri için Component örnekleri oluşturuyor.
    PhantomData'yı bileşenin türünü belirtmek için kullanıyoruz ancak bu tür bilgisi çalışma zamanında kullanılmıyor.
    Sıfır maliyet. vtable ve dynamic dispatch kullanılmıyor. Component türü tamamen derleme zamanı için bir takı(tag) olarak işlev görüyor.
*/
fn create_button(content: &str) -> Component<Html> {
    Component {
        content: content.to_string(),
        marker: PhantomData,
    }
}

fn create_button_linux(content: &str) -> Component<LinuxDesktop> {
    Component {
        content: content.to_string(),
        marker: PhantomData,
    }
}

fn create_label(content: &str) -> Component<LinuxDesktop> {
    Component {
        content: content.to_string(),
        marker: PhantomData,
    }
}

fn create_text_field(content: &str) -> Component<MobileIos> {
    Component {
        content: content.to_string(),
        marker: PhantomData,
    }
}
```

Bu örnekte kullanılan `Component<Render>` veri yapısı farklı ortamlara render edilebilecek bileşenleri temsil ediyor. Örneğin **HTML** olarak render edilecek bir **Button** veya **Linux** masaüstü için bir **Label** kontrolü gibi. `PhantomData<Render>` kullanarak bir bileşenin hangi ortam için olduğunu derleme zamanında belirtiyoruz. Ancak bu tür bilgisi çalışma zamanında saklanmıyor.

Örneğin kodun sonlarına doğru yer alan ve yazıda yorum satırı haline getirilmiş aşağıdaki kısmı açtığımızı düşünelim.

```rust
render_button(&input_field);
```

ve uygulamayı **build** edelim. Derleyici bize aşağıdaki gibi bir hata verecektir.

![PhantomData02.png](/assets/images/2026/PhantomData02.png)

Eğer bu tip ihlalleri yapmazsak örnek kod başarılı bir şekilde çalışacaktır. İspatını da koyalım :D

![PhantomData03.png](/assets/images/2026/PhantomData03.png)

## Unsafe Kodlar ve Drop Check

Rust programlama diline başlayan birçok kişi için **PhantomData** türü kafa karıştırıcıdır ancak doğru kullanıldığında, derleme zamanında tür güvenliği sağlamak ve çalışma zamanında gereksiz bellek tahsisinden kaçınmak için güçlü bir araçtır. Örneğin **unsafe** kod alanlarında, özellikle generic veri yapıları ve tür seviyesinde doğrulama gereken senaryolarda **PhantomData** kullanımı tercih edilebilir.

Konuyu biraz daha detaylandıralım. `*const T`, `*mut T` gibi saf işaretçiler *(raw pointers)* sahiplik *(ownership)* bilgisi taşımazlar. Söz gelimi **Box**, **Vec** ya da **Rc** gibi bellek yönetimini kendi üstlenen veri yapıları inşa ederken biraz da mecburen **raw pointer** kullanırız. Ancak bu durumda derleyici **T** türündeki nesnelerin ne zaman **drop** edileceğini bilemez. Kendi drop mekanizmamızı ekleyebiliriz elbette fakat bu sefer de veriyi silmeye çalıştığımızda, söz konusu veri başka yerlere referanslar içeriyorsa, derleyicinin lifetime kurallarının atlanmasına neden olabiliriz ki bu da **dangling pointer** durumu oluşturabilir ve bildiğiniz üzere ciddi bir güvenlik açığıdır. İşte tam bu noktada tasarımın içine `PhantomData<T>` ekleyerek derleyiciye *"Bu yapı T türüne sahiptir ve drop işlemi gerçekleştiğinde içindeki T türü de drop edilmelidir"* garantisini verebiliriz. Bu sayede derleyici, drop check mekanizmasını doğru şekilde uygulayabilir ve bellek güvenliği sağlanır. Aşağıdaki örnek kod parçasında bu durum basitçe ele alınıyor.

```rust
use std::marker::PhantomData;

pub fn run() {
    let some_box = SomeBox::new(String::from("Phantom of the Opera"));
    println!("Created SomeBox with value: '{}'", unsafe { &*some_box.p });
}

struct SomeBox<T> {
    p: *mut T, // bellekteki veriyi işaret eden saf işaretçi (sahiplik yok)
    /*
    PhantomData<T> burada SomeBox<T> tipinin T tipine sahip olduğunu belirtmek için kullanılır.
    Bu, Rust'ın sahiplik ve yaşam süresi kurallarını doğru bir şekilde uygulamasına yardımcı olur.
    Yani drop check mekanizması, SomeBox<T> türünün T türüne sahip olduğunu bilir ve
    bu türün yaşam süresi boyunca SomeBox<T> türünün de geçerli olduğunu varsayar.
     */
    _marker: PhantomData<T>,
}

impl<T> SomeBox<T> {
    fn new(value: T) -> Self {
        let ptr = Box::into_raw(Box::new(value)); // Box'u saf işaretçiye dönüştürüyoruz
        SomeBox {
            p: ptr,
            _marker: PhantomData, // Çalışma zamanında 0 byte yer kaplar ki bunu biliyoruz artık
        }
    }
}

impl<T> Drop for SomeBox<T> {
    fn drop(&mut self) {
        // raw pointer kullandığımız için veriyi geri okuma işlemi güvenli değildir
        // Dolayısıyla bir unsafe bloğu içinde raw pointer'ı geri alarak belleği serbest bırakmamız gerekir
        unsafe {
            let _ = Box::from_raw(self.p);
        }
        println!("SomeBox dropped and memory freed.");
    }
}
```

Bu örnek kod parçasında `SomeBox<T>` isimli bir veri yapısının kullanıldığını görüyoruz. `SomeBox` yapısı içinde `*mut T` türünde bir saf işaretçi bulunuyor ve bu işaretçi `T` türündeki veriyi işaret etmekte. Drop işlemini garanti altına almak için `PhantomData<T>` kullanarak derleyiciye `SomeBox<T>` türünün `T` türüne sahip olduğunu ve drop işlemi gerçekleştiğinde içindeki `T` türünün de drop edilmesi gerektiğini bildiriyoruz. Örnek başarılı şekilde derlenecek ve çalışacaktır.

![PhantomData04.png](/assets/images/2026/PhantomData04.png)

## PhantomData Kalıpları

**PhantomData** kullanımı aslında bir kalıp olarak da düşünülebilir. Zira generic parametrenin birçok versiyonu vardır. Hal böyle olunca işin içine covariant, invariant, contravariant gibi kavramlar girer. Bu üçlü esasında alt tiplerle olan ilişkiyi tarif eder. **Covariant**, kısa yaşam ömürlü bir `T` yerine uzun ömürlü bir `T`'nin kullanılmasına izin verir. Örneğin `&'a str` yerine `&'static str` kullanılabilir. **Contravariant** ise ilişkinin tersine döndüğü durumdur. Son olarak **Invariant**, `T`'nin yaşam ömrünün aynı şekilde kullanılması gerektiğini belirtir. Yani alt tipin de aynı **lifetime** bilgisine sahip olması gerekir. Bu konuda [şu adreste](https://doc.rust-lang.org/nomicon/phantom-data.html#table-of-phantomdata-patterns) detaylı bilgiler yer alıyor ama ben, özet tablonun kendimce anladığım halini de buraya bırakıyorum.

| **Kalıp** | **Anlamı** |
| --------------------------- | ---------------------------------------------------------------------------------- |
| `PhantomData<T>` | T'nin sahibiymişim gibi davran. |
| `PhantomData<&'a T>` | 'a boyunca geçerli bir T referansına bağlıyım. |
| `PhantomData<&'a mut T>` | 'a boyunca mutable bir T erişimine bağlıyım. |
| `PhantomData<*const T>` | T'ye raw const pointer gibi bağlıyım ama sahip değilim. |
| `PhantomData<*mut T>` | T'ye raw mutable pointer gibi bağlıyım ve sahip değilim ama invariant davranabilirsin. |
| `PhantomData<fn(T)>` | T function input pozisyonunda olduğundan contravariant davran. |
| `PhantomData<fn() -> T>` | T function output pozisyonunda olduğundan covariant davran. |
| `PhantomData<fn(T) -> T>` | T hem input hem output pozisyonunda olduğundan invariant davran. |
| `PhantomData<Cell<&'a ()>>` | Interior mutability gibi davran ve invariant lifetime etkisi oluştur. |

Rust'ın bazı kuralları gerçekten çok zorlayıcı, itiraf ediyorum :D Bu tabloyu ezberlememek lazım ama referans olarak bir yerlerde durması iyi olabilir. Asıl mesele, **PhantomData**'nın hangi senaryolarda gerçekten önem arz ettiğinin farkına varmaktır. Eğer **raw pointer** içeren bir container, iterator, buffer veya **Foreign Function Interface *(FFI)*** sarmalayıcı gibi bir yapı inşa ediyorsak **PhantomData** kullanarak derleyiciye, "bu tip neye sahip, neyi ödünç alır, ne kadar yaşar, thread-safe midir?" gibi bilgileri vermek mümkün hale gelir. Bu da tahmin edileceği üzere güvende kalmak ve hataları önlemek açısından önemlidir. Bu kullanımları aslında rust'ın kendi kütüphanelerinde de sıklıkla görürüz. Örneğin iterator'lar da bu kullanıma rastlamak mümkün. *([Detaylar için kaynak koda bakın](https://doc.rust-lang.org/src/core/slice/iter.rs.html))*

![PhantomData05.png](/assets/images/2026/PhantomData05.png)

Bunu şöyle yorumlayabiliriz; **Iter** aslında `&'a T` saklamaz, **raw pointer** saklar ve kod derleyiciye "Bu yapı, 'a boyunca yaşayan T referansları üretir" demesi gerekir. İşte bunun için `PhantomData<&'a T>` kullanılır. Böylece derleyici, `Iter`'in `T` türüne sahip olduğunu ve `'a` boyunca geçerli olduğunu bilir. Benzer örgüleri birçok yerde görebilirsiniz. Görünce şaşırmayın, bir sebepleri var :D Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[Örnek kodlara github üzerinden ulaşmak için tıklayınız.](https://github.com/buraksenyurt/friday-night-programmer/tree/main/src/what-is-phantom-data)

[Orijinal Kaynak](https://www.buraksenyurt.com/post/rust-dilinde-phantom-type-kullanimi-phantomdata)
