---
layout: post
title: "Tauri ile Masaüstü Uygulama Geliştirme"
date: 2026-08-31 06:00:00
tags:
    - tauri
    - rust
    - desktop-application-development
    - typescript
    - cross-platform
categories:
    - Programlama Dilleri
---
Mesleğe ilk başladığım yıllarda Web teknolojileri daha yeni yeni yaygınlaşmaya başlamıştı. **Java** ilk sürümünü yayınlamışken ben daha çok **Delphi** ile **Windows** platformunda masaüstü uygulamalar geliştirmekle meşguldüm. Web tabanlı geliştirmenin avantajları bir yana masaüstü uygulamalarda konuk olunan işletim sisteminin gücünden yararlanma, state tutma şansına sahip olabiliyorduk. Elbette zaman içerisinde neredeyse tüm iş modelleri web tabanlı çözümlere geçti. Web 1.0, 2.0, 3.0 derken Internet'in neredeyse tüm altyapısına sızan sayısız **Javascript Framework** arasında geçiş yapar olduk. Özellikle cross-platform tabanlı sistemleri düşününce karşımıza farklı hibrit çözümler de çıktı. **Chromium** gibi tarayıcıların işletim sisteminde çalışabilen çekirdek arayüzleri ile backend tarafı klasik servis haberleşmeleri üzerinden konuşmaya başladı. Herhalde **Electron** bu çözümler arasında en bilinenleri arasındadır. Tabii farklı dillerin sunduğu farklı çözümler de var. Örneğin **Rust** cephesindeki yaklaşımların başında **Tauri** geliyor. Bir süredir kenara park ettiğim bu konuyu nihayet deneme fırsatı buldum ve öğrendiklerimi bir yazıda toplamak istedim. Amacımız **sysinfo** küfesini *(crate)* kullanarak ilkel bir **dashboard** hazırlamak ve burada en azından **CPU**, **RAM** ve **Disk** kullanımını göstermek.

## Tauri Çalışma Modeli

Bir **Tauri** uygulaması aslında tek bir process'te çalışan iki uygulamadan oluşur. Çekirdek fonksiyonellikler **Rust** tarafında ele alınırken önyüz tarafında **WebView** kullanılır. Bu WebView her platformda farklıdır; **Linux** tarafında **WebKitGTK**, **Windows** tarafında **Edge WebView2** ve **macOS** tarafında **WKWebView**. İşte **Electron** ile kıyaslandığında ilk fark tam olarak burada ortaya çıkar. **Electron** kendi **Chromium** motorunu paketin içinde taşırken, **Tauri** işletim sisteminde zaten var olan **WebView** bileşenini kullanır. Bu da paket boyutunda ve bellek tüketiminde ciddi bir fark yaratır.

Ele alacağımız örneği göz önüne alırsak Tauri'nin çalışma prensibini aşağıdaki şekildeki gibi özetleyebiliriz.

![sys-trace Mimarisi](/assets/images/2026/Tauri_Architecture.png)

Önyüz ve arka plan uygulamaları arasında **IPC *(Inter Process Communication)*** mekanizması ile veri alışverişi yapılır. **REST** gibi network katmanına çıkmayı gerektirecek bir iletişim söz konusu değildir, doğrudan IPC'nin avantajlarından yararlanılır. Önyüz için söyleyebileceğimiz önemli detaylardan birisi de işletim sistemine doğrudan temas etmiyor oluşudur. İhtiyaç duyduğu her şeyi Rust tarafından ister. Bu iletişim de temelde iki enstrüman üzerine kuruludur.

- **Commands**: **Javascript** veya **Typescript** tarafından **invoke** fonksiyonu ile `tauri::command` direktifi ile işaretlenmiş Rust fonksiyonları çağırılabilir. `Request/Response` işleyişi her zaman asenkrondur.
- **Events**: Fire and forget mantığında one-to-many şeklinde bir iletişim söz konusudur. Rust tarafından `tauri::event::emit` ile event yayınlanabilir ve önyüz tarafında `window.listen` ile yakalanabilir.

Aradaki iletişimde hareket eden bilgilerin **JSON** formatında serileşebilir olması gerekir. Bu da içeride **serde** küfesinin kullanıldığı anlamına gelir ki yazının ilerleyen kısımlarında bunu bolca göreceğiz.

## Kurulumlar

Ben örnek çalışmayı **Ubuntu 26.04** üzerinde gerçekleştirdim. Sistemimde zaten **Rust**, **Node.js** ve **npm** kurulu. Ancak bunların haricinde özellikle **Linux** tarafında `libwebkit2gtk-4.1-dev` paketinin de kurulu olması gerekiyor. Bu paket **WebKitGTK**'nın geliştirme kütüphanesini içeriyor. **Windows** tarafında kullanılan **WebView2** için ayrıca bir kurulum yapmaya gerek yok, güncel Windows sürümleriyle birlikte geliyor. **macOS** tarafında ise **WKWebView** zaten sistemin bir parçası.

```bash
# Öncelikle gerekli bazı ortam kütüphanelerini yükleyelim.
sudo apt update
sudo apt install libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    file \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev

# Tauri'nin kendisi Node'a ihtiyaç duymaz fakat CLI scaffolding ve Vite dev server ihtiyaç duyar.
# Bu nedenle her ihtimale karşı uyumlu bir node versiyonu kurmakta fayda var. Ben nvm kullandım.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install --lts

# Hemen bir kontrol
node --version
```

Bu paketlerin ne işe yaradığına kısaca bakmakta yarar var. Zira ilk defa karşılaşan birisi için `apt install` satırındaki liste biraz kalabalık görünebilir.

