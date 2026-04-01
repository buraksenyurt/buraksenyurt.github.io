---
layout: post
title: "Smart Enums"
date: 2026-04-01 18:00:00 +0300
categories:
  - Programlama Dilleri
tags:
  - csharp
  - rust
  - domain-driven-design
---
Yazılım geliştirme galaksisinin en zorlu yolculuklarından birisi sanıyorum ki **Domain Driven Design *(DDD)*** rotasında ilerlemek. Büyük çaplı kurumsal projelerde hangi mimari ile çalışacağımıza karar vermek bir yana dursun domain sınırlarını belirlemek, model nesneleri kurgulamak, ortak jargonu çıkarmak ve bu jargonu kod içerisinde nasıl temsil edeceğimize karar vermek gibi pek çok zorluğu beraberinde getiren bir yolculuk. Gerçekten farklı yetkinlikler gerektiğine inandığım bu yaklaşımda gün geçmiyor ki yeni bir konuyu tartışalım. İşte henüz gerçekleştirdiğimiz bir tartışma:

## Problem

Diyelim ki sipariş talep formlarını *(OrderForm olarak ifade edelim)* ele aldığımız bir çerçevede çalışıyoruz. Üzerinde duracağımız konu bir sipariş formunun herhangi bir andaki durumunu nasıl temsil edeceğimiz. Söz gelimi **C#** gibi nesne yönelimli bir dil kullanıyorsak bir **enum** türü ile bunu pekala sağlayabiliriz. Zira sipariş formu statüleri çoğunlukla bellidir ve değişmez *(Approved, Rejected, Canceled vb )* Tam o sırada bir arkadaşımız şöyle seslenir; "Bu ürünü farklı firmalar alacak ve bu firmaların ele alacağı senaryolarda var olan statülerin genişletilmesi gerekebilir". Örneğin sipariş formu statüleri arasında "Müdür Onayı Gerekiyor" *(ManagerApprovalRequired)* gibi farklı bir statü varsa... Bu durumda ne yapacağız? Ürünümüzün doğası gereği çekirdek domain modelimizi korumamız gerekiyor ama aynı zamanda müşterinin ihtiyacına göre de genişletilmesi. **Enum** yapısı bu esnekliği sağlayabilir mi? **Rust** ile geliştiriyor olsaydık farklı bir şekilde değerlendirebilirdik durumu ancak **C#** açısından konuya bakarsak belki de bu durumu sadece **enum** türü ile değil bir başka **Value Object** tasarlayarak ele almak gerekecek.

Bu problemde birkaç noktaya da dikkat etmemiz gerekiyor.

- Öncelikle kodumuzun yeni statüler eklenmesine izin verecek şekilde açık olmasını sağlamak ama mevcut domain kurallarının da değiştirilmesini engellemek istiyoruz. Bir nevi **Open/Closed Principle** vakasıyla karşı karşıya olduğumuzu ifade edebiliriz.
- Kuvvetle muhtemel bu ürün ilişkisel bir veritabanı sistemi kullanacak ve statü gibi **enum** benzeri yapıları saklarken metinsel bir değer yerine sayısal karşılıklarını kullanacağız. Öyle bir yaklaşıma gitmeliyiz ki örneğin veri tabanında **TenantId**, **Name**, **CoreStatusId** gibi bir tablo kullanabilelim.
- Ayrıca, bu statülerin iş mantığı ile nasıl etkileşime gireceğini de düşünmemiz gerekiyor. Örneğin, belirli bir statüye geçişin hangi koşullarda mümkün olduğunu ve bu geçişlerin nasıl yönetileceğini ayarlamalı, genişletilen statülerin de bu kurallara uymasını sağlamamız lazım.

ve daha aklıma gelmeyen başka başka sorunlar...

## Çözüm Yolu

