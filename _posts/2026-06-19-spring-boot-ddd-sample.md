---
layout: post
title: "Spring Boot ile Basit Bir DDD Projesi"
date: 2026-06-19 18:00:00
tags:
    - spring-boot
    - domain-driven-design
    - java
    - microservices
    - hexagonal-architecture
    - software-architecture
    - clean-code
    - enterprise-applications
    - sonarqube
    - docker-compose
    - postgresql
    - maven
categories:
    - Programlama Dilleri
---
Kendimi bildim bileli **C#** programlama dili ile geliştirme yapıyorum. Hobi amaçlı ilgilendiğim **Rust**, **Zig** ve **OCaml** dillerini saymazsak profesyonel iş hayatım **.NET** ekosistemi üzerinde geçti. Çok uzun yıllar önce ise Java programlama dilini öğrenmeye çalışmış ve bu vesile ile `Java ile 24 Kahve Molası` isimli bir seri yazmıştım. 2004 yılında yazdığım makaleleri derleyip bir doküman haline de getirmiştim ki [buradan](https://www.buraksenyurt.com/post/Java-ile-24-Kahve-Molasc4b1-Dokumanc4b1) erişebilirsiniz. Tabii aradan yıllar yıllar geçti. Yazılım geliştirme dünyası sürekli değişti ama bazı temel kavramlar ve ilkeler hala aynı. Nesne yönelimli dil prensipleri, SOLID ilkeleri, tasarım kalıpları, yazılım mimarileri halen daha programlama dilleri ve platformlara referans oluyor. İş dünyası çözümleri ve kurumsal projeler bu felsefeler üzerine inşa ediliyor. Sözü fazla uzatmadan bu yazıda nelerden bahsedeceğimize gelelim.

Amacım Domain Driven Design *(DDD)* yaklaşımını yine hafifsiklet bir senaryo ile olabildiğince basit bir şekilde ele almak *(CQRS, Event Sourcing, Message Bus gibi konuları sonraya bırakıyorum)* ancak bu sefer **Java** programlama dilini ve **Spring Boot Framework** kullanacağım. Başlarken **Java** dilinde duayen olan arkadaşlarımın affına sığınıyorum zira bir C# geliştiricisi personasıyla olaylara yaklaşacağım. Dolayısıyla Java'nın ve Spring Boot'un bazı niş yeteneklerini atlayabilirim. Bu konuda yorumlarla bana ve okurlarımıza destek olabilirsiniz. Öyleyse başlayalım.

## Senaryo

Bilgisayar oyunu kiralayabildiğimiz bir sistem üzerinde duracağız. Artık böyle bir devri yaşamıyoruz tabii ki ama zamanında **Commodore 64** oyunları kiraladığımızı ve hatta bildiğiniz ya da bilmediğiniz doksanlık müzik kasetlerine oyunlar yüklettiğimizi hatırlıyorum. Öğrenme amaçlı kullanabileceğimiz keyifli bir senaryo olabilir. Tabii **Domain Driven Design** denince işin içerisine giren bazı önemli unsurlar var. Bunlardan birisi herkesin söz konusu çözüm için kullandığı ortak dil. Denizcilik alanında bir şeyler yazıyorsak kullanacağımız jargon ile oyun geliştirme sahasındaki jargon tamamen farklı olacaktır. Bu jargon genellikle **Ubiquitous Language** olarak anılır ve program kodu içerisindeki enstrümanların isimlendirilmesinde hayati önem arz eder. Tabii bunu oluşturmak için aslında kullanıcı hikayelerini detaylıca dinlemek ve senaryolaştırmak gerekir. Biz çok basit birkaç cümleyi baz alalım.

