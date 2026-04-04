---
layout: post
title: "Ado.Net 2.0(Beta 2) - Connection String Security (Bağlantı Katarı için Güvenlik)"
date: 2005-10-17 09:00:00
tags:
  - ado.net
  - connection-string-security
categories:
  - Framework Tabanlı Programlama
---
Güvenlik günümüz uygulamalarında çok önemli bir yere sahiptir. Özellikle veritabanı kullanımını içeren uygulamalarda güvenliğin ayrı bir önemi vardır. Veritabanına gönderilen sorguların korunması, özellikle web servislerinden dönen veri kümelerinin etkin olarak şifrelenmesi gibi durumlar söz konusudur. Güvenlik prosedürü içerisinde yer alan unsurlardan birisi de bağlantı bilgilerinin saklanmasıdır. Biz bu makalemizde, .NET 2.0 ile birlikte gelen yeni tekniklerden birisine değinerek, bağlantı bilgisinin (çoğunlukla connection string olarak da ifade edebiliriz) kolay bir şekilde nasıl korunabileceğini incelemeye çalışacağız.

Bildiğiniz gibi, .NET tabanlı uygulamalar özellikle XML tabanlı konfigürasyon dosyalarını yoğun olarak kullanır. Varsayılan olarak Windows uygulamalarında app.config veya web uygulamalarında yer alan web.config dosyaları, genel bilgilerin yer aldığı kaynaklardır. Çoğunlukla proje genelinde kullanılan bağlantı bilgilerini bu dosyalarda key-value (anahtar-değer) çiftleri şeklinde tutmayı tercih ederiz. Aslında bağlantı katarı (connection string) bilgilerini kod içerisinde de global seviyede tanımlayıp kullanabiliriz. Ancak bunun birtakım dezavantajları vardır.

> Bağlantı katarı gibi sonradan (özellikle ürün canlı yayına başladıktan sonra) sıkça değişebilecek bilgileri kod içerisinde (hard-coded) tutmak güvenlik ve yönetilebilirlik açısından dezavantajlara sahiptir.

Birincisi, yazılan kodlar sonuç olarak IL dilini kullandığından ters çevrilerek açığa çıkartılabilir. (Disassembly araçları) Bu nedenle bağlantı katarı bilgisi de öğrenilebilir. Diğer yandan, uygulamalar canlı hayata geçtikten sonra, kullandıkları veri tabanı sunucularının IP bilgilerinin, kullanıcı tanımlamalarının sıkça değişmesi nedeniyle bağlantı katarı bilgilerinin sıkça güncellenmesi gerekebilir. İşte bu iki nedenden ötürü bu tip bilgiler XML tabanlı konfigürasyon dosyalarında, özel şifreleme teknikleri ile tutulur.

Aşağıdaki kod parçalarında bir web uygulaması ve bir console uygulaması için kullandığımız standart konfigürasyon dosyalarında yer alan bağlantı katarı tanımlamalarını ve bu bağlantı katarları içerisindeki bilgilerin kullanımını gösteren iki örnek yer almaktadır.

Sıradan bir console uygulaması için app.config içeriği;

```xml
<?xml version="1.0" encoding="utf-8" ?>
    <configuration>
        <appSettings>
            <add key="conStr" value="data source=localhost;database=AdventureWorks2000;user id=sa;password="></add>
        </appSettings>
</configuration>
```

conStr isimli anahtarın uygulama içerisinden kullanımı;

```csharp
using System;
using System.Data.SqlClient;

namespace UsingConnectionString
{
    class Class1
    {
        [STAThread]
        static void Main(string[] args)
        {
            string conStr=System.Configuration.ConfigurationSettings.AppSettings["conStr"].ToString();
            using(SqlConnection con=new SqlConnection(conStr))
            {
                con.Open();
            } 
        }
    }
}
```

Bir web uygulamasında web.config içerisinde bağlantı katarı (connection string) için anahatar-değer (key-value) kullanımı.

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <appSettings>
        <add key="conStr" value="data source=localhost;database=AdventureWorks2000;user id=sa;password="></add>
    </appSettings>
    <system.web>
        <!-- Diğer ayarlar-->
    </system.web>
