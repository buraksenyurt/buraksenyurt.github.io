---
layout: post
title: "Xml Web Servisleri - 4 ( Mimarinin Temelleri - WSDL)"
date: 2004-10-02 12:00:00
tags:
  - xml-web-service
  - xml
  - wsdl
categories:
  - Servis Tabanlı Geliştirme
---
İstemciler, web servisleri ile aralarındaki iletişimi, çalıştıkları makinede oluşturulan proxy nesneleri yardımıyla gerçekleştirir. Bu, istemci uygulamanın, web servisine ait üyelerin farkında olmasını gerektiren bir durumdur. Nitekim proxy nesnesini oluşturan sınıf, web servisindeki public arayüze göre tasarlanır. Dolayısıyla, istemci uygulamanın kullandığı web servisine ait bilgileri bir şekilde temin etmesi gerekmektedir. Visual Studio .NET ortamında geliştirdiğimiz istemci uygulamada, projeye web servisinin referans olarak eklenmesi sonucu oluşturulan bazı dosyalar olduğundan bahsetmiştik. Disco uzantılı bir dosya, WSDL uzantılı bir dosya ve proxy sınıfımıza ait cs uzantılı dosya.

![mk101_1.gif](/assets/images/2004/mk101_1.gif)

Şekil 1. Istemci uygulamada oluşturulan dosyalar.

Proxy sınıfı ile WSDL dosyası arasında sıkı bir ilişki vardır. Visual Studio .NET ortamını göz önüne aldığımızda, istemci uygulamaya Add Web Reference ile var olan bir web servisinin eklenmesi durumunda ilk olarak .NET, bu servisten WSDL uzantılı bir doküman talep edecektir. WSDL (Web Service Description Language - Web Servisleri Tanımlama Dili) ile oluşturulan bu doküman XML tabanlı olup, web servisinin herkese açık olan üyeleri, başka bir deyişle arayüzü hakkında tanımlamalara sahiptir. Talep edilen WSDL belgesi istemci uygulamaya indirilir. İndirilen doküman yardımıyla, istemcilerin web servisleri ile haberleşmelerini kolaylaştıracak proxy sınıfı oluşturulur.

WSDL dokümanları XML tabanlı olmaları nedeniyle her türlü platforma indirilebilirler. XML tabanlı olup web servisinin yapısı hakkında tanımlamalara sahip olduklarından, indirilme süreleri çok uzun değildir. Bir WSDL dokümanı istemci uygulamaya, web servisi ilk kez referans edildiğinde indirilir. Elbette ki web servisinde yapılacak güncellemelerin istemci bilgisayar üzerinde de gerçekleştirilmesi durumunda bu WSDL dokümanı tekrardan istemci bilgisayara indirilecektir.

![mk101_2.gif](/assets/images/2004/mk101_2.gif)

Şekil 2. WSDL Dokümanının Web Servislerinin Kullanımındaki Yeri.

Geliştirdiğimiz istemci uygulamaya ait WSDL dokümanı aşağıdaki gibidir.

