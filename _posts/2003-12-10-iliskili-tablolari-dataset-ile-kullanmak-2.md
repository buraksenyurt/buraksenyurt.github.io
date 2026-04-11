---
layout: post
title: "İlişkili Tabloları DataSet İle Kullanmak - 2"
date: 2003-12-10 12:00:00
tags:
  - ado.net
  - dataset
  - relations
categories:
  - Framework Tabanlı Programlama
---
Bugünkü makalemizde ilişkili tablolar arasında kısıtlamaların (constraints) nasıl kullanıldığını işlemeye çalışacağız. Hatırlayacağınız gibi bu yazı dizisinin ilk bölümünde DataRelation sınıfını kullanarak ilişkili tabloların bellekte nasıl ifade edilebileceğini görmüştük. Bir diğer önemli konu, bu ilişkili tablolar arasındaki parent-child ilişkisinin kayıt güncelleme, kayıt silme gibi durumlarda nasıl hareket edeceğini belirlemektir.

Buna verilecek en güzel örnek müşterilere ait sipariş detaylarının ve buna benzer ilişkilerin yer aldığı veritabanı tasarımlarıdır. Söz gelimi parent tablodan bir kaydın silinmesi ile bu kayda bağlı child tablodaki kayıtların da silinmesi gerekebilir ya da silinmemesi istenebilir. İşte bu noktada DataSet ile belleğe yüklenen tablolar arasındaki bu zorlamaları bir şekilde tanımlamamız gerekmektedir. Bu zorlamalar Constraints olarak tanımlanır. Bizim için en önemli iki kısıtlama Foreign Key Constraints ve Unique Constraints'tir.

Foreign Key Constraints (Yabancı anahtar kısıtlaması), parent-child ilişkisine sahip tablolarda kayıtların güncelleme ve silme olaylarında nasıl hareket edeceğini belirler. Unique Constraints tanımlanması ile de bir alanın değerlerinin asla tekrar edilemeyeceği şartını bildirmiş oluruz. Bir yabancı anahtar kısıtlaması için ForeignKeyConstraint sınıfı kullanılır. Aynı şekilde bir tekillik kısıtlaması için de UniqueConstraints sınıfı kullanılmaktadır. Her iki sınıfa ait örnek nesnelerin kullanılabilmesi için, ilgili tablonun Constraints koleksiyonuna eklenmesi gerekmektedir.

Şöyle ki, diyelim ki siparişlerin tutulduğu tablodaki veriler ile sipariş içinde yer alan ürünlerin tutulduğu tablolar arasında bire-çok bir ilişki var. Bu durumda, siparişlerin tutulduğu tablodan bir kayıt silindiğinde buradaki siparişi belirleyici alan (çoğunlukla ID olarak kullanırız) ile child tabloda yer alan ve yabancı anahtar ile parent tabloya bağlı olan alanları silmek isteyebiliriz. Burada zorlama unsurumuz parent tabloyu ilgilendirmektedir. Dolayısıyla, oluşturulacak ForeignKeyConstraints nesnesini parent tablonun Constraints koleksiyonuna ekleriz. Elbette, kısıtlamanın silme ve güncelleme gibi işlemlerde nasıl davranış göstermesi gerektiğini belirlemek için, ForeignKeyConstraints’e ait birtakım özelliklerin de ayarlanması gerekir. Bunlar,

- DeleteRule
- UpdateRule
- AcceptRejectRule

özellikleridir. Bu özelliklere atayabileceğimiz değerler ise,

- Rule.Cascade
- Rule.None
- Rule.SetDefault
- Rule.SetNull

Cascade değeri verildiğinde güncelleme ve silme işlemlerinden, child tablodaki kayıtların da etkilenmesi sağlanmış olur. Söz gelimi parent tabloda bir satırın silinmesi ile ilişkili tablodaki ilişkili satırların tümü silinir. None değeri verildiğinde tahmin edeceğiniz gibi bu değişiklikler sonunda child tabloda hiçbir değişiklik olmaz. SetDefault değeri, silme veya güncelleme işlemleri sonucunda child tablodaki ilişkili satırların alanlarının değerlerini varsayılan değerlerine (çoğunlukla veritabanında belirlenen) ayarlar. SetNull verildiğinde ise bu kez, child tablodaki ilişkili satırlardaki alanların değerleri DbNull olarak ayarlanır.

Burada AcceptRejectRule isimli bir özellik de dikkatinizi çekmiş olmalı. Bu özellik bir DataSet, DataTable veya DataRow nesnesine ait AcceptChanges (değişiklikleri onayla) veya RejectChanges (değişiklikleri iptal et) durumunda nasıl bir kısıtlama olacağını belirlemek için kullanılır. Bu özellik Cascade veya Null değerlerinden birini alır. Bir dataSet’in kısıtlamaları uygulaması için EnforceConstraints özelliğine true değeri atanması gerektiğini de söyleyelim.

