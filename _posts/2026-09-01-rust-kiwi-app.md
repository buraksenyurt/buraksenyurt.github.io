---
layout: post
title: "Rust ile Basit Bir Key-Value Store Uygulaması"
date: 2026-09-01 06:00:00
tags:
    - rust
    - concurrency
    - mutual-exclusion
    - fearless-concurrency
    - tokio
    - docker
    - docker-compose
    - containerization
categories:
    - Programlama Dilleri
---
Bir programlama dilini öğrenmeye çalışırken bazı kavramları anlamanın en iyi yolu elbette senaryo bazlı pratik yapmaktan geçiyor. Yazıyı yazdığım tarih itibariyle şöyle bir bakıyorum da repolarımın kıyısında köşesinde bu amaçla yazılmış ama unutulmuş denemeler var. Bugün onlardan birisini yazıya döküp tekrar etmeye çalışacağım. Elimdeki konu oldukça sağlam. Çok sık karşımıza çıkan ama üzerine fazla kafa yormadan ilerlediğimizde bize dert çıkarabilecek üç önemli parçası var; eşzamanlılık *(concurrency)*, müşterek kilitleme *(mutex)* ve çok kullanıcı tarafından ortaklaşa paylaşılmak istenen veri *(shared data)*. Bunları teorik olarak bilmek başka, aynı verinin birden fazla bağlantı tarafından aynı anda değiştirilmeye çalışıldığı bir senaryoda ele alıp test etmek bambaşka. O yüzden basit ama gerçekçi bir problem seçtim; **TCP** protokolü üzerinden konuşan, verileri bellekte tutan, minik bir key-value store yazmak.

Ortaya `kivi-store` adında küçük bir Rust projesi çıktı. Neden Kivi ismini kullandığımı çok irdelemeyin. Meyve olarak severim ama K ve V başharflerini nasıl kullansam derken ortaya böyle bir şey çıktı. Belki çok sağlam bir protokol üzerine oturutup, en süratli ve hafifsiklet dağıtık key-value veritabanı olsa meyvenin tonlarında sevimli bir logosu bile olabilirdi. Çok doğal olarak **Redis**'in milyonda biri kadar iddialı bir çalışma değil elbette. Asıl amaç üretim ortamda kullanılabilecek bir şey üretmek değil, `tokio` ile asenkron bir **TCP** sunucusu yazarken paylaşılan durumu *(shared state)* nasıl güvenli şekilde yöneteceğimizi görmek. Son adımda bunu bir de **Docker** imajına gömüp herkesin `docker run` diyerek ayağa kaldırabileceği hale getireceğiz. Asıl testleri kıymetli Alper Konuralp hocam yapacak :D

## Genel Mimari

Projenin genel yapısı oldukça basit ve birkaç modülden oluşuyor. Bunları aşağıdaki gibi özetleyebiliriz.

- `main.rs`: ortam değişkenlerini okuyup sunucuyu ayağa kaldırıyor
- `server.rs`: TCP dinleyicisini *(listener)* açıyor ve gelen her bağlantı için ayrı bir görev *(task)* başlatıyor
- `command.rs`: istemciden gelen metni `SET`, `GET`, `REMOVE`, `LIST` gibi komutlara dönüştürüyor *(parse)*
- `handler.rs`: bir bağlantının yaşam ömrü içerisinde gelen komutları işleyip cevabı *(response)* yazıyor
- `store/data.rs`: asıl paylaşılan veri yapısı ise burada. Yani key-value çiftlerini tutan `DataStore` bileşenimiz.