- `libwebkit2gtk-4.1-dev` : WebKitGTK'nın geliştirme kütüphanesi. Bir başka deyişle uygulama için önemli olan WebView'ın ta kendisi.
- `build-essential` : Rust için C toolchain linker.
- `libxdo-dev` : X11 için mouse ve keyboard event'lerini simüle etmek için gerekli kütüphane.
- `libssl-dev` : OpenSSL kütüphanesi. Rust tarafında bazı kriptografik fonksiyonlar için gerekli.
- `libayatana-appindicator3-dev` : Linux tarafında uygulama ikonları için gerekli kütüphane. System tray desteği.
- `librsvg2-dev` : SVG ikonlarının render edilmesi için gerekli kütüphane. Tauri uygulamaları SVG ikonlarını kullanır.

## Projenin Oluşturulması ve İlk Gösterim

Projeyi kurmak oldukça basit. Scaffolding için **Tauri CLI** aracını kullanıyoruz.

```bash
npm create tauri-app@latest
```

**CLI** arabirimi uygulama ile ilgili bize birkaç soru soracaktır. Bu soruları aşağıdaki gibi cevaplayabiliriz.

- **Project name**: sys-trace *(Bu benim verdiğim uygulama adı. Siz başka bir tane verebilirsiniz.)*
- **Identifier**: com.buraks.sys-trace *(Varsayılan olarak sunulanı kabul ettim. Bana biraz Java classpath mantığını hatırlattı.)*
- **Choose which language to use for the frontend**: Typescript
- **Choose your package manager**: npm
- **Choose your UI template**: Vanilla
- **Choose your UI flavor**: Typescript

Bilerek herhangi bir framework seçmedim. Zira odağımızın **React** veya **Svelte** gibi bir tarafa kaymasını şu an için gerek yok. Bu bizim bir nevi *Hello Tauri* uygulamamız. Sonrasında uygulama klasörüne girip gerekli **npm** paketlerini yükleyebilir ve uygulamanın ilk halini çalıştırabiliriz.

```bash
cd sys-trace
npm install

# Uygulamayı çalıştıralım.
npm run tauri dev
```

Karşımıza aşağıdaki gibi bir pencere çıkması lazım.

![sys-trace İlk Çalıştırma](/assets/images/2026/Tauri_Runtime_00.png)

> İlk çalıştırmada büyük ihtimalle **Rust** tarafı gerekli küfeleri *(crates)* yükleyecektir ve bu işlem birkaç dakika sürebilir. Sabırlı olun :D

## Proje İskeleti Hakkında Bilgi

Uygulama çalıştığına göre proje içeriğini biraz tanıyalım. Tabii sonraki sürümlerde değişiklikler olabilir.

- `index.html` : **WebView** giriş noktası *(entry point)*.
- `vite.config.ts` : **Tauri** development server için Vite konfigürasyonu.
- `src` klasörü: Tamamen önyüz tarafı.
- `src-tauri` klasörü: **Rust** tarafı ve ayrı bir crate. Kendi `Cargo.toml` dosyasına sahiptir. Dolayısıyla bu örnekte kullanacağımız **sysinfo** kütüphanesi de buraya eklenir.
- `src-tauri/capabilities` klasörü: **Tauri** uygulamasının hangi yetenekleri kullanacağını belirten manifest dosyaları *(Permission grants)*.
- `lib.rs` ve `main.rs` : İş kurallarımız burada yaşar.

**Rust** tarafında programın çalıştığı sistemden bazı bilgileri toplamak için kullanılan popüler küfelerden birisi **sysinfo** crate'idir. Bunu `src-tauri` klasöründe aşağıdaki gibi yükleyebiliriz.

```bash
cd src-tauri
cargo add sysinfo --no-default-features --features system,disk
```

Buradaki `--no-default-features` kullanımı bilinçli bir tercih. **sysinfo** varsayılan olarak process listesi, network arabirimleri, sıcaklık sensörleri gibi pek çok bileşeni de derlemeye dahil ediyor. Bizim ihtiyacımız sadece sistem ve disk bilgileri olduğundan gereksiz yükten kurtulmuş oluyoruz. Sonuçta kullanmayacağımız enstrümanları paket içerisine almak gereksiz bir şişmeye de neden olacaktır. Bu işlemler sonrasında `Cargo.toml` dosyasında gerekli bağımlılıkları görmeliyiz.

```toml
[package]
name = "sys-trace"
version = "0.1.0"
description = "A simple system dashboard app written with Tauri"
authors = ["Burak Selim Şenyurt"]
edition = "2021"

[lib]
name = "sys_trace_lib"
crate-type = ["staticlib", "cdylib", "rlib"]

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
tauri-plugin-opener = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sysinfo = { version = "0.39.6", default-features = false, features = ["system", "disk"] }
```

`[lib]` bölümüne dikkat edelim. **Tauri**, çekirdek kodu bir kütüphane olarak paketler ve `main.rs` bunu sadece çağırır. Böylelikle aynı kod tabanı mobil hedefler için de kullanılabilir hale gelir.

## Rust Tarafındaki Veri Modeli

Şimdi sıra geldi asıl işi yapan kodları yazmaya. Ben **Rust** tarafını üç parçaya böldüm. Önyüze taşıyacağımız veri modelleri için `metrics.rs`, ölçümleri toplayan fonksiyonlar için `engine.rs` ve **Tauri** ile buluştuğumuz nokta olan `lib.rs`.

İşe olmazsa olmaz veri modelleriyle başlayalım. `src-tauri/src/metrics.rs` dosyasını aşağıdaki gibi oluşturabiliriz. *(Rust dilinde geliştirme yapıyor olsak bile program varlıklarını temsil eden veri modelleri ile çalışmak her zaman iyidir)*

