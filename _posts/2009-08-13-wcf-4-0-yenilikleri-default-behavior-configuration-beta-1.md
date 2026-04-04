---
layout: post
title: "WCF 4.0 Yenilikleri - Default Behavior Configuration [Beta 1]"
date: 2009-08-13 10:01:00
tags:
  - windows-communication-foundation
categories:
  - Servis Tabanlı Geliştirme
---
Bir kaç gece önce evde DVD keyfi yapmak için A Fistful Of Dollars (Per un pugno di dollari) isimli çok eski bir Western filmi seyrettim. Filmi seyretmeyenler için bir kaç hatırlatma yapayım. Film aslında The Good The Bad and The Ugly ile For a Few Dollars More birlikte oluşan bir üçlemenin ilk halkasını oluşturmakta. Hepside çok güzeldi. Bu filmin belkide en can alıcı ve etkileyici yeri ise sonlarında yaşanan silahlı dövüş sahneleridir.

![wcf 4 0 yenilikleri default behavior configuration beta 1 01](/assets/images/2009/wcf-4-0-yenilikleri-default-behavior-configuration-beta-1-01.png)

Kötü adam, Sarışına (ki bu üçlemenin hiç bir yerinde Client'in adını bilmeyiz. Herkes ona sarışın-Blonde der) defalarca ateş eder. Kötü adam keskin nişancıdır (bu filmlerdeki her kovboy gibi) ve sürekli olarak Sarışının göğsüne ateş eder. Ama Sarışın her yere düştüğünde tekrar ayağa kalkar. Sonunda kötü adamın mermisi tükenir. İşte o an...Sarışın üzerindeki kıyati aralar ve altından saç dökümden metal bir yelek çıkar. Kötü adamın şaşkın bakışları arasında film devam eder.

Buradaki metal döküm yelek çok küçük bir ayrıntıdır ama işlevselliği çok kritiktir. Bu işlevselliğin kritik olması bir yana, Sarışının bu detayla ilintili olarak kötü adamdan gelen kurşunları düşünmesinede gerek kalmamıştır. Şimdi bu konuya nereden geldik. İki sebebimiz var.

WCF 4.0 ile gelen yeniliklerin ilk kümesi olan basitleştirilmiş konfigurasyon (Simplified Configuration) kabiliyetleri, geliştiricinin bazı ince detayları düşünme zorunluluğunu ortadan kaldırmaktadır. Örneğin Endpoint eklenmesede varsayılan olanların çalışma zamanında oluşturulması, bağlayıcılar (Binding Types) için name, binding configuration gibi nitelikleri kullanma zorunluluğunun ortadan kaldırılması veya protocol eşleştirmelerinin kolayca ele alınması vb...Bu birinci nedenimiz. İkinci neden çok daha basittir. Sıkıcı olan bir blog girişi yapmamak...

Bu seferki konumuz aslında bir önceki yazımızda değerlendirdiğimiz Default Binding Configuration özelliğinin Behavior için olan versiyonudur. Dolayısıyla bu kez, name ve behaviorConfiguration niteliklerine olan zorunluluğun ortadan kalktığını söyleyerek işin içerisinden çıkabiliriz. Ama tembellik etmeyip araştırmamızdan bir zarar da gelmez.

Olaya ilk olarak davranış (Behavior) kavramından başlamakta yarar var. WCF tarafında Service, EndPoint, Operation veya Contract gibi seviyelerde çalışma zamanı davranışları belirlenebilir. Örneğin bir http bazlı bir servisin metadata publishind desteğinin olup olmaması, Exception detaylarının istemci tarafına gönderilip gönderilmemesi yada bir endPoint için kullanılacak sertifika bilgilendirmelerinin tasarlanması. Normal şartlar altında WCF 3.5 ile geliştirilen bir servis uygulamasında davranış tanımlamaları için config dosyalarını aşağıdaki örnekte olduğu gibi kullanırız.

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <system.serviceModel>
        <behaviors>
            <serviceBehaviors>
                <behavior name="CalculusServiceBehavior">
                    <serviceDebug includeExceptionDetailInFaults="true" />
                  <dataContractSerializer maxItemsInObjectGraph="3"/>
                </behavior>
            </serviceBehaviors>
        </behaviors>
        <services>
            <service behaviorConfiguration="CalculusServiceBehavior" name="NewVersion.Calculus">
                <endpoint address="net.tcp://localhost:4500/Calculus" binding="netTcpBinding"
                    bindingConfiguration="" name="EndPoint1" contract="NewVersion.ICalculus" />
                <endpoint address="http://localhost:4501/Calculus" binding="basicHttpBinding"
                    name="EndPoint2" contract="NewVersion.ICalculus" />
            </service>
        </services>
    </system.serviceModel>
</configuration>
```

Bu içeriğe göre servis için iki çalışma zamanı davranışı belirlenmiştir. serviceDebug ve dataContractSerializer. Bizim konsantre olacağımız nokta ise behavior elementinin name niteliğinin değeri ile, service elementinin behaviorConfiguration niteliğinin değerinin aynı olmasıdır. Dolayısıya servisler veya EndPoint'ler hangi davranışları kullanacaklarını behaviorConfiguration niteliklerinde bildirirler. E tabi bu config içeriğini ele alan bir uygulamayı test etmessek olmaz. Yenilikten emin olabilmemiz ve ispat edebilmemiz için bu şart. Bu nedenle sıkılmadan aşağıdaki kodları yazalım.(Tam bir Matematik Mühendisi gibi olaya yaklaşmaktan kendimi alamadığımı söyleyebilirim. İspat, ispat, ispat...

```csharp
using System;
using System.Linq;
using System.ServiceModel;

namespace NewVersion
{
    [ServiceContract]
    interface ICalculus
    {
        [OperationContract]
        double Sum(params double[] values);
    }

    class Calculus
        : ICalculus
    {
        public double Sum(params double[] values)
        {
            return values.Sum();
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            ServiceHost host = new ServiceHost(typeof(Calculus));
            host.Open();

            foreach (var behavior in host.Description.Behaviors)
            {
                Console.WriteLine(behavior.ToString());
            }

            Console.WriteLine("Kapatmak için bir tuşa basın");
            Console.ReadLine();

            host.Close();
        }
    }
}
```

Örneğimizde tek yaptığımız servisin açılmasından sonra yüklü olan davranışlarını listelemektir. Örneği çalıştırdığımızda aşağıdaki sonuçları elde ederiz.

![blg62_FirstRun.gif](/assets/images/2009/blg62_FirstRun.gif)

WCF 4.0 tarafında ise config dosyası içerisinde davranışlar için name ve behaviorConfiguration isimli niteliklerin kullanılma zorunluluğu yoktur. Dolayısıyla config dosyasını aşağıdaki gibi değiştirirsek,

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.serviceModel>
    <behaviors>
      <serviceBehaviors>
        <behavior><!-- name niteliği kullanılmamıştır.-->
          <serviceDebug includeExceptionDetailInFaults="true" />
          <dataContractSerializer maxItemsInObjectGraph="3"/>
        </behavior>
      </serviceBehaviors>
    </behaviors>
    <services>
      <service name="NewVersion.Calculus"><!-- behaviorConfiguration niteliği kullanılmamıştır-->
        <endpoint address="net.tcp://localhost:4500/Calculus" binding="netTcpBinding"
            name="EndPoint1" contract="NewVersion.ICalculus" />
        <endpoint address="http://localhost:4501/Calculus" binding="basicHttpBinding"
            name="EndPoint2" contract="NewVersion.ICalculus" />
      </service>
    </services>
  </system.serviceModel>
</configuration>
```

ve örneğimizi yeniden çalıştırırsak bir önceki ile aynı sonuçları elde ettiğimizi görürüz.

![blg62_LastRun.gif](/assets/images/2009/blg62_LastRun.gif)

Tabi son örneğimizin.Net Framework 4.0 Beta 1 tabanlı olarak Visual Studio 2010 Beta 1 üzerinde geliştirildiğini hatırlatalım. Basit çok basit bir özellik ama merak etmeyin. WCF 4.0 ile ilişkili daha baba yeniliklerde bulunmakta. İlerleyen yazılarımızda bunlarada değiniyor olacağız. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.

[DefaultBehaviorConfiguration.rar (43,75 kb)](/assets/files/2009/DefaultBehaviorConfiguration.rar)
