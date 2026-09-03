---
layout: post
title: "Kendi Bevy'ni Yazmaya Çalışmak: C# ile Basit Bir ECS Denemesi"
date: 2026-09-02 06:00:00
tags:
    - rust
    - csharp
    - ecs
    - entity-component-system
    - composition-over-inheritance
    - bevy
    - game-engine
    - game-programming
    - game-development
categories:
    - Oyun Programlama
---
Bir süre **Rust** programlama dili ile oyun geliştirmeye çalışmıştım. Topluluğun gücü olsa gerek [Are We Game Yet](https://arewegameyet.rs/) sitesinde birçok framework, oyun motoru, render platformu vs var. En çok kullanılan platformlardan birisi sanıyorum ki [Bevy](https://crates.io/crates/bevy). Onu özel kılan yönlerden birisi **Composition over Inheritance** prensibini merkeze alan **Entity Component System** implementasyonu da sunması. Bir önceki cümlede iki önemli kavramdan bahsettim; kalıtım yerine kompozisyonun tercih edilmesi ve entity nesneleri ile donatılmış bileşenlerin ele alındığı sistemler yaklaşımı. Bu yazıdaki amacım **Rust** tarafında **ECS** kullanımını göstermekten ziyade söz konusu yaklaşımı `C#` gibi nesne yönelimli bir dilde tasarlamak istersek nasıl bir yol izleyebileceğimizi keşfetmek *(Bevy ile ilgili bir denememi merak ediyorsanız [On My Way](https://github.com/buraksenyurt/game-dev-with-rust/blob/main/bevy/on-my-way) isimli oyunuma bakabilirsiniz)*

![Write Own Bevy 01](/assets/images/2026/WriteOwnBevy_01.png)

Oyundan muhteşem bir enstantane :P

## Rust Tarafında Nasıldı?

Bevy'nin o zamanlar kullandığım sürümünü baz alarak `On My Way` oyunundaki **main** fonksiyonunu kısaca değerlendirelim.

```rust
mod events;
mod game;
mod main_menu;
mod systems;

use crate::events::GameOverEvent;
use crate::game::GamePlugin;
use crate::main_menu::MainMenuPlugin;
use crate::systems::*;
use bevy::prelude::*;

fn main() {
    App::new()
        .add_message::<GameOverEvent>()
        .add_plugins(DefaultPlugins)
        .init_state::<AppState>()
        .add_plugins((GamePlugin, MainMenuPlugin))
        .add_systems(Startup, spawn_camera)
        .add_systems(
            Update,
            (
                change_to_game_state,
                change_to_main_menu,
                handle_game_over,
                exit_game,
            ),
        )
        .run();
}

#[derive(States, Debug, Clone, Eq, PartialEq, Hash, Default)]
pub enum AppState {
    #[default]
    MainMenu,
    Game,
    GameOver,
}
```

Oyun döngüsü aslında bir durum makinesi *(State Machine)* gibi düşünülebilir. Bu **state**'ler menüde olma, oyunu oynama ve oyunda yanma hallerini ele alıyor. **Bevy** sağladığı zincir fonksiyonelliklerle bu makine için gerekli tüm unsurları sağlıyor. Örneğin ekranla ilgili bilgiler veya kamera özellikleri dahili olarak sağladığı `plug-in`'ler üzerinden geliyor. Kendi tasarladığımız `plug-in`'ler de ise oyundaki varlıkları *(entities)*, bileşenleri *(components)* ve işleyen sistemleri tarifleyebiliyoruz. Tüm bunlar durum makinesinin işletildiği sonsuz döngüde güncellemeler sırasında *(Frame per second anlarında)* veya başlangıç durumunda devreye giriyor. Burası kodun son derece yalınlaştığı bir sorumluluklar zinciri *(Chain of responsibility)* implementasyonu. Konuyu biraz daha açmak adına örnek bir `plug-in` kurgusunu masaya yatıralım. Oyuncunun kullandığı uzay gemisini ele alarak başlayalıım. Bu veri yapısı aslında sistem içerisinde bir varlıkla ilişkilendirilecek bir bileşen *(component)*.

```rust
use bevy::prelude::*;
#[derive(Component)]
pub struct Spaceship {}
```

Onun bir bileşen olduğunu **Component** direktifi ile **Bevy** oyun motoruna bildiriyoruz. Aslında bu veri yapısı çoğunlukla tek başına değil oyun motoru tarafında üretilen bir varlıkla *(entity)* ilişkilendirilerek kullanılıyor. Pek tabii bu tip bir veri modeli çeşitli özelliklere de sahip olabilir. Örneğin aşağıdaki roket veri yapısını göz önüne alalım.

```rust
use bevy::prelude::*;
#[derive(Component, Clone)]
pub struct Missile {
    pub direction: Vec2,
    pub speed: f32,
    pub width: f32,
    pub fuel_cost: f32,
    pub disposable: bool,
    pub location: Vec3,
}
```

Bir roketin yönü, hızı, yakıt miktarı, konumu gibi bilgiler de lazım olur. Zira oyuncu bir tuşa basıp füzeyi fırlattığında aslında yeni ve benzersiz bir entity oluştururken başka bir sistemde bu **entity**'nin değerlerini ele alarak çeşitli güncellemeler yapar. Füze, belirtilen yöne doğru belli bir hızda ama yakıtı tükenene kadar hareket eder. Tüm bu değerlendirmeler oyun motorunun sonsuz döngüsündeki anlık güncellemelerde değerlendirilir. **System** olarak ifade edilen fonksiyonlarsa bu güncellemeleri üstlenerek varlıkların verilerinde ya da uygulama durumlarında değişiklikler yaparlar. Örneğin bir füzenin hareketi sadece buna odaklanmış bir sistemle ele alınabilir. Aşağıdaki fonksiyon tam olarak bu görevi üstleniyor.

```rust
pub fn move_missile(mut query: Query<(&mut Transform, &Missile)>, time: Res<Time>) {
    for (mut transform, missile) in query.iter_mut() {
        let direction = Vec3::new(missile.direction.x, missile.direction.y, 0.);
        transform.translation += direction * missile.speed * time.delta_secs();
    }
}
```

Bu fonksiyonun parametre yapısı son derece önemli. **Query** generic bir tür ve aslında sahada değiştirilebilir *(mutable)* **Transform** özelliği olan **Missile** nesne referanslarını bekliyor. Sahada füzelerin olması oyuncunun tuşa basmasına bağlı ancak bu sistem tuşa basılma halini değil ortamda hareket halinde olması beklenen füze varlıklarına ait referanslar var mı sorusunu cevaplıyor. Hatta sistemler arasındaki zamansal kaymaların önüne geçmek için delta farklarını da bir **Resource** üzerinden ele alıyor. Şimdi kafayı biraz karıştıralım. Oyuncu tuşa basıp füze ateşleyecek. Aslında bu da bir sistem olarak ele alınmalı. Aşağıdaki fonksiyon bu işi üstleniyor.

```rust
pub fn fire_missile(
    mut commands: Commands,
    mut query: Query<&mut Transform, With<Spaceship>>,
    keyboard_input: Res<ButtonInput<KeyCode>>,
    asset_server: Res<AssetServer>,
    launch_timer: Res<MissileLaunchCheckTimer>,
    mut live_data: ResMut<LiveData>,
) {
    if keyboard_input.pressed(KeyCode::KeyS) && launch_timer.timer.just_finished() {
        if let Ok(transform) = query.single_mut() {
            let missile = Missile {
                direction: Vec2::new(1., 0.),
                speed: MISSILE_003_SPEED,
                width: 51.,
                fuel_cost: 1.5,
                disposable: false,
                location: transform.translation,
            };
            commands.spawn((
                Sprite {
                    image: asset_server.load("sprites/spaceMissiles_003.png"),
                    ..default()
                },
                Transform::from_xyz(
                    transform.translation.x,
                    transform.translation.y,
                    0.,
                ),
                missile.clone(),
            ));
            live_data.spaceship_fuel_level -= missile.fuel_cost;
            live_data.used_missile_count += 1;
        }
    }
}
```

Kodun ilk etapta korkutucu geldiğini ifade edebilirim. Bu yazı açısından değerlendirirsek önemli olan noktaları vurgulamamız yeterli olacaktır. Sistemin ihtiyaç duyacağı birçok malzeme parametre üzerinden geliyor. Tuşa basılma durumunu kontrol edebileceğimiz, füze resmini gösterebileceğimiz, füze için sayaç başlatabileceğimiz bazı kavramlar oyun için birer kaynak *(Resource)*. Bir entity oluşturmamız gerektiğinden **Commands** bileşeni aktarılıyor. Elbette füzeyi ateşlemesi için ortamda bir de Spaceship olması lazım. Ancak bu sistem fonksiyonu için değiştirilebilir **Transform** bileşeni ile donatılmış bir Spaceship varlığına ihtiyaç var, işte bunu da **Query** karşılıyor. Anlayacağınız çalışma zamanında sistemler üzerinde çalışacakları varlıkları onları donattığımız bileşenler yardımıyla keşfedip kullanabilmekte ve ihtiyaç duydukları kaynakları *(resim, ses, zamanlayıcı vs)* yine genel ortamdan isteyebilmekte.

Eğer kodları detaylıca incelerseniz sayısız sistem ve bileşen olduğunu göreceksiniz. Bunları yönetmek klasik bir kodlama ile çok kolay değil. ECS *(Entity Component System)* gibi prensiplerin uyarlanması oyun motorlarında bazı işleri oldukça kolaylaştırıyor.

Pekala, elimizde *entity* haline dönüşen veri yapıları, onları çeşitli karakteristiklerle donatabildiğimiz bileşenler ve işlediğimiz sistemler var. Bunların sayısı bir noktadan sonra yönetilmesi zor bir hale gelebiliyor. Aynı kapsama *(context)* dahil olacak her şeyi paketlemek ve bir eklenti haline getirmek mümkün *(Bundle `plug-in`)*. Örneğin füzelerin kapsamını göz önüne alırsak şöyle bir plug-in kullanabiliyoruz.

```rust
use crate::game::missile::systems::*;
use crate::AppState;
use bevy::prelude::*;

pub mod components;
mod systems;
pub struct MissilePlugin;

impl Plugin for MissilePlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(
            Update,
            (
                move_missile,
                detect_collision_with_meteors,
                claim_hitted,
                check_outside_of_the_bounds,
                animate_explosion_sprites,
                despawn_explosions,
            )
                .run_if(in_state(AppState::Game)),
        )
        .add_systems(OnExit(AppState::Game), despawn_missiles);
    }
}
```

**Bevy** bunun bir `plug-in` olduğunu implemente ettiği **Plugin trait** dolayısıyla biliyor. Bu **trait** parametre olarak uygulama nesnesini kullanıyor ve böylece çalışma zamanına sistem ekleme kabiliyeti kazandırılıyor. İşte ilk başta gösterdiğimiz **main** fonksiyonu içerisindeki `plug-in` bildirimleri aslında kendi kapsamlarından *(context)* birçok enstrümanı çalışma zamanında enjekte edebiliyor.

## ECS Hangi Avantajları Getiriyor?

İlk başta alışmakta zorlandığım bir programlama paradigmasıydı. Özellikle **Bevy** oyun motorunun da sürekli değişmesi ve tam bir stabil sürüme gelmemesi işimi zorlaştırmıştı. Ancak önemli olan **ECS**'in getirdiği avantajları da anlamak. Bunları birkaç başlık altında toplayabiliriz.

- **Kompozisyonun kalıtıma tercih edilmesi *(Composition over Inheritance)*:** Klasik nesne yönelimli bir oyun motorunda genelde **GameObject** temelli, derin bir kalıtım ağacı kurma eğiliminde oluruz. **Meteor**, **Spaceship**, **Missile** gibi tipler ortak bir taban sınıftan türer, hareket edebilme, çizilebilme, hasar alabilme gibi yetenekler bu ağacın farklı katmanlarına dağılır. Zamanla elmas problemi *(diamond problem)* olarak da bilinen, bir sınıfın hem hareket edebilen hem menzili olan hem de çizilebilen bir şey olması gerektiğinde kalıtım ağacının nereye oturacağının belirsizleştiği açmaza düşebiliriz. **ECS**'de böyle bir kaygı yoktur. Nitekim bir varlık hangi davranışlara ihtiyaç duyuyorsa o kadar bileşenle donatılır, hatta çalışma zamanında bile bir bileşen eklenip çıkarılarak ilgili varlığın davranışı değiştirilebilir. Söz gelimi bizim örneğimizdeki *tower* sadece **Position** ve **Range** bileşenlerini taşırken player hem **Position** hem **Velocity** bileşenleri ile donatılmıştır. Aralarında hiçbir kalıtım ilişkisi kurmamıza gerek kalmamıştır.
- **Veri *(data)* ile davranışın *(behavior)* birbirinden ayrılması:** Bileşenler saf veri, sistemler ise bu veri üzerinde çalışan fonksiyonlar olarak düşünülebilir. Bu ayrım test edilebilirliği artırır. Bu sayede bir sistemi test etmek için koca bir oyun dünyası kurmaya gerek de kalmaz. Duruma uygun birkaç bileşen örneği hazırlayıp Apply metodunu çağırmak yeterli olacaktır. Aynı zamanda `bu davranış hangi sınıfa ait olmalı` tartışması da ortadan kalkar. Davranış *(behavior)* artık bir sınıfa değil, o davranışı üstlenen sisteme ait hale gelir.
- **Performans:** Gerçek **ECS** motorları bileşenleri bellekte birbirine yakın kompakt dizilerde tutmakta *(Structure of Arrays yaklaşımı)* Bir sistem sadece ilgilendiği bileşen tipini taradığında **CPU cache** dostu bir erişim deseni ortaya çıkar. Bizim `C#` denememizde bunu henüz sağlamayacağız *(Bir süre sonra...Sağlayamadı)*, `List<IComponent>` içinde `OfType<T>()` ile filtreleme yapıyoruz ki bu hem tip kontrolü hem de **LINQ** işlem maliyeti taşıyor ama gerçek bir ECS motorunun neden bu kadar performans vaadinde bulunduğunu anlamak için bu noktayı bilmekte fayda var.
- **Paralellik:** Sistemler hangi bileşenlere okuma/yazma erişimi istediklerini query üzerinden bildirdiklerinde, birbiriyle çakışmayan sistemler aynı anda farklı thread'lerde çalıştırılabilir. **Bevy**'nin zamanlayıcısı *(scheduler)* bunu otomatik olarak çözer. Örneğin **move_missile** ile hiçbir ortak bileşeni olmayan başka bir sistemi aynı frame içinde paralel koşturabilir. Bizim tasarlayacağımız **Scheduler** sınıfı şu an için tamamen sıralı düzende çalışıyor ama mimarinin ileride bu tür bir genişlemeye kapalı olmadığını açıkça belirtmek isterim.

## Gelelim `C#` Tarafına

**Bevy**'nin sağladığı **ECS** yetkinlikleri oldukça önemli seviyede. Peki `C#` gibi bir nesne yönelimli dili göz önüne alırsak bu tip bir geliştirmeyi nasıl yaparız? En azından bir **entity** ve **component** ikilisini bir sistemde yürütebilmek ama bunu çalışma zamanındaki ana motor üstünden sağlayabilmek ilk amaç olabilir. Yazının devam eden kısmında işte bu maceraya dalıyor olacağız. İşe temiz bir Console uygulaması ile başlamakta yarar var. **Engine** olarak isimlendirdiğim dosya içeriğini aşağıdaki gibi doldurdum.

```csharp
namespace NetBevy;

public interface IComponent
{
}

public interface IEntity
{
    Guid ID { get; set; }
    List<IComponent> Components { get; set; }
    void AddComponent(IComponent component);
}

public class Entity
    : IEntity
{
    public Guid ID { get; set; }
    public List<IComponent> Components { get; set; } = [];

    public void AddComponent(IComponent component)
    {
        Components.Add(component);
    }
}

public interface ISystem<T> where T : IComponent
{
    void Apply(IEnumerable<(Entity entity, T component)> components);
}

public enum SystemState
{
    Startup,
    Update
}

public class Scheduler
{
    private readonly World _world;

    private Dictionary<SystemState, List<object>> _systems = new()
    {
        { SystemState.Startup, new List<object>() },
        { SystemState.Update, new List<object>() }
    };

    public Scheduler(World world) => _world = world;

    public void AddSystem<T>(SystemState state, ISystem<T> system) where T : IComponent
    {
        _systems[state].Add(system);
    }

    public void Run(SystemState state)
    {
        if (!_systems.TryGetValue(state, out List<object>? value)) return;

        foreach (var system in value)
        {
            var systemType = system
                .GetType()
                .GetInterfaces()
                .FirstOrDefault(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(ISystem<>));

            if (systemType != null)
            {
                var componentType = systemType.GetGenericArguments()[0];
                var queryType = typeof(Query<>).MakeGenericType(componentType);
                var queryInstance = Activator.CreateInstance(queryType, _world);
                var getEntitiesMethod = queryType.GetMethod("GetEntities");
                var entities = getEntitiesMethod.Invoke(queryInstance, null);

                var applyMethod = systemType.GetMethod("Apply");
                _ = applyMethod.Invoke(system, [entities]);
            }
        }
    }
}


public class World
{
    private List<Entity> _entities = [];

    public Entity CreateEntity()
    {
        var entity = new Entity { ID = Guid.NewGuid() };
        _entities.Add(entity);
        return entity;
    }

    public IEnumerable<Entity> GetEntities() => _entities;
}

public class Query<T> where T : IComponent
{
    private readonly World _world;

    public Query(World world) => _world = world;

    public IEnumerable<(Entity entity, T component)> GetEntities()
    {
        return _world.GetEntities()
            .SelectMany(e => e.Components
                .OfType<T>()
                .Select(c => (e, c)));
    }
}
```

Şimdi burada neler olduğuna birlikte bakalım. Ne yapmak istediğimize dikkat etmemiz lazım. **Engine** içerisindeki enstrümanlar asıl oyun programcısının ekleyeceği ve motorun hiçbir suretle bilemeyeceği ama ele alması gereken kavramları sağlamalı. Bu nedenle arayüzler *(interface)* bizim için önemli aktörlerden birisi. Bileşenleri tariflemek için **IComponent** arayüzünü kullanıyoruz. Şu an için bir bileşenin oyun programcısı tarafından mutlaka ele alması gereken davranışları *(behavior)* yok.

**Entity**'ler aslında programcının motordan istediği ve üretilen *(spawn)* şeyler. Benzersiz bir kimlikleri olması ve ayrıca bileşenler ile donatılabilmeleri gerekiyor. Bir varlığın bileşenlerle donatılması aslında bize şöyle bir imkan sağlıyor; oyun başlar ve karakter sahaya gelir *(spawn)* ve gelirken zırhlanır, ateş gücü kazanır, hareket eder vs. Zırhlanabilir, ateş edebilir *(Weapon)*, hareket edebilir *(Moveable)* aslında programcının tanımladığı ve belli nitelikler taşıyan bileşenler olarak düşünülebilir. O halde sistemin bir varlığın nasıl tanımlanıp neler yapabileceğinin de tariflenmesi gerekiyor. Bu nedenle **IEntity** arayüzü içerisinde **Guid** türünden bir özellik *(düşündüm de şimdi sadece readonly de yapılabilirmiş)*, bileşen eklemeyi sağlayan bir metot *(AddComponent)* ve sahip olduğu bileşenleri çekmemizi sağlayan başka bir özellik yer alıyor.

Varlıkların ve bileşenlerin oyun motoru için gerekli olan sözleşmeleri *(contracts)* hazır. Bunların değerlendirileceği yer ise sistemler. Ve sistemler yine oyun programcısı tarafından tanımlanıyor. Oyun motoru oyunun kullandığı sistemler hakkında bilgi sahibi olamaz ama hangi kurallara uymaları gerektiğini sözleşmeler aracılığıyla belirtebilir. Bunu **ISystem** arayüzü ile sağlıyoruz. Dikkat edileceği üzere sistem sözleşmesi generic ve **T** türünün **IComponent** implementasyonu yapmış olmasını bekliyor. Tek bir davranışı var o da **Apply**. Metodun parametre yapısı üzerinden hareket edersek **Entity** ve **IComponent** **tuple**'larından oluşan numaralanabilir bir liste aldığını görebiliriz. Tabii bu çok ilkel bir sistem fonksiyonelliği. **Rust** gibi motorların sağladığı varyasyonlar düşünüldüğünde inanılmaz derecede yalın kalıyor. Ancak hedefe giden yolda işimize yarayacağını açıkça söyleyebilirim.

Bevy tarafındaki sistem fonksiyonlarını hatırlarsanız eğer dünyaya hükmetmek için **Command** ve dünyadaki şeyleri çetrefilli biçimde sorgulayabilmek için akıllı bir **Query** bileşenine sahipti. Burada benzer bir işlevselliği sağlamak için kodun alt kısımlarında gördüğünüz World ve generic **Query** sınıflarını kullanıyoruz. **World** sınıfı aslında oyun motorunun sağladığı dünyadaki enstrümanları sunuyor diyebiliriz. Şu an için sadece **Entity**'leri yönetiyoruz. **Entity** oluşturmak ve hafızaya almak, var olan entity listesini çekmek sağladığı fonksiyonellikler. Generic Query sınıfı ise bir World nesne örneği ile var olabilen bir bileşen. Sınıfın belki de en önemli noktası GetEntities içerisindeki **LINQ *(Language Integrated Query)*** sorgusu. **Entity**'leri alırken söz konusu bileşene sahip olanları çekiyor. Tabii şu an için tek seviyede bir sorgulama mümkün. Örneğin, hareket edebilen varlıklar için bir hareket sistemi yazmamız kolay lakin hareket edebilen ve ateş gücü olan varlıkları çekmek şimdilik mümkün değil. Bu da size bir ödev olsun. Sorgunun tek **component** yerine n adet **component**'i sorguya alması yeterli olacaktır.

Şu ana kadar oyun motoru için gerekli birçok unsuru tesis ettik. Varlık oluşturmak, bileşen tanımlayıp varlıklarla ilişkilendirmek, bileşenleri baz alan sistemler tasarlamak ve hatta sorgulamak. Ancak oyun motorunun programcısına sunması gereken durum yönetimini yapan planlayıcı *(Scheduler)* bileşeni de gerekiyor. Scheduler sınıfının tam olarak yaptığı şey de bu. Bir **World** nesnesi ile başlatılabiliyor. Oyun dünyasının işleteceği sistemleri state bazlı olarak bir **Dictionary**'de tutuyor. **Scheduler** sayesinde programcı tasarladığı sistemleri dahili gelen oyun dünyasına ekleyebiliyor. **Run** metodunun içeriği ise kayda değer. Temel olarak sistemleri bulup **Apply** metotlarını işlettiğini ifade edebiliriz. Tabii pek çok handikapı var. **Type** üstünden **reflection** ile gittiğinde sistemleri yükleme ve fonksiyon çağırma aksiyonlarının her çalıştırmada tekrarlanması ciddi bir yük. Ancak bunu optimize etmek sonraya bıraktığım ve kabullendiğim bir teknik borç. Henüz ilk denemeyi yapıyoruz. Çalışır bir versiyon elde etmek kritik.

## O Zaman Deneyelim

Aslında oyun motoru kabaca hazır. Denemek için oyun programcısı rolüne bürünelim. İlk olarak ihtiyacımız olan bileşenleri *(components)* tasarlayalım.

```csharp
namespace NetBevy.Game;

public class Position
    : IComponent
{
    public float X { get; set; }
    public float Y { get; set; }
}

public class Velocity
    : IComponent
{
    public float X { get; set; }
    public float Y { get; set; }
}

public class Range
    : IComponent
{
    public float Value { get; set; }

}
```

Klasik bileşenlerimiz var. Pozisyon, ivme ve mesafe gibi. Bunlar gerçekten de oyundaki bir varlıkla ilişkilendirildiklerinde daha çok anlam kazanıyorlar. Hatta o zaman **Query**'ler de mantıklı hale geliyor. Hareket edebilen ve mesafe kat edebilen şeyler esasında bu oyun programcısı açısından **Velocity**, **Range** ve **Position** bileşenleri ile donatılmış varlıklar. Bir kale sadece **Position** ve **Range** bileşeni içerirken şehrin giriş kapısı sadece **Position** bileşenine sahiptir. Öyleyse iki de örnek sistem ekleyelim.

```csharp
namespace NetBevy.Game;

public class SetupPositionSystem : ISystem<Position>
{
    public void Apply(IEnumerable<(Entity entity, Position component)> components)
    {
        foreach (var (entity, position) in components)
        {
            position.X = 0;
            position.Y = 0;
            Console.WriteLine($"[Setup] Entity {entity.ID} initialized at (0,0)");
        }
    }
}

public class MovementSystem : ISystem<Position>
{
    public void Apply(IEnumerable<(Entity entity, Position component)> components)
    {
        foreach (var (entity, position) in components)
        {
            position.X += 1.0f;
            position.Y += 1.0f;
            Console.WriteLine($"[Update] Entity {entity.ID} moved to ({position.X}, {position.Y})");
        }
    }
}
```

İlk sistem **Position** bileşeni olan ne kadar varlık varsa onların konumlarını sıfırlıyor. Oyun için anlamsız ama bizim testlerimiz için kafi. **MovementSystem** isimli sınıf ise Position bileşeni yüklü olan tüm varlıkların **X** ve **Y** değerlerini değiştiriyor. Evet çok anlamsız ancak bir önceki cümlede de belirttiğim gibi bunlar bizim sistem testlerimiz. Dikkat edeceğimiz noktalardan birisi her iki sistemin de **ISystem** arayüzünü implemente etmesi. Dolayısıyla oyun motorunun ihtiyaç duyacağı **Apply** davranışını uygulamak zorundalar. Oyun programcısı olarak koda baktığımızda bazı şeyler biraz daha net görünüyor. O yüzden artık oyunun kendisini geliştirmek de kolay. Aşağıdaki sınıfı göz önüne alalım.

```csharp
namespace NetBevy.Game;

public static class GameApp
{
    public static void Run()
    {
        World world = new();

        var player = world.CreateEntity();
        player.AddComponent(new Position { X = 10, Y = 10 });
        player.AddComponent(new Velocity { X = 1, Y = 0 });

        var enemy = world.CreateEntity();
        enemy.AddComponent(new Position { X = 100, Y = 10 });
        enemy.AddComponent(new Velocity { X = -1, Y = 0 });

        var tower = world.CreateEntity();
        tower.AddComponent(new Position { X = 0, Y = 0 });
        tower.AddComponent(new Range { Value = 85 });

        var scheduler = new Scheduler(world);

        scheduler.AddSystem(SystemState.Startup, new SetupPositionSystem());
        scheduler.AddSystem(SystemState.Update, new MovementSystem());

        scheduler.Run(SystemState.Startup);
        for (int i = 0; i < 3; i++)
        {
            scheduler.Run(SystemState.Update);
        }
    }
}
```

Dünyada üç varlık oluşturup planlayıcıyı kuruyor ve sistemleri ekliyoruz. Startup durumunu bir kez, **Update** durumunu ise üç kez çalıştırarak varlıkların ardışık adımlarda nasıl güncellendiğini gözlemliyoruz. Ana program kodumuz ise epeyce sade. Bir nevi uçtan uca test fonksiyonumuz diyebilirim.

```csharp
using NetBevy.Game;

namespace NetBevy;

internal class Program
{
    static void Main()
    {
        // Basic Sample
        GameApp.Run();
    }
}
```

İşte çalışma zamanı çıktımız.

![Write Own Bevy 02](/assets/images/2026/WriteOwnBevy_02.png)

## Daha Neler Yapılabilir?

Aslında planladığımız gibi *(en azından benim kafamda)* yürüyen iskelet hazır. Bir kütüphane haline getirildiğinde bileşen eklenebilen, sistem tanımlanıp işletilebilen bir oyun motoruna sahibiz fakat elbette çok fazla eksiği ve hatta iyileştirilmesi gereken yerler var. Örneğin;

- Query sınıfını geliştirmek gerekiyor. Birden fazla **IComponent** türevini ele alabilmeli.
- Sistem davranışlarında oyun dünyasında basit aksiyonları yapabilecek **Command** bileşen entegrasyonu gerekli. Örneğin bir sistem içerisinde bir varlık oluşturmak World nesnesindeki **Entity** zincirine bir nesne örneği eklemek demek. Bu kabiliyet kazandırılabilir.
- Oyun motorları varlıklarla ilişkilendirilecek asset'ler için bir yönetici mekanizma sunuyor. Zira ses, animasyon akışı, resim gibi birçok asset söz konusu. Bunların bellek dostu olacak şekilde yönetilmesi başlı başına bir mevzu. Örneğin On My Way örneğimizdeki `spawn_spaceship` metodu **Resource** olarak bir **AssetServer** alıyor ve onun `load` metodu ile yeni bir varlık tanımlanırken ilişkilendiriliyor. Böylece **draw** mekanizması uzay gemisi varlığı için sahneye ilgili asset'i çizeceğini de biliyor. Büyük çaplı bir oyunda load metodunun gecikmesiz çalışması, gereksiz yere yükleme yapmaması, zaten var ama ihtiyaç yoksa alandan atması gibi düşünülmesi gereken birçok şey var.
- Şu anki sürüm sadece terminalden çalışan bir motor vaat ediyor. Ekran çizdirebilmeli, kamerayı **2D** veya **3D** olma durumuna göre ayarlayabilmeli ve bunları cross-platform sağlarken varsayılan versiyonlarını da programcıya sağlayabilmeli.
- Sistemlerin çalışma sırası şu an tamamen eklenme sırasına bağlı. `before/after` gibi bağımlılık bildirimleriyle deterministik bir sıralama garanti altına alınabilir.
- Varlık ve bileşen çıkarma *(despawn, RemoveComponent)* yeteneği yok. Şu an motor sadece varlık ekleme işlemlerini yapabiliyor. Bir füze menzil dışına çıktığında ya da bir meteor vurulduğunda onu dünyadan silme gerekiyor. Bunu yabana atmayın. Füzeler oluştukça belleği bir anda şişirebilirler ve oyun kitlenebilir *(Açıkçası .Net gibi bir ortam yerine bellek güvenliği konusunda çok daha titiz olan Rust bu açıdan her zaman önde bana kalırsa)*
- `Scheduler.Run` içerisindeki reflection tabanlı çözümleme her çalıştırmada tekrar tekrar ve tekrar yapılıyor :) Bu maliyet bir Source Generator ya da derleme zamanı kod üretimiyle önemli ölçüde azaltılabilir esasında. İşte bakılacak bir konu daha. Source Generator.
- Sistemler arası iletişim için Bevy'deki `Message/Event` kavramına benzer bir yapı eklenebilir. Oyun başladı veya bitti gibi durumları bildirmek için böyle bir mekanizma epeyce faydalı olur.
- ve daha birçok şey...