```rust
use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CpuCore {
    pub name: String,
    pub frequency: u64,
    pub usage: f32,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MemorySnapshot {
    pub total: u64,
    pub used: u64,
    pub available: u64,
    pub swap_total: u64,
    pub swap_used: u64,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DiskSnapshot {
    pub name: String,
    pub mount_point: String,
    pub file_system: String,
    pub kind: String,
    pub total_space: u64,
    pub available_space: u64,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Metrics {
    pub global_cpu: f32,
    pub cpu_cores: Vec<CpuCore>,
    pub memory: MemorySnapshot,
    pub disks: Vec<DiskSnapshot>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HostInfo {
    pub name: String,
    pub os: String,
    pub kernel_version: String,
    pub architecture: String,
    pub cpu_brand: String,
    pub physical_cores: Option<usize>,
    pub logical_cores: usize,
}
```

Dosya boyunca tekrar eden iki direktif var. `Serialize`, bu veri yapılarının **JSON**'a dönüştürülebilmesini sağlıyor ki **IPC** hattından geçebilmesi için bu şart diyebilirim. `#[serde(rename_all = "camelCase")]` ile belirtilen **rename_all** değeri ise daha önemli. Rust tarafında `snake_case` yazım tarzını seçiyoruz ve `swap_total` gibi alan adları kullanıyoruz. **Typescript** tarafında ise `camelCase` daha yaygın bir isimlendirme standardı. Bu direktif sayesinde serileştirme sırasında `swap_total` alanı JSON'a `swapTotal` olarak yazılıyor. Yani iki dünyanın da kendi geleneğine sadık kalabiliyoruz *(Biz ayrı dünyaların insanıyız demeye son)* Bu arada `physical_cores` alanını `Option<usize>` olarak tanımladığımı fark etmiş olmalısınız. Zira **sysinfo**, her platformda fiziksel çekirdek sayısını tespit edemeyebilir. Bu bilgi **JSON** tarafında `null` olarak yer alacak, önyüzde de ona göre bir kontrol yapacağız.

## Ölçümleri Toplamak

Veri yapıları hazır olduğuna göre bunları dolduracak fonksiyonları geliştirmeye başlayabiliriz. Bu amaçla `src-tauri/src/engine.rs` isimli bir dosya oluşturup içeriğini aşağıdaki gibi dolduralım.

```rust
use crate::metrics::HostInfo;
use crate::metrics::Metrics;
use sysinfo::{Disks, System};

pub fn get_host_info(sys: &System) -> HostInfo {
    let name = System::host_name().unwrap_or_else(|| "Unknown".to_string());
    let os = System::long_os_version().unwrap_or_else(|| "Unknown".to_string());
    let kernel_version = System::kernel_version().unwrap_or_else(|| "Unknown".to_string());
    let architecture = std::env::consts::ARCH.to_string();
    let cpu_brand = sys
        .cpus()
        .first()
        .map_or("Unknown".to_string(), |cpu| cpu.brand().to_string());
    let physical_cores = System::physical_core_count();
    let logical_cores = sys.cpus().len();

    HostInfo {
        name,
        os,
        kernel_version,
        architecture,
        cpu_brand,
        physical_cores,
        logical_cores,
    }
}
```

`get_host_info` fonksiyonu makine ile ilgili ve çalışma boyunca değişmeyecek bilgileri topluyor. Bu bilgilerin bir kısmına *(host adı, işletim sistemi sürümü, kernel sürümü gibi)* **System** türü üzerinden statik fonksiyonlarla erişebiliyoruz. Hepsi `Option<String>` döndürdüğü için `unwrap_or_else` ile makul bir varsayılan değer veriyoruz. Mimari bilgisini ise **sysinfo**'ya sormaya gerek yok, `std::env::consts::ARCH` sabiti derleme zamanında zaten hedef mimariyi biliyor. Asıl iş yükü ise sürekli çağıracağımız `collect` fonksiyonunda. Bu fonksiyonu da aynı dosyaya ekleyerek devam edelim.

```rust
pub fn collect(sys: &mut System, disks: &mut Disks) -> Metrics {
    sys.refresh_cpu_usage();
    sys.refresh_cpu_frequency();
    sys.refresh_memory();
    disks.refresh(true);

    let cpu_cores = sys
        .cpus()
        .iter()
        .map(|cpu| crate::metrics::CpuCore {
            name: cpu.name().to_string(),
            frequency: cpu.frequency(),
            usage: cpu.cpu_usage(),
        })
        .collect();

    let memory = crate::metrics::MemorySnapshot {
        total: sys.total_memory(),
        used: sys.used_memory(),
        available: sys.available_memory(),
        swap_total: sys.total_swap(),
        swap_used: sys.used_swap(),
    };

    let disks = disks
        .iter()
        .map(|disk| crate::metrics::DiskSnapshot {
            name: disk.name().to_string_lossy().to_string(),
            mount_point: disk.mount_point().to_string_lossy().to_string(),
            file_system: disk.file_system().to_string_lossy().to_string(),
            kind: format!("{:?}", disk.kind()),
            total_space: disk.total_space(),
            available_space: disk.available_space(),
        })
        .collect();

    crate::metrics::Metrics {
        global_cpu: sys.global_cpu_usage(),
        cpu_cores,
        memory,
        disks,
    }
}
```

Fonksiyonun ilk dört satırı konuşmaya değer. **sysinfo** tembel *(lazy)* modda çalışır. Yani `sys.total_memory()` çağrısı gerçek zamanlı bir ölçüm yapmaz bunun yerine en son `refresh` sırasında alınan değeri döndürür. Dolayısıyla her ölçüm turunda ilgili bileşenleri açıkça tazelememiz gerekiyor. Burada da yine sadece ihtiyacımız olanları yeniletiyoruz. Söz gelimi `refresh_all` gibi kapsamlı bir çağrı yapsaydık process listesi de dahil pek çok gereksiz bilgi toplanacaktı ki saniyede bir çalışan bir döngüde bunun maliyeti hiç hoş olmaz.