</configuration>
```

Web.Config içerisindeki bağlantı katarı bilgisinin default.aspx içerisinde kullanımı;

```csharp
private void Page_Load(object sender, System.EventArgs e)
{
    string conStr=System.Configuration.ConfigurationSettings.AppSettings["conStr"].ToString();
    using(SqlConnection con=new SqlConnection(conStr))
    {
        con.Open();
    }
}
```

Gelelim .NET 2.0'a. Yeni versiyonda özellikle bağlantı katarlarına yönelik olarak geliştirilmiş özel bir güvenlik tekniği mevcuttur. Bu tekniğin kilit noktaları olarak, konfigürasyon ayarlarına eklenen iki yeni nitelik söz konusudur. Bu nitelikler protectedData ve protectedDataSections'dır. ProtectedDataSections niteliği altında sonradan şifrelenmesi düşünülen anahtar bilgileri tutulmaktadır. Bağlantı katarı için kullanacağımız anahtar bilgisini burada tutabiliriz. ProtectedData kısmında ise, ProtectedDataSections içerisinde yer alan anahtar bilgisini şifreleyecek (encryption) ve deşifre edecek (decryption) provider nesnesine ait bilgiler yer alır. Şu an için RSAProtectedConfigurationProvider ve DPAPIProtectedConfigurationProvider adında iki adet şifreleme provider'ı mevcuttur. Bu provider'lar, ilgili verinin şifrelenmesinden ve özellikle çalışma zamanında kullanılırken deşifre edilmesinden sorumludur. İlk olarak konfigürasyon dosyası içerisinde bu yapıları kullanarak gerekli düzenlemeleri yapmamız gerekmektedir.

.NET 2.0 için bir console uygulamasına ait app.config konfigürasyon dosyasının örnek içeriği.

```xml
<?xml version="1.0" encoding="utf-8" ?>
    <configuration>
        <connectionStrings>
            <EncryptedData/>
        </connectionStrings>

        <protectedData>
            <providers>
                <add name="prvCon" type="System.Configuration.RsaProtectedConfigurationProvider" keyContainerName="AnahtarDeger" useMachineContainer="true"/>
            </providers>

            <protectedDataSections>
                <add name="connectionStrings" provider="prvCon" inheritedByChildren="false"/>
            </protectedDataSections>

        </protectedData>
</configuration>
```

Dikkat ederseniz protectedDataSections sekmesi, protectedData altında yer alan bir bölümdür. Providers kısmında, şifreleme işlemini yapacak olan tipe ait bilgiler yer almaktadır. Bu tipin takma adı name özelliği ile, tipin kendisi type özelliği ile, kullanılacak şifreleme anahtarının adı ise keyContaionerName özelliği ile tutulur. ProtectedDataSections kısmında, şifrelenecek olan anahtar bilgisi yer alır. Ancak dikkat ederseniz burada bağlantı katarına ilişkin herhangi bir bilgi yoktur. Sadece şifrelemeyi yapacak provider'ın takma adını alan name özelliği vardır. Bu özellik ile, provider sekmesinde yer alan tipi işaret ederiz. Peki bağlantı katarımız nerede yer almaktadır?

Dikkat ederseniz dosyanın başında connectionStrings isimli takılar arasında yer alan EncryptedData isimli bir sekme yer almaktadır. ConnectionStrings konfigürasyon dosyalarına eklenen yeni niteliklerden birisidir ve sadece bağlantı katarı bilgisi ile ilgilidir. Biz biraz sonra yazacağımız kodları çalıştırdığımızda, bağlantı katarımıza ait bilgiler şifrelenerek bu kısım içerisine eklenecektir. Bir başka deyişle EncryptedData kısmı şifrelenen verinin taşıyıcısıdır. Burada dikkat edilmesi gereken noktalardan birisi isim uyumluluğudur. Öyle ki connectionStrings takısının ismi, protectedDataSections kısmındaki anahtarın ismi ile aynı olmak zorundadır.

Bağlantı katarının connectionStrings isimli anahtara eklenmesi için ekstra kod yazmamız gerekmektedir. .NET 2.0'da System.Configuration isim alanına birtakım yeni sınıflar eklenmiştir. Biz bu sınıflar yardımıyla, konfigürasyon dosyamıza müdahale ederek, connectionStrings isimli anahtara hem değer ataması yapabilir hem de şifreleme işlemini başlatabiliriz. Bu amaçla aşağıdaki gibi bir kod yazmamız gerekmektedir. Örnek olarak bir console uygulaması göz önüne alınmıştır.

```csharp
using System;
using System.Configuration;
using System.Collections.Generic;
using System.Text;