```xml
<?xml version="1.0" encoding="utf-8"?> 
<definitions xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:s0="http://ilk/servis/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" targetNamespace="http://ilk/servis/" xmlns="http://schemas.xmlsoap.org/wsdl/">
<types>
<s:schema elementFormDefault="qualified" targetNamespace="http://ilk/servis/">       
<s:element name="DaireAlan">         
<s:complexType>
<s:sequence>
<s:element minOccurs="1" maxOccurs="1" name="r" type="s:double" />
</s:sequence>
</s:complexType>
</s:element>
<s:element name="DaireAlanResponse">
<s:complexType>
<s:sequence>
<s:element minOccurs="1" maxOccurs="1" name="DaireAlanResult" type="s:double" />
</s:sequence>
</s:complexType>
</s:element>
<s:element name="DaireCevre">
<s:complexType>
<s:sequence>
<s:element minOccurs="1" maxOccurs="1" name="r" type="s:double" />
</s:sequence>
</s:complexType>
</s:element>
<s:element name="DaireCevreResponse">
<s:complexType>
<s:sequence>
<s:element minOccurs="1" maxOccurs="1" name="DaireCevreResult" type="s:double" />
</s:sequence>
</s:complexType>
</s:element>
<s:element name="DaireCevreDizi">
<s:complexType>
<s:sequence>
<s:element minOccurs="0" maxOccurs="1" name="r" type="s0:ArrayOfDouble" />
</s:sequence>
</s:complexType>
</s:element>
<s:complexType name="ArrayOfDouble">
<s:sequence>
<s:element minOccurs="0" maxOccurs="unbounded" name="double" type="s:double" />
</s:sequence>
</s:complexType>
<s:element name="DaireCevreDiziResponse">
<s:complexType>
<s:sequence>
<s:element minOccurs="0" maxOccurs="1" name="DaireCevreDiziResult" type="s0:ArrayOfDouble" />
</s:sequence>
</s:complexType>
</s:element>
</s:schema>
</types>
<message name="DaireAlanSoapIn">
<part name="parameters" element="s0:DaireAlan" />
</message>
<message name="DaireAlanSoapOut">
<part name="parameters" element="s0:DaireAlanResponse" />
</message>   <message name="DaireCevreSoapIn">
<part name="parameters" element="s0:DaireCevre" />
</message>   <message name="DaireCevreSoapOut">
<part name="parameters" element="s0:DaireCevreResponse" />
</message>   <message name="DaireCevreDiziSoapIn">
<part name="parameters" element="s0:DaireCevreDizi" />
</message>   <message name="DaireCevreDiziSoapOut">
<part name="parameters" element="s0:DaireCevreDiziResponse" />
</message>   <portType name="Geometrik_x0020_HesaplamalarSoap">
<operation name="DaireAlan">
<documentation>Daire Alan Hesabi Yapar</documentation>
<input message="s0:DaireAlanSoapIn" />
<output message="s0:DaireAlanSoapOut" />
</operation>     <operation name="DaireCevre">
<documentation>Daire Çevre Hesabi Yapar.</documentation>
<input message="s0:DaireCevreSoapIn" />
<output message="s0:DaireCevreSoapOut" />
</operation>
<operation name="DaireCevreDizi">
<documentation>Daire Cevre Hesabini Dizi Elamanlarina Uygular.</documentation>
<input message="s0:DaireCevreDiziSoapIn" />
<output message="s0:DaireCevreDiziSoapOut" />
</operation>
</portType>
<binding name="Geometrik_x0020_HesaplamalarSoap" type="s0:Geometrik_x0020_HesaplamalarSoap">
<soap:binding transport="http://schemas.xmlsoap.org/soap/http" style="document" />
<operation name="DaireAlan">
<soap:operation soapAction="http://ilk/servis/DaireAlan" style="document" />
<input>
<soap:body use="literal" />
</input>
<output>
<soap:body use="literal" />
</output>
</operation>
<operation name="DaireCevre">
<soap:operation soapAction="http://ilk/servis/DaireCevre" style="document" />
<input>
<soap:body use="literal" />
</input>
<output>
<soap:body use="literal" />
</output>
</operation>
<operation name="DaireCevreDizi">
<soap:operation soapAction="http://ilk/servis/DaireCevreDizi" style="document" />
<input>
<soap:body use="literal" />
</input>
<output>
<soap:body use="literal" />
</output>
</operation>
</binding>
<service name="Geometrik_x0020_Hesaplamalar">
<documentation>Geometrik Hesaplamalar Üzerine Metodlar Içerir. Ucgen, Dortgen gibi sekillere yönelik alan ve çevre hesaplamalari.</documentation>
<port name="Geometrik_x0020_HesaplamalarSoap" binding="s0:Geometrik_x0020_HesaplamalarSoap">
<soap:address location="http://localhost/GeoWebServis/GeoMat.asmx" />
</port>
</service>
</definitions>
```