`disks.refresh(true)` satırındaki `true` değeri ise listede artık görünmeyen diskleri koleksiyondan çıkarmak anlamına geliyor. Uygulama çalışırken bir harici bellek takıp çıkardığımızda listenin doğru güncellenmesini istiyorsak bu parametre işimize yarayacaktır.

Küçük bir uyarı da **CPU** kullanımı hakkında. **sysinfo**, **CPU** kullanım yüzdesini iki ölçüm arasındaki farktan hesaplar. Bu nedenle programın ilk ölçümünde çekirdek değerlerinin sıfır çıkması son derece normaldir. İkinci turdan itibaren gerçek değerler görünmeye başlar. Örneğimizde tazeleme aralığı bir saniye olduğu için kütüphanenin beklediği minimum aralığın da epeyce üzerindeyiz. Ben sorun yaşamadım sizin de yaşayacağını düşünmüyorum.

Son olarak `kind` alanı için kullandığımız `format!("{:?}", disk.kind())` ifadesine değinelim. **sysinfo**, disk türünü `DiskKind` isimli bir **enum** ile veriyor *(HDD, SSD, Unknown)*. Bunu doğrudan serileştirmek yerine `Debug` çıktısını metinsel bilgiye çeviriyoruz. Bu tamamen benim tembelliğimden kaynaklanıyor :D Daha temiz bir yaklaşım olarak `DiskKind` için kendi dönüşüm fonksiyonumuzu yazabilirdik de.

## Uygulama Durumu ve Command'ler

Şimdi geldik **Rust** tarafının **Tauri** ile buluştuğu yere. `src-tauri/src/lib.rs` dosyasında önce uygulama durumunu tutacak yapıyı tanımlayalım.

```rust
mod engine;
mod metrics;

use std::sync::Mutex;
use sysinfo::{CpuRefreshKind, Disks, MemoryRefreshKind, RefreshKind, System};

use crate::metrics::Metrics;

/*
    Uygulamamız çalışırken System ve Disk bilgilerinin sık sık güncellenmesi gerekecek ancak bu iş
    çapraz çağrılarda eş zamanlılık sorunlarına yol açabilir.
    Bu nedenle System ve Disk nesnelerini Mutex ile sarmalayarak eş zamanlı erişimi güvenli hale getiriyoruz.
    Mutex, birden fazla iş parçacığının aynı anda System ve Disk nesnelerine erişmesini engeller
    ve sadece bir iş parçacığına erişim izni verir.

    Command ile işaretlenmiş fonksiyonlar worker thread pool üzerinden çağırıldığı için de
    bu Mutex yapısı, System ve Disk nesnelerine erişimde güvenliği sağlar.
*/
pub struct AppState {
    pub system: Mutex<System>,
    pub disks: Mutex<Disks>,
}

impl AppState {
    fn new() -> Self {
        /*
            Sadece CPU ve bellek bilgilerini izleyeceğiz (track). Diğer sistem bilgilerine ihtiyacımız yok.
            Bu nedenle RefreshKind ile sadece gerekli alanları güncelleyecek şekilde bir yapılandırma yapıyoruz.
        */
        let refresh = RefreshKind::nothing()
            .with_cpu(CpuRefreshKind::everything())
            .with_memory(MemoryRefreshKind::everything());

        Self {
            system: Mutex::new(System::new_with_specifics(refresh)),
            disks: Mutex::new(Disks::new_with_refreshed_list()),
        }
    }
}
```

Burada üzerinde durulması gereken asıl konu **Mutex** kullanımı. Neden ihtiyaç duyduğumuz açıklamaya çalışayım. `System` nesnesini her ölçümde yeniden oluşturmak hem maliyetli hem de anlamsız. Zira **CPU** kullanım yüzdesinin hesaplanabilmesi için bir önceki ölçümün hafızada tutuluyor olması gerekiyor. Dolayısıyla bu nesneyi uygulama ömrü boyunca yaşatmamız lazım. **Tauri** bunun için `manage` fonksiyonuyla kullanabileceğimiz bir durum *(state)* mekanizması sunuyor. Ancak **command** olarak işaretlediğimiz fonksiyonlar bir **worker thread** havuzu üzerinden çağırıldığından, aynı `System` nesnesine birden fazla iş parçacığından erişim ihtimali doğuyor. `Mutex` ile sarmalayarak bu erişimi güvenli hale getiriyoruz. **Rust**'ın bize burada bir kolaylık sağladığını da söylemeliyim zira `Mutex` kullanmasak zaten uygulama kodumuz büyük ihtimalle derlenmeyecekti. *(Fakat siz bana güvenmeyin ve bunu kendiniz deneyip ispatlayın)* `RefreshKind::nothing()` ile başlayıp sadece CPU ve bellek bileşenlerini eklememiz ise `collect` fonksiyonundaki yaklaşımın bir devamı niteliğinde. Bir başka deyişle nesneyi baştan gereksiz bilgi toplamayacak şekilde yapılandırıyoruz.

Sırada önyüzün çağıracağı fonksiyonlar var.

```rust
#[tauri::command]
fn get_metrics(state: tauri::State<'_, AppState>) -> Result<Metrics, String> {
    let mut system = state
        .system
        .lock()
        .map_err(|_| " Sys state poisoned".to_string())?;
    let mut disks = state
        .disks
        .lock()
        .map_err(|_| " Disk state poisoned".to_string())?;
    Ok(engine::collect(&mut system, &mut disks))
}

#[tauri::command]
fn get_host_info(state: tauri::State<'_, AppState>) -> Result<metrics::HostInfo, String> {
    let system = state
        .system
        .lock()
        .map_err(|_| " Sys state poisoned".to_string())?;
    Ok(engine::get_host_info(&system))
}
```