- Oyunların her biri kataloğumuzda birer isim *(Pacman, Super Mario,...)* olarak varlığını sürdürür. Mağazamızda oyun kutularından n adet olabilir.
- Sistemde abonelerimiz vardır *(Bu demoda aboneleri sadece bir ID olarak tanımlayacağız)*
- Abonelerimiz oyun kiralayabilirler ancak bir kiralama süresi vardır. Kiralanan oyunlar belli bir sürede geri getirilir.
- Abone, kiraladığı oyunu geri getirdiğinde kiralama sona erer ve oyun tekrar mağazada kiralanabilir hale gelir. Ama gecikme olursa bu gecikme süresi kadar ekstra ücret ödenir. Örneğin gecikilen gün başına 2.5 TL ceza ödemek gibi.

Bu cümlelerden aslında belli başlı iş kuralları da ortaya çıkar. Örneğin;

- Mağaza stoğunda olmayan bir oyun kiralanamaz.
- Oyun kiralandığında kullanılabilir oyun sayısı 1 azalır, geri getirildiğinde 1 artar.
- Bir kiralama iki kez geri getirilemez.
- Gecikme ücreti için şu formül geçerlidir: `gecikme ücreti = gecikilen gün sayısı * 2.5 TL`

Buradaki basit iş kuralları domain model içerisinde yaşar ve asla atlanamaz *(No Bypass)*. Böylece iş kurallarımızın her zaman geçerli olmasını garanti edebiliriz. DDD yaklaşımında domain'i dış etkenlerden izole etmek çok önemlidir. Bana göre domain modelimiz first citizen' dir.

## DDD Özeti

DDD daha çok iş modelini kodun tam merkezine yerleştirmeye odaklanmış bir yaklaşımdır. Bu sayede iş kuralları ve mantığı, programın her yerinde tutarlı bir şekilde uygulanabilir. Ayrıca framework, veritabanı ve benzeri altyapı detaylarını dışarıda tutarak iş modelinin bağımsız ve test edilebilir olmasını hedefler. Bu örnek özelinde ele alacağımız kavramları aşağıdaki tablo ile özetleyebiliriz...

| **Kavram** | **Ne anlama gelir?** | **Bizim örneğimizde neye karşılık gelir?** |
| --- | --- | --- |
| **Ubiquitous Language** | Tüm ekip *(Geliştiriciler, İş Analistleri, Test Uzmanları, vb.)* tarafından paylaşılan ortak dil. | Game, Rental, lateFee, returnOn vb |
| **Value Object** | Kimliği olmayan, sadece değerleriyle tanımlanan nesneler. Değiştirilemezdirler. *(Immutable)* | Money, GameId gibi |
| **Entity** | Kimliği olan, yaşam döngüsü boyunca değişebilen nesneler. | Game, Rental gibi |
| **Aggregate** | Birbirleriyle ilişkili Entity ve Value Object'lerin bir araya gelerek oluşturduğu tutarlı bir bütün. | RentalAggregate, GameAggregate gibi |
| **Aggregate Root** | Aggregate'in dış dünya ile olan tek giriş noktasıdır. | RentalAggregate'in root'u Rental, GameAggregate'in root'u Game gibi |
| **Repository** | Aggregate'lerin saklanması ve erişilmesi için kullanılan koleksiyon benzeri aggregate yapıları. | RentalRepository, GameRepository gibi |
| **Domain Service** | Birden fazla Entity veya Value Object'in etkileşimde bulunduğu karmaşık iş mantığını içeren servisler. | Bu örnekte ele almayacağız. |
| **Application Service** | Bir transaction *(Use Case)* orkestrasyonunu yöneten servis. | RentGameService, GameCatalogService gibi |

## Proje Mimarisi

Projede oldukça yalın düşünerek hareket edebiliriz ve katmanlı *(layered)* bir mimari modeli kullanabiliriz. Biraz ucundan da olsa **hexagonal mimari** ilkelerine göre inşa edebiliriz. Altın kural bağımlılıkların yönünün *(Dependency Direction)* doğru uygulanması. Örneğin domain paketi sıfır framework bağımlılığına sahip olmalı ki domain modelindeki iş kurallarını çok kısa sürelerde hiçbir dış framework bağımlılığı olmadan değiştirebilelim veya test edebilelim. Bu sayede domain modelimizi daha esnek ve sürdürülebilir bir hale getirebiliriz. Mimari kurguyu kabaca aşağıdaki şekilde olduğu gibi özetleyebiliriz.

