---
layout: post
title: "Ado.Net 2.0 ve Sql Komutlarını Asenkron Olarak Yürütmek - 3"
date: 2004-10-22 12:00:00
tags:
  - ado.net
  - asynchronous-programming
  - async
categories:
  - Framework Tabanlı Programlama
---
Hatırlayacağınız gibi, asenkron erişim teknikleri ile ilgili önceki makalelerimizde Polling ve Callback modellerini incelemiştik. Bu makalemizde ise, Wait modelini incelemeye çalışacağız. Wait modeli, diğer asenkron SQL komutu yürütme tekniklerine göre biraz daha farklı bir işleyişe sahiptir. Bu model, bazı durumlarda asenkron olarak çalışan SQL komutları tamamlanıncaya kadar uygulamayı bekletmek istediğimiz durumlarda kullanılmaktadır. WaitHandle modeli aslında birden fazla sunucu üzerinde çalışacak farklı sorgular söz konusu olduğunda işe yarayacak etkili bir tekniktir. Diğer taraftan eşzamanlı çalışan sorgu sonuçlarının uygulamanın kalanında etkili olduğu durumlarda da tercih edilmelidir. Wait modeli şu an için 3 teknik ile gerçekleştirilmektedir. Dilerseniz bu tekniklerin ne olduklarını ve nasıl uygulandıklarını kısaca inceleyelim.

![mk104_1.gif](/assets/images/2004/mk104_1.gif)

Şekil 1. Wait Modelleri.

Wait modellerini en kolay hâliyle anlayabilmek için işe, WaitOne modeli ile başlamakta fayda vardır. WaitOne modeli, sadece tek bir SQL komutu için uygulamanın bekletilmesini sağlar. Ne kastettiğimi anlamak için aşağıdaki örneğimizi dikkatle inceleyelim.

```bash
#region Using directives

using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Threading;

#endregion

namespace WaitModeli
{
    class Program
    {
        static void Main(string[] args)
        {
            SqlConnection con = new SqlConnection("data source=localhost;initial catalog=AdventureWorks;integrated security=SSPI;async=true");
            SqlCommand cmd = new SqlCommand("WAITFOR DELAY '0:0:5';UPDATE Production.Product SET ListPrice=ListPrice*1.15", con);

            con.Open();
            IAsyncResult res1 = cmd.BeginExecuteNonQuery(); //Komutu asenkron olarak çalıştır.

            WaitHandle wh1 = res1.AsyncWaitHandle; // WaitHandle nesnesini al.
            Console.WriteLine("Herhangibir islem"); // Bu aralıkta eş zamanlı kodlar çalışır.

            wh1.WaitOne(); // Eğer komut tamamlanmamışsa bekle.
            int sonucUpdate = cmd.EndExecuteNonQuery(res1); // Komut işleyişini tamamladı sonuçları al.
            con.Close();
            Console.WriteLine(sonucUpdate.ToString() + " SATIR GUNCELLENDI");

            Console.ReadLine();
        }
    }
}
```

Bu örnek console uygulamasında, Yukon üzerinde yer alan AdventureWorks veritabanındaki Product isimli tabloda güncelleme işlemi gerçekleştiren bir komut söz konusudur. Senaryonun daha gerçekçi olması için SQL üzerinde WaitFor ile işlemi 5 saniye geç başlatıyoruz. Biz komutu asenkron olarak yürütmek istiyoruz. Lakin komutun sonuçlarını almadan önce birtakım kod satırlarının da çalıştırılmasını istiyoruz. Buraya kadar her şey normal. Ancak eşzamanlı yürüyen kod satırlarından sonra da, eğer işlenen komut hâlâ daha tamamlanmamışsa, o komut tamamlanıncaya kadar güncel uygulamanın duraksamasını ve başka bir işlem yapmamasını istiyoruz. İşte bu gibi tek komutlara wait modelini uygulamak istediğimizde, WaitHandle sınıfının statik metotlarından olan WaitOne'ı kullanmaktayız.

Uygulama kodlarımızı incelediğimizde ilk olarak asenkron olarak çalışmasını istediğimiz komuta ait Begin metotlarından birisini kullanarak IAsyncResult arayüzü tipinden bir nesne örneğini elde ediyoruz.

```csharp
IAsyncResult res1 = cmd.BeginExecuteNonQuery();
```

Daha sonra ise, bu arayüz nesnesinin AsyncWaitHandle özelliği ile bir WaitHandle nesnesi oluşturuyoruz.

```csharp
WaitHandle wh1 = res1.AsyncWaitHandle;
```

Bu WaitHandle nesnesinin elde edilişi sırasında ve sonrasındaki uygulama satırları SQL komutumuz ile eşzamanlı olarak yürütülmektedir. Biz WaitHandle nesnemizin WaitOne metodunu uyguladığımızda, çalışan SQL komutunun tamamlandığına dair bir sinyal WaitHandle nesnesine gelinceye kadar aktif thread'in duraksatılmasını sağlamış oluyoruz.