namespace UsingAppSettings
{
    class Program
    {
        static void Main(string[] args)
        {
            Configuration cnfg = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None, "");
            cnfg.ConnectionStrings.ConnectionStrings.Add(new ConnectionStringSettings("conStr","data source=localhost;database=AdventureWorks;integrated security=SSPI"));
            cnfg.Save();
        }
    }
}
```

Çok fazla detaya girmeden yukarıdaki kodlar ile ne yaptığımızdan kısaca bahsetmek istiyorum. İlk olarak bir Configuration nesnesine atama yapıyoruz. Bu atamada ConfigurationManager sınıfının statik OpenExeConfiguration metodunu kullanmaktayız. Bu metot aslında belirtilen konfigürasyon dosyasını bir Configuration nesnesi olarak atamak için kullanılmaktadır. İkinci parametre konfigürasyon dosyasının yolunu belirtir. Biz aynı uygulama içerisinde olduğumuzdan burayı boş bıraktık. Daha sonra bu nesne üzerinde hareket ederek ConnectionStrings sınıfının Add metodunu çağırıyor ve bağlantı katarımızı conStr ismi ile ilgili dosyaya ekliyoruz. Tabii ki bu ekleme işlemi sırasında provider'ımız devreye giriyor ve bilgiyi şifreleyerek uygulamaya ait konfigürasyon dosyasına yazıyor. Son olarak Save metodu ile konfigürasyon dosyamızı kaydediyoruz.

Normalde bu tip işlemleri 1.1 versiyonunda yapmak için, yani XML tabanlı konfigürasyon dosyasına kod bazında müdahale etmek için XmlDocument sınıfını kullanarak ayrıştırma işlemlerini (parsing) yapmamız gerekirdi. Yeni versiyonda gördüğünüz gibi bu tarz işlemleri nesne bazında kolayca yapabilmekteyiz.

> Uygulamayı denediğim .NET 2.0 Beta versiyonunda, Configuration sınıfına erişebilmek için, System.Configuration isim alanını projenin referanslarına Add Reference tekniği ile açıkça eklemem gerekti. Aksi takdirde, System.Configuration üzerinden Configuration ve ConfigurationManager gibi sınıflara direkt olarak erişilemiyor.

Yazdığımız Console uygulamasını ilk çalıştırdığımızda konfigürasyon dosyalarında herhangi bir değişiklik olmadığını görürüz. Özellikle uygulamanın debug klasöründe yer alan ve exe dosyamız ile aynı isme sahip konfigürasyon dosyalarında bir değişiklik olmayacaktır. Bunun sebebi, provider'ın şifreleme için kullanacağı bir anahtar değerin bulunmayışıdır. Hatırlarsanız provider tanımında keyContaionerName isimli bir özellik belirlemiştik. KeyContainerName özelliğine atadığımız AnahtarDeger, RS şifrelemesi için gerekli anahtar kodunu taşımak için kullanılacaktır. Peki böyle bir anahtar değerini nasıl elde edebiliriz? Bunun için aspnet_regiis aracını kullanabiliriz. Aşağıdaki komut satırı yardımıyla bu işlemi gerçekleştirmekteyiz.

![mk139_1.gif](/assets/images/2005/mk139_1.gif)

Bu işlemi yaptığımız takdirde uygulamamızın exe kodunun bulunduğu klasörde yer alan aynı isimli konfigurasyon dosyası (UsingAppSettings.EXE.xml) içeriğinin aşağıdaki gibi yazıldığını görürüz. Özellikle EncryptedData ve EncryptedKey kısımlarına dikkat ediniz.

```xml
<?xml version="1.0" encoding="utf-8" ?>
    <configuration>
        <connectionStrings>
            <EncryptedData Type="http://www.w3.org/2001/04/xmlenc#Element" xmlns="http://www.w3.org/2001/04/xmlenc#">
                <EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#tripledes-cbc" />
                <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <EncryptedKey Recipient="" xmlns="http://www.w3.org/2001/04/xmlenc#">
                <EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#rsa-1_5" />
                <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <KeyName>Rsa Key</KeyName>
                </KeyInfo>
                <CipherData>                            <CipherValue>EIskDt2vsIN6xk5qC1S6slkWX97Ua28KGGJTkHx500UsfMbed1TnZpQLYJaJW5XJXQPe