![DDD Basic](/assets/images/2026/JDDDBasic.png)

> **Küçük bir not:** Ben bu projeyi bir **Linux** platformunda *(Ubuntu 26.04)* geliştiriyorum ancak aynı prensipler diğer platformlar için de geçerlidir.

## Proje İskeletinin Oluşturulması

Bir .NET geliştiricisi olarak normalde bir **solution** açıp projeleri tek tek içerisinde oluştururuz. İhtiyacımız olan bağımlılıkları ise projelere göre ekleriz. Java dünyasında bu tür işlemler ve özellikle bağımlılıkların en ideal şekilde tesis edilmesi uzun zamandır **Spring Framework** gibi araçlarla etkili bir şekilde yapılmakta. Benzer şekilde hareket edeceğiz. **Spring Boot** proje oluşturma aracı olan [Spring Initializr](https://start.spring.io/) adresini kullanarak uygulama iskeletini ve tüm gereklilikleri hazırlayabiliriz. Ama aynı işlemleri **curl** komutu ile terminalden de yapabiliriz.

![Spring Boot Initializr](/assets/images/2026/JDDDSpringBootInit.png)

Özellikle kendi sistemimizde hangi **Java** ve **Maven** versiyonları olduğuna dikkat etmekte yarar var. Zira versiyon parametleri uyumlu olmalı. Resimde görülen işlemleri **curl** komutu ile terminalden yapmak istersek de aşağıdaki gibi hareket edebiliriz.

```bash
curl https://start.spring.io/starter.zip \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.5.15 \
  -d javaVersion=25 \
  -d groupId=com.example \
  -d artifactId=game-rental \
  -d name=game-rental \
  -d packageName=com.example.gamerental \
  -d dependencies=web,data-jpa,postgresql,validation,flyway \
  -o game-rental.zip

unzip game-rental.zip -d game-rental
cd game-rental
```

Dikkat edileceği üzere proje oluşturulurken bazı bağımlılıklar *(dependencies)* da ekledik. Hangisini ne için kullandığımızı özetleyelim.

| **Paket** | **Ne işe yarar?** |
| --- | --- |
| **Spring Web** | REST API geliştirmek için gerekli olan Spring MVC altyapısını sağlar. Tomcat gibi gömülü bir web sunucusu içerir. |
| **Spring Data JPA** | ORM *(Object-Relational Mapping)* işlemleri için gerekli altyapıyı sağlar. JPA *(Java Persistence API)* standartlarını kullanarak veritabanı işlemlerini kolaylaştırır. |
| **PostgreSQL Driver** | PostgreSQL veritabanına bağlanmak için gerekli sürücüyü sağlar. |
| **Spring Validation** | Bean Validation API'sini kullanarak veri doğrulama işlemlerini kolaylaştırır. |
| **Flyway** | Veritabanı şemasını yönetmek ve sürüm kontrolü sağlamak için kullanılan bir araçtır. Migrations işlemlerini kolaylaştırır. |

## Proje Oluşturulduktan Sonra Bazı Ayarlamalar

Proje oluşturulduktan sonra **PostgreSQL** desteği için yeni bir **flyway** bağımlılığı *(dependency)* eklememiz de gerekebilir. Bunun için tüm proje ayarlarını içeren `pom.xml` dosyasına aşağıdaki bağımlılığı eklemek yeterli olacaktır. Daha önceden eklediğimiz bağımlılıklar da bu dosyada yer alır.

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-database-postgresql</artifactId>
</dependency>
```

Eğer projeyi komut satırından oluşturduysak konfigurasyon dosyası *(application.properties)* **YAML** formatında oluşmamış olabilir. Bu dosyayı silip `application.yml` isimli yeni bir dosya oluşturup içeriğini aşağıdaki şekilde düzenleyebiliriz. *(Dosya `src/main/resources` dizininde olmalıdır.)* Bu şart değil ancak yml formatında daha okunabilir ve hiyerarşik bir yapı sağladığı için tercih ediyorum. Tabii ki bu tamamen kişisel bir tercih.

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/gamerental
    username: gamerental
    password: secret

  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
    properties:
      hibernate:
        format_sql: true

  flyway:
    enabled: true

logging:
  level:
    org.hibernate.SQL: debug
```

Dikkat edileceği üzere veritabanı bağlantı bilgisi, hibernate ve flyway ayarları yapılıyor. Bu ayarlara göre JPA *(Java Persistence API)* nesneleri ORM tarafında **hibernate** kullanacak ve veritabanı şeması **flyway** ile yönetilecek. Ayrıca loglama seviyesini debug olarak ayarladık ki SQL sorgularını loglarda görebilelim *(Bunu sadece development aşamasında açmak ama üretim ortamında kapatmak iyi bir pratiktir.)*. Son olarak `ddl-auto` değerini **validate** olarak ayarladık. Bu sayede JPA, uygulama başlatıldığında veritabanı şemasını kontrol edecek ve eğer tablolar eksikse veya hatalıysa uygulama başlatılmayacaktır. Bu sayede veritabanı şemasının her zaman güncel ve doğru olmasını garanti edebiliriz.

## Migration Hazırlıkları

Migration işlemleri için `src/main/resources/db/migration` klasöründe `V1__init.sql` isimli bir dosya oluşturalım ve içeriğini aşağıdaki gibi hazırlayalım. Bu basit çalışma için çoğul eki *(plural)* formatında isimlendirilmiş **games** ve **rentals** tabloları yeterli olacaktır.

```sql
CREATE TABLE games (
    id               UUID         PRIMARY KEY,
    title            VARCHAR(100) NOT NULL,
    platform         VARCHAR(50)  NOT NULL,
    total_copies     INT          NOT NULL,
    available_copies INT          NOT NULL
);

CREATE TABLE rentals (
    id                 UUID          PRIMARY KEY,
    game_id            UUID          NOT NULL,
    member_id          UUID          NOT NULL,
    rented_on          DATE          NOT NULL,
    due_on             DATE          NOT NULL,
    returned_on        DATE,
    status             VARCHAR(20)   NOT NULL,
    late_fee_amount    NUMERIC(10,2) NOT NULL,
    late_fee_currency  VARCHAR(3)    NOT NULL
);

CREATE INDEX idx_rentals_game_id ON rentals (game_id);
```

DDD tasarımında her aggregate kendi tutarlı bütünlüğünü korumaktan sorumludur. Genellikle bir aggregate diğer aggregate'lere ID ile referans verir. Bu nedenle herhangi bir **foreign key constraint** kullanmamıza gerek yok. Böylece aggregate'ler birbirlerinden bağımsız olur ve aggregate root'lar kendi aggregate'lerini yönetebilirler. Zaten **foreign key constraint** kullandığımızda aggregate'ler DB seviyesinde birbirlerinin yaşam döngüsüne bağımlı hale gelir ve bu DDD tasarımına aykırıdır.

## Docker-Compose Olmadan Asla

Pek çok kişisel ve uzun soluklu çalışmamdan alışılageldiği üzere burada da bir **docker-compose** dosyası ile **PostgreSQL** veritabanını ve varsa başka gereklilikleri ayağa kaldırmayı tercih ediyorum. İşte `docker-compose.yml` içeriğimiz;

```yaml
services:

  postgres:
    image: postgres:latest
    container_name: spring-postgres
    environment:
      POSTGRES_USER: johndoe
      POSTGRES_PASSWORD: somew0rds
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql
    networks:
      - spring-network

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: spring-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: scoth@tiger.com
      PGADMIN_DEFAULT_PASSWORD: 123456
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - spring-network

  sonarqube:
    image: sonarqube:community
    container_name: spring-sonarqube
    restart: unless-stopped
    stop_grace_period: 1h
    ports:
      - "9000:9000"
    environment:
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions

volumes:
  postgres_data:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:

networks:
  spring-network:
    driver: bridge
```

Haftasonu yapabileceğiniz türden olan bu tip çalışmalarda ideal bir pratik olduğunu düşünüyorum. İşiniz bitince konteynerleri kapatır veya silersiniz. Tavsiye edeceğim bir diğer alışkanlıksa temiz kod prensiplerine uymak ve teknik borcu en başından itibaren kontrol altına almak. Bu nedenle **Sonarqube** servisini de **docker-compose** içerisine ekledim. Sizden sonraki yazılımcıyı düşünerek kod yazın lütfen :D Konteynerleri ayağa kaldırmak için terminalden aşağıdaki komutu kullanabiliriz.

```bash
sudo docker-compose up -d
```

## Uygulama Kodlarımız

Artık sırasıyla uygulama içerisindeki gerekli enstrümanları yazmaya başlayabiliriz. Tabii artık Java dünyasındayız. Efsane paket sistemi URL benzeri bir yapıya sahip. Bu proje açısından baktığımızda root paketimiz `com.example.gamerental` şeklinde. Diğer tüm alt modülleri bu paket altına açacağız. Kabaca aşağıdaki gibi bir dizin yapısı oluşturmamız gerektiğini ifade edebiliriz.

![Project Skeleton](/assets/images/2026/JDDDSkeleton_00.png)

Yazıyı çok fazla uzatmaması için kod dosyalarının içeriklerini buraya eklemedim. Dolayısıyla sizi güzel bir mücadele bekliyor. Kodları ve projeyi [buradan](https://github.com/buraksenyurt/enterprise-patterns-with-java/tree/main/src/DDD) çekip inceleyebilir veya sıfırdan kendi senaryonuzla yazabilirsiniz. Kod dosyalarına olabildiğince yorum satırı ekledim umarım anlaşılır olur.

## C# Geliştiricileri Açısından

Bu çalışma özelinde bir karşılaştırma tablosu da eklemek isterim. Kodları yazarken veya yazdıktan sonra işinize yarayabilir. En azından Java tarafında kullandığımız enstrüman veya kavramlar C# tarafında neye karşlık geliyor özetleyebiliriz.

| **Mesele** | **.NET/C#** | **Java/Spring Boot** |
| --- | --- | --- |
| **Proje oluşturma** | dotnet new CLI | Spring Initializr veya curl |
| **Bağımlılık yönetimi** | .csproj içinde NuGet | pom.xml içinde Maven |
| **ORM** | Entity Framework Core | Spring Data JPA + Hibernate |
| **Migration** | EF Core Migrations | Flyway |
| **Value Object** | record | record |
| **Entity kimliği** | Dahili Guid desteği | UUID sınıfı |
| **Çalıştırma** | dotnet run | mvnw spring-boot:run |
| **Test Framework** | xUnit, NUnit, MSTest | JUnit 5 |
| **Inheritance** | `:` operatörü | `extends` |
| **Interface uygulama** | `:` operatörü | `implements` |
| **Paket kavramı** | GameRental şeklinde namespace | com.example.gamerental şeklinde package |
| **Class Yerleşimi** | Bir dosya içinde birden fazla class olabilir | Her class kendi java dosyasında olmalı |
| **Opsiyonel değerler** | Nullable reference types, `?` operatörü | `Optional<T>` sınıfı |

Bununla birlikte kodlarda Spring Boot dünyasından gelen birçok anotasyon *(annotation)* kullanımı var. Bunlarla ilgili bir eşleştirmeyi de aşağıdaki tabloda bulabilirsiniz.

| **Konu** | **Spring/Java** | **.NET/C#** |
| --- | --- | --- |
| Bir şeyin Entity olduğunu belirtmek | `@Entity` | Genelde bir Entity sınıfından türetmek |
| DB tarafındaki tabloyu belirtmek | `@Table` | `[Table]` |
| Bir entity alanının identity olduğunu belirtmek | `@Id` | `[Key]` |
| Bir entity alanının enum olduğunu belirtmek | `@Enumerated` | `[EnumDataType]` |
| Repository olarak kullanılacağını belirtmek | `@Repository` | Repository deseni ve DbContext |
| Service olduğunu belirtmek | `@Service` | Tam karşılığı yok sanırım |
| Transaction yönetimine dahil olduğunu söylemek | `@Transactional` | TransactionScope veya DbContext üzerinden Transaction yönetimi |
| Doğrulama (Validation) | `@Valid` | `[Required]`, `[Range]` gibi Data Annotation'lar |
| Üst tür metodunu ezmek | `@Override` | `override` anahtar kelimesi |
| REST türünden bir controller | `@RestController` | `[ApiController]` |
| Request mapping | `@RequestMapping` | `[Route]` |
| Request body | `@RequestBody` | `[FromBody]` |
| Path variable | `@PathVariable` | `[FromRoute]` |
| HTTP Post, Get, Put, Delete gibi aksiyonlar | `@PostMapping`, `@GetMapping`, `@PutMapping`, `@DeleteMapping` | `[HttpPost]`, `[HttpGet]`, `[HttpPut]`, `[HttpDelete]` |

Arada kaçırdıklarım olabilir ancak **Spring Boot** çatısının birçok anotasyon ile işimizi kolaylaştırdığını söyleyebilirim. Sanıyorum ki boilerplate kod yazmak zorunda kalmıyoruz.

## Çalışma Zamanı

Projeyi tamamladıktan sonraki olası sonuçlarımı paylaşarak devam edelim. Beni en çok düşündüren şeylerden birisi nasıl **build** alacağım veya çalıştıracağım idi. .NET tarafında **dotnet**, rust dünyasında **cargo** gibi tekil araçlara alıştığım için Java tarafındaki **maven**, **gradle** gibi araç çokluğu biraz kafa karıştırıcı olabiliyor. Ancak ne nihyatetinde hedefim projeyi çalıştırmak olduğundan detaylarda çok fazla boğulmadan ilerledim ve aşağıdaki **maven** komutu ile projeyi başlattım. Tabii **postgresql** konteynerinin çalışır durumda olduğundan emin olmalıyız ve söz konusu komutu projenin kök dizininde işletmeliyiz.

```bash
# Derleme için
./mvnw compile

# Doğrudan çalıştırmak için
./mvnw spring-boot:run
```

Başlangıçta `V1__init.sql` dosyasındaki SQL scriptleri çalışacak ve veritabanında gerekli tablolar oluşturulacaktır. Daha sonra API endpoint'lerine *(interfaces katmanındaki Controller sınıflarımız)* aşina olduğumuz HTTP isteklerini göndererek uygulama çıktılarını sorgulayabiliriz. İşte birkaç deneme;

Tabii işin gereği kiralanacak oyunlar lazım. Efsanelerden Super Mario'yu kataloğumuza ekleyerek testlere başlayabiliriz.

```bash
curl -X POST http://localhost:8080/api/games \
  -H "Content-Type: application/json" \
  -d '{
        "title": "Super Mario",
        "platform": "NINTENDO_SWITCH",
        "totalCopies": 5
      }'
```

![Runtime 00](/assets/images/2026/JDDDRuntime_00.png)

ve şimdi de bir oyun kiralayalım. Tabii tam bir abonelik sistemimiz olmadığı için abone ID bilgisini kendimiz veriyoruz. Game ID değeri içinse bir önceki denemede eklediğimiz ID değerini kullanabiliriz.

```bash
curl -s -X POST http://localhost:8080/api/rentals \
  -H 'Content-Type: application/json' \
  -d "{\"gameId\":\"3c23c76e-3902-40c6-8424-366196f669ca\",\"memberId\":\"de4b0278-b1fd-4dc1-a05b-2509107fd49b\",\"rentalDays\":10}"
```

Şimdide kullanılabilecek oyun kopya sayısını kontrol edebiliriz.

```bash
curl -s http://localhost:8080/api/games/3c23c76e-3902-40c6-8424-366196f669ca
```

![Runtime 01](/assets/images/2026/JDDDRuntime_01.png)

Abonemizin oyunu çok sevdiğini ve birkaç gün geç iade ettiğini düşünelim. Bunu simüle etmek için aşağıdaki gibi ilerleyebiriz.

```bash
# Önce iade tarihini bugünden 15 sonraya ayarlayalım ki gecikme ücreti oluşsun.
LATE_DATE=$(date -d "+ 15 days" +%F)

# Bu çağrı sonrasında bir gecikme ücreti oluşmasını bekliyoruz.
curl -s -X POST http://localhost:8080/api/rentals/040cf074-9fc2-4480-9cc5-10a258efe7df/return \
  -H 'Content-Type: application/json' \
  -d "{\"returnDate\":\"$LATE_DATE\"}"

# Son olarak oyun bilgilerini tekrar kontrol edelim. Kiralama sona erdiği için kullanılabilir oyun sayısının tekrar 5 olduğunu görmemiz lazım.
curl -s http://localhost:8080/api/games/3c23c76e-3902-40c6-8424-366196f669ca
```

![Runtime 02](/assets/images/2026/JDDDRuntime_02.png)

Son olarak birde dükkana geri dönen bir oyunu tekrar döndürmek istediğimiz almamız gereken Conflict hatasına bakalım.

```bash
curl -i -s -X POST http://localhost:8080/api/rentals/040cf074-9fc2-4480-9cc5-10a258efe7df/return \
  -H 'Content-Type: application/json' -d '{}'
```

![Runtime 03](/assets/images/2026/JDDDRuntime_03.png)

## Testler

API noktaları sorunsuz çalışıyor gibi ama kurumsal çapta bir projenin olmazsa olmazlarından birisi de elbetteki birim testler *(Unit Tests)*. Birim testler **Code Coverage** açısından önemlidir. Bu sayede kodun hangi parçalarının test edildiği yani üzerinden geçilerek sağlamasının yapıldığı yüzdesel olarak ölçülebilir ki bu kodun güvenilirliğinin bir garantisidir. Projemizdeki testler `test/java/com/example/gamerental` dizininde yer almaktadır. Örnek olması açısından **Game** ve **Rental** nesnelerinin domain bazlı iş kurallarını test ediyoruz. Projedeki tüm testleri çalıştırmak için kök dizindeyken aşağıdaki komutu kullanmamız yeterli.

```bash
./mvnw test
```

![Runtime 04](/assets/images/2026/JDDDRuntime_04.png)

## Sonarqube ile Kod Taraması

Dilerseniz birde yazdığımız kod tabanının röntgenini çekip projenin sağlık durumunu kontrol edelim. Öncelikle `docker-compose.yml` içerisinde tanımladığımız **Sonarqube** servisinin çalıştığından emin olalım. Ayarlarımıza göre `localhost:9000` adresine gidip Sonarqube arayüzüne ulaşabiliyorsak her şey yolunda demektir. Sonrasında aşağıdaki adımları takip edebilirz.

- `Create a local project` ile ilerleyelim: **Project display name** ve **Project key** değerlerini **game-rental** olarak belirleyebiliriz. Bir değişiklik yoksa **Main branch name** değerini **main** olarak bırakabiliriz.
- `Set up new code for project` adımında **Follows the instance's default** seçeneğini işaretleyip **Create Project** butonuna tıklayalım.
- `Analysis Method` adımında birkaç seçenek görebiliriz. Bunlar genellikle uzak kod repolarına bağlanabileceğimiz alternatiflerdir. Biz local ortamda ilerlediğimiz için **Locally** seçimi ile devam edelim.
- `Analyze your project` kısmında öncelikle bir **token** üretmemiz gerekiyor. Gerçek hayat senarylarında belirli sürelerde token değerinin değiştirilmesi istenir ancak bu eğitim projesinde **Expires in** seçeneğini **No expiration** olarak bırakabiliriz. Token değerini oluşturduktan sonra **Continue** tuşuna basarak devam edelim.
- `Run analysis on your project` adımında projemizin **Java** tabanlı olduğunu belirtmemiz gerekiyor. Örneğimizde **build tool** olarak **Maven** kullanıldığı için onu işaretleyebiliriz.

Tüm bu adımları tamamladığımızda terminalden çalıştıracağımız bir komutumuz olacaktır. Bunu yine projenin root klasöründe işletmemiz gerekiyor. *(Token bilgisi az önce üretilen bilgidir ve siz denerken farklı bir token olacaktır.)*

```bash
mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
  -Dsonar.projectKey=game-rental \
  -Dsonar.projectName='game-rental' \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=sqp_859e5004eaccc5c0bb1b2a7f3ada6b5b0c26ce54
```

İşte projenin teknik değerlendirmesine dair ilk MR raporu. Her ne kadar **Passed** olarak işaretlense de birçok uyarı var.

![Sonar Runtime 00](/assets/images/2026/JDDDSonarqube_00.png)

## Ya Sonrası?

Buraya kadar sabırla geldiyseniz ve benzer çıktılara ulaştıysanız sizi tebrik ederim. En azından bu haftasonunu iyi bir şekilde değerlendirmiş olduğunuzu düşünüyorum. Tabii ki bu çalışma benim gibi C# programcıları için başlangıç seviyesinde bir pratik. Dil bağımsız konuşmak gerekirse, DDD yaklaşımının gerçek hayat senaryolarında uygulanması sanıldığı kadar kolay da değil. Özellikle domain büyüdükçe, farklı domain'ler işin içerisine dahil oldukça, iş kuralları karmaşıklaştıkça kurgu giderek zorlaşabiliyor. Örneğin kim aggregate olmalı veya aggregate root olarak düşünülmeli, kim Value Object olmalı, kim Entity olmalı, hangi iş kuralları aggregate içerisinde yaşamalı, hangileri Domain Service içerisinde konuşlanmalı gibi sorulara cevap bulmak kolay değil. Bu nedenle DDD yaklaşımını öğrenmek için bolca pratik yapmak veya uygulandığı açık kaynak projeleri incelemek gerekiyor. Peki bu çalışma üzerine başka neler neler yapabiliriz?

- **Üye nesnesini gerçek bir aggregate' e dönüştürmek.** Örneğin bir üye en fazla 3 kiralama yapabilir gibi bir senaryoyu ele almak.
- **Domain bazlı event'ler eklemek.** GameRented, GameReturned gibi event'ler kurgulayıp örneğin bildirim göndermek veya iki aggregate üzerinden transactional bir senaryo kurgulamak.
- **İkinci bir bounded context ile çalışmak.** Ödeme *(Billing)* olabilir mesela. Renting diye farklı bir bounded context ile de event'ler yardımıyla haberleşebiliriz. DDD'nin stratejik tasarımını sahada deneyimleriz.
- **Mapping operasyonları için farklı alternatifler aramak.** Örneğin **MapStruct** gibi bir enstrümanı işin içerisine katabiliriz.

Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[Orjinal repoya ve kodlara github üzerinden erişebilirsiniz](https://github.com/buraksenyurt/enterprise-patterns-with-java/tree/main/src/DDD)
