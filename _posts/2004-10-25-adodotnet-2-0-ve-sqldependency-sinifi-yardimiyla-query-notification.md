---
layout: post
title: "Ado.Net 2.0 ve SqlDependency Sınıfı Yardımıyla Query Notification"
date: 2004-10-25 18:00:00
tags:
  - ado.net
  - sql
categories:
  - Framework Tabanlı Programlama
---
Çoğu zaman istemci uygulamalarda, kullanıcıya sunduğumuz verilerin yer aldığı tablolarda başka kullanıcılar tarafından gerçekleştirilen değişikliklerin anında görünmesini isteriz. SqlDependency sınıfı sayesinde artık, bir veritabanında meydana gelen değişiklikleri (şu an için SQL Server ve Yukon) anında yakalayabilme şansına sahibiz. İşte bugünkü makalemizde aslında son derece derin ve geniş bir konu olan SQL Server Notification meselesini çok basit bir örnek ve ADO.NET 2.0 ile gelen yeni sınıflardan birisi olan SqlDependency yardımıyla incelemeye çalışacağız. İlk olarak şu soruyu düşünelim.

Sunucu üzerinde ne gibi gelişmeler olduğunda anında haberdar olmak isteyebiliriz?

- Verilerde meydana gelebilecek değişikler; bir başka deyişle yeni satırların eklenmesi, satırların silinmesi veya güncellenmesi.

- Tablo üzerinde Drop, Alter veya Delete işlemlerinin uygulanması.

- SQL sunucusunun yeniden başlatılması.

- SQL sunucusu üzerinde hatalar oluşması nedeniyle sunucunun işleyişinin durması.

İşte bu gibi durumlarda, istemci uygulamaların meydana gelecek olan değişikliklerden anında haberdar olmasını isteyebiliriz. Bu durum özellikle, bağlantısız katman nesnelerinin kullanıldığı uygulamalarda büyük önem kazanmaktadır. Peki bu anında haber bildirilmesini nasıl sağlayabiliriz? Bunun için kullanılan mimari kabaca aşağıdaki şekilde olduğu gibidir.

![mk105_1.gif](/assets/images/2004/mk105_1.gif)

Şekil 1. Mimari.

Dilerseniz kısaca mimarinin işleyişinden ve bileşenlerinden bahsedelim. SqlDependency sınıfı, bir SqlCommand ile ilişkilendirilerek kullanılır ve içsel olarak bir SqlNotificationRequest nesnesini de barındırır. (Bu sınıfı ilerleyen makalelerimizde incelemeye çalışacağız.) SqlCommand sınıfının Notification işlemine uyan bir Select sorgusu içermesi gerekir. Öyle ki bu Select sorgusu şu anki versiyonlar itibarıyla aşağıdaki gibi olamaz.

```sql
Select * From Tablo
```

Select sorgusunda talep edilen alan isimleri açıkça belirtilmelidir. Bununla birlikte, tablonun sahibi de yani yaratıcısı da açıkça belirtilmelidir. Yani ancak aşağıdaki gibi bir SQL ifadesi Notification desteğini sağlayabilir.

```sql
Select Ad,Soyad From dbo.Tablo
```

Belirtilen SQL ifadesi çalıştırıldığında, SqlDependency nesnesi ilgili SqlCommand nesnesi için sunucuda bir Notification açılacağını SQL sunucusuna bildirir. SQL sunucusu bu mesaj üzerine ilgili SQL komutunu çalıştırır ve Notification nesnesini sunucuya register eder. Bu bize, çalıştırılan SQL sorgusunun sunucuya ekstradan birtakım bilgiler daha gönderdiğini göstermektedir. Bu bilgiler çoğunlukla, kaydı tutulacak Notification ile ilgilidir ve SqlDependency sınıfının ilgili yapıcı metotları yardımıyla ayarlanabilir.

Notification nesnesi, sunucuya kaydedildikten sonra, komutun çalışması ile elde edilen sonuçlar ön belleğe alınır ve ilgili Notification nesnesi de Server Service Broker Queue tarafından kuyruğa atılır. Buradaki ön bellekleme işlemi aslında bir temp tablosunun oluşturulmasından başka bir şey değildir. Bu noktadan itibaren SQL sunucusu, ilgili satır kümesini izlemeye başlar. Eğer satır kümesi üzerinde yukarıda bahsettiğimiz durumlardan birisi nedeniyle değişiklikler olursa, sp_DispatcherProc sistem prosedürü yardımıyla istemci uygulamanın SqlDependency sınıfına ait olan OnChange olayına bilgi mesajı gider.

Mimari her ne kadar karışık gibi görünse de, uygulanabilirliği son derece kolay ve basittir. Bu amaçla olayı daha iyi irdeleyebilmek için aşağıdaki Windows uygulamasını göz önüne alalım.

![mk105_2.gif](/assets/images/2004/mk105_2.gif)

Şekil 2. Windows Uygulamamız

