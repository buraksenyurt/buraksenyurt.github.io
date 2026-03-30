---
layout: post
title: "Transaction Kavramı"
date: 2003-11-17 10:00:00 +0300
categories:
  - Framework Tabanlı Programlama
tags:
  - ado.net
  - transaction
  - sql
  - stored-procedures
---
Bu makalemizde sizlere veritabanı programcılığında ve özellikle de çok katlı mimaride çok önemli bir yere sahip olan Transaction’lar hakkında bilgi vermeye çalışacağım. Her zaman olduğu gibi konuyu iyi anlayabilmek için bir de örnek uygulamamız olacak. Öncelikle Transaction nedir, ne işe yarar bunlardan bahsedelim. Çoğu zaman programlarımızda ardı ardına veritabanı işlemleri uygulatırız. Örneğin, bir veritabanındaki bir tablodan kayıt silerken, aynı olayın sonucunda başka bir ilişkili tabloya silinen bu verileri ekleyebilir veya güncelleyebiliriz. Hatta bu işlemin arkasından da silinen kayıtların bulunduğu tablo ile ilişkili başka tablolardan da aynı verileri sildiğimiz işlemleri başlatabiliriz. Dikkat edecek olursanız burada birbirleriyle ilintili ve ardışık işlemlerden söz ediyoruz.

Farz edelim ki, üzerinde çalıştığımız bu tablolar farklı veritabanı sunucularında bulunsun. Örneğin, birisi Adana’da diğeri Arnavutluk’ta ortağı olduğumuz şirketin sunucularında. Hatta bir diğeri de Kazakistan’daki ortağımızın birkaç sunucusunda bulunuyor olsun. E hadi bir tane de bizim sunucumuzda farklı bir veya birkaç tablo olsun. Şimdi düşünün ki, biz Kazakistan’a sattığımız malların bilgisini, Arnavutluk’taki ortağımızın sunucularına da bildiriyoruz.

Stoğumuzda bulunan mallardan 1000 adet televizyonu Kazakistan’a göndermek amacıyla ihraç birimimize rapor ediyoruz. İhraç birimi ilgili işlemleri yaptıktan sonra, Kazakistan’daki sunuculardan gelen ödeme bilgisini alıyor. Sonra ise stoktan 1000 televizyonu düşüyor, muhasebe kayıtlarını güncelliyor, Kazakistan’daki sunucularda stok artışını ve hesap eksilişlerini bildiriyor. Daha sonra ise, Arnavutluk’taki sunuculara stok artışı ve stok azalışlarını ve muhasebe hareketlerini belirtiyor. Senaryo bu ya. Çok hızlı bir teknolojik altyapıya sahip olduğumuzu ve bankalardan şirkete olan para akışlarının anında görülüp, tablolara yansıtılabildiğini ve bu sayede de stoklardaki hareketlerin ve şirket muhasebe kayıtlarındaki hareketlerin hemen gerçekleşebileceğini yani mümkün olduğunu düşünelim. (Değerli okuyucularım biliyorum ki uzun bir cümle oldu ama umarım gelmek istediğim noktayı anlamaya başlamışsınızdır)

Bahsettiğimiz tüm bu işlemler birer iş parçacığıdır ve aslında hepsi toplu olarak tek bir amaca hizmet etmektedir. Tüm sunucuları stok hareketlerinden ve gerekli muhasebe değişikliklerinden eş zamanlı olarak (aşağı yukarı yani) haberdar etmek ve veritabanı sunucularını güncellemek. Dolayısıyla tüm bu iş parçacıklarını, tek bir bütün işi gerçekleştirmeye çalışan unsurlar olduğunu söyleyebiliriz. İşte burada tüm bu iş parçacıkları için söylenebilecek bazı hususlar vardır. Öncelikle,