Bu WSDL dokümanı, geliştirdiğimiz servise ait tüm bilgileri içerir. Hangi metotların kullanılabileceği, bu metotların ne çeşit parametreler aldığı ve geriye ne tür değerleri nasıl döndürdüğü gibi bilgileri sunar. Temel olarak bir WSDL dokümanı 5 ana kısımdan oluşur.

![mk101_3.gif](/assets/images/2004/mk101_3.gif)

Şekil 3. Bir WSDL dokümanının temel kısımları.

Types kısmında, web servisi ile ilişkili SOAP mesajlarında taşınacak parametre ve geri dönüş değerlerine ait şema elemanları tanımlanır. Örneğin,

```xml
<s:element name="DaireAlan">
	<s:complexType>
		<s:sequence>
			<s:element minOccurs="1" maxOccurs="1" name="r" type="s:double" />
		</s:sequence>
	</s:complexType>
</s:element>
```

elamanında, DaireAlan isimli parametrenin double tipinden ve r isminde olduğu belirtilmektedir. Aynı şekilde geri döndürelecek değer ise, DaireAlanRespone elamanı olarak tanımlanmıştır.

```xml
<s:element name="DaireAlanResponse"> - <s:complexType>
		<s:sequence>
			<s:element minOccurs="1" maxOccurs="1" name="DaireAlanResult" type="s:double" />
		</s:sequence>
	</s:complexType>
</s:element>
```

Message kısmında, web servisinin kabul edeceği ve geri döndüreceği mesajlara ait özet bilgiler yer alır.

```xml
<message name="DaireAlanSoapIn">
	<part name="parameters" element="s0:DaireAlan" />
	</message>
	<message name="DaireAlanSoapOut">
	<part name="parameters" element="s0:DaireAlanResponse" />
	</message>
	<message name="DaireCevreSoapIn">
	<part name="parameters" element="s0:DaireCevre" />
	</message>
	<message name="DaireCevreSoapOut">
	<part name="parameters" element="s0:DaireCevreResponse" />
	</message>
	<message name="DaireCevreDiziSoapIn">
	<part name="parameters" element="s0:DaireCevreDizi" />
	</message>
<message name="DaireCevreDiziSoapOut">
```

Görüldüğü gibi, her SOAP mesajı için In ve Out takılı mesaj elemanları mevcuttur. Buradaki mesajlar, belirledikleri metod için input ve output parametrelerini tanımlarlar. Bir başka deyişle, SOAP mesajları içine konan ve SOAP mesajları ile geri dönen parametreler tanımlanmaktadır.

```xml
<message name="DaireAlanSoapIn">
	<part name="parameters" element="s0:DaireAlan" />
	</message>
	<message name="DaireAlanSoapOut">
	<part name="parameters" element="s0:DaireAlanResponse" />
</message>
```

Örneğin burada, DaireAlan metodu için oluşturulan SOAP Mesajlarının, iki türü tanımlanmıştır. Web servisine gidecek olan SOAP mesajları, DaireAlan elemanı tipinden parametre alacaktır. DaireAlan elemanının types kısmında tanımlanmış olduğuna dikkat edelim. Aynı şekilde, istemciye dönecek olan SOAP mesajıda, DaireAlanResponse elemanı tipinden bir parametre ile gelecektir.

PortType kısmında ise, her bir web servisi metodu için birer operasyon tanımlaması yapılır. Bu sayede, proxy nesnesi üzerindeki bir metod ile web servisi üzerinde kullanılabilir çağırılar gerçekleştirilebilecektir. Başka bir deyişle, web servisi üzerinden gerçekleştirilebilecek operasyonların tanımlamaları yapılmaktadır. Operasyon isimleri, burada görüldüğü gibi web servisindeki metod isimleri ile aynıdır. Buradaki eleman isimleri ile fiziki metodlar binding kısmında eşleştirilecektir.