Programın çalışma akışı kabaca şöyle. `main.rs` içinde `.env` dosyasından `LISTEN_ADDRESS` okunuyor ve `server::run` metodu çağrılıyor. `server.rs` içindeki döngü her yeni bağlantıyı kabul ettiğinde `tokio::spawn` ile ayrı bir asenkron görev başlatılıyor ve o bağlantının okuma/yazma işi `handler::handle_request`'e devrediliyor. Yani her istemci kendi görevinde yaşıyor ama hepsi aynı veri deposuna erişiyor. İşte tam da bu noktada paylaşılan veri *(shared data)* problemiyle karşılaşıyoruz. *(Ne dediğinizi duyar gibiyim. 100 client bağlansın bu uygulama patlar. Lakin amaçlardan birisi de sınırlarda çalıştırıp eksiklerimizi görmek ve Redis gibi sistemleri geliştirenlere bir kez daha saygı duymak)*

server modülünün `run` fonksiyonu, gelen bağlantıları kabul edip her biri için ayrı bir görev başlatıyor;

```rust
use crate::handler::handle_request;
use crate::store::DataStore;
use log::info;
use tokio::net::TcpListener;

pub async fn run(address: &str) -> tokio::io::Result<()> {
    let listener = TcpListener::bind(address).await?;
    let store = DataStore::new();

    info!("Server running at {}", address);

    loop {
        let (stream, addr) = listener.accept().await?;
        info!("Client {} connected", addr);
        let store = store.clone();
        tokio::spawn(async move {
            handle_request(stream, store).await;
        });
    }
}
```

## Komut Protokolü

Komutlarımızın çalışma protokolü kasıtlı olarak çok basit tutuldu. Satır satır, boşlukla ayrılmış metin komutları şeklinde ilerliyoruz. Örneğin istemci `SET key value` komutunu gönderdiğinde, sunucu `key` ve `value`'yu alıp `DataStore`'a kaydediyor. `GET key` komutu ile değeri alabiliyor, `REMOVE key` ile silebiliyor ve `LIST` komutu ile tüm anahtarları listeleyebiliyoruz.

```bash
SET key value
GET key
REMOVE key
LIST
```

`command.rs` içindeki `Command::parse` fonksiyonu gelen metni en fazla üç parçaya bölüyor (`splitn(3, ' ')`). Böylece `value` kısmında boşluk geçse bile bozulmuyor.

```rust
#[derive(Debug)]
pub enum Command {
    Set { key: String, value: String },
    Get { key: String },
    Remove { key: String },
    List,
    Invalid(String),
}

impl Command {
    pub fn parse(input: &str) -> Self {
        let mut parts = input.trim().splitn(3, ' ');
        let cmd = parts.next().unwrap_or("").to_uppercase();

        match cmd.as_str() {
            "SET" => {
                let key = parts.next().unwrap_or("").to_string();
                let value = parts.next().unwrap_or("").to_string();
                Command::Set { key, value }
            }
            "GET" => {
                let key = parts.next().unwrap_or("").to_string();
                Command::Get { key }
            }
            "REMOVE" => {
                let key = parts.next().unwrap_or("").to_string();
                Command::Remove { key }
            }
            "LIST" => Command::List,
            _ => Command::Invalid(cmd),
        }
    }
}
```

Bilinmeyen bir komut geldiğinde programı patlatmak yerine `Command::Invalid` dönüyoruz ve hata durumunu tip sisteminin bir parçası haline getiriyoruz. Bu Rust tarafında alıştığımız bir yaklaşım.

## Paylaşılan Veriyi Yönetmek: `Arc, Mutex, HashMap`

Gelelim paylaşılan veriyi nasıl yöneteceğimizi. İşte asıl mevzumuz biraz da bu. `DataStore` veri yapımız içinde `HashMap<String, String>` taşıyan ama bunu `Arc<Mutex<...>>` enstrümanı ile sarmalayan bir bileşen. Aşağıdaki kod parçasında içeriğini bulabilirsiniz.