- İş parçacıklarının birinde meydana gelen aksaklık, diğer işlerin ve özellikle takip eden iş parçacıklarının doğru şekilde işlemesine neden olabilir. Dolayısıyla tüm bu iş parçacıkları başarılı olduğu takdirde bütün iş başarılı olmuş sayılabilir.
- Diğer yandan iş parçacıklarının işleyişi sırasında veriler üzerindeki değişikliklerin de tutarlı olması, birbirlerini tamamlayıcı nitelik taşıması gerekir. Söz gelimi stoklarımızda 2000 televizyon varken 1000 televizyon ihraç ettiğimizde stoğumuza mal eklenmediğini düşünecek olursak 1000 televizyon kalması gerekir. 1001 televizyon veya 999 televizyon değil. İşte bu verilerin tutarlılığını gerektirir.

İşte bu nedenlerden ötürü Transaction kavramı ortaya çıkarmıştır. Bu kavrama göre aslında bahsedilen tüm iş parçacıkları kusursuz olarak başarılı olduklarında “işlem tamam” denebilir. İşte biz de veritabanı uygulamalarımızı geliştirirken, bu tip iş parçacıklarını bir Transaction bloğuna alırız. Şimdi ise karşımıza iki yeni kavram çıkacaktır. Commit ve Rollback. Eğer Transaction bloğuna dahil edilen iş parçacıklarının tümü başarılı olmuş ise Transaction Commit edilir ve iş parçacıklarındaki tüm veri değişimleri gerçekten veritabanlarına yansıtılır. Ama iş parçacıklarından herhangi birinde tek bir hata oluşup iş parçacığının işleyişi bozulur ise bu durumda tüm Transaction Rollback edilir ve bu durumda, o ana kadar işleyen tüm iş parçacıklarındaki işlemler geri alınarak, veritabanları Transaction başlamadan önceki haline döndürülür. Bu bir anlamda güvenlik ve verileri koruma adına oluşturulmuş bir koruma mekanizmasıdır.

Peki ya iş parçacıklarının düzgün işlemeyişine sebep olarak neler gösterebiliriz. Tabii ki çevresel faktörler en büyük etkendir. Sunucuları birbirine bağlayan hatlar üzerinde olabilecek fiziki bir hasar işlemleri yarıda bırakabilir ve Kazakistan’daki sunuculardaki 1000 televizyonluk artış buraya hiç yansımayabilir. Kazakistan’daki yetkili Türkiye’deki merkezi arayıp “stoğumda hâlâ 1000 televizyon görünmüyor.” diyebilir. Merkezdeki yetkili ise, “Bizim stoklardan 1000 TV dün çıkmış. Bilgisayar kayıtları yalan mı söyleyecek kardeşim.” diyebilir. Neyse ki Transactionlar sayesinde olay şöyle gelişir.

Kazakistan Büro: Stokta bir hareket yok bir sorunmu var acaba?

Merkez: Evet. Karadenizden geçen boru hattında fırtına nedeni ile kopma olmuş. Mallar bizim stokta halen daha çıkmadılar. Gemide bekletiyoruz.

Çok abartı bir senaryo oldu aslında. Nitekim o televizyonlar bir şekilde yerine ulaşır Transaction’lara gerek kalmadan. Ama olayı umarım size betimleyebilmişimdir. Şimdi gelin olayın teknik kısmını bir de grafik üzerinde görelim.

![mk5_1.gif](/assets/images/2003/mk5_1.gif)

Şekil 1. Transaction Kavramı

Şekilde görüldüğü gibi örnek olarak 3 adet işlem parçacığı içeren bir Transaction bloğumuz var. Bu işlemler birbirine bağlı olarak tasvir edilmiştir. Eğer herhangi biri başarısız olursa veriler üzerinde o ana kadar olan değişiklikler geri alınır ve sistem Transaction başlamadan önceki haline konumlandırılır. Şekilimizde bunlar R-point yani Rollback Noktasına git olarak tasvir edilmiştir. Ancak tüm işlemler başarılı olursa Transaction içinde gerçekleşen tüm veri değişiklikleri onaylanmış demektir.