**Domain Driven Design** açısından olaya bakarsak değişmezler olarak çevirebileceğimiz **invariants** önemli bir role sahiptir. **OrderForm** gibi aslında bir **Aggregate Root** olarak tanımlayabileceğimiz bir nesne modeli söz konusu olduğunda, bu modelin durumunu temsil eden statülerin de belirli değişmez değerlere sahip olması beklenir. Zira verinin her zaman tutarlı ve kurallara uygun *(geçerli)* bir durumda kalması sağlanmalıdır. Firmaların kendi statülerini eklemelerine izin verdiğimizde, temel domain üzerinde konuşlandırdığımız iş kurallarının ihlal edilme riski ortaya çıkar. Örneğin, **"sadece onaylandı statüsündeki siparişlerin iptal edilebileceği"** gibi bir kuralımız varsa ve ürünümüzü kullanan firma **"Üst Yönetici İncelemesinde *(ManagerApprovalRequired)*"** şeklinde yeni bir statü eklerse domain'imiz gelen yeni statünün iptal edilebilir olup olmadığını bilemeyecektir. Bu sorunu şöyle çözebiliriz.

- Domain tarafından kesinlikle bilinmesi gereken statüleri yine bir **Enum** türü ile tanımlayabiliriz. Örneğin **OrderFormStatus** isimli bir **enum** kullanılabilir. Bunlar ana statülerdir ve domain'in temel iş kurallarına göre hareket ederler.
- Müşteri yeni bir statü ekleyecekse bu statü mutlaka bir **OrderFormStatus**'a bağlanmalıdır. Yani bir nevi **mapping** yapısı kurgularız.

## C# Yaklaşımı

Bu kadar laf kalabalığından sonra gelin **C#** tarafında çok basit bir şekilde durumu ele alalım. İlk olarak çekirdek **Enum** türümüzü tanımlayalım.

```csharp
public enum OrderFormStatus
{
    Draft,
    Canceled,
    Completed,
    Processing
}
```

Şimdi standart statüleri ve müşteriye özel statüleri tutabileceğimiz değer türü nesnemizi *(Value Object)* tasarlayalım ki bunu **Smart Enum** olarak isimlendirebiliriz.

```csharp
public class OrderFormTenantStatus // : ValueObject
{
    public Guid Id { get; }
    public Guid TenantId { get; }
    public string Name { get; }
    public OrderFormStatus CoreStatus { get; }

    private OrderFormTenantStatus(Guid id, Guid tenantId, string name, OrderFormStatus coreStatus)
    {
        if (string.IsNullOrEmpty(name))
            throw new ArgumentException("Name cannot be null or empty.", nameof(name));

        Id = id;
        TenantId = tenantId;
        Name = name;
        CoreStatus = coreStatus;
    }

    public static readonly OrderFormTenantStatus Draft = new(Guid.NewGuid(), Guid.Empty, "Draft", OrderFormStatus.Draft);
    public static readonly OrderFormTenantStatus Processing = new(Guid.NewGuid(), Guid.Empty, "Processing", OrderFormStatus.Processing);
    public static readonly OrderFormTenantStatus Completed = new(Guid.NewGuid(), Guid.Empty, "Completed", OrderFormStatus.Completed);
    public static readonly OrderFormTenantStatus Canceled = new(Guid.NewGuid(), Guid.Empty, "Canceled", OrderFormStatus.Canceled);

    public static OrderFormTenantStatus Create(Guid id, Guid tenantId, string name, OrderFormStatus mappedCoreStatus)
    {
        return new OrderFormTenantStatus(id, tenantId, name, mappedCoreStatus);
    }
}
```

Ne güzel tek bir **enum** değerine bağlayarak devam edecektik değil mi? :D Ama işte gerçek dünya senaryolarında durum böyle olmuyor. Nihayetinde taban sistem ve genişleyebildiği dünya açısından baktığımızda bir sipariş formunun durumunu belirtmek, onu sayısal, metinsel ve dönüşebileceği diğer statülerle ilişkilendirdiğimiz daha yetenekli bir nesne modeline ihtiyaç duyuyor. Denklem işin içerisine **Tenant** kavramının girmesiyle değişiyor. Tanımladığımız **OrderFormTenantStatus** sınıfı, çekirdek statüleri temsil eden **OrderFormStatus** enum'ına bağlanarak müşterinin istediği kadar yeni statü ekleyebilmesine olanak tanır. Aynı zamanda domain kurallarını da korumaya devam eder. Müşteri yeni bir statü eklediğinde, bu statünün hangi çekirdek statüye karşılık geldiğini belirtmesi gerekir ve böylece domain'in temel iş kurallarının ihlal edilmesini engelleriz. Varsayılan statülerde tenant id değerleri bilerek boş bırakılır ki bunların en üst noktada bağımsız statüler olduğu anlaşılabilsin. Senaryoyu basit tutabilmek adına buradaki üst türev sınıf veya bazı domain kurallarını göz ardı ettik. Şimdi de **OrderForm** isimli aggregate root modelinde bu enstrümanları nasıl kullanacağımıza bir bakalım.