```bash
#region Using directives

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using System.Data.SqlClient;

#endregion

namespace NotifySample
{
    partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        SqlConnection con;
        SqlCommand cmd;
        SqlDependency dep;
        SqlDataAdapter da;
        DataTable dt;

        private void btnVeriCek_Click(object sender, EventArgs e)
        {
            con = new SqlConnection("data source=localhost;initial catalog=Dukkan;integrated security=SSPI");
            con.Open();
            cmd = new SqlCommand("Select DetayID,PersonelID,Ad,Soyad,Mail From dbo.PersonelDetay", con);
            dep = new SqlDependency(cmd);
               SqlDependency.Start("data source=localhost;initial catalog=Dukkan;integrated security=SSPI");
            dep.OnChange+=new OnChangeEventHandler(dep_OnChange);
            da = new SqlDataAdapter(cmd);
            dt = new DataTable();
            da.Fill(dt);
            dgVeriler.DataSource = dt;
        }

        void dep_OnChange(object sender, SqlNotificationEventArgs e)
        {
            MessageBox.Show("YENI VERILER EKLENDI...TAZELEME YAPIN");
        }
    }
}
```

Uygulamamız, Yukon üzerinde Dukkan isimle veritabanında yer alan PersonelDetay isimli tabloya ait verileri kullanmaktadır. Kullanıcı Veri Çek başlıklı butona bastığında ilgili tabloya ait tüm satırlar DataGridView kontrolüne yüklenmektedir. Şimdi gelelim, burada önemli olan kod satırlarına. Dikkat ederseniz, SqlDependency sınıfına ait nesne örneğimizi aşağıdaki kod satırı ile oluşturuyoruz. Böylece ilgili komut için Notification servisinin kullanılacağını belirtmiş oluyoruz.

```csharp
dep = new SqlDependency(cmd);
```

Bu arada Select sorgumuzun kurallara uygun bir yapıda olduğuna dikkat edelim. Yani, alan adlarını ve tablonun sahibini açıkça belirtiyoruz. Daha sonra ise, SqlDependency sınıfımıza OnChange olayını aşağıdaki kod satırı ile ekliyoruz.

```csharp
dep.OnChange += new OnChangeEventHandler(dep_OnChange);
```

Bu olayın bizim için büyük bir önemi var. Nitekim, sunucu üzerinde ön belleklenen veri kümesinde değişiklikler olduğunda, SQL sunucusu tarafından uygulamaya bir Notification mesajı gönderilecektir. İşte bu mesajın ele alınacağı olay SqlDependency sınıfına ait OnChange'dır. Bu olayın prototipi aşağıdaki gibidir.

```csharp
public event OnChangeEventHandler OnChange;
```

Gördüğünüz gibi bu olay OnChangeEventHandler temsilcisinin tanımladığı metodları çalıştırabilir. OnChangeEventHandler temsilcisinin prototipi ise aşağıdaki gibidir.

```csharp
public sealed delegate void OnChangeEventHandler(object sender, SqlNotificationEventArgs e);
```

Bu temsilcinin işaret edeceği metotlara ait ikinci parametre SqlNotificationEventArgs sınıfı tipinden olup oldukça önemlidir. Nitekim bu parametre yardımıyla, gelen bildirinin hangi olaya istinaden oluştuğunu ayırt edebilir ve işlemlerimize yön verebiliriz. Bu sınıfı da detaylı bir şekilde ilerleyen makalelerimizde inceleyeceğiz. Olay metodumuzda ise basit olarak herhangi bir Notification mesajı alındığında bir MessageBox'ın çıkmasını sağlıyoruz.

```csharp
void dep_OnChange(object sender, SqlNotificationEventArgs e)
{
    MessageBox.Show("YENI VERILER EKLENDI...TAZELEME YAPIN");
}
```

Şimdi uygulamamızı çalıştıralım ve verileri çekelim. Yazdığımız kodlar gereği, SQL sunucusu üzerinde Select sorgumuza istinaden bir Notification nesnesi register edilecektir. Şimdi biz bu noktada doğrudan Yukon üzerinden yeni bir satır gireceğiz. (Aslında aynı uygulamanın başka bir örneğinden veya başka bir uygulamadan da bu tablo üzerinde değişiklikler yapabiliriz.) Bunu uygulamamız çalışıyorken yapacağız.

![mk105_3.gif](/assets/images/2004/mk105_3.gif)

Şekil 3. Yukon üzerinden tablomuza yeni bir satır ekliyoruz.

Bu işlemi gerçekleştirdiğimiz anda, uygulamamıza bir bildiri mesajı iletilir ve tabloda değişiklik olduğu söylenir. Bunun sonucu olarak da, SqlDependency nesnemiz ile ilişkilendirdiğimiz OnChange olayı aktif hâle gelecektir. Sonuç aşağıdaki gibi olacaktır. Yeni satır eklenir eklenmez uygulama OnChange olayını çalıştıracaktır.

![mk105_4.gif](/assets/images/2004/mk105_4.gif)

Şekil 4. Notification mesajı uygulamaya gönderildi.

Dolayısıyla biz, veri çekme işlemimizi bu olay içerisine alarak istemci uygulamanın daima güncel veriler ile konuşmasını sağlayabiliriz. SqlDependency sınıfının pek çok üyesi ve önemli özelliği vardır. Bir sonraki makalemizde, bu sınıfı daha detaylı bir şekilde incelemeye çalışırken, gerçekleşen değişikliğin tipine göre nasıl hareket edebileceğimizide göreceğiz. Tekrardan görüşünceye dek sağlıcakla kalın.