Transactionlar ile ilgili olarak önemli bir konu ise yukarıdaki örneklerde anlattığımız gibi birden fazla veritabanı olması durumunda bu Transaction işlemlerinin nasıl koordine edileceğidir. Burada Dağıtık Transaction dediğimiz Distributed Transaction kavramı ortaya çıkar. Bu konuyu ilerleyen makalelerimizde işlemeye çalışacağım. Şimdilik sadece tek bir veritabanı üzerinde yazabileceğimiz Transaction’lardan bahsetmek istiyorum. .NET içerisinde SqlClient sınıfında yer alan nesneleri Transaction nesneleri kullanarak bu işlemi gerçekleştirebiliriz. Ben SqlTransaction nesnesini ele alacağım. Bu nesneyi oluşturmak için herhangi bir yapıcı metod yoktur. SqlDataReader sınıfında da olduğu gibi bu sınıfa ait nesneler birer değişkenmiş gibi tanımlanır. Nesne atamaları SqlConnection nesnesi ile gerçekleştirilir ve bu aynı zamanda Transaction’ın hangi SqlConnection bağlantısı için başlatılacağını belirlemeye yarar.

```text
SqlTransaction tran;
tran = conNorthwind.BeginTransaction();
```

Yukarıdaki ifadeye dikkat edersek, bir SqlTransaction nesnesi tanımlanmış ve daha sonra conNorthwind isimli SqlConnection nesnesi için başlatılmıştır. İşte Transaction bloğunun başladığı nokta burasıdır. Şimdi ise, hangi Sql komutlarını dolayısıyla hangi iş parçacıklarını bu transaction nesnesine (yani bloğuna) dahil edeceğimizi belirlemeliyiz. Bu işlem genelde çalıştırılacak olan SqlCommand nesnelerinin Transaction özelliklerine Transaction nesnesinin atanması ile gerçekleştirilir. Dilerseniz gerçekçi bir örnek üzerinde çalışalım ve Transaction kavramını daha iyi anlayalım.

Merkezi İstanbul’da olan uluslararası devre mülk satan bir şirket, ülke ofislerinde satışını yaptığı devre mülkler için, satışı yapan personele ait banka hesaplarına EFT işlemi içeren bir uygulamaya sahip olsun. Bahsi geçen uygulamanın çalışmasına bir örnek verelim; Brezilya’daki ofisimizde bir satış personelimizin, devre mülk sattığını ve satış tutarı üzerinden %1 prim aldığını farz edelim. Yapılan satış sonucunda İstanbul’daki suncuda yer alan veritabanına ait tablolarda peşisıra işlemler yapıldığını varsayalım.

Personelin bilgilerinin olduğu tabloda alacağı toplam prim tutarı satış tutarının %1’i oranında artsın, ödenecek prime ait bilgiler ayrı bir tabloya işlensin ve aynı zamanda, şirkete ait finans kurumundaki toplam para hesabından bu prim tutarı kadar TL eksilsin. İşte bu üç işlemi göz önünde bulundurduğumuzda, tek bir işleme ait iş parçacıkları olduğunu anlayabiliriz. Dolayısıyla burada bir Transaction’dan rahatlıkla söz edebiliriz. Dilerseniz uygulamamıza geçelim. Öncelikle tablolarımıza bir göz atalım. IstanbulMerkez isimli veritabanımızda şu tablolar yer alıyor.

![mk5_2.gif](/assets/images/2003/mk5_2.gif)

Şekil 2. IstanbulMerkez veritabanındaki tablolar.