```rust
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Clone)]
#[allow(dead_code)]
pub struct DataStore {
    context: Arc<Mutex<HashMap<String, String>>>,
}

#[allow(dead_code)]
impl DataStore {
    pub fn new() -> Self {
        DataStore {
            context: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    pub async fn set(&self, key: &str, value: &str) {
        let mut context = self.context.lock().await;
        context.insert(key.to_string(), value.to_string());
    }

    pub async fn remove(&self, key: &str) -> bool {
        let mut context = self.context.lock().await;
        context.remove(key).is_some()
    }

    pub async fn get(&self, key: &str) -> Option<String> {
        let context = self.context.lock().await;
        context.get(key).cloned()
    }

    pub async fn keys(&self) -> Vec<String> {
        let context = self.context.lock().await;
        context.keys().cloned().collect()
    }
}
```

Burada önemli olan bazı temelleri hatırlamamızda fayda var.

- **`Arc` (Atomic Reference Counting)**, aynı veriye birden fazla sahibin *(owner)* güvenli bir şekilde referans tutabilmesini sağlıyor. Rust'ın sahiplik *(ownership)* modelinde normalde *bir değerin tek sahibi olur* kuralı var. `Arc` bu kuralı, referans sayısını atomik olarak takip ederek gevşetiyor. `server.rs` içinde her yeni bağlantı için `store.clone()` çağrısı yaptığımızda aslında `HashMap`'in kendisi kopyalanmıyor, sadece referans sayacı artıyor. Referanslar scope dışına çıktığında `Arc` otomatik olarak sayacı azaltıyor ve son referans silindiğinde veri de serbest bırakılıyor.
- **`Mutex` (Mutual Exclusion)** ise aynı anda yalnızca bir görevin *(task)* veriye erişebileceğini garanti ediyor. `.lock().await` çağrısı, kilit başka bir görev tarafından tutuluyorsa mevcut görevi bekletiyor *(ama iş parçacığını-thread değil. Asenkron bir bekleme söz konusu burada)*

Uygulamada dikkat edilmesi gereken bir ayrıntı var. Kullanılan `Mutex` enstrümanı dikkat edileceği üzere `std::sync::Mutex` değil, `tokio::sync::Mutex`. Standart kütüphane ile gelen primitive'lerden olan `Mutex` senkron çalışıyor ve bu nedenle kilidi tutarken bir `.await` noktasına girilirse o kilidi tutan iş parçacığı *(thread)* bloke oluyor ve bu da tokio'nun runtime'ında beklenmedik tıkanmalara yol açabilir. `tokio::sync::Mutex` ise tamamen asenkron çalışma moduna uyumlu şekilde yazılmış. Kilit meşgulken bekleyen görev, iş parçacığını serbest bırakıp runtime'ın başka görevleri çalıştırmasına izin veriyor. Bu projede kilit tutulan bloklar zaten çok kısa (`HashMap` üzerinde `insert`/`get`/`remove`) olduğu için pratikte farkın küçük olacağını düşünebiliriz ama alışkanlık olarak asenkron kod içinde asenkron kilit kullanmak daha doğrudur. Tabii bunu bir denemenizi ve gerçeken dediğim gibi olup olmadığını ispatlamanızı şiddetle tavsiye ederim ;)

## Bağlantı Başına Bir Görev Meselesi *(Task)*

`tokio::spawn`, işletim sistemi seviyesinde yeni bir iş parçacığı *(thread)* açmaz. Tokio'nun kendi çok iş parçacıklı *(multi-threaded)* zamanlayıcısında *(scheduler)* çalışacak hafif bir görev *(task - ki sanırım buna bazen "green thread" de deniyor)* oluşturur. Yüzlerce istemci bağlansa bile işletim sistemi bunun yükünü hissetmeyecektir çünkü tokio bu görevleri az sayıda gerçek iş parçacığı üzerinde zamanlar. `DataStore` üzerindeki `Arc<Mutex<...>>` sayesinde de bu görevlerin hepsi aynı veriye tutarlı biçimde erişebilir.