`#[tauri::command]` direktifi ile işaretlenen fonksiyonlar önyüzden `invoke` ile çağırılabilir hale geliyor. Fonksiyon imzasındaki `tauri::State<'_, AppState>` parametresini biz doldurmuyoruz, **Tauri** bunu çalışma zamanında otomatik olarak enjekte ediyor. *(Bir nevi dependency injection gerçekleştiriyoruz diyebilirim)*

Dönüş türü olarak `Result<T, String>` seçilmesinin de bir sebebi var. Bir **command** `Result` döndürdüğünde **Tauri**, `Err` durumunu önyüz tarafında bir **Promise rejection**'a çeviriyor. Böylece Typescript tarafında `try/catch` ile hatayı yakalayabiliyoruz. Hata türü olarak `String` kullanmamızın sebebi serileşebilir olma zorunluluğu. Daha kurumsal bir çalışmada `thiserror` gibi bir küfeyle kendi hata türümüzü tanımlayıp `Serialize` implementasyonunu vermek çok daha şık olacaktır.

Diğer yandan `lock()` çağrısındaki `map_err` kısmına bakmakta da yarar var. Rust'ta bir `Mutex`, kilidi tutan iş parçacığı panic fırlatırsa zehirlenebilir *(poisoned duruma geçer)* Bu durumda `lock()` çağrısı da hata döner. Uygulamamızın kilitlenmesi yerine önyüze anlamlı bir mesaj göndermeyi tercih ediyoruz.

Nihayetinde uygulamayı ayağa kaldıran `run` fonksiyonunu yazarak devam edelim.

```rust
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(AppState::new())
        .invoke_handler(tauri::generate_handler![get_metrics, get_host_info])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

`manage` ile oluşturduğumuz `AppState` örneğini **Tauri**'nin state havuzuna bırakıyoruz. `generate_handler!` makrosu ise önyüzden çağırılabilecek fonksiyonların listesini derleme zamanında oluşturuyor. Buraya eklemeyi unuttuğumuz bir fonksiyonu `invoke` ile çağırmaya kalkarsak çalışma zamanında hata alırız ki bu benim de birkaç kez düştüğüm bir tuzak oldu :D

`main.rs` dosyasını değiştirmemize gerek yok. **Scaffolding** sırasında gelen haliyle bırakabiliriz.

```rust
// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    sys_trace_lib::run()
}
```

> `windows_subsystem = "windows"` özelliği release derlemesinde uygulamanın arkasında bir konsol penceresi açılmasını engeller. Yorum satırındaki uyarıyı ciddiye almakta fayda var.

## Konfigürasyon ve İzinler

Rust tarafı bitti ancak önyüze geçmeden önce iki konfigürasyon dosyasına bakmamız lazım. İlki `src-tauri/capabilities/default.json` ve aşağıdaki içeriğe sahip.

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Capability for the main window",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "opener:default"
  ]
}
```

**Tauri 2** ile gelen izin modeli framework'ün önemli özelliklerinden birisi. Uygulamanın hangi pencerede hangi yetenekleri kullanabileceğini açıkça beyan etmek gerekiyor. Makaledeki örneğimizde ekstra bir izne ihtiyaç yok çünkü sistem bilgilerini bir plugin üzerinden değil kendi yazdığımız command bileşenlerinden alıyoruz. Ancak dosya sistemine erişmemiz veya bir shell komutu çalıştırmamız gerekseydi ilgili izinleri buraya eklememiz gerekecekti. Tahmin edeceğiniz üzere **permissions** tarafı oldukça kritik.

İkinci konfigurasyon dosyası ise `src-tauri/tauri.conf.json`. Pencere boyutları, tema ve güvenlik ayarları burada yapılıyor.

```json
{
  "$schema": "https://schema.tauri.app/config/2",
  "productName": "sys-trace",
  "version": "0.1.0",
  "identifier": "com.buraks.sys-trace",
  "build": {
    "beforeDevCommand": "npm run dev",
    "devUrl": "http://localhost:1420",
    "beforeBuildCommand": "npm run build",
    "frontendDist": "../dist"
  },
  "app": {
    "withGlobalTauri": true,
    "windows": [
      {
        "title": "sys-trace",
        "width": 800,
        "height": 720,
        "minWidth": 560,
        "minHeight": 480,
        "resizable": true,
        "theme": "Dark"
      }
    ],
    "security": {
      "csp": "default-src 'self'; style-src 'self' 'unsafe-inline'"
    }
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ]
  }
}
```

Ben çok fazla şey değiştirmedim ama gördüğünüz gibi bundle paketine eklenecek simgelerden, build aşamasındaki detaylara kadar birkaç şey var. `csp` ayarı ile **WebView**'ın sadece kendi kaynaklarına erişmesine izin veriyoruz. `style-src` için `unsafe-inline` eklenmiş durumda çünkü örnekte inline stiller kullanıyoruz. Üretim ortamına çıkacak bir uygulamada bunu kaldırıp stilleri ayrı bir dosyaya taşımak daha doğru olabilir elbette. `build` bölümünde ise **Tauri**'nin geliştirme sırasında **Vite** sunucusunu nasıl ayağa kaldıracağı ve paketleme sırasında hangi klasördeki çıktıyı kullanacağı belirtiliyor.

## Önyüz Tarafı

Arayüz için **Material Web** bileşenlerini tercih ettim. Kullanabilmek için önce ilgili paketi **npm** ile yüklemek gerekiyor. Ben **npm** dedim ama kuruluma göre **yarn** veya farklı bir alternatif de tercih edilebilir.

```bash
npm install @material/web
```