Buradaki tablolardan ve görevlerinden kısaca bahsedelim. Personel tablosunda personele ait bilgiler yer alıyor. Bu tablo Prim isimli tablo ile bire-çok ilişkiye sahip. AFinans ise, bize ait finans kurumunun kasasındaki güncel TL miktarını tutan bir tablo. Personel satış yaptığında, satış tutarı üzerinden hesaplanan prim, Personel tablosundaki PrimToplami alanının değerini %1 artırıyor, sonra Prim tablosuna bunu işliyor ve son olarak da AFinans tablosundaki Tutar alanından bahsi geçen %1'lik prim miktarını azaltıyor.

Peki buradaki üç işlem için neden Transaction kullanıyoruz? Farz edelim ki, Personel tablosunda PrimToplami alanının değeri arttıktan sonra, bir sorun nedeni ile veritabanına olan bağlantı kesilmiş olsun ve diğer işlemler gerçekleşmemiş olsun. Bu durumda personelin artan prim tutarını karşılayacak kadar TL’si finans kurumunun ilgili hesabından düşülmemiş olacağı için, finansal dengeler bozulmuş olacaktır. İşin içine para girdiği zaman Transaction’lar daha bir önem kazanmaktadır. Uygulamamızı basit olması açısından Console uygulaması olarak geliştireceğim. Haydi başlayalım. İşlemlerin kolay olması açısından başlangıç için Personel tablosuna bir kayıt girdim. Şu an için görüldüğü gibi PrimToplami alanının değeri 0 TL’dir. Ayrıca AFinans tablosunda bir başlangıç tutarımızın olması gerekiyor.

![mk5_3.gif](/assets/images/2003/mk5_3.gif)

Şekil 3. Personel Tablosu

![mk5_4.gif](/assets/images/2003/mk5_4.gif)

Şekil 4. Afinans tablosu

Uygulamamızda, Personel tablosunda yer alan PrimToplami alanının değerini prim tutarı kadar arttırmak için aşağıdaki Stored Procedure’ü kullanacağız.

```text
CREATE PROCEDURE [Prim Toplami Arttir] 
@prim float,

@pid int 

AS 
UPDATE Personel SET PrimToplami = PrimToplami+@prim
WHERE PersonelID=@pid 
GO
```

Prim tablosuna eklenecek veriler için ise INSERT sql cümleciği içeren bir Stored Procedure’ümüz var.

```text
CREATE PROCEDURE [Prim Bilgisi Gir] 
@pid int,
@st float,
@p float,
@str datetime 
AS 
INSERT INTO Prim (PersonelID,SatisTutari,Prim,SatisTarihi)
VALUES (@pid,@st,@p,@str) 
GO
```

Son olarak AFinans isimli tablomuzdan prim miktarı kadar TL’sını düşecek olan Stored Procedure’ümüzü yazalım.

```text
CREATE PROCEDURE [Prim Dus]  
@prim float 
AS 
UPDATE AFinans SET Tutar=Tutar-@prim 
GO 
```

Artık program kodlarımıza geçebiliriz. Kodları C# ile yazmayı tercih ettim.