```csharp
wh1.WaitOne();
```

Gelelim, WaitAll tekniğine. WaitAll ise, birden fazla SQL komutunun asenkron olarak çalıştığı durumlarda devreye giren ve tüm komutlar başarılı bir şekilde tamamlanıncaya kadar aktif uygulamayı duraksatan bir tekniktir. Bu sefer, WaitHandle nesneleri her bir komut için ayrı ayrı tanımlanmalıdır. Dolayısıyla bize WaitHandle tipinden bir dizi gerekmektedir. Aşağıdaki örnek uygulama, WaitAll tekniğinin nasıl uygulandığını göstermektedir.

```csharp
SqlConnection con1 = new SqlConnection("data source=localhost;initial catalog=AdventureWorks;integrated security=SSPI;async=true");
SqlConnection con2 = new SqlConnection("data source=localhost;initial catalog=AdventureWorks;integrated security=SSPI;async=true");
SqlConnection con3 = new SqlConnection("data source=localhost;initial catalog=AdventureWorks;integrated security=SSPI;async=true");
SqlCommand cmd1 = new SqlCommand("WAITFOR DELAY '0:0:4';UPDATE Production.Product SET ListPrice=ListPrice*1.15", con1);
SqlCommand cmd2 = new SqlCommand("WAITFOR DELAY '0:0:5';UPDATE Production.Product SET ListPrice=ListPrice*1.20", con2);
SqlCommand cmd3 = new SqlCommand("WAITFOR DELAY '0:0:2';UPDATE Production.Product SET ListPrice=ListPrice*1.45", con3);

con1.Open();
IAsyncResult res1 = cmd1.BeginExecuteNonQuery();
con2.Open();
IAsyncResult res2 = cmd2.BeginExecuteNonQuery();
con3.Open();
IAsyncResult res3 = cmd3.BeginExecuteNonQuery();

WaitHandle[] wh = new WaitHandle[3];
wh[0] = res1.AsyncWaitHandle;
wh[1] = res2.AsyncWaitHandle;
wh[2] = res3.AsyncWaitHandle;

Console.WriteLine("Burada bir şeyler yapılır...");
for (int i = 1; i < 100; i++)
{
    Console.Write(i.ToString()+" ");
}
Console.WriteLine();

WaitHandle.WaitAll(wh);
int sonucGuncel1 = cmd1.EndExecuteNonQuery(res1);
con1.Close();
int sonucGuncel2 = cmd2.EndExecuteNonQuery(res2);
con2.Close();
int sonucGuncel3 = cmd3.EndExecuteNonQuery(res3);
con3.Close();
Console.WriteLine(sonucGuncel1 + " SATIR GUNCELLENDI");
Console.WriteLine(sonucGuncel2 + " SATIR GUNCELLENDI");
Console.WriteLine(sonucGuncel3 + " SATIR GUNCELLENDI");
Console.ReadLine();
```

Burada görüldüğü gibi, üç adet SQL komutumuz var. Her ne kadar anlamsız olsalar da sonuçta amacımız Wait modelinin nasıl işlediğini anlamaktır. WaitHandle dizisi içindeki her eleman, bu elemanlar ile ilişkili komutlara ait IAsyncResult nesnelerinin AsyncWaitHandle özellikleri yardımıyla oluşturulur. Bu esnada, SQL komutları asenkron olarak yürütülmektedir. Dolayısıyla WaitHandle sınıfının WaitAll metodunu çalıştırdığımız satıra kadar olan kodlar, komutlar ile birlikte eşzamanlı olarak yürümektedir. WaitAll metodunun olduğu satıra gelindiğinde, uygulama çalışan komutların hepsi tamamlanmış olmak şartıyla yoluna devam eder. Bir başka deyişle, eğer bu satıra gelindiğinde hâlen daha tamamlanmamış komutlar varsa, varsayılan timeout süresi doluncaya kadar bu komutların da tamamlanması beklenir.

Wait modelindeki son teknik ise, WaitAny yapısıdır. Bu teknik bir öncekilere nazaran biraz daha karmaşıktır. WaitAny tekniğinde, asenkron olarak yürütülen komutlar sırasıyla tamamlanıncaya kadar uygulama bekletilir. Burada sıralamayı belirten WaitAny metodudur. Nitekim, işleyişi önce tamamlanan metodun WaitHandle nesnesi diğerlerine göre daha öncelikli olarak sinyal alacak ve sonuçlar ortama aktarılacaktır. WaitAny tekniğinde işin ilginç ve bir o kadar da önemli olan yanı, WaitAny metodunun geriye integer olarak döndürdüğü değerin kullanılmasında yatmaktadır. Bu değer aslında, WaitHandle dizisi içindeki indeksi işaret etmektedir. Yani, WaitAny metodu ile aktif olarak alınan WaitHandle eğer tamamlanmışsa, metodun geriye döndüreceği değer bu komuta bağlı WaitHandle elemanının dizi içerisindeki indeksidir.

