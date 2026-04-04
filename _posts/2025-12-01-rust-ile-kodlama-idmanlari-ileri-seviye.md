---
layout: post
title: "Rust ile Kodlama İdmanları - İleri Seviye"
date: 2025-12-01 19:51:00
categories:
  - Programlama Dilleri
tags:
  - rust
  - rust-lang
---
Rust programlama dili ile ilgili maceralarımıza devam ediyoruz. Gerçi geçtiğimiz günlerde sizin de bildiğiniz üzere unwrap metodunun hatalı bir kullanımı sebebiyle internet sitelerinin %20sini koruyan [Cloudfare](https://www.cloudflare.com/) çöktü ve birçok hizmet uzun süre kullanılamaz hale geldi. Konuyla ilgili detaylı bilgilere[şu adreste](https://blog.cloudflare.com/18-november-2025-outage/)ki yazıdan ulaşabilirsiniz. Ferris şaşkın, ferris üzgün!

![15_mini.png](/assets/images/2025/15_mini.png)

Şunu kabul etmek lazım ki C, C++ gibi diller gerçekten dikkat isteyen, kaotik sorunlara yol açabilen, programıcısının yüksek yetkinlikte olmasını gerektiren programlama dilleri. En azından ben bu şekilde düşünüyorum. Rust'ın kendi bellek yönetim felsefesi bu sebeple en çok öne çıkan ve rağbet gören özellikleri arasında. Lakin dil ne kadar becerikli de olsa biz programcılar zaman zaman kötü hatalara sebebiyet veriyoruz.

Unwrap fonksiyonu genellikle yazılımı geliştirme aşamasında, testleri kolaylaştırmak amacıyla tercih edilen bir metot. Result değerini match ifadeleri ile sürekli kontrol ederek vakit kaybetmek yerine, zaten bir değer döndüreceğinden emin olduğumuz çağrılarda doğrudan değeri alıp kod işletmeye devam ediyoruz. Ama işte bu kod parçası üretime çıktığında olaslığının %0.00001 olduğu ihtimalin gerçekleşmesi mümkün. Bu yakın zaman trajedisini şimdilik kenara park edelim ve ileri seviye konularımıza başlayalım.

## Unsafe Kodları Soyutlamalar ile Sarmak

Derleyicinin bellek güvenliğini garantiye alamadığı durumlar için unsafe kod blokları kullanılır. Ancak unsafe kodların doğrudan kullanımı, bellek güvenliği sorunlarına da yol açabilir. Bu nedenle unsafe kodları güvenli soyutlamalar (safe abstractions) ile sarmak ideal yaklaşımlardan birisidir.

Örneğin bir sayı dizisini referans olarak kullanırken ödünç alma kurallarını atlayarak herhangi bir noktasından ikiye bölmek istediğimizi düşünelim. 101 elemanlı bir sayı dizisini 16ncı indisinden itibaren iki ayrı parça halinde değiştirilebilir referans olarak ele almak istiyoruz. Normalde rust aynı anda aynı veriye iki farklı değiştirilebilir referans vermeye izin vermez. Lakin unsafe çağrılabileceğini bildiğimiz bir fonksiyona göz yumup bu kuralı atlayarak geliştirme yapabiliriz. İşte burada unsafe kodu güvenli bir soyutlama ile sarmak önemlidir. Aşağıdaki kod parçasında bu durum basitçe ele alınmakta.

```rust
use std::slice;

fn main() {
    let mut numbers = vec![1, 4, 6, 1, 6, 2, 4, 6, 7, 9, 123, 7, 1, 7];

    // numbers dizisi 3. indexten ikiye bölünüyor
    let (left_slice, right_slice) = split_array_from(&mut numbers, 3);

    println!("Left slice values: {:?}", left_slice);
    println!("Right slice values: {:?}", right_slice);

    // left_slice dilimindeki ilk elemanı değiştiriyoruz
    // bu değişiklik orijinal numbers dizisini de etkileyecektir
    left_slice[0] = 345;
    println!("After changed the left slice: {:?}", numbers);
}

/// Bu fonksiyon, verilen `values` dilimini `index` konumunda ikiye böler
/// ve iki ayrı dilim olarak döner.
///
/// # Güvenlik Notu
///
/// Bu fonksiyon unsafe kod kullanır, bu nedenle dikkatli olunmalıdır.
///
/// # Parametreler
///
/// - `values`: Bölünecek olan tamsayı dilimi.
/// - `index`: Bölme işleminin gerçekleşeceği konum.
///
/// # Dönüş Değeri
/// İki ayrı tamsayı dilimi olarak döner.
fn split_array_from(values: &mut [i32], index: usize) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    // ptr değişkeni, values diliminin başlangıç adresini tutan bir işaretçidir(pointer).
    let ptr = values.as_mut_ptr();

    /*
        from_raw_parts_mut fonksiyonu unsafe türdendir ve bu nedenle
        unsafe kod bloğu içerisinde çalıştırılması gerekir.
    */
    unsafe {
        // ptr ile tutulan adresten başlayarak index uzunluğunda bir dilim oluşturur.
        let left = slice::from_raw_parts_mut(ptr, index);
        // index noktasından başlayarak len - index uzunluğunda bir dilim oluşturur.
        let right = slice::from_raw_parts_mut(ptr.add(index), len - index);
        (left, right)
    }
}
```

Burada özellikle fromrawpartsmut metodunun resmi dokümantasyonunda yer alan Safety kısmını okumak lazım. Performans açısından bize avantaj sağlar ama beraberinde bazı riskler de getirir sonuçta. Diğer yandan bu metot unsafe çağırılabilen bir fonksiyondur ve unsafe kod bloğuna almadığımız takdirde call to unsafe function is unsafe and requires an unsafe function or block şeklinde bir derleme hatası ile karşılaşırız.

Kodun çalışma zamanı çıktısı aşağıdaki gibidir.

![rust_exc_19.png](/assets/images/2025/rust_exc_19.png)

## Eşzamanlı (Concurrency) Veri Paylaşılan Durumlarda Kilitlenme ve Yarış Durumlarından (Data Races) Kaçınmak

Farklı iş parçacıklarının aynı veriye eşzamanlı olarak erişmesi gereken senaryolar vardır. Özellikle erişilen veri üzerinde değişiklik yapılacaksa deadlock'lar oluşması muhtemeldir. Hatta bu durum çoğunlukla Data Races olarak da bilinir. Rust tarafında son yazan kazanır gibi durumlarının üstesinden gelmek için bir Smart Pointer türevi olan Arc (Atomic Reference Counting) ve Mutex (Mutual Exclusion) enstrümanları kullanılır.

Bir web sunucusuna gelen sayısız isteğin birden fazla iş parçacığı tarafından işlendiğini düşünelim. Her bir thread gelen request ile ilgili bir şeyler yapıyor olsun. Bu vakada toplam istek sayısını global bir sayaç ile tuttuğumuzu varsayalım. Her thread aynı veri üzerinde değişiklik yapmaya çalışacaktır. Bu durumu Arc ve Mutex enstrümanlarını kullanarak aşağıdaki kod parçasında olduğu gibi ele alabiliriz.

```rust
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

fn main() {
    // Global paylaşımlı değişken
    // Arc ile çoklu sahiplik
    // Mutext kilitleme ile değiştirebilir erişim imkanı
    let counter = Arc::new(Mutex::new(0));
    let mut threads = vec![];
    let thread_count = 4;

    for i in 0..thread_count {
        let counter_clone = Arc::clone(&counter); // Referansları say

        let thread = thread::spawn(move || {
            println!("Thread {} starting", i);

            // Mutext ile kilitlenir ve MutexGuard alınır.
            // Diğer erişmeye çalışanlara müsaade edilmez
            let mut value = counter_clone.lock().unwrap();
            *value += 1;

            thread::sleep(Duration::from_millis(100));
        });
        threads.push(thread);
    }

    // Tüm iş parçacıklarının bitmesini bekleyelim
    for t in threads {
        t.join().unwrap();
    }

    println!(
        "Current total request count is {}",
        *counter.lock().unwrap()
    );
}
```

Bu kodun çalışma zamanı çıktısı aşağıdakine benzer olacaktır. Dikkat edileceği üzere ay sayıda thread açılmış olmasına rağmen her çalıştırmada genelde farklı sıralamalarda işletimler söz konusudur. Bu son derece doğaldır zira thread'ler herhangi bir sırada başlar. Ancak hangi sırada başlarlarsa başlasınlar sonuçta toplam değeri hep aynı çıkar.

![rust_exc_20.png](/assets/images/2025/rust_exc_20.png)

## Spawn Blocking Tasks ile Asenkron Kodlarda Performans Artışı Sağlamak

Merkezi işlem biriminin (CPU) yoğun kullanıldığı uzun süreli işler veya bloklamaya neden olan I/O operasyonlarında asenkron yürütücüler sorunlar yaşar. Örneğin diğer asenkron görevlerin ilerlemesi bu bloklamalar sırasında durur. Eğer işler farklı bir thread pool'a alınabilecek kıvamdaysa örneğin tokio küfesinin spawnblocking yapısı kullanılarak ilerlenebilir. Örneğin bir web sunucusu gelen isteğe ait bir asenkron iş akışı yürütülürken, şifre çözme gibi CPU'yu yoracak bir görevin gereksiz beklemeler olmadan çalıştırılması için bu özellik kullanılabilir. Tabii öncesinde rust projesinde gerekli Tokio küfesinin (crate) yüklü olması gerektiğini de hatırlatalım.

```text
[dependencies]
tokio = { version = "1.48.0", features = ["full"] }
```

Şimdi örnek uygulama kodlarına bakalım.

```rust
use tokio::time::{self, Duration};
use std::thread;

#[tokio::main]
async fn main() {
    call().await;
}

async fn call(){
    let start_time = time::Instant::now();
    println!("Service started...");

    // // Bad Practice: CPU yoğun işlemi doğrudan asenkron bağlam içinde ele aldığımızda
    // // asıl executor'ı da engeller
    // let pwd = decrypt("some hash value");

    // Good Practice: CPU yoğun işlemi spawn_blocking ile ayrı bir thread pool'a devrediyoruz
    let pwd_handle = tokio::task::spawn_blocking(|| {
        decrypt("some hash value")
    });

    // Diğer asenkron işlemleri simüle etmek için geçici bir bekleme yapıyoruz
    let io_opt = time::sleep(Duration::from_millis(500));

    // Burada tokio join ile iki asenkron işlemi paralel olarak işletiliyor
    tokio::join!(
        async{
            // Sembolik bir I/O operasyonu icra ettiğimizi düşünelim.
            println!("I/O operations completed");
            io_opt.await;
            println!("I/O wait is over");
        },
        async {
            // // Bad Practice :
            // println!("Decryption result '{}'",pwd);

            // Good Practice :
            let pwd = pwd_handle.await.expect("Blocking task failed.");
            println!("Decryption result '{}'",pwd);
        }
    );

    /*
        Toplam süreyi raporluyoruz.
        Gözlemlere göre spawn_blocking kullanımı ile asenkron işlemler engellenmeden paralel yürütülüyor.
        Buna göre toplam çalışma süresi yaklaşık olarak 1 saniye civarında oluyor.
        Ancak decrypt fonksiyonunu doğrudan asenkron bağlam içinde çağırıldığında bu süre 1.5 saniye civarına çıkıyor.
        Çünkü, decrypt fonksiyonu asenkron executor'ı bloke ediyor.

        Bad Practice toplam süre: ~1500 ms ve çalışma zamanı çıktısı:

        Service started...
        Starting decryption for 'some hash value'
        I/O operations completed
        Decryption result 'value decrypted'
        I/O wait is over
        Total process duration is 1506

        Good Practice toplam süre: ~1000 ms ve çalışma zamanı çıktısı:

        Service started...
        I/O operations completed
        Starting decryption for 'some hash value'
        I/O wait is over
        Decryption result 'value decrypted'
        Total process duration is 1002
    */

    println!("Total process duration is {}",start_time.elapsed().as_millis());
}

fn decrypt(value:&str) -> String {
    println!("Starting decryption for '{}'",value);
    thread::sleep(Duration::from_millis(1000));
    "value decrypted".to_string()
}
```

Uygulama kodunda hem Bad Practice hem de Good Practice şeklinde yorum satırlarımız var. Bunları ayrı ayrı açarak test etmekte yarar var. İdeal ve önerdiğimiz pratikte tokio küfesinden spawnblocking fonksiyonunu kullanarak decrypt işlemini farklı bir thread havuzuna devretmekteyiz. Buna göre sembolik olarak duraksatma yaptığımız ioopt işlemi ile ayrı bir havuz işletiliyor diyebiliriz. İlk versiyonda 1500 mili saniye süren işlem ideal sürümde 1000 mili saniye seviyelerine iniyor. Dolayısıyla bir thread'in ilgisi olmayan diğer thread'leri bekletmesinin önüne geçmiş oluyoruz.

![rust_exc_30_new.png](/assets/images/2025/rust_exc_30_new.png)

## Typestate Pattern ile Daha Güvenli Program Arayüzleri (API) Tasarlamak

Typestate Pattern'de bir nesnenin durumu tür sistemi ile ifade edilir. Böylece nesnenin belirli bir durumda hangi işlemleri yapabileceği tür sistemi tarafından garanti altına alınır. Bu desen, özellikle karmaşık State makineleri veya belirli adımların sırasıyla takip edilmesi gerektiği süreçler için faydalı bir kullanımdır.

Örneğin bir ağ nesnesninin alabileceği durumları düşünelim: Bağlantı kurulmamış, bağlantı kurulmuş, veri gönderilmiş veya veri alınmış gibi farklı pozisyonlarda olabilir. Bu durumlardan hangisinde ne tür işlemlerin yapılabileceğini de tür sistemi üzerinden ifade edebiliriz. Böylece yanlış sırayla yapılan işlemler derleme zamanında kolayca yakalanabilir. Aşağıdaki kod parçasına bu gözle bakabiliriz.

```rust
fn main() {
    let connection = Connection::new();
    let initialized_connection = connection.initialize("server=localhost;port=8080");
    match initialized_connection.connect() {
        Ok(_connected_connection) => {
            println!("Connection established successfully!");
        }
        Err(e) => {
            println!("Failed to connect: {}", e);
        }
    }
}

/*
    Durumları temsil eden tipler. Genellikle veri içermezler.
    Bunlar marker types olarak da bilinir.

    Aşağıdaki örnekte üç durum tanımlanmıştır:
    - Disconnected: Bağlantı kurulmamış durum
    - Initialized: Bağlantı başlatılmış ama henüz bağlanmamış durum
    - Connected: Bağlantı kurulmuş durum

    Initialized durumuna geçilebilmesi için önce Disconnected durumunda olunması gerekir.
    Connected durumuna geçilebilmesi için ise Initialized durumunda olunması gerekir.
*/
struct Disconnected;
struct Initialized;
struct Connected {
    _address: String,
}

// Connection yapısı, State tür parametresi ile durumunu belirtir.
struct Connection<State> {
    config: String,
    // State türü, Connection yapısının bir parçası değildir ancak tür sistemi tarafından da izlenmesi gereken bir bilgidir.
    // Bu nedenle PhantomData kullanılmakta. PhantomData, built-in bir marker type'dır. Rust ile gelen standart tür sistemi dışındaki
    // tür bilgilerini taşımak için kullanılır.
    state: std::marker::PhantomData<State>,
}

impl Connection<Disconnected> {
    fn new() -> Self {
        println!("Creating new connection");
        Connection {
            config: String::new(),
            state: std::marker::PhantomData,
        }
    }

    fn initialize(mut self, config: &str) -> Connection<Initialized> {
        println!("Initializing connection with config: {}", config);
        self.config = config.to_string();

        Connection {
            config: self.config,
            state: std::marker::PhantomData,
        }
    }
}

impl Connection<Initialized> {
    fn connect(self) -> Result<Connection<Connected>, String> {
        println!("Connecting with config: {}", self.config);
        // Konfigürasyon geçerli ise ve bağlantı başarılı ise Connected durumuna geçiş yaparız.
        // Aksi halde hata döneriz. Burada basit bir örnek olması için her zaman başarılı sonuç dönüyoruz.
        Ok(Connection {
            config: self.config,
            state: std::marker::PhantomData,
        })
    }
}
```

Aslında bu kod parçasındaki en kritik konulardan birisi PhantomData türünün kullanımıdır. İleride tekrar uğrayacağımız bu tür ile derleme zamanında bilinen ama çalışma zamanına taşınmayacak türlerin kullanımı mümkün hale gelir. Bu, tipik olarak sıfır maliyetli bir soyutlama yaklaşımdır (Zero Cost Abstraction) ve derleme zamanında tür kontrolü ile bazı garantileri çalışma maliyeti olmaksızın tesis etmemizi sağlar.

Örnek kod parçasının çalışma zamanı çıktısı aşağıdaki gibidir.

![rust_exc_22.png](/assets/images/2025/rust_exc_22.png)

## Uygulama Düzeyinde Hata Yayılımı (Error Propagation) için anyhow Kullanmak

Uygulamalar büyüdükçe hata yönetimi de karmaşıklaşır. Farklı modüllerin peşi sıra çağrılan farklı fonksiyonlarından gelen hata türlerini tek bir dinamik hata türünde toplamak ve yönetmek için anyhow kütüphanesi kullanılabilir. Bu kütüphane, farklı hata türlerini tek bir Error türüne sararark hata yayılımını (Error Propagation) kolaylaştırır. anyhow kütüphanesi ayrıca hata bağlamı (context) ekleme yeteneği de sağlar. Bu sayede hataların nerede ve neden oluştuğu daha iyi loglanabilir. Hatalar genel bir türe evrilirken detaydaki hatalar da downcast edilerek yakalanabilir. Tabii bu küfeyi kullanabilmek için projeye yüklenmiş olması gerekir. Yani toml dosyamızda aşağıdaki gibi bir bağımlılık tanımı olmalıdır.

```text
[dependencies]
anyhow = "1.0.100"
```

Tabii sürüm değişirse kullanım şeklinde de değişiklik olabilir. Lütfen güncel sürümdeki fonksiyonları kontrol ederek deneyiniz.

Şimdi gelin bu küfeyi basit bir kod parçasında ele alalım.

```rust
use anyhow::{Context, Result};
use std::io;
use std::num::ParseIntError;

fn main() {
    match run() {
        Ok(_) => println!("All operations completed successfully."),
        Err(e) => {
            // Burada oluşan tüm hataları ve context bilgilerini yazdırabiliriz
            let mut source = e.source();
            let mut level = 1;
            while let Some(err) = source {
                println!("  {}. {}", level, err);
                source = err.source();
                level += 1;
            }

            // İstersek bir anyhow::Error içindeki spesifik hata türlerine de erişebiliriz
            // Bunu, downcast_ref fonksiyonu ile sağlayabiliriz.
            if let Some(io_err) = e.downcast_ref::<io::Error>() {
                println!("IO Error details: {:?}", io_err.kind());
            }

            // Örneğin detaya gelen hata ParseIntError ise,
            if let Some(parse_err) = e.downcast_ref::<ParseIntError>() {
                println!("Parse Error details: {}", parse_err);
            }
        }
    }
}

// Bu fonksiyonda farklı senaryoları test ediyoruz
// Her adımda context ekleyerek hataların nerede oluştuğunu daha iyi anlamak mümkün.
// Kod tabanı geniş uygulamalarda bu yaklaşım hata ayıklamayı kolaylaştırır.
fn run() -> Result<()> {
    // Senaryoları tek tek açarak deneyebiliriz.
    add_product(1001, "ElCi Laptop", 999.99)
        .with_context(|| "Failed in scenario 1 - product not found")?;

    add_product(1003, "AyFone Smartphone", -399.99)
        .with_context(|| "Failed in scenario 3 - negative price test")?;

    add_product(9999, "Mouse Optical", 100.45)
        .with_context(|| "Failed in scenario 4 - database error test")?;

    Ok(())
}

// business modülünde ürün ekleme fonksiyonu
// anyhow ile context ekleme örneği
fn add_product(id: u32, name: &str, price: f64) -> Result<()> {
    validate_product(id, name, price)
        .with_context(|| format!("Product validation failed for ID: {}", id))?;
    write(&Product::new(id, name, price))
        .with_context(|| format!("Database operation failed for product: {}", name))?;

    Ok(())
}

// business modülünde çağrılan bir ürün doğrulama fonksiyonu
fn validate_product(id: u32, name: &str, price: f64) -> Result<()> {
    if id == 0 {
        return Err(anyhow::anyhow!("Product ID cannot be zero"));
    }

    if name.is_empty() {
        return Err(anyhow::anyhow!("Product name cannot be empty"));
    }

    if name.len() > 50 {
        return Err(anyhow::anyhow!(
            "Product name too long: {} characters (max: 50)",
            name.len()
        ));
    }

    if price < 0.0 {
        return Err(anyhow::anyhow!(
            "Product price cannot be negative: ${:.2}",
            price
        ));
    }

    if price > 10000.0 {
        return Err(anyhow::anyhow!(
            "Product price too high: ${:.2} (max: $10000.00)",
            price
        ));
    }

    Ok(())
}

// db modülünde bir ürün yazma fonksiyonu
// En alt katman - io::Error döndürüyor, anyhow yukarıdaki katmanlarda kullanılıyor
fn write(product: &Product) -> io::Result<()> {
    // Sadece database bağlantı hatasını simüle etmek için
    if product.id == 9999 {
        return Err(io::Error::new(
            io::ErrorKind::ConnectionRefused,
            "Database connection failed",
        ));
    }

    Ok(())
}

#[derive(Debug)]
#[allow(dead_code)]
struct Product {
    id: u32,
    name: String,
    price: f64,
}

impl Product {
    fn new(id: u32, name: &str, price: f64) -> Self {
        Product {
            id,
            name: name.to_string(),
            price,
        }
    }
}
```

Bu kodun çalışma zamanı çıktısı ise aşağıdaki gibidir.

![H1Tz6WZq55bbAAAAAElFTkSuQmCC](/assets/images/2025/rust-ile-kodlama-idmanlari-ileri-seviye-01.png)

## FFI (Foreign Function Interface) Kullanımlarında Unsafe ile Güvenli Soyutlamalar Oluşturmak

Rust kodlarında diğer diller ile etkileşim kurmak için FFI (Foreign Function Interface) desteği vardır. Ancak FFI kullandığımızda bellek güvenliği garantileri devre dışı kalır. Bir başka deyişle unsafe kod blokları kullanmak durumunda kalırız. İdeal yaklaşımda harici FFI çağrılarının güvenli soyutlamalar ile sarılması benimsenir. Böylece dışarıya açık API'ler güvenli kalır ve bellek güvenliği sorunları minimize edilir (Safe Abstractions). Örneğin C dilindeki bazı fonksiyonları kullanarak rastgele sayılar üretmek istediğimiz düşünelim. Bu senaryoda genelde libc'den srand ve rand gibi C fonksiyonlarını kullanırız. Aşağıdaki örnek kod parçasında bu fonksiyonların güvenli bir soyutlama ile nasıl sarılabileceği ele alınmaktadır.

```rust
use std::os::raw::{c_int, c_uint};
use std::sync::Mutex;

/*
    C ile yazılmış rand/srand fonksiyonlarını Rust tarafında kullanmak için FFI(Foreign Function Interface) tanımı.
    libc kütüphanesinden srand fonksiyonu ile rastgele sayı üreteci başlatılır ve rand fonksiyonu ile rastgele sayı alınır.
*/
unsafe extern "C" {
    fn rand() -> c_int;
    fn srand(seed: c_uint);
}

// Thread-safety için global mutex oluşturmamızda fayda var
static RAND_MUTEX: Mutex<()> = Mutex::new(());
static mut INITIALIZED: bool = false;

fn main() {
    for i in 0..5 {
        let random_number = generate_random_number();
        println!("#{}: {}", i + 1, random_number);
    }
}
/*
    Güvenli Soyutlamayı yaptığımız metot.
    Öncelikle global mutext ile thread-safety sağlanıyor.
    Daha sonra unsafe blok içinde C'nin srand fonksiyonu ile rastgele sayı üreteci initialize ediliyor.
    Ardından rand fonksiyonu çağrılıyor ve dönen değer güvenli bir şekilde u32'ye çevriliyor.
    Negatif değerler 0'a mapleniyor, böylece u32 overflow riski minimize ediliyor.
    Tüm unsafe kod bu fonksiyon içinde kapsülleniyor, dışarıya güvenli bir API sunuluyor.
*/
fn generate_random_number() -> u32 {
    // Thread safety için lock alıyoruz
    let _guard = RAND_MUTEX.lock().unwrap();

    /*
        unsafe blok için iki C fonksiyonu çağrılıyor.
        ilki srand ile rastgele sayı üretecini initialize ediyor.
        Burada amaç tutarlı rastgele sayılar üretmek.
        İkinci fonksiyon rand ile de gerçekten bir rastgele sayı oluşturuluyor.
    */
    unsafe {
        if !INITIALIZED {
            let seed = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() as c_uint;
            srand(seed);
            INITIALIZED = true;
        }
    }

    let result = unsafe { rand() };

    // max çağrısı ile negatif değerleri 0'a map ederek bir overflow oluşma riskini minimize ediyoruz
    result.max(0) as u32
}
```

Bu kodun çalışma zamanı çıktısı aşağıdaki gibidir.

![rust_exc_23.png](/assets/images/2025/rust_exc_23.png)

## Eşzamanlılık (Concurrency) Garantisi için Send ve Sync Trait'lerini Kullanmak

Eş zamanlı (Concurrent) çalışan işler arasında tiplerin güvenli bir şekilde paylaşımı/kullanımı önemli bir konudur. Send ve Sync trait'leri eş zamanlılık için gerekli kısıtlamaları tiplere ekleme becerisine sahiptir. Bir tür Send trait'ini implemente ediyorsa, bu türün sahipliği bir iş parçacığından diğerine güvenli bir şekilde taşınabilir. Sync trait'ini implemente eden türler ise, birden fazla iş parçacığı tarafından güvenli bir şekilde erişilebilir hale gelir.

Rust'ın standart kütüphanesinde yer alan pek çok tür varsayılan olarak send ve sync trait'lerini uygularken bazıları uygulamaz. Örneğin smart pointer'lardan birisi olan Rc yapısı Send ve Sync trait'lerini implemente etmez. Dolayısıyla referans sayımı iş parçacıkları arasında güvenli bir şekilde paylaşılamaz. Zaten yapının kullanım amacında bu yoktur. Diğer yandan örneğin Cell ve RefCell türleri de Sync trait'ini implemente etmezler çünkü sadece dahili olarak değiştirilebilirlik (mutability) sağlarlar. Diğer yandan Mutex ve RwLock türleri Sync trait'ini uygularlar, zira değiştirilebilirliği güvenli bir şekilde yönetirler. Özellikle thread-safe olmayan varlıkları kullandığımız veri yapıları olduğunda bu trait'leri kullanmak önemlidir. Aşağıdaki tabloda Send ve Sync trait'lerinin uygulandığı türlerle ilgili bilgiler verilmiştir.

![rust_exc_24.png](/assets/images/2025/rust_exc_24.png)

Buna göre örnek olarak aşağıdaki kod parçasını ele alabiliriz. Senaryo ve işleyiş yorum satırlarında yer almaktadır.

```rust
/*
    Bir oyundaki oyuncu ve takım sayılarına ait istatistikleri tutan Stats isimli bir veri yapımız var.
    Bu veri yapısındaki player_count alanı Raw Pointer türündendir ve bu türler
    Rust'ta Send ve Sync trait'lerini otomatik olarak implemente etmezler.

    Dolayısıyla bu veri yapısını farklı thread'ler arasında paylaşmaya çalıştığımızda,
    "*mut 32 cannot be sent between threads safely" hatasını alırız. Bu hatayı çözmek için
    Stats yapısına manuel olarak Send trait'ini implemente etmemiz gerekir.

    Şu anki senaryoda sync trait'ine de ihtiyacımız yok gibi görünebilir zira derleme zamanında
    hata alınmaz. Yine de raw pointer'lar thread-safe olmadığından dolayı Sync trait'ini açıkça
    ekleyerek kodun güvenliğini artırabiliriz.
*/
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let game_stats = Arc::new(Mutex::new(Stats {
        player_count: Box::into_raw(Box::new(0)),
    }));

    let mut handlers = vec![];

    for _ in 0..10 {
        let stats_clone = Arc::clone(&game_stats);
        let handle = std::thread::spawn(move || {
            let mut stats = stats_clone.lock().unwrap();
            unsafe {
                *stats.player_count += 1;
            }
            thread::sleep(std::time::Duration::from_millis(10));
        });
        handlers.push(handle);
    }

    for handle in handlers {
        handle.join().unwrap();
    }

    println!("Player Count: {}", unsafe {
        *game_stats.lock().unwrap().player_count
    });
}

#[allow(dead_code)]
#[derive(Debug)]
struct Stats {
    player_count: *mut u32,
}

unsafe impl Send for Stats {}
unsafe impl Sync for Stats {}
```

Bu kodun çalışma zamanı çıktısı aşağıdaki gibidir.

![rust_exc_25.png](/assets/images/2025/rust_exc_25.png)

## Eşzamanlı Garantilerde Mutex (Mutual Exclusion) Yerine Atomic Türleri Kullanmak

Rust'ta eşzamanlı (concurrent) programlama işlemlerinde paylaşılan veriyi yönetmek için genellikle Mutex enstrümanından yararlanılır. Ancak özellikle yüksek performans gerektiren senaryolarda Mutex yerine Atomic türleri tercih edilebilir. Atomic türleri kullanarak kilitlenme (locking) maliyetinden kaçılabilir ki bu da performansı artırır.

Örneğin mikroservis cennetine dönüşmüş bir eko sistemde servislere gelen istek sayılarını tuttuğumuzu ve belli bir eşik değerinin aşılması halinde yükün arttığını belirten alarm mekanizmalarını tetiklemek istediğimizi düşünelim. Gelen her istek için paylaşılan bir sayaç değeri üzerinden artış yapmamız gerekir. Mutex kullanabiliriz ama her artış işlemi için kilitleme ve açma maliyeti oluşur. Bunun yerine örneğin AtomicI32 türünü kullanarak Lock-free (kilitsiz) bir sayaç oluşturabiliriz. Aşağıdaki ilk kod parçasında klasik Mutex kullanımı ile bu senaryo ele alınmaktadır.

> Mutex senaryosunda bir thread öncelikle kilit ister, işletim sistemi buna göre thread takvimini planlar, eğer bir thread müşterek veri üzerinde çalışmak için onu kitlediyse diğer thread'ler uykuya geçer ve işletim sistemi planlamayı buna göre düzenler, müşterek veriyi çalışan thread işini tamamladığında kilit serbest kalır ve işletim sistemi planına göre uykudaki bir başka thread işine devam eder. Oysa ki Atomic tür kullanıldığında doğrudan CPU üzerindeki komut çalıştırılır. Elbette Mutex daha çok karmaşık veri türlerinin söz konusu olduğu senaryolarda çne çıkan bir kullanım şeklidir.

Senaryonun çok karmaşık olmaması için servis çağrılarının belli bir eşiği aşması halinde sadece bir uyarı mesajı bastırılıyor. Normal şartlarda servis çağrısını başka bir servise yönlendirme gibi işlemler de yapılabilir.

```rust
use std::sync::Mutex;
use std::thread;
use std::time::Duration;

static REQUEST_COUNTER: Mutex<i32> = Mutex::new(0);
const THRESHOLD_LEVEL: i32 = 100;

fn main() {
    let mut handlers = vec![];

    // Farklı servis isteklerini simüle eden thread'ler oluşturuyoruz
    // İlk thread ProductService isteklerini simüle ediyor
    let handle = thread::spawn(move || {
        for _ in 1..100 {
            handler(
                ServiceId {
                    name: "ProductService",
                    id: 1,
                },
                "api/product/10".to_string(),
            );
        }
    });
    handlers.push(handle);

    // İkinci thread CatalogService isteklerini simüle ediyor
    let handle = thread::spawn(move || {
        for _ in 1..100 {
            handler(
                ServiceId {
                    name: "CatalogService",
                    id: 2,
                },
                "api/catalog/computers/top/10".to_string(),
            );
        }
    });
    handlers.push(handle);

    // Tüm thread'lerin bitmesini bekliyoruz
    for handle in handlers {
        handle.join().unwrap();
    }
}

/*
    Sunucuya gelen servis isteklerini ele alan handler fonksiyon olarak düşünebiliriz.
    Parametrelerin senaryomuz gereği çok bir önemi yok.

*/
fn handler(service: ServiceId, body: String) {
    loop {
        /*
            Sonsuz döngüde iken sayacı hemen 1 artırıyoruz.
            Ardından sembolik olarak gelen isteği işliyoruz.
            Son olarak sayaç eşiği aşıldıysa alarm fonksiyonunu çağırıyoruz.
        */

        // REQUEST_COUNTER değişkenini kullanabilmek için öncelikle kilidini açıyoruz
        let mut counter = REQUEST_COUNTER.lock().unwrap();
        // * operatörü ile Mutex içindeki gerçek değere erişiyoruz
        *counter += 1;

        _ = read_request(&body);

        // Sayaç eşiğini aşıp aşmadığını kontrol ediyoruz
        if *counter > THRESHOLD_LEVEL {
            alert(service);
        }
    }
}

// Simülasyon amaçlı çalışan ve gelen isteği güya işleyen bir fonksiyon
fn read_request(body: &str) -> Result<(), ()> {
    // Sanki gerçekten bir iş yapılıyormuş gibi talep okuma işini belirli bir süre uyutuyoruz
    println!("Processing request body: {}", body);
    thread::sleep(Duration::from_millis(100));
    Ok(())
}

/*
    Uyarı mesajı veren fonksiyon.
    Örneğin basit olması açısından sadece mesaj veriyoruz.
    Aslında buradan dönecek değere göre ana süreç servis çağrılarını başka bir servise yönlendirebilir.
*/
fn alert(service: ServiceId) {
    println!("Alert for {:?}", service);
}

// Sadece servis ile ilgili bilgi taşımak için kullandığımız bir veri yapısı
// Sembolik olarak servisin adını ve sayısal değerini taşıyor
#[derive(Debug, Copy, Clone)]
struct ServiceId<'a> {
    id: u32,
    name: &'a str,
}
```

Bu kodun çalışma zamanı çıktısı aşağıdaki gibi olur.

![rust_exc_26.png](/assets/images/2025/rust_exc_26.png)

Şimdi aynı senaryoyu AtomicI32 türünü kullanarak yazalım.

```rust
use std::sync::atomic::{AtomicI32, Ordering};
use std::thread;
use std::time::Duration;

static REQUEST_COUNTER: AtomicI32 = AtomicI32::new(0);
const THRESHOLD_LEVEL: i32 = 100;

fn main() {
    let mut handlers = vec![];

    let handle = thread::spawn(move || {
        for _ in 1..100 {
            handler(
                ServiceId {
                    name: "ProductService",
                    id: 1,
                },
                "api/product/10".to_string(),
            );
        }
    });
    handlers.push(handle);

    let handle = thread::spawn(move || {
        for _ in 1..100 {
            handler(
                ServiceId {
                    name: "CatalogService",
                    id: 2,
                },
                "api/catalog/computers/top/10".to_string(),
            );
        }
    });
    handlers.push(handle);

    for handle in handlers {
        handle.join().unwrap();
    }
}

fn handler(service: ServiceId, body: String) {
    loop {
        /*
            Sonsuz döngüde iken sayacı hemen 1 artırıyoruz.
            Ardından sembolik olarak gelen isteği işliyoruz.
            Son olarak sayaç eşiği aşıldıysa alarm fonksiyonunu çağırıyoruz.

            Bunu iki farklı şekilde yapmaktayız.
            Normalde Mutex kullanarak yaptığımız işlemin çalışma zamanında kilit açma ve kapama
            maliyeti olduğunu düşünürsek bunu Atomic değişkenler ile yapmanın daha performanslı
            olacağını iddia edebiliriz.
        */

        REQUEST_COUNTER
            .fetch_update(Ordering::Relaxed, Ordering::Relaxed, |count| {
                Some(count + 1)
            })
            .ok();

        _ = read_request(&body);

        if REQUEST_COUNTER.load(Ordering::Relaxed) > THRESHOLD_LEVEL {
            alert(service);
        }
    }
}

fn read_request(body: &str) -> Result<(), ()> {
    println!("Processing request body: {}", body);
    thread::sleep(Duration::from_millis(100));
    Ok(())
}

fn alert(service: ServiceId) {
    println!("Alert for {:?}", service);
}

#[derive(Debug, Copy, Clone)]
struct ServiceId<'a> {
    id: u32,
    name: &'a str,
}
```

Bu kodun çalışma zamanı çıktısı da aşağıdaki gibi olacaktır.

![rust_exc_27.png](/assets/images/2025/rust_exc_27.png)

Bu yeni kullanımda görüldüğü üzere herhangi bir kilit açma veya kapatma işlemi kullanılmıyor. Bunun yerine fetchupdate metodu ile atomik bir şekilde sayaç değerini artırıyoruz. Ayrıca sayaç değerini okumak için load metodunu kullanıyoruz. Atomik operasyonlarda işin sırrı Rust'ın doğrudan CPU komutlarını (Instructions) kullanmasıdır. Bu komutlar CPU seviyesinde kesintilerin sorunsuz şekilde garanti edilmesini sağlar. Bir nevi CPU komutlarının garantisini kullandığımızı ifade edebiliriz zira donanım seviyesinde gerçekleştirilen işlemler söz konusudur. Örneğin x86 tabanlı işlemci setlerinde LOCK XADD komutu kullanılarak kesintisiz sayaç artımı yapılabilir. Burada tüm çekirdekler değişikliği anında görür, hiçbir işletim sistemi mekanizması devreye girmez (thread scheduling gibi)

Lakin burada özellikle dikkat edilmesi gereken nokta Ordering parametresine verilen değerle ilgilidir. Bu parametreler, atomik işlemlerin bellek sıralaması üzerindeki etkilerini belirler. Yukarıdaki örnekte Relaxed sıralama kullanılmıştır ki bu en gevşek sıralamadır ve en yüksek performansı sağlar. Ancak bazı senaryolarda daha güçlü sıralama garantilerine ihtiyaç duyulabilir. Bu durumda Acquire, Release veya SeqCst gibi farklı sıralama türleri tercih edilmelidir. Karar vermek zor olabilir bu yüzden aşağıdaki tabloyu incelemek faydalı var.

![rust_exc_28.png](/assets/images/2025/rust_exc_28.png)

Diğer sıralama türleri Release ve Acquire için [resmi dokümantasyona](https://doc.rust-lang.org/std/sync/atomic/enum.Ordering.html) bakılabilir.

Bunlardan hangisinin kullanılacağına karar vermek içinse aşağıdaki tablodan yararlanılabilir.

![rust_exc_29.png](/assets/images/2025/rust_exc_29.png)

Bu iki yaklaşım arasındaki süre farkı hakkında fikir vermek için aşağıdaki örnek kod parçasını da ele alabiliriz. Senaryoda 10 farklı thread tarafından ortak bir sayaç değerinin artırılması söz konusu. Mutex ve AtomicI32 kullanımı arasındaki süre farkını ölçüyoruz.

```rust
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Mutex;
use std::thread;
use std::time::Instant;

static COUNTER: Mutex<u32> = Mutex::new(0);
static ATOMIC_COUNTER: AtomicU32 = AtomicU32::new(0);
const NUMBER_OF_ITERATIONS: u32 = 10_000_000;

fn main() {
    println!("Calculating with Mutex:");
    calculate_with_mutex();

    println!("\nCalculating with Atomic:");
    calculate_with_atomic();
}

fn calculate_with_mutex() {
    let mut threads = vec![];
    let time_start = Instant::now();

    for _ in 0..10 {
        let t = thread::spawn(|| {
            for _ in 0..NUMBER_OF_ITERATIONS {
                let mut num = COUNTER.lock().unwrap();
                *num += 1;
            }
        });
        threads.push(t);
    }

    for t in threads {
        t.join().unwrap();
    }

    let duration = time_start.elapsed();
    println!("Final counter value: {}", *COUNTER.lock().unwrap());
    println!("Time elapsed: {:?}", duration);
}

fn calculate_with_atomic() {
    let mut threads = vec![];
    let time_start = Instant::now();

    for _ in 0..10 {
        let t = thread::spawn(|| {
            for _ in 0..NUMBER_OF_ITERATIONS {
                ATOMIC_COUNTER.fetch_add(1, Ordering::SeqCst);
            }
        });
        threads.push(t);
    }

    for t in threads {
        t.join().unwrap();
    }

    let duration = time_start.elapsed();
    println!(
        "Final atomic counter value: {}",
        ATOMIC_COUNTER.load(Ordering::SeqCst)
    );
    println!("Time elapsed: {:?}", duration);
}
```

İşte sonuçlar...

![mutex_vs_atomic.png](/assets/images/2025/mutex_vs_atomic.png)

Böylece geldik bir makalemizin daha sonuna.

[Bu bölümde yer alan kod parçalarına github reposu üzerinden de erişebilirsiniz](https://github.com/buraksenyurt/friday-night-programmer/tree/main/src/rust-exercises). Ayrıca [Ferris logosunu sevdiyseniz Maria Letta'nın reposunda daha fazlasını da bulabilirsiniz](https://github.com/MariaLetta/free-ferris-pack);)

Kaynaklar:

- [Rust for the Polyglot Programmer](https://www.chiark.greenend.org.uk/~ianmdlvl/rust-polyglot/intro.html)
- [Nine Rust Pitfalls,Daniel Hayes](https://leapcell.io/blog/nine-rust-pitfalls)
- [The Rust Programming Language, 2nd Edition](https://nostarch.com/rust-programming-language-2nd-edition)
- [Welcome to Comprehensive Rust](https://google.github.io/comprehensive-rust/comprehensive-rust.pdf)
- [Design Patterns in Rust](https://refactoring.guru/design-patterns/rust)
- [Rust by Example](https://doc.rust-lang.org/stable/rust-by-example/)
- [Too Many Lists](https://rust-unofficial.github.io/too-many-lists/index.html)
- [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/)

Bir başka yazıda görüşünceye dek hepinize mutlu günler dilerim.