Y3IWm7iKdEZ+idx7THKlAx8eLf/HHDSi/HWp7sSJe6/4vcS6uQ+OyigdLpO6X3LEqoGYhwCNPoZq7e/e
B/P+w9pzLwivdczR1sOYMlQ=</CipherValue>
                </CipherData>
            </EncryptedKey>
            </KeyInfo>
            <CipherData>   <CipherValue>fKJrwr1tdHNyVH9OYKlFeK7B7C1tzxp2ikrgu+KbCNBHM9fffFGt
EIRc9n0edC8poSskU7+APE18O6SRFqXD3OG0NX+9b65OIIHAXhEHdMYAbejU
VvqGoNw4xkisDfk/CgANrO9kST5f15g/0bH+5Cv83ptAV8mzIvzbvAzd+kpWdk
Q0T99jmiymcwqICBExmvUhT1wSUemYMC2Rzz3
JbJISvyqOZH9AYIxCesaeWwcyOvQfzLyHEw==</CipherValue>
            </CipherData>
        </EncryptedData>
    </connectionStrings>
    <protectedData>
        <providers>
            <add name="prvCon" type="System.Configuration.RsaProtectedConfigurationProvider" keyContainerName="AnahtarDeger" useMachineContainer="true"/>
        </providers>
        <protectedDataSections>
            <add name="connectionStrings" provider="prvCon" inheritedByChildren="false"/>
        </protectedDataSections>
    </protectedData>
</configuration>
```

Gördüğünüz üzere, içeride şifrelenmiş bir takım veriler bulunmaktadır. Bu veriler aslında, programatik olarak atadığımız bağlantı katarına ilişkin bilgilerdir. Peki bu bilgiyi uygulamamızda nasıl kullanabiliriz? ConfigurationManager sınıfı yardımıyla bu bağlantı bilgisini kod içerisinden okuyabilir ve ilgili bağlantı nesneleri için atayabiliriz. Aşağıdaki örnek kod parçası bu işlemin örnek olarak nasıl yapılabileceğini göstermektedir.

```csharp
string conStr=ConfigurationManager.ConnectionStrings["conStr"].ConnectionString.ToString();
using (SqlConnection con = new SqlConnection(conStr))
{
    // Bir takım kodlar
}
```

Yapmış olduklarımızı özetlersek; .NET 2.0, Configuration isim alanı altında yeni özelliklere sahip pek çok tip sunmaktadır. Buradaki sınıfları ve konfigürasyon dosyaları için geliştirilen yeni nitelikleri kullanarak, config dosyalarında tutulan bağlantı katarı bilgilerini yabancı gözlerden saklayabiliriz. Elbette, kod içerisinde ConfigurationManager üzerinde ilgili bağlantı katarı bilgisini okuyabilirsiniz. Ancak herkesin görebildiği config dosyalarından bağlantı katarı bilgisini okuyamazsınız. Tabii ne yaparsanız yapın yine de güvenliği tam olarak sağlamak söz konusu olamaz. Her zaman için en azından %1 ihtimal ile tüm sistemler güvensizdir. Böylece geldik bir makalemizin daha sonuna. Bir sonraki makalemizde görüşünceye dek hepinize mutlu günler dilerim.