`handler.rs` içindeki `handle_request` fonksiyonu, bağlantı kapanana kadar döngüde okuma yapıp gelen komutu `DataStore` üzerinde çalıştırır ve cevabı istemci tarafa yine Tcp stream üzerinde yazar.

```rust
use crate::command::Command;
use crate::store::DataStore;
use log::{error, info};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

#[allow(dead_code)]
pub async fn handle_request(mut stream: TcpStream, data_store: DataStore) {
    let mut buffer = [0; 1024];
    loop {
        let size = match stream.read(&mut buffer).await {
            Ok(0) => break,
            Ok(n) => n,
            Err(e) => {
                error!("{}", e);
                break;
            }
        };

        info!("Read {}(bytes)", size);

        let request = String::from_utf8_lossy(&buffer[..size]);
        let cmd = Command::parse(&request);

        let response = match cmd {
            Command::Set { key, value } => {
                data_store.set(&key, &value).await;
                "OK\r\n".to_string()
            }
            Command::Get { key } => {
                info!("GET {}", key);
                match data_store.get(&key).await {
                    Some(value) => format!("{}\r\n", value),
                    None => "NOT FOUND\r\n".to_string(),
                }
            }
            Command::Remove { key } => {
                info!("REMOVE {}", key);
                if data_store.remove(&key).await {
                    "OK\r\n".to_string()
                } else {
                    "NOT FOUND\r\n".to_string()
                }
            }
            Command::List => {
                let keys = data_store.keys().await;
                format!("{}\r\n", keys.join("\r\n"))
            }
            Command::Invalid(cmd) => format!("ERROR: Unknown command '{}'\r\n", cmd),
        };

        if let Err(e) = stream.write_all(response.as_bytes()).await {
            error!("{}", e);
            break;
        }
    }
}
```

Sabit boyutlu 1024 byte veri taşıyacak bir tampon *(buffer)* kullanılıyoruz. Küçük komutlar için yeterlidir ama gerçek bir üretim sistemi için elbette değişken uzunluklu ya da uzunluk-öncelikli *(length-prefixed)* bir protokol tercih edilebilir. Bu proje kapsamında amaç protokol tasarımı değil, eşzamanlılık pratiği olduğu için basit tutuldu. *(Cidden bu amaçla kendi protokolümü yazacak seviyede bilgim olsun isterdim)*

## Testler

Repoda hem `DataStore` hem de `Command::parse` için birkaç birim testimiz var esasında. `DataStore` testinde bir anahtar-değer çifti ekleyip sonra onu alıyoruz ve beklenen değerle karşılaştırıyoruz. `Command::parse` testinde ise bir metin komutunu parse edip doğru şekilde ayrıştırıldığını kontrol ediyoruz. Başka birim testler de eklenip kodun güvenilirliği artırılabilir.

```rust
#[tokio::test]
async fn test_set_and_get() {
    let data_store = DataStore::new();
    data_store.set("Resilience", "on").await;
    let expected = data_store.get("Resilience").await.unwrap();
    assert_eq!(expected, "on");
}

#[test]
fn test_command_parse() {
    let cmd = Command::parse("SET Connection dataSource=localhost;database=MongoDb");
    match cmd {
        Command::Set { key, value } => {
            assert_eq!(key, "Connection");
            assert_eq!(value, "dataSource=localhost;database=MongoDb");
        }
        _ => panic!("Expected to parse SET command!"),
    }
}
```

`#[tokio::test]` makrosunun burada işaret ettiği önemli bir nokta var. `DataStore` asenkron metotlar barındırdığı için, testin kendisinin de bir *tokio runtime* içinde çalışması gerekiyor. Sıradan bir `#[test]` ile `.await` kullanmaya çalışsaydık derleyici bunu kabul etmeyecektir. Testleri çalıştırmak için bildiğiniz üzere `cargo test` komutunu kullanıyoruz.

![KiviStore_00](/assets/images/2026/KiviStore_00.png)

## Docker Imajını Oluşturmak