Bu liste elbette uzatılabilir. Asıl mesele küçük ama çalışan bir çekirdekten yola çıkıp üzerine katman katman eklemek.

## Sonuç

Görüldüğü üzere, birkaç arayüz ve reflection tabanlı bir Scheduler ile bile temel bir **ECS** mimarisinin iskeletini `C#` tarafında ayağa kaldırmak mümkün. Elbette bu Bevy'nin sunduğu zenginliğin çok gerisinde. Ne paralel çalışan sistemler var, ne asset yönetimi ne de deklaratif bir plugin sistemi. Ama amaç zaten bunları birebir yeniden inşa etmek değildi. Kompozisyon, veri ile davranışın ayrılması ve sorgu *(query)* tabanlı sistemlerin nesne yönelimli bir dilde nasıl karşılık bulabileceğini elle deneyerek görmekti.

Bir sonraki adımda yapmayı uzun süredir ertelediğim birkaç şey var. **Query** sınıfını çoklu bileşen destekleyecek şekilde genişletmek, **Command** deseni ile sistemler içinde güvenli biçimde varlık oluşturmak, silmek ve **reflection** yükünü bir Source Generator ile derleme zamanına taşımak. Belki bunları da ayrı bir yazıda ele alırım. Böylece geldik bir çalışmamızın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

- Kod örneklerinin ilk haline [github](https://github.com/buraksenyurt/friday-night-programmer/tree/main/src/NetBevy) reposundan ulaşabilirsiniz.
- Ancak devam eden serüvene dahil olmak isterseniz *(Örneğin Source Code Generator eklenmiş bir versiyonu görmek)* [buradaki](https://github.com/buraksenyurt/friday-night-programmer/tree/main/src/BevyDotNet) örneğe de bakabilirsiniz.

[Orijinal Kaynak](https://www.buraksenyurt.com/post/c-ile-basit-bir-ecs-denemesi)