Buna göre, WaitAny tekniğinin, WaitHandle dizisi içindeki tüm elemanları işleyen bir döngü içerisinde kullanılması ve bu metodun döndürdüğü değerlerin de dizi indeksleri ile burada karşılaştırılması gerekmektedir. Her ne kadar karışık bir teknikmiş gibi görünse de, aşağıdaki kod bloğunu incelediğimizde olayı çok daha kolay anlayabileceğimize inanıyorum.

```csharp
SqlConnection con1 = new SqlConnection("data source=Manchester;initial catalog=AdventureWorks;integrated security=SSPI;async=true");
SqlConnection con2 = new SqlConnection("data source=Manchester;initial catalog=AdventureWorks;integrated security=SSPI;async=true");
SqlCommand cmd = new SqlCommand("WAITFOR DELAY '0:0:5';UPDATE Production.Product SET ListPrice=ListPrice*1.15", con1);
SqlCommand cmd2 = new SqlCommand("WAITFOR DELAY '0:0:3';UPDATE Production.Product SET ListPrice=ListPrice*1.20", con2);

con1.Open();
IAsyncResult res1 = cmd.BeginExecuteNonQuery();
con2.Open();
IAsyncResult res2 = cmd2.BeginExecuteNonQuery();

WaitHandle[] wh = new WaitHandle[2];
wh[0] = res1.AsyncWaitHandle;
wh[1] = res2.AsyncWaitHandle;
for (int i = 0; i < 2; i++)
{
    int iIndis = WaitHandle.WaitAny(wh);
    if (iIndis == 0)
    {
        int result=cmd.EndExecuteNonQuery(res1);
        con1.Close();
        Console.WriteLine(iIndis.ToString()+" tamamlandı." +result.ToString());
    }
    if (iIndis == 1)
    {
        int result = cmd2.EndExecuteNonQuery(res2);
        con2.Close();
        Console.WriteLine(iIndis.ToString() + " tamamlandı." + result.ToString());
    }
}
```

Dilerseniz bu kod parçasını inceleyelim. WaitHandle dizimizi, iki SQL komut için gerekli olan WaitHandle nesnelerini tutmak üzere kullanıyoruz. Bu dizi için gerekli WaitHandle nesnelerini elde edebilmek amacıyla da, IAsyncResult arayüzüne ait AsyncWaitHandle özelliğini kullanmaktayız. Buraya kadar her şey anlaşılır. Asıl önemli olan açtığımız for döngüsüdür. Bu döngü, WaitHandle dizisinin eleman sayısı kadar iterasyon yapmaktadır. Döngü içerisinde,

```csharp
int iIndis = WaitHandle.WaitAny(wh);
```

satırı ile, dizi içindeki WaitHandle nesnelerinden herhangi birinin ilgili komutun bittiğine dair bir sinyal alıp almadığına bakılır. Eğer böyle ise, komut işleyişini tamamlamış demektir. Bu durumda WaitAny metodu geriye integer bir değer döndürür. Elbette ki işleyen SQL komutlarından herhangi biri tamamlanmamış ise, uygulama bu satırda bu komutlardan herhangi biri tamamlanıncaya ve ilgili WaitHandle nesnesine sinyal gönderilinceye kadar duraksar. Dönen integer değer, WaitAny metodunun yapısı gereği, WaitHandle dizisi içindeki ilgili WaitHandle nesnesinin indeks değerini işaret eder. Bu nedenle uygulama bir sonraki satıra geçtiğinde if koşuluna girer ve burada hangi komutun tamamlandığı WaitAny metodundan dönen integer değer yardımıyla belirlenir. Tabii ki tamamlanan komuta uygun olan Begin metodu da bu if döngüsü içinde çalıştırılır.

Daha sonra ise, döngü ikinci iterasyondan işleyişine devam eder. Bu kez hâlen daha çalışmakta olan diğer SQL komutlarına ait WaitHandle nesnelerinin bir sinyal alıp almadığına bakılır. Yine, ilk iterasyonda olduğu gibi önce tamamlanan komuta ait WaitHandle nesnesi gerekli sinyali alır ve geriye dizi içindeki indeks değerini döndürür. Ardından tekrar if koşulları uygulanır ve gerekli sonuçlar elde edilir. Bu işleyiş, döngü içindeki tüm WaitHandle nesneleri ilişkili oldukları komutların tamamlandığına dair sinyaller alıncaya, dolayısıyla komutlar işleyişini bitirinceye kadar devam eder.

Görüldüğü gibi Wait modeli içerdiği teknikler itibariyle biraz karışıktır. Ancak ilerleyen zamanlarda, ADO.NET 2.0'ın son sürümünde bu tekniklerin çok daha kullanışlı hâle geleceğine inanıyorum. Bir sonraki makalemizde görüşmek dileğiyle hepinize mutlu günler dilerim.