Çalışmamızın son adımında projeyi herkesin kolayca çalıştırabileceği bir hale getireceğiz. Burada amaç uygulamayı container olarak da sunabilmek. Bunun için bilindiği üzere bir `Dockerfile` dosyasına ihtiyacımız var. İki aşamalı *(multi-stage)* bir yapı kullanıyoruz. İlk aşamada `rust:1.87.0` imajı üzerinden `cargo build --release` ile derleme yapılıyor. İkinci aşamadaysa sadece derlenmiş binary çok daha küçük olan `debian:bookworm-slim` imajına kopyalanıyor.

```dockerfile
FROM rust:1.87.0 AS builder

WORKDIR /app
COPY . .

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/kivi-store /usr/local/bin/kivi-store
COPY .env .env

EXPOSE 5555

CMD ["kivi-store"]
```

Bu sayede son imaj Rust derleyicisini ve ara derleme dosyalarını içermiyor. Onun yerine çalıştırılabilir dosyayı ve gerekli sertifikaları taşıyor. `docker-compose.yml` ise tek servisli, minimal bir tanımlamadan ibaret.

```yaml
services:
  kivi-store:
    build: .
    ports:
      - "5555:5555"
```

İmajı build etmek ve konteynırımızı ayağa kaldırmak için aşağıdaki komutları deneyebiliriz.

```bash
# Docker imajını oluşturmak
docker build -t kivi-store .

# docker-compose ile ayağa kaldırmak için
docker-compose up -d

# Eğer kodda bir değişiklik yaparsak container imajını tazelemek gerekir
docker-compose up -d --build
```

## Gerçek Denemeler

Sunucu ayağa kalktıktan sonra herhangi bir TCP istemcisiyle deneme yapabiliriz ancak en güzeli kendi istemcimizi sunmak olacaktır. Bu amaçla **bin** klasöründe aşağıdaki içeriği sahip programı yazalım.

```rust
use std::env;
use std::io::{self, Write};
use tokio::io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader};
use tokio::net::TcpStream;

#[tokio::main]
async fn main() -> tokio::io::Result<()> {
    let address = env::var("KIVI_ADDRESS").unwrap_or_else(|_| "127.0.0.1:5555".to_string());
    let mut stream = TcpStream::connect(&address).await?;
    let mut stdin = BufReader::new(tokio::io::stdin()).lines();

    println!("kivi-store istemcisi - {} adresine bağlandı", address);
    println!("Komutlar: SET key value | GET key | REMOVE key | LIST (çıkmak için Ctrl+C)\n");

    loop {
        print!("> ");
        io::stdout().flush()?;

        let line = match stdin.next_line().await? {
            Some(line) if !line.trim().is_empty() => line,
            Some(_) => continue,
            None => break,
        };

        stream.write_all(format!("{}\r\n", line).as_bytes()).await?;

        let mut buffer = [0u8; 1024];
        let n = stream.read(&mut buffer).await?;
        if n == 0 {
            println!("Bağlantı sunucu tarafından kapatıldı.");
            break;
        }
        print!("{}", String::from_utf8_lossy(&buffer[..n]));
    }

    Ok(())
}
```

İstemci taraf, `kivi-store` protokolünün doğası gereği *(bir istek -> bir cevap)* tamamen senkron bir döngüyle çalışır. Satırı okur ve sonuna `\r\n` ekleyip gönderir. Ardından cevabı bekler ve sonucu ekrana basar. `tokio::io::stdin()`'in asenkron satır okuma desteği zaten küfenin *(crate)* full özellik kümesiyle *(feature set)* geliyor, dolayısıyla ekstra bir bağımlılık eklemeye de gerek yok.

Şimdi terminalden testlerimize başlayabiliriz.