```csharp
public class OrderForm
{
    public Guid Id { get; private set; }
    public Guid TenantId { get; private set; }
    public OrderFormTenantStatus Status { get; private set; }

    public OrderForm(Guid id, Guid tenantId, OrderFormTenantStatus initialStatus)
    {
        Id = id;
        TenantId = tenantId;
        
        if (initialStatus.CoreStatus != OrderFormStatus.Draft)
            throw new ArgumentException("Initial status must be Draft.", nameof(initialStatus));

        Status = initialStatus;
    }

    public void UpdateStatus(OrderFormTenantStatus newStatus)
    {
        if (newStatus.TenantId != Guid.Empty && newStatus.TenantId != TenantId)
            throw new InvalidOperationException("Cannot change status to a status from a different tenant.");

        OrderFormStatus currentCoreStatus = Status.CoreStatus;
        OrderFormStatus newCoreStatus = newStatus.CoreStatus;

        if (currentCoreStatus == OrderFormStatus.Draft && newCoreStatus != OrderFormStatus.Processing)
            throw new InvalidOperationException("Draft status can only transition to Processing.");

        if (currentCoreStatus == OrderFormStatus.Processing && newCoreStatus == OrderFormStatus.Draft)
            throw new InvalidOperationException("Processing status cannot transition back to Draft.");

        Status = newStatus;
    }
}
```

Evet zihinler karışmış kafamızın üst kısmında dumanlar yükseliyor olabilir. **OrderForm** kendi içinde statüleri **OrderFormTenantStatus** türünden tutuyor. Bu tür varsayılan çekirdek değerlerin oluşturulmasına **static readonly** alanlar üzerinden izin verirken aynı zamanda müşterinin istediği kadar yeni statü ekleyebilmesine de olanak tanıyor. Ayrıca statü değişikliği yapmak istediğimizde özel statüler de bağlandıkları statüler gereğince çekirdek iş kurallarına tabii oluyor. Yalnız burada dikkat edilmesi gereken bir şey daha var; yeni bir statü oluştururken **id**,**name**, **tenantId** değerleri ile müşteri nezdinde özelleşen statüyü bir **OrderFormStatus** değeri ile içeriye almak zorunda oluşumuz. Yani tenant'lar bir sipariş formunda kendi statülerini kullanmak isterse mutlaka baz statüde karşılık bulmuş bir statü örneği ile eklemeliler. Dilerseniz durumu örnek bir senaryo ile pekiştirelim zira ben de ortalığı karıştırmış olabilirim. En güzel sözü kod söyleyecek.

Müşterimizin kullanmak istediği üç farklı statü olsun; **Parça bekleniyor *(WaitingForParts)***, **Montaj Hattında *(AssemblyLine)*** ve **Terzide *(InTailor)***. Yine müşteri açısından değerlendirdiğimiz bu statülerin hepsi domain açısından **Processing** statüsüne karşılık geliyor olsun. Buna göre **OrderForm** nesnemizi örneklemeye ve statü güncellemeleri yapmaya çalışalım.

```csharp
public class Program
{
    public static void Main()
    {
        Guid myTenantId = Guid.NewGuid();

        var waitingForPartsStatus = OrderFormTenantStatus.Create(Guid.NewGuid(), myTenantId, "Waiting for Parts", OrderFormStatus.Processing);
        var assemblyLineStatus = OrderFormTenantStatus.Create(Guid.NewGuid(), myTenantId, "Assembly Line", OrderFormStatus.Processing);
        var inTailorStatus = OrderFormTenantStatus.Create(Guid.NewGuid(), myTenantId, "In Tailor", OrderFormStatus.Processing);

        var order = new OrderForm(Guid.NewGuid(), myTenantId, OrderFormTenantStatus.Draft);
        Console.WriteLine($"Initial Order Status: {order.Status.Name}");
        
        order.UpdateStatus(waitingForPartsStatus);
        Console.WriteLine($"Updated Order Status: {order.Status.Name}");
        
        order.UpdateStatus(assemblyLineStatus);
        Console.WriteLine($"Updated Order Status: {order.Status.Name}");
        
        order.UpdateStatus(inTailorStatus);
        Console.WriteLine($"Updated Order Status: {order.Status.Name}");
        
        order.UpdateStatus(OrderFormTenantStatus.Canceled);
        Console.WriteLine($"Updated Order Status: {order.Status.Name}");
    }
}
```

