---
layout: post
title: "Tek Fotoluk İpucu 124 - Pratik Bir Deep Clone Senaryosu"
date: 2015-12-13 17:00:00
categories:
  - Genel
tags:
  - csharp
  - deep-clone
  - deep-copy
  - shallow-copy
  - IClonable
  - generic
  - object-oriented-programming
  - .net-framework
  - clr
---
Nesnelerin çalışma zamanında klonlanması ile ilişkili olarak bahsi geçen iki kavram vardır. Shallow (Yüzeysel) ve Deep (Derinsel diyelim) klonlama. Shallow türüne göre, kopyalanan nesnenin alanları orjinal nesnedeki aynı referans adreslerini işaret edecektir (Yani nesne içerisindeki referans türleri kopyalanacak ama aynı bellek adreslerini gösterecektir) Deep Copy tekniğine göreyse kopyalanan nesne alanları orjinal nesne alanlarının yeni kopyalarını referans etmektdir. Bir başka deyişle Deep Copy tekniğini uyguladığımızda, orjinal nesne içeriği ile aynı veri yapısına sahip yeni bir referans (bellekte farklı bir adreste konuşlandırılmış şekilde) üretmiş oluruz.

.Net içerisinde klonlama işlemi için çoğunlukla ICloneable arayüzünden (Interface) yararlanılmaktadır. Bu Interface aşağıdaki içeriğe sahiptir.

![tek fotoluk ipucu 124 pratik bir deep clone senaryosu 01](/assets/images/2015/tek-fotoluk-ipucu-124-pratik-bir-deep-clone-senaryosu-01.gif)

Görüldüğü gibi çok genel bir fonksiyonellik söz konusu.

Bu bilgilerden sonra şöyle bir ihtiyacımız olduğunu düşünelim; Uygulama Domain'i içerisinde yer alan belirli türdeki varlıklar için Deep Copy işlemini pratik olarak uygulamak istiyoruz (Aşağıdaki gibi çok basit bir domain yapımız olduğunu düşünelim)

```csharp
interface IWebEntity{}

[Serializable]
class Category
:IWebEntity
{
	public int ID { get; set; }
	public string Name { get; set; }
	public override string ToString()
	{
		return string.Format("{0}-{1}",
		ID.ToString(),
		Name
		);
	}
}

[Serializable]
class Product
: IWebEntity
{
	public int ID { get; set; }
	public string Name { get; set; }
	public decimal ListPrice { get; set; }
	public Category Category { get; set; }
	public override string ToString()
	{
		return string.Format("{0},{1},{2}({3})",
		ID.ToString(),
		Name,
		ListPrice.ToString(),
		Category.ToString()
		);
	}
}
```

Her nesnenin varlığını ifade eden özellik değerleri farklılık göstereceğinden, bu konuya dahil olacak tüm tipler için kullanılabilecek ortak bir fonksiyonellik geliştirmek iyi olacaktır. Peki bu fonksiyonu nasıl yazardınız? Aşağıdaki gibi bir çözüm olabilir mi?

![tek fotoluk ipucu 124 pratik bir deep clone senaryosu 02](/assets/images/2015/tek-fotoluk-ipucu-124-pratik-bir-deep-clone-senaryosu-02.gif)

Kodda dikkat edilmesi gereken nokta DeepCopier sınıfının generic olarak tasarlanan GetDeepCopy metodudur. Metodun kullandığı T tipi sadece IWebEntity arayüzünü uygulamış tiplerle kullanılabilir (Generic constraint kullanımına dikkat edelim) Metod içerisinde T tipinden gelen source isimli nesne örneğinin Binary formatta serileştirilmesi, serileşen içeriğinin bir MemoryStream örneğine alınması ve son olarak bu bellek içeriğinin ters serileştirilerek T türünden yeni bir nesne örneğine taşınması söz konusudur. Bu sayede source isimli nesne örneğinin farklı referansta ama aynı veri içeriğine sahip bir kopyası üretilmiş olur.

Örnekteki bağlayıcı nokta Product ve Category tiplerinin binary serileştirilebilir olma zorunluluğudur. Bu yüzden Product ve Category sınıfları Serializable niteliği ile işaretlenmişlerdir. Elbette farklı bir yolda düşünülebilir. Nitekim Binary serileştirme özelliği olmayan nesneler söz konusu olduğunda bu teknik işe yaramayacaktır. Bu durumda reflection'dan yararlanabilir ve source isimli nesne örneğinin tüm seviyelerdeki özelliklerini dolaşarak yeni üretilecek nesne örneğine verebiliriz (Bu çözüm recursive'lik gerektirecek bir senaryodur çünkü tip ağacında ne kadar derine inilmesi gerektiği bilinmeyecektir) Sizin için iyi bir antrenman olabilir.

> ![tek fotoluk ipucu 124 pratik bir deep clone senaryosu 03](/assets/images/2015/tek-fotoluk-ipucu-124-pratik-bir-deep-clone-senaryosu-03.gif)

Bir başka Tek Fotoluk İpucunda görüşünceye dek hepinize mutlu günler dilerim.