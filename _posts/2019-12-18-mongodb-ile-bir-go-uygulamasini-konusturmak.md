---
layout: post
title: "MongoDB ile Bir GO Uygulamasını Konuşturmak"
date: 2019-12-18 08:00:00
tags:
  - golang
  - mongodb
  - docker
  - gRPC
  - pomodoro
  - rest-api
  - api
  - protobuf
  - container
  - brew
  - proto
  - json
categories:
  - Programlama Dilleri
---
Teknoloji baş döndüren bir hızla ilerlerken beynimizin tembelleştiğini de kabul etmemiz gerekiyor. Artık pek çok işimiz otonomlaştırıldığından zihnimiz eski egzersizleri yapmıyor. Yıllar önce İngiltere'de yapılan bir araştırmada çocukların hesap makinesi kullanması sebebiyle temel dört işlem matematiğinde sorunlar yaşadığı tespit edilmişti. Yine Kanada'da yapılan bir araştırma insanların dikkat dağılma sürelerinin 8 saniyelere kadar indiğini gösterdi. Hafızamızı dinç tutma noktasında Japon balıkları ile yarışır bir konumda olduğumuz da aşikar. Kaçımız aklından ezbere 4 telefon numarasını sayabilir (Üç haneliler yasak) Otonomlaşan dünya sebebiyle tembelleşen ve dış uyarıcılar yüzünden sürekli dikkati dağılan zihnimiz...Gerçekten de dikkatimizi dağıtan, odaklanmamızı bozan o kadar çok şey var ki. Dolayısıyla kendimizi yetiştirmek istediğimiz konulara çalışırken ne kadar verimli olabiliyoruz bir bakmak gerekiyor. Tekrar satın alınamayacak olan zamanın ne kadar kıymetli olduğunu düşünürsek verimli çalışmanın ilerleyen yaşlarda çok çok önemli bir mesele haline geldiğini vurgulamak isterim.

![screenshot_9.png](/assets/images/2019/screenshot_9.png)