```csharp
using System;
using System.Data;
using System.Data.SqlClient;  
namespace TransactionSample1
{
     class Trans
     {
          [STAThread]
          static void Main(string[] args)
          {
			/* IstanbulMerkez veritabanına bir bağlantı nesnesi referans ediyoruz. */
			SqlConnection conIstanbulMerkez=new SqlConnection("initial catalog=IstanbulMerkez;data source=localhost;integrated security=sspi");

			/* Transaction nesnemizi tanımlıyor ve bu Transaction'ın conIstanbulMerkez isimli SqlConnection nesnesinin belirttiği bağlantıya ait komutlar için çalıştırılacağını belirtiyoruz. */

			SqlTransaction tr;
			conIstanbulMerkez.Open();
			tr=conIstanbulMerkez.BeginTransaction(); 
			double satisTutari=150000000000;
			double primTutari=satisTutari*0.01; 
			/* Şimdi, Personel tablosundaki PrimToplami alanın değerini primTutari değişkeninin değerin kadar arttıracak Stored Procedure'ü çalıştıracak SqlCommand nesnesini tanımlıyor ve gerekli parametreleri ekleyerek bu parametrelere değerlerini veriyoruz. Son olaraktan da SqlCommand'in Transaction özelliğine oluşturduğumuz tr isimli SqlTransaction nesnesini atıyoruz. Bu şu anlama geliyor. "Artık bu SqlCommand tr isimli Transaction içinde çalışıcak olan bir iş parçacaığıdır." */
			SqlCommand cmdPrimToplamiArttir=new SqlCommand("Prim Toplami Arttir",conIstanbulMerkez);               cmdPrimToplamiArttir.CommandType=CommandType.StoredProcedure;               cmdPrimToplamiArttir.Parameters.Add("@prim",SqlDbType.Float);               cmdPrimToplamiArttir.Parameters.Add("@pid",SqlDbType.Int);
			cmdPrimToplamiArttir.Parameters["@prim"].Value=primTutari;
			cmdPrimToplamiArttir.Parameters["@pid"].Value=1;
			cmdPrimToplamiArttir.Transaction=tr; 
			/* Aşağıdaki satırlarda ise "Prim Bilgisi Gir" isimli Stored Procedure'ü çalıştıracak olan SqlCommand nesnesi oluşturulup gerekli paramtere ayarlamaları yapılıyor ve yine Transaction nesnesi belirlenerek bu komut nesneside Transaction bloğu içerisine bir iş parçacığı olarak bildiriliyor.*/
			SqlCommand cmdPrimBilgisiGir=new SqlCommand("Prim Bilgisi Gir",conIstanbulMerkez);
			cmdPrimBilgisiGir.CommandType=CommandType.StoredProcedure;               cmdPrimBilgisiGir.Parameters.Add("@pid",SqlDbType.Int);               cmdPrimBilgisiGir.Parameters.Add("@st",SqlDbType.Float);               cmdPrimBilgisiGir.Parameters.Add("@p",SqlDbType.Float);               cmdPrimBilgisiGir.Parameters.Add("@str",SqlDbType.DateTime);
			cmdPrimBilgisiGir.Parameters["@pid"].Value=1;               cmdPrimBilgisiGir.Parameters["@st"].Value=satisTutari;
			cmdPrimBilgisiGir.Parameters["@p"].Value=primTutari;             cmdPrimBilgisiGir.Parameters["@str"].Value=System.DateTime.Now;
			cmdPrimBilgisiGir.Transaction=tr; 
			/* Son olarak AFinans isimli tablodaki Tutar alanından prim tutarı kadar TL'sını düşücek olan Stored Procedure için bir SqlCommand nesnesi tanımlanıyor, prim tutarını taşıyacak olan parametre eklenip değeri veriliyor. Tabiki en önemlisi, bu komut nesnesi içinde SqlTransaction nesnemiz belirleniyor.*/
			SqlCommand cmdTutarDus=new SqlCommand("Prim Dus",conIstanbulMerkez);
			cmdTutarDus.CommandType=CommandType.StoredProcedure;
			cmdTutarDus.Parameters.Add("@prim",SqlDbType.Float);
			cmdTutarDus.Parameters["@prim"].Value=primTutari;
			cmdTutarDus.Transaction=tr; 
			/* Evet sıra geldi programın can alıcı kodlarına. Aşağıda bir Try-Catch-Finally bloğu var. Bu bloklarda dikkat edicek olursanız tüm SqlCommand nesnelerinin çalıştırılması try bloğunda yapılamktadır. Eğer tüm bu komutlar sorunsuz bir şekilde çalışırsa bu durumda, tr.Commit() ile transaction onaylanır vee değişikliklerin veritabanı üzerindeki tablolara yazılması onaylanmış olur*/
			try
			{
				int etkilenen=cmdPrimToplamiArttir.ExecuteNonQuery();
				Console.WriteLine("Personel tablosunda {0} kayıt güncellendi",etkilenen);
				int eklenen=cmdPrimBilgisiGir.ExecuteNonQuery();
				Console.WriteLine("Prim tablosunda {0} kayıt eklendi",eklenen);
				int hesaptaKalan= cmdTutarDus.ExecuteNonQuery();
				Console.WriteLine("AFinans tablosunda {0} kayıt güncellendi",hesaptaKalan);
				tr.Commit();
			}
			catch(Exception hata) /* Ancak bir hata olması durumdan ise, kullanıcı hatanın bilgisi ile uyarılır ve tr.Rollback() ile hatanın oluştuğu ana kadar olan tüm işlemler iptal      edilir.*/
			{
				Console.WriteLine(hata.Message+" Nedeni ile işlmeler iptal edildi");
				tr.Rollback();
			}
			finally /* hata oluşsada oluşmasada açık bir bağlantı var ise bunun kapatılmasını garanti altına almak için finally bloğunda bağlantı nesnemizi Close metodu ile kapatırız.*/
			{
				conIstanbulMerkez.Close();
			}
        }
    }
}
```