```xml
<portType name="Geometrik_x0020_HesaplamalarSoap">
	<operation name="DaireAlan">
		<documentation>Daire Alan Hesabi Yapar</documentation>
		<input message="s0:DaireAlanSoapIn" />
		<output message="s0:DaireAlanSoapOut" />
	</operation>
	<operation name="DaireCevre">
		<documentation>>Daire Çevre Hesabi Yapar.</documentation>
		<input message="s0:DaireCevreSoapIn" />
		<output message="s0:DaireCevreSoapOut" />
	</operation>
	<operation name="DaireCevreDizi">
		<documentation>Daire Cevre Hesabini Dizi Elamanlarina Uygular.</documentation>
		<input message="s0:DaireCevreDiziSoapIn" />
		<output message="s0:DaireCevreDiziSoapOut" />
	</operation>
</portType>
```

DaireAlan operasyonunu ele alalım. Bu operasyon gerçekleştiğinde, SOAP mesajlarının nasıl bir formatta olacağı, başka bir deyişle hangi tipte ve isimde elemanlar alacağı, input message ve output message elemanlarının karşılık geldiği message elemanlarında belirtilmiştir. Message elemanları ise, bu mesajların taşıyacağı parametrelerin tipini tanımlar. Bu tipler ise, types kısmında belirtilmiştir.

Binding kısmında, WSDL dokümanındaki her bir operasyon için, bu operasyona web servisinde karşılık gelecek metot tanımlamaları yapılır. Bir başka deyişle her bir operation elemanı için fiziki olarak metot adresleri belirlenir. Bu adresler için kullanılacak operasyonlar belirli olduğu için, bu operasyonlara bağlı mesajlar da fiziki adreslere bağlanmış olur.

```xml
<binding name="Geometrik_x0020_HesaplamalarSoap" type="s0:Geometrik_x0020_HesaplamalarSoap">
<soap:binding transport="http://schemas.xmlsoap.org/soap/http" style="document" />
<operation name="DaireAlan">
<soap:operation soapAction="http://ilk/servis/DaireAlan" style="document" />
	<input>
		<soap:body use="literal" />
	</input> 
	<output>
		<soap:body use="literal" />
	</output>
</operation>
```

Örneğin, DaireAlan metoduna ilişkin operation elemanı, soapAction anahtar kelimesini takip eden kısımda web servisinin isim alanı ve metodu ile oluşturulmuş url’ ye bağlanmıştır. Son olarak service kısmında ise, tanımlanan port’ ların gerçekte fiziki olarak hangi adrese bakacağı tanımlanır.

```xml
<service name="Geometrik_x0020_Hesaplamalar">
<documentation>Geometrik Hesaplamalar Üzerine Metodlar Içerir. Ucgen, Dortgen gibi sekillere yönelik alan ve çevre hesaplamalari.</documentation>
	<port name="Geometrik_x0020_HesaplamalarSoap" binding="s0:Geometrik_x0020_HesaplamalarSoap">
		<soap:address location="http://localhost/geowebservis/geomat.asmx" />
	</port>
</service>
```

WSDL dokümanının içeriği karmaşık gibi görünse de, aslında bu içeriğin oluşturulması ile fazla uğraşmayız. Bir web servisi kullanıcısı, Visual Studio .NET ortamını kullanmasa dahi, bu web servisine ait WSDL dokümanını yazmak zorunda değildir. Sonuç olarak WSDL dokümanı, web servisinden aşağıdaki gibi bir URL ile talep edilebilir.

```text
http://localhost/geowebservis/geomat.asmx?wsdl
```