Ardından `index.html` içeriğini aşağıdaki gibi düzenleyebiliriz. Burada esas olarak bir grid kullanılıyor ve verilerin yerleşeceği alanları `id` ile işaretliyoruz. Hemen önemli bir notu vurgulayalım. Ezelden beri tasarım konusunda beceriksizimdir ve genelde çok zorlanırım. Aşağıdaki arayüz tasarımını tamamen **GPT 5.6 SOL**'a yaptırdım. Sadece **Rust** ile olan ilişkileri kurguladım diyebilirim.

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>System Dashboard</title>
  <script type="module" src="/src/main.ts" defer></script>
</head>

<body>
  <main style="max-width: 1280px; margin: 0 auto; padding: 8px;">
    <div style="display:grid; grid-template-columns: repeat(4, minmax(0, 1fr)); grid-template-rows: repeat(4, auto); gap:8px;">
      <md-elevated-card style="display:block; padding:10px; grid-column: 1 / span 2; grid-row: 1 / span 2;">
        <h2 style="margin: 0;">Summary</h2>
        <h1 id="hostname" style="margin: 6px 0 4px 0;">—</h1>
        <p id="hostmeta" style="margin: 0 0 8px 0;">connecting…</p>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:8px;">
          <md-outlined-card style="display:block; padding:8px;">
            <div>CPU</div>
            <div id="cpu-total">—</div>
          </md-outlined-card>
          <md-outlined-card style="display:block; padding:8px;">
            <div>Memory</div>
            <div id="mem-total">—</div>
          </md-outlined-card>
        </div>
        <p id="loadavg" style="margin: 8px 0 0 0;"></p>
      </md-elevated-card>

      <md-elevated-card style="display:block; padding:10px; grid-column: 3 / span 2; grid-row: 1 / span 2;">
        <h2 style="margin: 0 0 8px 0;">CPU Cores</h2>
        <div id="cores"></div>
      </md-elevated-card>

      <md-outlined-card style="display:block; padding:10px; grid-column: 1 / span 4; grid-row: 3 / span 2;">
        <h2 style="margin: 0 0 8px 0;">Memory &amp; Storage</h2>
        <div style="display:grid; grid-template-columns: 1fr; gap:10px;">
          <div>
            <h3 style="margin: 0 0 6px 0;">Memory</h3>
            <div id="memory"></div>
          </div>
          <div>
            <h3 style="margin: 0 0 6px 0;">Storage</h3>
            <div id="disks"></div>
          </div>
        </div>
      </md-outlined-card>
    </div>
  </main>
</body>

</html>
```

Şimdi `src/main.ts` dosyasına geçelim. Önce Rust tarafındaki veri modellerinin Typescript karşılıklarını tanımlamalıyız. Bu amaçla içeriği aşağıdaki gibi oluşturabiliriz.

```typescript
import { invoke } from "@tauri-apps/api/core";
import "@material/web/all.js";

const REFRESH_MS = 1000;

type CpuCore = { name: string; usage: number; frequency: number };
type MemorySnapshot = {
  total: number; used: number; available: number;
  swapTotal: number; swapUsed: number;
};
type DiskSnapshot = {
  name: string; mountPoint: string; fileSystem: string; kind: string;
  totalSpace: number; availableSpace: number;
};
type Metrics = {
  globalCpu: number; cpuCores: CpuCore[]; memory: MemorySnapshot;
  disks: DiskSnapshot[];
};
type HostInfo = {
  name: string; os: string; kernelVersion: string; architecture: string;
  cpuBrand: string; physicalCores: number | null; logicalCores: number;
};
```

Alan adlarının `camelCase` olduğuna dikkat edelim lütfen. **Rust** tarafında `#[serde(rename_all = "camelCase")]` direktifini kullanmamızın karşılığını burada alıyoruz. `physicalCores` alanının `number | null` olarak tanımlanması da **Rust** tarafındaki `Option<usize>` tür kullanımının bir karşılığı. Zira Typescript tarafına bu şekilde ifade edebiliriz.

Tabii burada dikkat edilmesi gereken bir konu var. Bu tür tanımlarını elle yazdığımızda iki taraf arasında sessiz bir bağımlılık oluşturmaktayız. **Rust** tarafında bir alan adını değiştirdiğimizde **Typescript** tarafı bundan haberdar olmayabilir çünkü değiştirmeyi unutabiliriz ve sorunu ancak çalışma zamanında alacağımız hata sonrası fark edebiliriz. **ts-rs** veya **specta** gibi küfeler **Rust** türlerinden otomatik olarak **Typescript** tür tanımları üretebiliyorlar. Sonraki denemelerde bu küfeleri ele almayı da düşünebilirsiniz. Kodun devamında birkaç yardımcı fonksiyonumuz bulunuyor. Bunlar veriyi ekranda gösterilebilir hale getirmek için kullandığımız parçalar. Her ikisi de **GPT 5.6 SOL** tarafından üretildi. Tasarımı beğenmezseniz kabahat bende değil :D