```bash
# Docker imajı ile veya cargo run ile sunucuyu ayağa kaldırdıktan sonra
# İstemciyi işletebiliriz
cargo run --bin client

# İşte birkaç örnek komut
SET Language Rust
SET Framework Tokio
LIST
SET System Linux
GET Language
REMOVE Language
GET Language
NOT FOUND
LIST

```

İşte çalışma zamanından bir ekran görüntüsü.

![KiviStore_01](/assets/images/2026/KiviStore_01.png)

Aynı örneği docker-compose üzerinden ayağa kaldırıp denediğimizde de benzer sonuçları almamız gerekiyor.

![KiviStore_02](/assets/images/2026/KiviStore_02.png)

Bu arada kendi istemcimizi denedik ama şart değil. `ncat` gibi bir aracı da kullanabiliriz. Ben Windows 11 sistemine chocolatey ile `ncat` kurdum ve aşağıdaki gibi denedim.

```bash
# kurmak için
# choco install nmap

# bağlanmak için
ncat localhost 5555

# sonraki komutlar aynı şekilde çalışıyor
```

![KiviStore_03](/assets/images/2026/KiviStore_03.png)

## Dağıtım *(Deployment)*

Diyelimki kıymetli Alper Konuralp hocam ile birlikte yaptığımız yayında bu sunucu uygulamasını docker paketi olarak verip denemesini istiyeceğim. Hoş örneği `docker-hub`'a yükleyip `docker pull` ile çekmesini de sağlayabilirim. Ama buna gerek duyulmayacak kadar sıradan bir örneğimiz var. Aşağıdaki komutlarla ilerleyelim.

```bash
# Önce temiz bir build alalım
docker build --no-cache -t kivi-store:v0.1.0 .

# Şimdi imajımızı tek bir dosyaya paketleyelim
docker save -o kivi-store-v0.1.0.tar kivi-store:v0.1.0

# Boyut büyük mü? Hiç dert değil sıkıştırıp transfer boyutunu ufaltabiliriz de
# Gzip yoksa yüklemek gerekir. Bende yoktu çikolata yardımıma yetişti
# choco install gzip
docker save kivi-store:v0.1.0 | gzip > kivi-store-v0.1.0.tar.gz

# Alper Hocam'a bu çıktıyı ulaştırdıktan sonra onun da yapması gerekenler var tabii
# Önce imajı yüklemeli
docker load -i kivi-store-v0.1.0.tar
# Eğer zip'li dosya ile gönderildiysek
# gunzip -c kivi-store-v0.1.0.tar.gz | docker load

# Sonra Container'ı ayağa kaldırabilir
docker run -d -p 5555:5555 --name kivi-store kivi-store:v0.1.0
```

Bakalım neler olacak?

## Sonuç

`kivi-store`, iddialı bir proje olma amacı taşımıyor; amacı, `Arc<Mutex<...>>` ikilisinin neden birlikte kullanıldığını, `tokio::spawn` ile açılan görevlerin işletim sistemi iş parçacıklarından farkını ve asenkron kod içinde neden asenkron bir kilide ihtiyaç duyduğumuzu elle deneyerek pekiştirmekti. Ortaya çıkan sonuç, birkaç yüz satırlık küçük bir TCP sunucusu ama içinde paylaşılan durumu (shared state) güvenli yönetmenin temel desenini barındırıyor.

Bir sonraki adım olarak aklımda şunlar var: uzunluk-öncelikli *(length-prefixed)* bir protokole geçmek, `RwLock` ile okuma-ağırlıklı senaryoları karşılaştırmak ve belki de basit bir TTL *(time-to-live)* desteği eklemek. Böylece geldik derlenmiş bir maceramızın daha sonuna. Umarım faydalı olmuştur. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[Örnek kodlara github üzerinden ulaşmak için tıklayınız.](https://github.com/buraksenyurt/rust-farm/tree/main/handson/kivi-store)

[Orijinal Kaynak](https://www.buraksenyurt.com/post/rust-ile-basit-bir-key-value-store-uygulamasi)