Şimdi önceki makalemizde yazdığımız örnek uygulama üzerinden hareket ederek, ForeignKeyConstraint tekniğini inceleyelim. Konuyu uzatmamak amacıyla aynı örnek kodları üzerinden devam edeceğim. Uygulamamızda kullanıcı silmek istediği Siparis’in SiparisID bilgisini elle girecek ve silme işlemini başlatacak. İşte bu noktada, DataSet’e eklemiş olduğumuz kısıtlama devreye girerek, Sepet tablosunda yer alan ilişkili satırların da silinmesi gerçekleştirilecek. Haydi gelin kodlarımızı yazalım.

```csharp
SqlConnection conFriends;
SqlDataAdapter daSiparis;
SqlDataAdapter daSepet;
DataTable dtSiparis;
DataTable dtSepet;
ForeignKeyConstraint fkSiparisToSepet;
DataSet ds;

private void Form1_Load(object sender, System.EventArgs e)
{
    conFriends = new SqlConnection("data source=localhost;initial catalog=Friends;integrated security=sspi");
    daSiparis = new SqlDataAdapter("Select * From Siparis", conFriends);
    daSepet = new SqlDataAdapter("Select * From Sepet", conFriends);
    dtSiparis = new DataTable("Siparisler");
    dtSepet = new DataTable("SiparisDetaylari");
    daSiparis.Fill(dtSiparis);
    daSepet.Fill(dtSepet);
    dtSiparis.PrimaryKey = new DataColumn[] { dtSiparis.Columns["SiparisID"] };
    /* Sıra geldi foreignKeyConstraint tanımlamamıza. */
    fkSiparisToSepet = new ForeignKeyConstraint("fkS_S", dtSiparis.Columns["SiparisID"], dtSepet.Columns["SiparisID"]);
    /* Öncelikle yeni bir ForeignKeyConstraint nesnesi tanımlıyoruz.*/
    fkSiparisToSepet.DeleteRule = Rule.Cascade;
    /* Delete işleminde uygulanacak kuralı belirliyoruz.*/
    fkSiparisToSepet.UpdateRule = Rule.Cascade;
    /* Güncelleme işleminde uygulanacak kuralı belirliyoruz.*/
    fkSiparisToSepet.AcceptRejectRule = AcceptRejectRule.Cascade;
    /* AcceptChanges ve RejectChanges metodları çağırılıdığında uygulanacak olan kuralları belirliyoruz.*/
    ds = new DataSet();
    ds.Tables.Add(dtSiparis);
    ds.Tables.Add(dtSepet);
    ds.Tables["SiparisDetaylari"].Constraints.Add(fkSiparisToSepet);
    /* Oluşturduğumuz kısıtlamayı ilgili tablonun Constraints koleksiyonuna ekliyoruz. */
    ds.EnforceConstraints = true;
    /* Dataset'in barındırdığı kısıtlamaları uygulatmasını bildiriyoruz. False değeri atarsak dataset nesnesinin içerdiği tablo(lara) ait      kısıtlamalar görmezden gelinir.*/
    dataGrid1.DataSource = ds;
}
private void btnSil_Click(object sender, System.EventArgs e)
{
    try
    {
        DataRow CurrentRow = dtSiparis.Rows.Find(txtSiparisID.Text);
        CurrentRow.Delete();
    }
    catch (Exception hata)
    {
        MessageBox.Show(hata.Source + ":" + hata.Message);
    }
}
```

Şimdi uygulamamızı çalıştıralım. Siparis tablosuna baktığımızda aşağıdaki görünüm yer almaktadır.

![mk17_1.gif](/assets/images/2003/mk17_1.gif)

Şekil 1. Sipariş Verileri

Siparis Detaylarının tutulduğu Sepet tablosunda ise görünüm şöyledir.

![mk17_2.gif](/assets/images/2003/mk17_2.gif)

Şekil 2. Sipariş Detayları

Şimdi 10002 nolu sipariş satırını silelim. Görüldüğü gibi Sepet tablosundan 10002 ile ilgili tüm ilişkili kayıtlar da silinecektir. Aynı zamanda Siparis tablosundan da bu sipariş numarasına ait satır silinecektir. Elbette dataSet nesnemize ait Update metodunu kullanmadığımız için bu değişiklikler sql sunucumuzdaki orijinal tablolara yansımayacaktır.

![mk17_3.gif](/assets/images/2003/mk17_3.gif)

Şekil 3. 10002 nolu siparise ait tüm kayıtlar, Sepet tablosundan Silindi.

![mk17_4.gif](/assets/images/2003/mk17_4.gif)

Şekil 4. 10002 Siparis tablosundan silindi.

Şimdi oluşturmuş olduğumuz bu kısıtlamada Delete kuralını None yapalım ve bakalım bu kez neler olacak. Bu durumda aşağıdaki hata mesajını alacağız.

![mk17_5.gif](/assets/images/2003/mk17_5.gif)

Şekil 5. DeleteRule=Rule.None

Doğal olaraktanda, ne Siparis tablosundan ne de Sepet tablosundan satır silinmeyecektir. Bu kısa bilgilerden sonra umuyorumki kısıtlamalar ile ilgili kavramlarkafanızda daha net bir şekilde canlanmaya başlamıştır. Geldik bir makalemizin daha sonuna bir sonraki makalemizde görüşmek dileğiyle hepinize mutlu günler dilerim.