Bu URL'nin çalışması sonucunda, yazdığımız web servisi için otomatik olarak bir WSDL dokümanı üretilecektir. Peki elimizde Visual Studio .NET gibi bir geliştirme ortamı yok ise, bu WSDL dokümanını kullanarak bir proxy sınıfını nasıl oluşturabiliriz? Bunun için .NET Framework'te yer alan wsdl aracını kullanmamız yeterlidir.

Buraya kadar işlediklerimiz ile, bir web servisini kullanmak için, bu web servisinin modelini istemci bilgisayarda oluşturacak bir proxy sınıfına ihtiyacımız olduğunu biliyoruz. Bununla birlikte, bu proxy nesnesini oluşturmak için, istemcinin web servisine ait WSDL dokümanını talep ettiğini de biliyoruz. Her ne kadar Visual Studio .NET gibi bir görsel geliştirme ortamında, web servisine ait referans bilgisini istemci uygulamaya birkaç basit adımda ekleyerek, proxy nesnesinin veri modelini kapsülleyecek sınıfı oluşturmak kolay olsa da, bu işi .NET Framework ile gelen Wsdl aracı yardımıyla da gerçekleştirebiliriz. Sonuç olarak, her zaman elimizin altında Visual Studio .NET gibi profesyonel bir yazılım geliştirme platformu olmayabilir.

Wsdl aracı.Net Framework ile birlikte standart olarak gelen bir araçtır. Görevi, istemci uygulamalar için proxy nesnelerine veri modeli sağlayacak proxy sınıflarını oluşturmaktır. Wsdl aracının çeşitli kullanım versiyonları vardır. Bunlardan en çok kullanılanı, web servisine ait asmx dosyasının tam url bilgisini parametre olarak alan aşağıdaki yöntemdir.

```text
Wsdl url/<web servisi adı>.asmx
```

Şimdi, geliştirmiş olduğumuz web servisine ait bir proxy sınıfını wsdl aracı ile nasıl oluşturabileceğimize bakalım. Bunun için komut satırında aşağıdaki söz dizimini kullanmamız yeterli olacaktır.

![mk101_4.gif](/assets/images/2004/mk101_4.gif)

Şekil 4. WSDL Aracının kullanılması.

Wsdl aracının bu şekildeki kullanımında dikkat etmemiz gereken tek nokta, web servisine ait url bilgisinin tam olarak girilmesidir. Bu işlemin sonucunda, wsdl aracını çalıştırdığımız klasörde, parametre olarak verilen web servise ait bir sınıf dosyası oluşturulduğunu görürüz. Bu dosya, proxy sınıfımıza ait veri modelini kapsülleyen bir yapıda teşkil edilmiştir. Dosyanın adı varsayılan olarak, web servisini oluşturduğumuz sınıf dosyası içindeki, WebServices niteliğindeki Name özelliğininin değerinden alınmıştır.

![mk101_5.gif](/assets/images/2004/mk101_5.gif)

Şekil 5. Proxy sınıfımız.

İstemci uygulamamız web servisi ile bu proxy sınıfından örneklenecek nesneler üzerinden konuşabilecektir. Wsdl aracı, bir web servisi için bir proxy sınıfını oluştururken, ilk olarak servisten WSDL dokümanını talep eder. Bu işlem sonucunda istemci bilgisayara indirilen WSDL dokümanındaki XML bilgilerinden yararlanılarak, wsdl aracı uygun sınıf kodlarını otomatik olarak oluşturur. Oluşturulan proxy sınıfına ait kodlar aşağıdaki gibidir.