```typescript
const $ = (id: string) => document.getElementById(id)!;

function gib(bytes: number): string {
  return (bytes / 1024 ** 3).toFixed(1) + " GiB";
}

function band(pct: number): string {
  return pct < 50 ? "calm" : pct < 85 ? "warm" : "hot";
}

function meter(pct: number, label: string, detail: string): string {
  const clamped = Math.min(100, Math.max(0, pct));
  const state = band(clamped);
  const color = state === "calm" ? "#4caf50" : state === "warm" ? "#ff9800" : "#f44336";
  return `
    <div style="display:grid; grid-template-columns: minmax(120px, 1fr) minmax(130px, 1fr) auto; align-items:center; gap:6px; margin-bottom:4px;">
      <div style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${label}</div>
      <md-linear-progress value="${(clamped / 100).toFixed(3)}" style="--md-linear-progress-active-indicator-color:${color};"></md-linear-progress>
      <div style="font-variant-numeric: tabular-nums; white-space:nowrap; font-size:12px;">${detail} · ${clamped.toFixed(1)}%</div>
    </div>`;
}

function coreMeter(c: CpuCore): string {
  const clamped = Math.min(100, Math.max(0, c.usage));
  const state = band(clamped);
  const color = state === "calm" ? "#4caf50" : state === "warm" ? "#ff9800" : "#f44336";
  return `
    <div title="${c.name} · ${c.usage.toFixed(1)}% @ ${c.frequency} MHz" style="display:flex; flex-direction:column; align-items:center; width:20px;">
      <div style="height:92px; width:14px; border-radius:6px; background:#e0e0e0; display:flex; align-items:flex-end; overflow:hidden;">
        <div style="width:100%; height:${clamped}%; background:${color};"></div>
      </div>
      <div style="font-size:11px; margin-top:3px;">${c.name.replace(/^cpu/i, "").trim() || c.name}</div>
    </div>`;
}
```

`gib` fonksiyonu **Rust** tarafından **byte** cinsinden gelen değerleri **GiB**'e çeviriyor. `band` fonksiyonu ise kullanım yüzdesine göre bir renk bandı belirliyor. Buna göre yüzde ellinin altı yeşil, seksen beşin altı turuncu ve üzeri kırmızı renkte. `meter` yatay bir ilerleme çubuğu üretirken `coreMeter` her **CPU** çekirdeği için dikey bir sütun üretiyor. *(Yani şu tasarımı sanıyorum birkaç gün uğraşsam yapamazdım. Ey yüce EyAy sen neymişsin be abi!)*

Şimdi de gelen veriyi ekrana basan fonksiyonlara bakalım.

```typescript
function renderMessage(targetId: string, message: string): void {
  $(targetId).innerHTML = `<p>${message}</p>`;
}

function renderHost(info: HostInfo) {
  $("hostname").textContent = info.name;
  const cores = info.physicalCores
    ? `${info.physicalCores} cores / ${info.logicalCores} threads`
    : `${info.logicalCores} threads`;
  $("hostmeta").textContent =
    `${info.cpuBrand} · ${cores} · ${info.os} · kernel ${info.kernelVersion} · ${info.architecture}`;
}

function render(m: Metrics) {
  $("cpu-total").textContent = m.globalCpu.toFixed(1) + "%";
  $("cores").innerHTML = `
    <div style="display:flex; align-items:flex-end; gap:6px; overflow-x:auto; padding-bottom:2px;">
      ${m.cpuCores.map(coreMeter).join("")}
    </div>`;
  $("loadavg").textContent = "";

  const memPct = (m.memory.used / m.memory.total) * 100;
  $("mem-total").textContent = `${gib(m.memory.used)} / ${gib(m.memory.total)}`;
  const swapPct = m.memory.swapTotal
    ? (m.memory.swapUsed / m.memory.swapTotal) * 100
    : 0;
  $("memory").innerHTML =
    meter(memPct, "RAM", `${gib(m.memory.used)} / ${gib(m.memory.total)} · ${gib(m.memory.available)} free`) +
    (m.memory.swapTotal > 0
      ? meter(swapPct, "swap", `${gib(m.memory.swapUsed)} / ${gib(m.memory.swapTotal)}`)
      : "");

  $("disks").innerHTML = m.disks
    .map((d) => {
      const used = d.totalSpace - d.availableSpace;
      const pct = (used / d.totalSpace) * 100;
      const tag = `${d.name} · ${d.mountPoint} · ${d.fileSystem} · ${d.kind}`;
      return meter(pct, tag, `${gib(used)} / ${gib(d.totalSpace)}`);
    })
    .join("");
}
```

`renderHost` fonksiyonunda `physicalCores` değerinin `null` gelebileceğinin hesaba katıldığını fark etmiş olmalısınız. Değer yoksa sadece mantıksal çekirdek sayısı gösteriliyor. `render` fonksiyonunda ise takas alanı *(swap)* için de bir kontrol var. Swap tanımlı değilse o satır hiç çizilmiyor. Nihayet en can alıcı kısma geldik. **IPC** hattının kullanıldığı yer...

```typescript
async function tick() {
  try {
    render(await invoke<Metrics>("get_metrics"));
  } catch (err) {
    $("hostmeta").textContent = `sampling failed: ${err}`;
    renderMessage("cores", "Unable to fetch processor metrics.");
    renderMessage("memory", "Unable to fetch memory metrics.");
    renderMessage("disks", "Unable to fetch storage metrics.");
  }
  setTimeout(tick, REFRESH_MS);
}

async function start() {
  try {
    renderHost(await invoke<HostInfo>("get_host_info"));
  } catch (err) {
    $("hostmeta").textContent = `could not read host info: ${err}`;
  }
  tick();
}

start();
```

`invoke<Metrics>("get_metrics")` çağrısındaki metin ifadesi, **Rust** tarafındaki fonksiyonun adıyla birebir aynı olmak zorunda. Bu da biraz önce değindiğimiz sessiz bağımlılığın bir başka örneği. Generic parametre olarak verdiğimiz `Metrics` türü ise sadece Typescript'in derleme zamanındaki bilgisi. Yani gelen **JSON** içeriği gerçekten çalışma zamanında doğrulanmıyor. Bu nedenle **IPC** hattından ne geldiğine dikkat etmemiz gerekiyor. Döngü için `setInterval` yerine `setTimeout` kullanılıyor. Böylece bir sonraki ölçüm ancak mevcut ölçüm tamamlandıktan sonra planlanıyor. `setInterval` kullanmayı tercih etseydik ölçüm herhangi bir sebeple bir saniyeden uzun sürdüğünde çağrıların üst üste binmesi söz konusu olabilirdi. Yine de bunu bir denemekte yarar var.