Çalışma zamanı çıktısına bir bakalım mı?

![Smart Enums 00](/assets/images/2026/SmartEnums_00.png)

O sırada dinlediğim şarkı bir yana statüler arasında sorunsuzca geçiş yapabildiğimizi görebiliriz. Yani **Draft** statüsünden itibaren olması gerektiği gibi sırasıyla **Processing** ve **Canceled** statülerine geçiş yapabildik. Müşterinin eklediği statüler de domain kurallarına uygun şekilde hareket ettik. Tabii burada iş kurallarını ihlal eden vakaları da denememiz lazım. Bu güzide görevleri de sizlere bırakıyorum :D

## Rust'ın Şık Yaklaşımı

Tabii tüm bu sorular üzerinde ilerlerken insan ister istemez **Rust** dilinin zengin **enum** veri yapılarını düşünüyor. Evet tam anlamıyla nesne yönelimli bir dil değil ama ortak paydada soyutlamaları karşılama şekli değişse de aynı pratiği ele alabiliriz diye düşünüyorum. Rust'ın enum veri yapısı **Algebraic Data Types** olarak bilinir ve her bir enum varyantı kendi içinde farklı veri taşıyabilir. Bu da bize çok daha esnek ve güçlü bir şekilde statüleri tanımlama imkanı verir. Ayrıca **null** diye bir kavram olmaması bu tip kontrolleri yapacağımız kısımlarda **Option** gibi çok daha güvenli bir türden yararlanmamıza vesile olur. Şimdi de aynı senaryoyu **Rust** tarafında ele alalım. Sadece **guid** kullanımı için **uuid** crate'ini eklememiz gerekecek.

```bash
cargo add uuid -F v4
```

İşe OrderFormStatus enum veri yapısını tanımlayarak başlayalım. Bu en çekirdek statüleri tutacağı için dümdüz bir enum.

```rust
use uuid::Uuid;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OrderFormStatus {
    Draft,
    Cancelled,
    Completed,
    Processing,
}
```

Şimdi işin en azından bana göre sanata dönüştüğü bir kısım geliyor. Bir statü ya sistemin kendi statüsüdür ya da içine veri gömülmüş bir özel statüdür. Bunu yaparken sınıf hiyerarşisine bağlı kalmadan hareket edebiliriz. Nasıl mı? İşte böyle;

```rust
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum OrderFormTenantStatus {
    System(OrderFormStatus),
    Custom {
        id: Uuid,
        tenant_id: Uuid,
        name: String,
        core_status: OrderFormStatus,
    },
}

impl OrderFormTenantStatus {
    pub fn core_status(&self) -> OrderFormStatus {
        match self {
            OrderFormTenantStatus::System(core) => *core,
            OrderFormTenantStatus::Custom { core_status, .. } => *core_status,
        }
    }

    pub fn tenant_id(&self) -> Option<Uuid> {
        match self {
            OrderFormTenantStatus::System(_) => None,
            OrderFormTenantStatus::Custom { tenant_id, .. } => Some(*tenant_id),
        }
    }

    pub fn name(&self) -> String {
        match self {
            OrderFormTenantStatus::System(core) => format!("{:?}", core),
            OrderFormTenantStatus::Custom { name, .. } => name.clone(),
        }
    }

    pub fn new(
        id: Uuid,
        tenant_id: Uuid,
        name: &str,
        core_status: OrderFormStatus,
    ) -> Result<Self, &'static str> {
        if name.trim().is_empty() {
            return Err("Statü adı boş olamaz.");
        }
        Ok(OrderFormTenantStatus::Custom {
            id,
            tenant_id,
            name: name.to_string(),
            core_status,
        })
    }
}
```