```csharp
using System.Diagnostics;
using System.Xml.Serialization;
using System;
using System.Web.Services.Protocols;
using System.ComponentModel;
using System.Web.Services;

[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.ComponentModel.DesignerCategoryAttribute("code")]
[System.Web.Services.WebServiceBindingAttribute(Name="Geometrik HesaplamalarSoap", Namespace="http://ilk/servis/")]
public class GeometrikHesaplamalar : System.Web.Services.Protocols.SoapHttpClientProtocol 
{
    public GeometrikHesaplamalar() 
    {
        this.Url = "http://localhost/GeoWebServis/GeoMat.asmx";
    }

    [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://ilk/servis/DaireAlan", RequestNamespace="http://ilk/servis/", ResponseNamespace="http://ilk/servis/", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
    public System.Double DaireAlan(System.Double r) 
    {
        object[] results = this.Invoke("DaireAlan", new object[] {r});
        return ((System.Double)(results[0]));
    }

    public System.IAsyncResult BeginDaireAlan(System.Double r, System.AsyncCallback callback, object asyncState) 
    {
        return this.BeginInvoke("DaireAlan", new object[] {r}, callback, asyncState);
    }

    public System.Double EndDaireAlan(System.IAsyncResult asyncResult) 
    {
        object[] results = this.EndInvoke(asyncResult);
        return ((System.Double)(results[0]));
    }

    [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://ilk/servis/DaireCevre", RequestNamespace="http://ilk/servis/", ResponseNamespace="http://ilk/servis/", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
    public System.Double DaireCevre(System.Double r) 
    {
        object[] results = this.Invoke("DaireCevre", new object[] {r});
        return ((System.Double)(results[0]));
    }

    public System.IAsyncResult BeginDaireCevre(System.Double r, System.AsyncCallback callback, object asyncState) 
    {
        return this.BeginInvoke("DaireCevre", new object[] {r}, callback, asyncState);
    }

    public System.Double EndDaireCevre(System.IAsyncResult asyncResult) 
    {
        object[] results = this.EndInvoke(asyncResult);
        return ((System.Double)(results[0]));
    }   

    [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://ilk/servis/DaireCevreDizi", RequestNamespace="http://ilk/servis/", ResponseNamespace="http://ilk/servis/", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
    public System.Double[] DaireCevreDizi(System.Double[] r) 
    {
        object[] results = this.Invoke("DaireCevreDizi", new object[] {r});
        return ((System.Double[])(results[0]));
    }   

    public System.IAsyncResult BeginDaireCevreDizi(System.Double[] r, System.AsyncCallback callback, object asyncState) 
    {
        return this.BeginInvoke("DaireCevreDizi", new object[] {r}, callback, asyncState);
    }   

    public System.Double[] EndDaireCevreDizi(System.IAsyncResult asyncResult) 
    {
        object[] results = this.EndInvoke(asyncResult);
        return ((System.Double[])(results[0]));
    }
}
```

Gelelim, bu sınıfı herhangi bir uygulamada nasıl kullanacağımıza. Artık elimizde bir proxy sınıfı olduğu için bu sınıftan faydalanarak herhangi bir uygulamadan web servisine ait metotlara erişebilir ve sonuçları değerlendirebiliriz. Bunun için ilk olarak proxy sınıfımıza ait bir dll oluşturalım. Bu sayede proxy sınıfını temsil edecek bir assembly'e sahip olmuş olacağız. Böylece, herhangi bir platformdaki programda bu dll dosyasını kullanarak web servisimiz ile konuşabileceğiz. Bunun için komut satırından aşağıdaki satırı çalıştırmamız yeterli olacaktır.

![mk101_6.gif](/assets/images/2004/mk101_6.gif)

Şekil 6. Proxy sınıfımız için dll'in oluşturulması.

Şimdi bu sınıfı kullanacağımız bir Console uygulaması geliştirebiliriz. Bunun için aşağıdaki kod satırlarını içerecek bir sınıf dosyasını proxy sınıfımıza ait dll ile aynı klasör altında oluşturalım.

```csharp
using System;
using System.Web;
using System.Web.Services;
public class Uygulama
{
    public static void Main(String[] args)
   {
        GeometrikHesaplamalar hesap=new GeometrikHesaplamalar();
        double alan;
        Console.WriteLine("YARICAP ");
        double yariCap=Convert.ToDouble(Console.ReadLine());
        alan=hesap.DaireAlan(yariCap);
        Console.WriteLine("ALAN = {0}",alan);
    }
}
```