İşte bu sebepten birkaç haftadır [Saturday-Night-Works](https://github.com/buraksenyurt/saturday-night-works) çalışmalarım sırasında pomodoro tekniğini neden kullanmadığımı karar kara düşünmekteyim. Oysa ki çok verimli bir çalışma pratiği. Atladığım bu önemli detayı SkyNet çalışmalarımın ilk gününden itibaren uygulamaya karar verdim. Genellikle gece 22:00 sularında başlayarak 4X25 dakikalık seanslar halinde ilerliyorum. Her seans arasında 5er dakikalık standart molalar var. Tabii bu tekniği uygularken en önemli kural çalışmayı bölecek unsurları mutlak suretle dışarıda bırakmak. Cep/ev telefonu, televizyon, radyo, e-mail programı ve benzeri odak dağıtıcı ne kadar şey varsa kapatmak gerekiyor. Bunun faydasını epeyce gördüğümü ve 25 dakikalık zaman dilimlerindeki çalışmalardan iyi seviyede verim aldığımı ifade edebilirim. Aranızda uygulamayanlar varsa bir göz atsınlar derim;)

> Pomodoro tekniğini uygularken size akıllı bir kronometre gerekecek. Tarayıcıda çalışan [Tomato-Timer](https://tomato-timer.com/) tam size göre. Hatta Visual Studio Code için eklentisi bile var;)

Gelelim SkyNet'te geçirdiğim ikinci güne. Elimizdeki malzemeleri sayalım. MongoDB için bir docker imajı, gRPC ve GoLang. Bu üçünü kullanarak CRUD (Create Read Update Delete) operasyonlarını icra eden basit bir uygulama geliştirmek niyetindeyim. Bir önceki öğretide Redis docker container'dan yararlanmıştım. Kaynakları kıymetli olan Ahch-To sistemini kirletmemek adına MongoDB için de benzer şekilde hareket edeceğim. Açıkçası GoLang bilgim epey paslanmış durumda ve sistemde yüklü olup olmadığını dahi bilmiyorum.

```bash
go version
```

terminal komutu da bana yüklü olmadığını söylüyor. Dolayısıyla ilk adım onu MacOS üzerine kurmak.

## İlk Hazırlıklar (Go Kurulumu ve MongoDB)

GoLang'i Ahch-To adasına yüklemek için [şu adrese](https://golang.org/dl/) gidip Apple macOS sürümünü indirmem gerekti. Ben öğretiyi hazırlarken go1.13.4.darwin-amd64.pkg dosyasını kullandım. Kurulum işlemini tamamladıktan sonra komut satırından go versiyonunu sorgulattım ve aşağıdaki çıktıyı elde ettim.

![11_02_screenshot_1.png](/assets/images/2019/11_02_screenshot_1.png)

Pek tabii içim rahat değildi. Versiyon bilgisi gelmişti ama bir "hello world" uygulamasını çalışır halde görmeliydim ki kurulumun sorunsuz olduğundan emin olayım. Hemen resmi dokümanı takip ederek $HOME\go\src\ altında helloworld isimli bir klasör açıp aşağıdaki kod parçasını içeren helloworld.go dosyasını oluşturdum (Visual Studio Code kullandığım için editörün önerdiği go ile ilgili extension'ları yüklemeyi de ihmal etmedim)

```go
package main
 
import "fmt"
 
func main() {
    fmt.Printf("Artık go çalışmaya hazırım :) \n")
}
```

Terminalden aşağıdaki komutları işlettikten sonra çıktıyı görebildim.

```bash
go build
./helloworld
```

![11_02_screenshot_2.png](/assets/images/2019/11_02_screenshot_2.png)

Go ile kod yazabildiğime göre MongoDB docker imajını indirip bir deneme turuna çıkabilirim. İşte terminal komutları.

```bash
docker pull mongo
docker run -d -p 27017-27019:27017-27019 --name gondor mongo
docker container ps -a
docker exec -it gondor bash
 
mongo
show dbs
use AdventureWorks
db.category.save({title:"Book"})
db.category.save({title:"Movie"})
db.category.find().pretty()
 
exit
exit
```

![11_02_screenshot_3.png](/assets/images/2019/11_02_screenshot_3.png)

İlk komutla mongo imajı çekiliyor. İzleyen komut docker container'ını varsayılan portları ile sistemin kullanımına açmak için. Container listesinde göründüğüne göre sorun yok. MongoDB veritabanını container üzerinden test etmek amacıyla içine girmek lazım. 4ncü komutu bu işe yarıyor. Ardından mongo shell'e geçip bir kaç işlem gerçekleştirilebilir. Önce var olan veritabanlarını listeliyor sonra AdventureWorks isimli yeni bir tane oluşturuyoruz. Devam eden kısımda category isimli bir koleksiyona iki doküman ekleniyor ve tümünü güzel bir formatta listeliyoruz. Arka arkaya gelen iki exit komutunu fark etmişsinizdir. İlki mongo shell'den, ikincisi de container içinden çıkmak için.

Ah çok önemli bir detayı unuttum! Örnekte gRPC protokolünü kullanacağız. Bu da bir proto dosyamız olacağı ve Golang için gerekli stub içeriğine derleyeceğimiz anlamına geliyor. Dolayısıyla sistemde protobuf ve go için gerekli derleyici eklentisine ihtiyacım var. brew ile bunları sisteme yüklemek oldukça kolay.

```bash
brew install protobuf
protoc --version
brew install protoc-gen-go
```

Kod tarafına geçmeye hazırız ama öncesinde ufak bir bilgi.

## gRPC Hakkında Azıcık Bilgi

| **REST Tarafı** | **gRPC Tarafı** |
| --- | --- |
| HTTP 1.1 nedeniyle gecikme yüksek | HTTP/2 sebebiyle daha düşük gecikme |
| Sadece Request/Response | Stream desteği(Örneğimizde bir kullanımı var) |
| CRUD odaklı servisler için | API odaklı(Burada CRUD odaklı yapacağız çaktırmayın) |
| HTTP Get,Post,Put,Delete gibi fiil tabanlı | RPC tabanlı, sunucu üzerinden fonksiyon çağırabilme özelliği |
| Sadece Client->Server yönlü talepler | Çift yönlü ve asenkron iletişim |
| JSON kullanıyor(serileşme yavaş, boyut büyük) | Protobuffer kullanıyor(veri daha küçük boyutta ve serileşme hızlı) |

Gelelim kod tarafına... Uygulamanın temel klasör yapısını aşağıdaki gibi oluşturabiliriz. Ben bu işlemleri $HOME\go\src\ altında gerçekleştirdim.

```bash
mkdir gRPC-sample
cd gRPC-sample
mkdir playerserver
mkdir clientapp
mkdir proto
```

playerserver ve clientapp tahmin edileceği üzere sunucu ve istemci uygulama görevini üstleniyorlar. proto klasöründe yer alan player.proto, gRPC mesaj sözleşmesine ait tanımlamaları içermekte. Servis metodları, parametre tipleri ve içerikleri bu dosyada aşağıdaki gibi bildiriliyor.

```protobuf
syntax="proto3"; //protobuffers v3 versiyonu kullaniliyor
 
package player; // proto paketinin adi
option go_package="playerpb"; // generate edilecek go paketinin adi
 
// Player mesaj tipinin tanimi
message Player{
    string id=1;
    string player_id=2;
    string fullname=3;
    string position=4;
    string bio=5;
}
 
// Operasyonlarin kullandigi request ve response mesajlarina ait tanimlamalar
message AddPlayerReq{
    Player plyr=1;
}
 
message AddPlayerRes{
    Player plyr=1;
}
 
message EditPlayerReq{
    Player plyr=1;
}
 
message EditPlayerRes{
    Player plyr=1;
}
 
message RemovePlayerReq{
    string player_id=1;
}
 
message RemovePlayerRes{
    bool removed=1;
}
 
message GetPlayerReq{
    string player_id=1;
}
 
message GetPlayerRes{
    Player plyr=1;
}
 
message GetPlayerListReq{}
 
message GetPlayerListRes{
    Player plyr=1;
}
 
// servis ve operasyon tanimlari
service PlayerService{
    rpc GetPlayer(GetPlayerReq) returns (GetPlayerRes);
    rpc GetPlayerList(GetPlayerListReq) returns (stream GetPlayerListRes); //server bazlı streaming kullanacağımız için dönüş parametresi stream tipinden
    rpc AddPlayer(AddPlayerReq) returns (AddPlayerRes);
    rpc EditPlayer(EditPlayerReq) returns (EditPlayerRes);
    rpc RemovePlayer(RemovePlayerReq) returns (RemovePlayerRes);
}
```

Bu içeriği Go tarafında kullanabilmek için derlememiz lazım. Derlemeyi aşağıdaki terminal komutu ile gerçekleştirebiliriz (proto dosyasını VS Code tarafında daha kolay düzenlemek için vscode-proto3 isimli extension'ı kullandım)

```text
protoc player.proto --go_out=plugins=grpc:.
```

Proto dosyasının tamamlanmasını takiben playerserver klasöründeki main.go dosyasını yazmaya başlayabiliriz. Biraz uzun bir kod dosyası ama sabırla yazıp, yorum satırlarını da okuyarak neler yaptığımızı anlamaya çalışmakta yarar var.

```go
package main
 
import (
    "context"
    "fmt"
    "net"
    "os"
    "os/signal"
    "strings"
 
    "go.mongodb.org/mongo-driver/bson/primitive"
 
    playerpb "gRPC-sample/proto"
 
    "go.mongodb.org/mongo-driver/bson"
    "go.mongodb.org/mongo-driver/mongo"
    "go.mongodb.org/mongo-driver/mongo/options"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)
 
/* proto'dan otomatik üretilen player.pb.go içerisindeki RegisterPlayerServiceServer metoduna bir bakın.
Pointer olarak gelen grpc server nesnesi ikinci parametre olarak gelen tipi register etmek için kullanılır.
Bir nevi interface üzerinden enjekte işlemi yaptığımızı düşünebilir miyiz?
*/
type PlayerServiceServer struct{}
 
var db *mongo.Client
var playerCollection *mongo.Collection
var mongoContext context.Context
 
func main() {
    // TCP üzerinden 5555 nolu portu dinleyecek olan nesne oluşturuluyor
    server, err := net.Listen("tcp", ":5555")
    // Olası bir hata durumunu kontrol ediyoruz
    if err != nil {
        fmt.Printf("5555 dinlenemiyor: %v", err)
    }
 
    // gPRC sunucusu için kayıt(register) işlemleri
    grpcOptions := []grpc.ServerOption{}
    // yeni bir grpc server oluşturulur
    grpcServer := grpc.NewServer(grpcOptions...)
    // Bir PlayerService tipi oluşturulur
    playerServiceType := &PlayerServiceServer{}
    // servis sunucu ile birlikte kayıt edilir
    playerpb.RegisterPlayerServiceServer(grpcServer, playerServiceType)
 
    // mongoDB bağlantı işlemleri
    fmt.Println("MongoDB sunucusuna bağlanılıyor")
    mongoContext = context.Background()
    // bağlantı deneniyor
    db, err = mongo.Connect(mongoContext, options.Client().ApplyURI("mongodb://localhost:27017"))
    // olası bir bağlantı hatası varsa
    if err != nil {
        fmt.Println(err)
    }
    // Klasik ping metodunu çağırıyoruz
    err = db.Ping(mongoContext, nil)
    if err != nil {
        fmt.Println(err)
    } else {
        // çağrı başarılı olursa bağlandık demektir
        fmt.Println("MongoDB ile bağlantı sağlandı")
    }
    // nba isimli veritabanındaki player koleksiyonuna ait bir nesne örnekliyoruz
    // veritabanı ve koleksiyon yoksa oluşturulacaktır
    playerCollection = db.Database("nba").Collection("player")
 
    // gRPC sunucusunu aktif olan TCP sunucusu içerisinde bir child routine olarak başlatıyoruz
    go func() {
        if err := grpcServer.Serve(server); err != nil {
            fmt.Println(err)
        }
    }()
    fmt.Println("Sunucu 5555 nolu porttan gPRC tabanlı iletişime hazır.\nDurdurmak için CTRL+C.")
 
    // CTRL+C ile başlayan kapatma operasyonu
    cnl := make(chan os.Signal)      // işletim sisteminde sinyal alabilmek için bir kanal oluşturduk
    signal.Notify(cnl, os.Interrupt) // CTRL+C mesajı gelene kadar ana rutin açık kalacak
    <-cnl
 
    fmt.Println("Sunucu kapatılıyor...")
    grpcServer.Stop() // gRPC sunucusunu durdur
    server.Close()    // TCP dinleyicisini kapat
    fmt.Println("GoodBye Crow")
}
 
/* Protobuf mesajlarında taşınan serileşmiş içeriği nesnel olarak ele alacağımı struct */
type Player struct {
    ID       primitive.ObjectID `bson:"_id,omitempty"` // MongoDB tarafındaki ObjectId değerini taşır
    PlayerID string             `bson:"player_id"`
    Fullname string             `bson:"fullname"`
    Position string             `bson:"position"`
    Bio      string             `bson:"bio"`
}
 
/* PlayerServiceServer'ın uygulanması gereken metodlarını. Yani servis sözleşmesinin tüm operasyonları
 */
 
// Yeni bir oyuncu eklemek için kullanacağımız fonksiyon
func (srv *PlayerServiceServer) AddPlayer(ctx context.Context, req *playerpb.AddPlayerReq) (*playerpb.AddPlayerRes, error) {
    payload := req.GetPlyr() // GetPlyr (GetPlayer değil o servis metodumuz) fonksiyonu ile request üzerinden gelen player içeriği çekilir
 
    // İçerik ile gelen alan değerleri player struct nesnesini oluşturmak için kullanılır
    player := Player{
        PlayerID: payload.GetPlayerId(),
        Fullname: payload.GetFullname(),
        Position: payload.GetPosition(),
        Bio:      payload.GetBio(),
    }
 
    // player nesnesi mongodb veritabanındaki koleksiyona kayıt edilir
    result, err := playerCollection.InsertOne(mongoContext, player)
 
    // bir problem oluştuysa
    if err != nil {
        // gRPC hatası döndürülür
        return nil, status.Errorf(
            codes.Internal,
            fmt.Sprintf("Bir hata oluştu : %v", err),
        )
    }
 
    // Hata oluşmadıysa koleksiyona eklenen yeni doküman
    // üretilen ObjectID değeri de atanarak geri döndürülür
    objectID := result.InsertedID.(primitive.ObjectID)
    payload.Id = objectID.Hex()
    return &playerpb.AddPlayerRes{Plyr: payload}, nil
}
 
func (srv *PlayerServiceServer) EditPlayer(ctx context.Context, req *playerpb.EditPlayerReq) (*playerpb.EditPlayerRes, error) {
    return nil, nil
}
 
func (srv *PlayerServiceServer) RemovePlayer(ctx context.Context, req *playerpb.RemovePlayerReq) (*playerpb.RemovePlayerRes, error) {
    // önce silinmek istenen playerId bilgisi alınır
    id := strings.Trim(req.GetPlayerId(), "\t \n")
    fmt.Println(id)
    // DeleteOne metodu ile silme operasyonu gerçekleştirilir
    _, err := playerCollection.DeleteOne(ctx, bson.M{"player_id": id})
 
    // hata kontrolü yapılıyor
    if err != nil {
        return nil, status.Errorf(codes.NotFound, fmt.Sprintf("Silinmek istenen oyuncu bulunamadı. %s", err))
    }
 
    // hata yoksa işlemin başarılı olduğuna dair sonuç dönülür
    return &playerpb.RemovePlayerRes{
        Removed: true,
    }, nil
}
 
// MongoDB'deki ID bazlı olarak oyuncu verisi döndüren metodumuz
func (srv *PlayerServiceServer) GetPlayer(ctx context.Context, req *playerpb.GetPlayerReq) (*playerpb.GetPlayerRes, error) {
    // request ile gelen player_id bilgisini alıyoruz
    // Trim işlemi önemli. İstemci terminalden değer girdiğinde alt satıra geçme işlemi söz konusu.
    // Veri bu şekilde gelirse kayıt bulunamaz. Dolayısıyla bir Trim işlemi yapıyoruz
    id := strings.Trim(req.GetPlayerId(), "\t \n")
    // bson.M metoduna ilgili sorguyu ekleyerek oyuncuyu koleksiyonda arıyoruz
    result := playerCollection.FindOne(ctx, bson.M{"player_id": id})
 
    player := Player{}
    // bulunan oyuncu decode metodu ile ters serileştirilip player değişkenine alınır
    if err := result.Decode(&player); err != nil {
        return nil, status.Errorf(codes.InvalidArgument, fmt.Sprintf("Sanırım aranan oyuncu bulunamadı %v", err))
    }
 
    // Decode işlemi başarılı olur ve koleksiyondan bulunan içerik player isimli değişkene ters serileşebilirse
    // artık dönecek response nesne içeriğini hazırlayabiliriz
    res := &playerpb.GetPlayerRes{
        Plyr: &playerpb.Player{
            Id:       player.ID.Hex(),
            PlayerId: player.PlayerID,
            Fullname: player.Fullname,
            Position: player.Position,
            Bio:      player.Bio,
        },
    }
    return res, nil
}
 
// Tüm oyuncu listesini stream olarak dönen metod
func (srv *PlayerServiceServer) GetPlayerList(req *playerpb.GetPlayerListReq, stream playerpb.PlayerService_GetPlayerListServer) error {
 
    currentPlayer := &Player{}
 
    // Find metodu veri üzerinden hareket edebileceğimiz bir Cursor nesnesi döndürür
    // bu cursor nesnesi sayesinde istemciye tüm oyuncu listesini bir seferde göndermek yerine
    // birer birer gönderme şansına sahip olacağız
    // Bu nedenle sunucu bazlı bir streamin stratejimiz var
    cursor, err := playerCollection.Find(context.Background(), bson.M{})
    if err != nil {
        return status.Errorf(codes.Internal, fmt.Sprint("Bilinmeyen hata oluştu"))
    }
 
    // metod işleyişini tamamladığında cursor nesnesini kapatacak çağrıyı tanımlıyoruz
    defer cursor.Close(context.Background())
 
    // iterasyona başlanır ve Next true döndüğü sürece devam eder
    // yani okunacak mongodb dokümana kalmayana dek
    for cursor.Next(context.Background()) {
        // cursor verisini currentPlayer nesnesine açıyoruz
        cursor.Decode(currentPlayer)
        // istemciye mongodb'den gelen güncel oyuncu bilgisinden yararlanarak cevap dönüyoruz
        stream.Send(&playerpb.GetPlayerListRes{
            Plyr: &playerpb.Player{
                Id:       currentPlayer.ID.Hex(),
                PlayerId: currentPlayer.PlayerID,
                Fullname: currentPlayer.Fullname,
                Position: currentPlayer.Position,
                Bio:      currentPlayer.Bio,
            },
        })
    }
 
    return nil
}
```

Sunucu tarafındaki kodlama tamamlandıktan sonra istemci tarafı için clientapp altında tester.go isimli bir başka dosya oluşturarak ilerleyelim. Burada komut satırından temel CRUD operasyonlarını icra edeceğiz. Yeni bir oyuncunun eklenmesi, bir oyuncu bilgisinin çekilmesi, tüm oyuncuların listesinin alınması vb

```go
package main
 
import (
    "bufio"
    "context"
    "fmt"
    "io"
    "os"
    "strings"
 
    playerpb "gRPC-sample/proto"
 
    "google.golang.org/grpc"
)
 
var client playerpb.PlayerServiceClient
var reqOptions grpc.DialOption
 
func main() {
 
    // HTTPS ayarları ile uğraşmak istemedim
    reqOptions = grpc.WithInsecure()
    // gRPC servisi ile el sıkışmaya çalışıyoruz
    connection, err := grpc.Dial("localhost:5555", reqOptions)
    if err != nil {
        fmt.Println(err)
        return
    }
    // proxy nesnesini ilgili bağlantıyı kullanacak şekilde örnekliyoruz
    client = playerpb.NewPlayerServiceClient(connection)
 
    // Oyuncu ekleyelim
    insertPlayer()
    // tüm oyuncu listesini çekelim
    getAllPlayerList()
 
    // sembolik olarak ID bazlı 3 oyuncu aratalım
    for i := 0; i < 3; i++ {
        reader := bufio.NewReader(os.Stdin)
        fmt.Println("Oyuncu IDsini gir.")
        playerID, _ := reader.ReadString('\n')
        getByPlayerID(playerID)
    }
 
    // Silme operasyonunu deniyoruz
    reader := bufio.NewReader(os.Stdin)
    fmt.Println("Silmek istediğiniz oyuncunun IDsini girin.")
    playerID, _ := reader.ReadString('\n')
    removePlayerByID(playerID)
 
    // tüm oyuncu listesini çekelim
    getAllPlayerList()
}
 
func insertPlayer() {
    // Yeni oyuncu eklenmesi için deneme kodu
    // Veri ihlalleri örneğin basitliği açısından göz ardı edilmiştir
    reader := bufio.NewReader(os.Stdin)
    fmt.Println("Yeni oyuncu girişi")
    fmt.Println("Id->")
    id, _ := reader.ReadString('\n')
    id = strings.Replace(id, "\n", "", -1)
    fmt.Println("Adı->")
    fullname, _ := reader.ReadString('\n')
    fullname = strings.Replace(fullname, "\n", "", -1)
    fmt.Println("Pozisyon->")
    position, _ := reader.ReadString('\n')
    position = strings.Replace(position, "\n", "", -1)
    fmt.Println("Kısa biografisi->")
    bio, _ := reader.ReadString('\n')
    bio = strings.Replace(bio, "\n", "", -1)
 
    // protobuf dosyasındaki şemayı kullanarak örnek bir oyuncu nesnesi örnekliyoruz
    newPlayer := &playerpb.Player{
        PlayerId: id,
        Fullname: fullname,
        Position: position,
        Bio:      bio,
    }
 
    // servisin AddPlayer metodunu o anki context üzerinden çalıştırıp
    // request payload içerisinde yeni oluşturduğumuz nesneyi gönderiyoruz
    res, err := client.AddPlayer(
        context.TODO(),
        &playerpb.AddPlayerReq{
            Plyr: newPlayer,
        },
    )
    if err != nil {
        fmt.Println(err)
        return
    }
    // Eğer bir hata oluşmamışsa MongoDB tarafından üretilen ID değerini ekranda görmemiz lazım
    fmt.Printf("%s ile yeni oyuncu eklendi \n", res.Plyr.Id)
}
 
// Tüm oyuncu listesini çektiğimiz metod
func getAllPlayerList() {
 
    // önce request oluşturulur
    req := &playerpb.GetPlayerListReq{}
 
    // proxy nesnesi üzerinden servis metodu çağrılır
    s, err := client.GetPlayerList(context.Background(), req)
    if err != nil {
        fmt.Println(err)
        return
    }
 
    // sunucu tarafından stream bazlı dönüş söz konusu
    // yani kaç tane oyuncu varsa herbirisi için sunucudan istemciye
    // cevap dönecek
    for {
        res, err := s.Recv() // Recv metodu player.pb.go içerisine otomatik üretilmiştir. İnceleyin ;)
        if err != io.EOF {   // döngü sonlanmadığı sürece gelen cevaptaki oyuncu bilgisini ekrana yazdırır
            fmt.Printf("[%s] %s - %s \n\n", res.Plyr.PlayerId, res.Plyr.Fullname, res.Plyr.Bio)
        } else {
            break
        }
    }
}
 
// Oyuncuyu PlayerID değerinden bulan metodumuz
func getByPlayerID(playerID string) {
    // parametre olarak gelen playerID değerinden bir request oluşturulur
    req := &playerpb.GetPlayerReq{
        PlayerId: playerID,
    }
    // GetPlayer servis metoduna talep gönderilir
    res, err := client.GetPlayer(context.Background(), req)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Println(res.Plyr.Fullname)
}
 
// Oyuncu silme fonksiyonumuz
func removePlayerByID(playerID string) {
    // RemovePlayer servis çağrısı için gerekli Request tipi hazırlanır
    req := &playerpb.RemovePlayerReq{
        PlayerId: playerID,
    }
    // servisi çağrısı yapılıp sonucu kontrol edilir
    _, err := client.RemovePlayer(context.Background(), req)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Println("Oyuncu silindi")
}
```

Piuvvv!!! Uzun bir yol oldu. Öyleyse çalışma zamanı sonuçlarımıza bakalım mı?

## Çalışma Zamanı

İlk gün çalışmasının meyveleri pek fena değil. server ve client tarafa ait go dosyalarını kendi klasörlerinde aşağıdaki terminal komutları ile derledikten sonra

```bash
go build main.go
go build tester.go
```

önce sunucu ardından istemci programlarını çalıştırıp kodlaması ilk önce biten AddPlayer fonksiyonunu deneme şansı buldum. Birkaç oyuncu verisini girdikten sonra mongodb container'ına ait shell'e bağlanıp gerçekten de yeni dokümanların player koleksiyonuna eklenip eklenmediğine baktım. Sonuç tebessüm ettiriciydi:) İstemci uygulama gRPC üzerinden sunucuya mesaj göndermiş, sunucuya gelen içerik docker container üzerinde duran mongodb veritabanına yazılmıştı.

![11_02_screenshot_4.png](/assets/images/2019/11_02_screenshot_4.png)

İkinci gün tüm oyuncu listesini gRPC üzerinden istemciye döndüren süreci yazmaya çalıştım. İlk başta yaptığım bir hata nedeniyle epey vakit kaybettim. GetPlayerList metodunu protobuffer dosyasında stream döndürecek şekilde tasarlamamıştım. Büyük bir veri kümesini filtresiz çektiğimizde bu ağ trafiğinin sağlıklı çalışması açısından sorun olabilir. Oyuncuları sunucudan istemciye doğru bir stream üzerinden tek tek göndermek çok daha mantıklı (Burada REST ile gRPC arasındaki farkları hatırlayalım) Sonunda servis sözleşmesini değiştirip gerekli düzenlemeleri yaptıktan sonra aşağıdaki ekran görüntüsünde yer alan mutlu sona ulaşmayı başardım.

![11_02_screenshot_5.png](/assets/images/2019/11_02_screenshot_5.png)

Devam eden gün bir öncekine göre daha zorlu geçti. FindOne metodunu player_id değerine göre çalıştırmayı bir türlü başaramadım. Neredeyse 4 pomodoro periyodu uğraştım. Hatta pomodoro süreci bittikten sonra farkında olmadan saatlerce bilgisayar başında kaldım. Sorunu araştırırken vakit nasıl geçti anlamamışım. Sonuçta işe 3 saatlik uykuyla gittim. Ertesi gün Ahch-To'nun tuşuna bile basmadım. Bir günlük ara, problemi çözmem için beni sakinleştirmeye yeterdi. Nihayetinde sorunu buldum. İstemci aradığı ID değerini girip sunucuya çağrı yaptığında, servis metoduna gelen ID bilgisinin sonunda boşluk ve alt satıra geçme karakterleri de geliyordu. Trim fonksiyonu ile bu durumun oluşmasını engelledikten sonra silme operasyonunu da işin içerisine dahil ettim ve güncelleme operasyonu hariç komple bir test yaptım. Sonuçlar ekran görüntüsünde olduğu gibi tatmin ediciydi.

![11_02_screenshot_6.png](/assets/images/2019/11_02_screenshot_6.png)

Silme operasyonuna ilişkin çalışmaya ait örnek bir ekran görüntüsü de aşağıdaki gibi.

![11_02_screenshot_7.png](/assets/images/2019/11_02_screenshot_7.png)

## Neler Öğrendim?

Elbette SkyNet'te geçirdiğim bugünün de bana öğrettiği bir sürü şey oldu. Bunları aşağıda yer alan maddelerle ifade etmeye çalıştım.

- Bir protobuf dosyası nasıl hazırlanır ve Go tarafında kullanılabilmesi için nasıl derlenir,
- Go tarafından MongoDB ile nasıl haberleşilir,
- MongoDB docker container'ına ait shell üstünde nasıl çalışılır,
- Temel mongodb komutları nelerdir,
- Sunucudan istemciye stream açarak tek tek mongo db dokümanı nasıl döndürülür (main.go'daki GetPlayerList metoduna bakın)

## Eksikliği Hissedilen Konular

Her ne kadar pomodoro tekniği ile çalışmalarımı olabildiğince verimli hale getirsem de ister istemez yaşlı zihnim yoruluyor. Dolayısıyla şunları da yapabilsem iyi olurdu dediğim şeyler var. Bunları da şu iki madde ile sıralayabilirim.

- İstemci tarafını Go tabanlı bir web client olarak geliştirmeyi deneyebiliriz. Terminalden hallice daha iyidir. En azından çalışma sırasında yaşadığım Trim ihlali oluşmaz.
- Bir çok sunucu metodunda hata kontrolü var ancak bunların çalışıp çalışmadığı test etmek gerekiyor. Yani Code Coverage değerimizi neredeyse 0. Yazıyla sıfır:) Bir Go uygulamasındaki fonksiyonlar için Unit Test'ler nasıl yazılır öğrenmem lazım.

## Görev Listeniz

Ve tabii kabul ederseniz sizin için iki güzel görevim var:)

- Select * from players where fullname like 'A%' gibi bir sorguya karşılık gelecek mongodb fonksiyonunu geliştirip uygulamaya ekleyin.
- Güncelleme fonksiyonunu tamamlayın.

Böylece geldik SkyNet'te bir günün daha sonuna. Sonraki çalışmada Wails paketini kullanarak Go ile yazılmış bir masaüstü programı geliştirmek niyetindeyim. O zaman dek hepinize mutlu günler dilerim.

[Orijinal Kaynak](https://www.buraksenyurt.com/post/mongodb-ile-bir-go-uygulamasini-konusturmak)