`start` fonksiyonu değişmeyen host bilgilerini bir kez alıp ekrana yazıyor ve ardından döngüyü başlatıyor. Buradaki hata yakalama bloğu da kayda değer. **Rust** tarafındaki command'ler `Result` döndürdüğü için `Err` durumu buraya bir **exception** olarak düşüyor ve en azından kullanıcıya durumla ilgili bir mesaj gösterilebiliyor.

## Çalışma Zamanı *(Runtime)*

Rust tarafındaki geliştirmeler ile önyüz tarafı bittikten sonra çalışır bir örnekle karşılaşmış oldum. Sizde de benzer sonuçların çıkması gerekiyor.

![sys-trace Çalışma Zamanı](/assets/images/2026/Tauri_Runtime_01.png)

## Paketleme *(Building)*

Uygulama geliştirmelerini tamamladıktan sonra bir `deb` paketi oluşturabiliriz. Bunun için aşağıdaki komutu çalıştırmamız yeterli.

```bash
npm run tauri build

# Yukarıdaki işlem sonrasında bundle/deb ve bundle/appImage klasörleri oluşacaktır.
# Bu klasörler altında paketlenmiş uygulamayı bulabiliriz.

# Kurulum da oldukça basittir.
sudo dpkg -i src-tauri/target/release/bundle/deb/sys-trace_0.1.0_amd64.deb
sys-trace

# Ya da AppImage olarak çalıştırabiliriz.
chmod +x src-tauri/target/release/bundle/appimage/sys-trace-0.1.0_amd64.AppImage
./src-tauri/target/release/bundle/appimage/sys-trace-0.1.0_amd64.AppImage
```

> Aynı kod tabanını **Windows** tarafında da denedim. Rust ve Typescript kodlarında tek bir satır değiştirmeye gerek kalmadı. Yalnız `package.json` içerisine platforma özel CLI paketinin *(`@tauri-apps/cli-win32-x64-msvc`)* eklenmesi gerekti. Paketleme komutu tamamen aynı. `npm run tauri build` çağrısı bu sefer `deb` yerine `msi` ve `exe` çıktıları üretmeli. Tabii çapraz platform derleme yapmadığımızı, her platformda ayrı ayrı derlediğimizi hatırlatmam gerekiyor. Yani Windows kurulum paketi için bir Windows makineye ihtiyacımız var gibi.

## Sonuç

**Tauri** ile ilk kez bir uygulama geliştirmiş oldum. Tasarım aşamasına kadar yani Rust tarafında kaldığım sürece epey keyifliydi. Yine de zamanın **Delphi** ve **Windows Forms** arayüzlerindeki sürükle bırak rahatlığının olmadığını açıkça itiraf etmeliyim. Bileşenleri bir pencereye görerek bırakmakla tasarımı HTML seviyesinde veya karman çorman CSS stilleri ile *(her ne kadar modern framework'ler ile bu kolaylansa da)* yapmak zorunda kalmak can sıkıcı. Bu macera ile ilgili sonuçları da şöyle bırakalım öyleyse.

- Sorumlulukların ayrımı çok net *(Seperation of Concerns olmuş diyebilir miyiz?)*. İşletim sistemine dokunan her şey **Rust** tarafında, görsellik ise tamamen web dünyasında kalıyor. Bu ayrım önyüz tarafında hangi teknolojiyi seçersek seçelim arka planın değişmemesi anlamına da gelmekte ve pek tabii arka planda **Rust** dilinin güvenli ve yüksek performans vaat eden yapısından faydalanabiliyoruz.
- İzin modeli *(capabilities)* uygulamanın neye erişebileceğini açıkça beyan etmemizi zorunlu kılıyor. Yazılımın güvenliği açısından oldukça değerli.
- İki dünya arasındaki tür eşleşmesini bu örnekte elle yaptık ve bu insan hatasına açık. Rust tarafındaki bir alan adı değişikliğinin önyüzü sessizce bozması pekala mümkün. **[ts-rs](https://crates.io/crates/ts-rs)** veya **[specta](https://crates.io/crates/specta)** gibi çözümlere bakmakta fayda var.
- Bu örnekte veriyi önyüzden istiyoruz yani **Command** yaklaşımını kullandık. Halbuki metrikleri **Rust** tarafında bir arka plan thread'inde toplayıp **Event** ile yayınlamak daha yerinde bir tasarım olabilir ki bu yönde telkinler de var. Böylece güncelleme sıklığını önyüzün insafına bırakmamış oluruz. *(Bunu bir sonraki denemeye not alıyorum.)*

Elbette eksikler de var. Uygulamanın bir grafik geçmişi yok bir başka deyişle **CPU** kullanımının son otuz saniyedeki seyrini göremiyoruz örneğin. **System tray** desteği eklemedik ki bu tür bir aracın arka planda çalışıp ihtiyaç halinde açılması çok daha mantıklı olacaktır. Network arabirimleri ve process listesi de tamamen kapsam dışında bırakıldı. Bunları tek tek ele almak yerine öncelikle framework'ü tanımaya odaklandığımız bir örnek üzerinde çalıştık diyebilirim. Belki ilerleyen zamanlarda bu eksikleri de tamamlarız.

Böylece geldik bir çalışmamızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[Örnek kodlara github üzerinden ulaşmak için tıklayınız.](https://github.com/buraksenyurt/rust-farm/tree/main/handson/sys-trace)

[Orijinal Kaynak](https://www.buraksenyurt.com/post/tauri-ile-masaustu-uygulama-gelistirme)