Burada dikkat edilecek olursa, proxy sınıfımıza ait bir nesne örneğini oluşturma şeklimiz, Visual Studio .NET ile geliştirdiğimiz önceki istemci uygulamamızdaki ile aynıdır. Bu benzerlik tesadüfi olmamakla birlikte, web servislerini kullanacak tüm .NET uygulamaları için geçerlidir. Kodların yazımı, kullanılan programlama diline göre değişebilir olmasına rağmen teknik olarak yapılan iş, wsdl aracı ile oluşturulan proxy sınıfına ait bir nesne örneğinin oluşturulmasıdır. Örneklendirme işlemini izleyen satırlarda örnek olması açısından, web servisimizdeki DaireAlan metodu çağırılmış ve bu metodun sonucu ekrana yazdırılmıştır. Son aşamada, bu sınıf dosyamızı aşağıdaki şekilde olduğu gibi derlememiz gerekecektir.

![mk101_7.gif](/assets/images/2004/mk101_7.gif)

Şekil 7. Uygulamanın çalışması sonucu.

Bu işlemlerin sonucunda uygulamamızın bulunduğu klasördeki dosyalar aşağıdaki gibi olacaktır.

![mk101_8.gif](/assets/images/2004/mk101_8.gif)

Şekil 8. Dosyalar.

Şimdi uygulamamızı komut satırından çalıştıralım. Ekrandan bir yarıçap değeri girmemiz istenir. Girdiğimiz değer, proxy sınıfından örneklediğimiz nesne aracılığıyla Soap mesajı olarak kodlanarak web servisine iletilir. Web servisi mesajı çözer, parametreyi alır ve ilgili metodu çalıştırır. Sonuç (lar), Soap mesajı olarak kodlanarak, istemciye gönderilir. İstemci uygulamaya ait proxy sınıfınca çözülen mesajdan sonuç (lar) alınır ve konsol ekranına yazdırılır.

![mk101_9.gif](/assets/images/2004/mk101_9.gif)

Son olarak Wsdl aracının kullanımına ilişkin diğer tekniklere bir göz atalım. Proxy sınıfımızın ismini kendimiz belirlemek istersek aşağıdaki örnekte görülen komut satırını kullanırız.

```bash
Wsdl /out:ProxyAdi.cs http://localhost/geowebservis/geomat.asmx
```

Bazı durumlarda, web servisinin bulunduğu sunucuya giriş izni gerekebilir. Bunun için wsdl aracını aşağıdaki gibi, domain adı, kullanıcı adı ve şifre parametreleri ile birlikte kullanırız.

```bash
Wsdl http://localhost/geowebservis/geomat.asmx /domain:BURKI /username:Admin /password:Password
```

Bir web servisinin url bilgisini kullanarak proxy sınıfını oluşturabileceğimiz gibi, fiziki yol bilgisi ile birlikte var olan wsdl belgesini kullanarakta bu sınıfı oluşturabiliriz.

```bash
Wsdl d:\inetpub\wwwroot\geowebservis\geomat.wsdl
```

Bir proxy sınıfına ait kodlar, standart olarak C# dili baz alınarak oluşturulur. Eğer diğer.net dillerinden birisi ile oluşturulmasını istersek aşağıdaki gibi bir komut satırını kullanırız.

```text
Wsdl /language:VB http://localhost/geowebservis/geomat.asmx
```

Bir proxy sınıfını, web servisine ait bir disco dokümanı yardımıyla da oluşturabiliriz. Peki disco adı verilen discovery (keşif) dosyalarının web servisleri-istemci sistemindeki yeri nedir? Bu konuyu da bir sonraki makalemizde incelemeye çalışacağız. Tekrardan görüşünceye dek, hepinize mutlu günler dilerim.