Gördüğünüz gibi **OrderFormTenantStatus** enum'ı iki varyant içerir. İlki **System** varyantıdır ki çekirdek statüleri taşıyabilir, ikincisi ise **Custom** varyantıdır ve müşteriye özel statüleri temsil eder. **impl** bloğunda birçok fonksiyon bulunmakta. **new** fonksiyonu yeni bir statü oluşturmak için kullanılır ve geçersiz bir isimle karşılaşırsa hata döner. Diğer fonksiyonlar ise statünün çekirdek statüsünü, tenant id'sini ve adını almak için kullanılır. Bu fonksiyonlarda **pattern matching** tekniğini kullandığımız için kod oldukça temiz ve anlaşılır kalır diyebilirim. Evet yer yer bizi düşündüren kısımlar da yok değil. Örneğin new fonksiyonuna eklediğimiz deneysel iş kuralı ihlal edilirse **Result** türü statik yaşam ömründe bir literal döner. Burada kolay kaçtığımı itiraf edebilirim. Belki de statü oluşturulurken iş kurallarını ihlal eden bir durum varsa bunu compile time'da yakalayabileceğimiz bir yapıya gitmek daha doğru olurdu. Ancak bu örnekteki gibi runtime'da kontrol etmek de mümkün olabilir. Neyse neyse... Dağılmayalım ve **OrderForm** struct'ını yazarak devam edelim.

```rust
pub struct OrderForm {
    pub id: Uuid,
    pub tenant_id: Uuid,
    status: OrderFormTenantStatus,
}

impl OrderForm {
    pub fn new(
        id: Uuid,
        tenant_id: Uuid,
        initial_status: OrderFormTenantStatus,
    ) -> Result<Self, &'static str> {
        if initial_status.core_status() != OrderFormStatus::Draft {
            return Err("Sipariş sadece Draft statüsü ile başlayabilir.");
        }

        Ok(Self {
            id,
            tenant_id,
            status: initial_status,
        })
    }

    pub fn status(&self) -> &OrderFormTenantStatus {
        &self.status
    }

    pub fn update_status(&mut self, new_status: OrderFormTenantStatus) -> Result<(), &'static str> {
        if let Some(status_tenant_id) = new_status.tenant_id() {
            if status_tenant_id != self.tenant_id {
                return Err("Farklı bir firmaya ait statü bu siparişe atanamaz.");
            }
        }

        let current_core = self.status.core_status();
        let new_core = new_status.core_status();

        if current_core == OrderFormStatus::Draft && new_core != OrderFormStatus::Processing {
            return Err("Draft statüsü sadece Processing'e geçebilir.");
        }

        if current_core == OrderFormStatus::Processing && new_core == OrderFormStatus::Draft {
            return Err("Processing statüsü tekrar Draft'a dönemez.");
        }

        self.status = new_status;
        Ok(())
    }
}
```

**Rust** tarafındaki **OrderForm** veri yapımızda C#'takine benzer şekilde çeşitli kuralları işletebilir ve statü güncellemelerini yönetir. **new** fonksiyonu sipariş formu oluştururken başlangıç statüsünün **Draft** olması gerektiğini kontrol eder. **update_status** fonksiyonu ise yeni statünün aynı tenant'a ait olup olmadığını ve geçiş kurallarını kontrol eder. Eğer herhangi bir kural ihlal edilirse hata dönülür. Aksi takdirde statü başarılı bir şekilde güncellenir. Şimdi bu yapıyı nasıl kullanacağımıza bakalım.