![mk5_5.gif](/assets/images/2003/mk5_5.gif)

Şekil 5. Programın çalışması sonucu.

Bu durumda veritabanındaki tablolara bakacak olursak; Personel tablosunda PrimToplami alanının değeri artmış,

![mk5_6.gif](/assets/images/2003/mk5_6.gif)

Şekil 6. Personel tablosunda PrimToplami alanının değeri arttırıldı.

Prim tablosuna ilgili personele ait bilgiler eklenmiş,

![mk5_7.gif](/assets/images/2003/mk5_7.gif)

Şekil 7. Prim tablosuna ödenecek prime ait bilgiler girildi.

Son olarak da, AFinans isimli tablodaki Tutar alanının değeri güncellenmiştir.

![mk5_8.gif](/assets/images/2003/mk5_8.gif)

Şekil 8. AFinans tablosundaki Tutar alanının değeri prim tutarı kadar azaldı.

Şimdi dilerseniz bir hata tetikleyelim ve ne olacağına bakalım. Bir hata üretmek aslında isteyince o kadar kolay değil maalesef. Ben Stored Procedure’lerden birinin ismini yanlış yazacağım. Bakalım ne olacak. Şu anda tablodaki veriler yukarıdaki Şekil 6, 7 ve Şekil 8’de olduğu gibi.

```csharp
SqlCommand cmdPrimBilgisiGir=new SqlCommand("Prim Bisi Gir",conIstanbulMerkez); 
```

Burada Stored Procedure’ün ismi “Prim Bilgisi Gir” iken ben “Prim Bisi Gir “ yaptım. Şimdi çalıştıracak olursak; aşağıdaki ekran ile karşılaşırız. İşlemler iptal edilir.

![mk5_9.gif](/assets/images/2003/mk5_9.gif)

10. İşlemler iptal edildi.

Eğer transaction kullanmasaydık ilk SqlCommand çalışır ve Personel tablosunda PrimToplami alanın değeri artardı. Oysa şimdi bu tabloyu kontrol edecek olursak,

![mk5_10.gif](/assets/images/2003/mk5_10.gif)

Şekil 11. Bir etki olmadı.

Tekrar önemli bir noktayı vurgulamak isterim. Bu Transaction tek bir veritabanı üzerinde çalışmaktadır. Eğer birden fazla veritabanı söz konusu olursa, Distributed Transaction tekniklerini kullanmamız gerekiyor. Bunu ilerleyen makalelerimizde incelemeye çalışacağım. Umarım buraya kadar anlattıklarımla Transaction’lar hakkında bilgi sahibi olmuşsunuzdur. Bir sonraki makalemizde görüşmek dileğiyle hepinize mutlu günler dilerim.