```rust
fn main() -> Result<(), &'static str> {
    let firm_tenant_id = Uuid::new_v4();

    let waiting_for_parts = OrderFormTenantStatus::new(
        Uuid::new_v4(),
        firm_tenant_id,
        "Waiting for Parts",
        OrderFormStatus::Processing,
    )?;
    let assembly_line = OrderFormTenantStatus::new(
        Uuid::new_v4(),
        firm_tenant_id,
        "Assembly Line",
        OrderFormStatus::Processing,
    )?;
    let in_tailor = OrderFormTenantStatus::new(
        Uuid::new_v4(),
        firm_tenant_id,
        "In Tailor",
        OrderFormStatus::Processing,
    )?;

    let mut order = OrderForm::new(
        Uuid::new_v4(),
        firm_tenant_id,
        OrderFormTenantStatus::System(OrderFormStatus::Draft),
    )?;

    println!("Initial Order Status: {}", order.status().name());

    order.update_status(waiting_for_parts)?;
    println!("Updated Order Status: {}", order.status().name());

    order.update_status(assembly_line)?;
    println!("Updated Order Status: {}", order.status().name());

    order.update_status(in_tailor)?;
    println!("Updated Order Status: {}", order.status().name());

    order.update_status(OrderFormTenantStatus::System(OrderFormStatus::Cancelled))?;
    println!("Updated Order Status: {}", order.status().name());

    Ok(())
}
```

Ve çalışma zamanı çıktısı;

![Smart Enums 01](/assets/images/2026/SmartEnums_01.png)

## Sonuç

**Domain Driven Design** ilkeleri ile zorlayıcı ancak bir programlama dilinin bazı yeteneklerini daha iyi benimsemek adına harika pratikler vaat ediyor. **Rust** bir kenara tam anlamıyla nesne yönelimli dil paradigmalarını düşündüğümüzde dümdüz veri yapıları tasarlamanın ötesine geçtiğimiz bir hatta ilerlemeye zorluyor. Bu çalışmada müşteri açısından kıymetli olan bir gereksinimin çekirdek kurguyu bozmadan uyarlanabilmesi adına bazı hamleler yapmaya çalıştık. En ideal yol mudur tartışılır ama ziyadesiyle önemli dil kabiliyetlerini kullandık diyebiliriz. Adettendir bitirirken C# ve Rust açısından da bir kıyas yapalım.

- Bir statüyü nesne olarak oluştururken **OrderFormStatus.Draft** gibi kullanımlar söz konusu. Bu tahminimce bellekte bir yer tahsisine *(allocation)* neden olabilir. Rust tarafında **OrderFormTenantStatus::System(OrderFormStatus::Draft)** şeklinde bir kullanım var. Bu da enum'un kendi içinde veri taşıyabilmesi sayesinde mümkün. Buna göre gereksiz yer tahsisi yok desek doğru olur mu emin değilim :D Bunu ispatlamam en azından şimdilik zor.
- Boş **guid** kullanımında C# tarafında **Guid.Empty** şeklinde bir yaklaşımımız oldu. **Rust** tarafında **Option** türüne sahip olduğumuz için **None** ile tenant bağımsız statüleri temsil edebilir durumdayız. Daha tip güvenli *(type safe)* bir yaklaşıma sahip olduğumuzu ifade edebiliriz. **C#** tarafında bunun için çaresiz miyiz, asla. Pekala kendi generic **Option** türümüzü de yazabiliriz ama dilin doğasında bunun olması farklı bir şey.
- Option gibi yine **Rust** açısından güçlü olan bir başka enstrüman da generic **Result** türüdür. **C#** tarafında domain kural ihlallerini genellikle **Exception** fırlatarak cezalandırdık ama **Rust** tarafında **Result** türü kullandığımız için **try/catch** bloklarına ihtiyaç duymadan hataları yönetebiliriz. Yine **pattern matching** ile **Result** içeriğini yakalayarak hataları daha temiz bir şekilde ele alabiliriz. Pek tabii C# tarafında da belki **result pattern** ile aynı şeyi karşılamak mümkün olabilir.

Bu anlamsız karşılaştırma bir yana dursun asıl vurgulamam gereken şey şu; Kurumsal ölçekte bir yazılımda **domain driven design** pratiklerini ele alacaksak ürünü **Rust** ile yazmayız. Zira, bağımlılık yönetimi *(dependency injection)* gibi kritik konularda nesne yönelimli bir dilde kalmak kodu yazmak ve bakımı açısından daha kolay olabilir. Lakin bu sistemin ihtiyaç duyduğu yüksek performans isteyen ve görev kritik olan birçok senaryoda **Rust** ile ilerleyebiliriz. Bu tamamen kendimce yapmış olduğum bir yorum ;)

Bu çalışmada ele aldığımız örneklere [github reposundan](https://github.com/buraksenyurt/friday-night-programmer/tree/main/src/SmartEnums) erişebilirsiniz.
