---
layout: post
title: "JWT(JSON Web Token) Kullanımı"
date: 2017-12-08 06:00:00
tags:
  - jwt
  - json
  - security
  - bearer-authentication
  - authentication
  - .net-core
  - http-get
  - http-post
  - bearer
  - rest-api
  - web-api
  - asp.net-web-api
categories:
  - Framework Tabanlı Programlama
---
Daha önce söylemiş miydim bilemiyorum ama servis odaklı yaklaşımlarda güvenlik hep korktuğum ve anlamakta güçlük çektiğim konuların başında gelir. Özellikle WCF tarafındaki güvenlik senaryolarının çeşitliliği ve zenginliği bazen kafa karıştırıcı boyutlarda olabiliyor. Bu aralar şirketteki REST tabanlı servislerin JSON Web Token ile kullanılmalarına dair bir vaka çalışması söz konusu. Bu durum REST modelinde çalışan WCF servisleri için önemli.

![jwt json web token kullanimi 01](/assets/images/2017/jwt-json-web-token-kullanimi-01.png)

Evdeki West-World'de ise aynı mevzu Asp.Net Core 2.0 Web API servisleri için gündeme geldi (Birkaç gün önce) Aslında o tarafta nasıl kullanıldığını merak etmek benim işim diyebilirim. Öğrenmekten keyif alacağım bir başka konu diyerekten geç vakitte çalışma odama geçtim. Beyin hücrelerine zarar verdiği söylenen sarı gece lambamı açtım. Spotify'da kısık tonda çalacak şekilde ayarladığım piyano tınıları ağırlıklı konsantrasyon albümünü başlattım. Sıcak kahvemden bir yudum aldım ve tarayıcıda aramalara başladım. İlk olarak JSON Web Token ne demektir bulduğum kaynaklardan anlamaya çalıştım. Sonrasında aşağıdakine benzer bir şeyler karalamayı da başardım.

![core_jwt_1.jpg](/assets/images/2017/core_jwt_1.jpg)

Senaryo üzerinden gidildiğinde olay biraz daha basitleşmişti. REST tabanlı servisteki bir veya daha fazla operasyonu kullanmak isteyen bir kullanıcı olduğunu düşünelim. Kullanıcı hizmeti almadan önce username ve password bilgilerini de kullanarak doğrulanmakta (Authentication safhası diyelim) Doğrulama başlı başına büyük bir iş de olabilir. Microsoft Identity Server'dan tutun da Facebook doğrulamasına kadar farklı bir katman söz konusu esasında. Benim senaryomda bu kısım hep true olarak geçilecek ama bir gerçek hayat vakasında şirketin kimlik doğrulama sunucusundan veya Azure AD'den yararlanılabilir. Doğrulama işlemi başarılı olursa servis tarafında bir Token (bilet mi desek) üretilir. Bu Token konumuz gereği JSON Web Token tipinden olabilir.

## Kısaca JSON Web Token

JSON Web Token için ayrı bir parantez açmamız şart tabii. Yapısı 3 parçadan oluşan base64 formatında kodlanmış bir biletten bahsediyoruz. Sırasıyla Header, Payload ve Signature kısımlarından oluşmakta. Header kısmında biletin tipi ve şifreleme algoritmasına ait bilgiler yer alır. Payload içerisinde ise Claim olarak isimlendirdiğimiz diğer başka bilgilere bulunur. EMail, UniqueID, Certificate, Username vb veri içeren bir çok Claim aynı Token içerisinde yer alabilir.

Aslında JWT'nin kabul görmüş standartlarında yer alan Claim tiplerini koyabiliriz. Bu Claim'ler standartlara göre rezerve edilmiş tiplerden ya da Public, Private türünden oluşabilirler. Signature adı verilen son parça ise header, payload, şifreleme için kullanılacak gizli ifade ve şifreleme algoritmasının katkılarıyla üretilir. Var olan simetrik şifreleme algoritmalarından birisini tercih edebiliriz. base64 formatında oluşan bu üç parça aralarında noktalar içerek şekilde oluşur. Aslında örnek uygulama tamamlandığında nasıl bir şey olduğunu göreceğiz.

Token üretimi, doğrulanan kullanıcının bir sonraki talebi için önemlidir. Örneğin HTTP Get ile geleceği bir operasyon için Authorization Header bilgisi olarak {Bearer token} şeklinde kullanılması gerekiyor. Bir başka deyişle doğrulanan kullanıcı için sonraki operasyonlarında kullanacağı biletin, bilet için biçilen yaşam süresi sonlanana kadar istemciden servis tarafına gönderilmesi gerekmekte. Kabaca senaryo bu şekilde çalışmakta. Süre dolduktan sonra kullanıcı aynı bilet ile içeriye giremez ve HTTP 401 hatası alır. Bu nedenle yeni bir bilet alması gerekir.

Aslında Bearer olarak isimlendirilen Token Based Authentication ve Authorization modelindeki güvenlik senaryoloarı sıklıkla kullanılmaktadır. OAuth 2.0 içerisinde de benzer bir teoriyi görebilirsiniz. Peki.Net Core 2.0 ile geliştirdiğimiz bir Web API'de, JSON Web Token tipinden biletleri nasıl kullandırabiliriz? Haydi gelin işe başlayalım.

## Kod Tarafı

Öncelikle basit bir Web API uygulaması oluşturarak işe başlamamız gerekiyor. Örneği West-World'de geliştirdiğimizi hatırlatalım. Ubuntu 16.04 üzerinde.Net Core 2.0 kullanıyoruz.

```bash
dotnet new webapi -o HelloJWT
```

## Authentication Middleware Ayarlamaları

Şimdi Startup dosyasının içeriğini aşağıdaki gibi geliştirelim.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace HelloJWT
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc();
            
            services.AddAuthentication(options=>{
                options.DefaultAuthenticateScheme=JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme=JwtBearerDefaults.AuthenticationScheme;
                }
            )
            .AddJwtBearer(options=>{
                options.TokenValidationParameters=new TokenValidationParameters{
                    ValidateAudience=true,                    
                    ValidAudience="heimdall.fabrikam.com",
                    ValidateIssuer=true,
                    ValidIssuer="west-world.fabrikam.com",
                    ValidateLifetime=true,
                    ValidateIssuerSigningKey=true,                    
                    IssuerSigningKey=new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes("uzun ince bir yoldayım şarkısını buradan tüm sevdiklerime hediye etmek istiyorum mümkün müdür acaba?"))
                };

                options.Events=new JwtBearerEvents{
                    OnTokenValidated=ctx=>{
                        //Gerekirse burada gelen token içerisindeki çeşitli bilgilere göre doğrulam yapılabilir.
                        return Task.CompletedTask;
                    },
                    OnAuthenticationFailed=ctx=>{
                        Console.WriteLine("Exception:{0}",ctx.Exception.Message);
                        return Task.CompletedTask;
                    }                  
                };
            });     
        }
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseAuthentication();

            app.UseMvc();
        }
    }
}
```

ConfigureServices içeriği oldukça önemli. İlk olarak doğrulama şemalarının eklendiğini görüyoruz. AddAuthentication metodunun ilk parametresinde bu tanımlamalar yapılmakta. AddJwtBearer metodundaki options parametresinin bir kaç özelliği belirlenmekte. Token için Auidence, Issuer ve SymmetricKey gibi bilgiler söz konusu. Diğer yandan bir Token doğrulandığında veya çalışma zamanı istisnası oluştuğunda devreye giren iki olay metodumuz da var. Örneğin eskimiş bir Token ile gelindiğinde OnAuthenticationFailed metodu devreye girecektir. ConfigureServices içerisinde tanımlanan bu doğrulama tekniğinin devreye alınabilmesi için Configure fonksiyonunda app.UseAuthentication çağrısının yapılması gerekiyor.

## Controller Tipleri

Controller klasörüne iki sınıf ekleyeceğiz. Birisi Token üretimi işini üstlenecek. Bunu herkese açacağımız bir servis olarak düşünebiliriz. Bu nedenle AllowAnonymous niteliği ile imzalanabilir. Ana görevi gelen kullanıcı için bir token bilgisi üretip geri vermek. Diğer Controller tipimiz ise örnek bir operasyonu geçerli bir token için gerçekleştirmek üzere kullanılacak. Önce TokenController sınıfımızı yazalım.

```csharp
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace HelloJWT
{
    [Route("token")]
    [AllowAnonymous()]
    public class TokenController
        :Controller
        {
            [HttpPost("new")]
            public IActionResult GetToken([FromBody]UserInfo user)
            {
                Console.WriteLine("User name:{0}",user.Username);
                Console.WriteLine("Password:{0}",user.Password);

                if(IsValidUserAndPassword(user.Username,user.Password))
                    return new ObjectResult(GenerateToken(user.Username));
                    
                return Unauthorized();
            }

        private string GenerateToken(string userName)
        {
            var someClaims=new Claim[]{
                new Claim(JwtRegisteredClaimNames.UniqueName,userName),
                new Claim(JwtRegisteredClaimNames.Email,"heimdall@mail.com"),
                new Claim(JwtRegisteredClaimNames.NameId,Guid.NewGuid().ToString())
            };

            SecurityKey securityKey=new SymmetricSecurityKey(Encoding.UTF8.GetBytes("uzun ince bir yoldayım şarkısını buradan tüm sevdiklerime hediye etmek istiyorum mümkün müdür acaba?"));
            var token=new JwtSecurityToken(
                issuer:"west-world.fabrikam.com",
                audience:"heimdall.fabrikam.com",
                claims:someClaims,
                expires:DateTime.Now.AddMinutes(3),
                signingCredentials:new SigningCredentials(securityKey,SecurityAlgorithms.HmacSha256)
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private bool IsValidUserAndPassword(string userName, string password)
        {
            //Sürekli true dönüyor. Normalde bir Identity mekanizması ile entegre etmemiz lazım.
            return true;
        }
    }
}
```

Senaryomuzda harici bir Identity enstrümanı kullanmadığımız için IsValidUserAndPassword fonksiyonu daima true dönmekte. GenerateToken fonksiyonu bir kullanıcı için gerekli JSON Token içeriğini üretmekle görevli. PayLoad içerisine alınacak Claim bilgisi için someClaims değişkeninden yaralanılmakta. İçerisinde UniqueName, Email ve NameId gibi önceden tanımlı bilgiler bulunuyor.

Token'ın Signature içeriğinde kullanılmak üzere bir SecuritKey değişkeni kullanıyoruz. JwtSecurityToken nesnesini örneklerken de bazı bilgilere veriyoruz. Hatırlarsanız Authentication Middleware'ini ayarlarken Issuer, Audience, ExpireTime gibi bilgilerin gerekliliğinden bahsettik. Bu bilgileri yapıcı metoda parametre olarak girmekteyiz. issuer, audience, claims, expires, ve signingCredentials.

Şifreleme algoritması olarak genellikle Sha256 kullanılmakta. Bende geleneği bozmadım. Bu arada IActionResult döndüren GetToken operasyonu, istemcinin Body ile gönderdiği UserInfo bilgisini doğrulamak için kullanmakta (Body'den geleceğini belirtmek için [FromBody] niteliğini kullandık) UserInfo sınıfında Username ve Password özellikleri yer alıyor. Oluşturulan Token'ın dönüş içeriğine yazılması içinse WriteToken metodu çağırılmakta.

UserInfo yardımcı sınıfımıza ait kodlar;

```csharp
namespace HelloJWT
{
    public class UserInfo
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }
}
```

Son olarak PromotionController sınıfını yazarak işlemlerimize devam edelim.

```csharp
using System;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HelloJWT
{
    [Authorize()]
    [Route("promotion")]
    public class PromotionController
        :Controller
    {
        [HttpGet("new")]
        public IActionResult Get() {
            foreach(var claim in HttpContext.User.Claims)
            {
                Console.WriteLine("Claim Type: {0}:\nClaim Value:{1}\n",claim.Type,claim.Value);
            }
            var promotionCode=Guid.NewGuid();
            return new ObjectResult($"Your promotion code is {promotionCode}");
        }
    }
}
```

Get isimli operasyon içerisinde o anki kullanıcıya ait Claim bilgilerinin ekrana bastırılması söz konusu. Bunu tamamen sunucu tarafındaki servise gelen token içeriğini izlemek amacıyla ekledik. Dönüş olarak istemciye şanslı promosyon kodunu göndermekteyiz. Bu promosyon kodu ile istediği marketten 50 liralık bedava alışveriş yapabilecek:P

Aslına bakarsanız kodlarımız hazır. Şimdi test sürüşüne çıkabiliriz. Ne varki saat epeyce ilerlemiş durumda. Testlere ertesi gün Gondor'da devam etmek zorundayım (Gondor şirketteki Ubuntu)

![core_jwt_8.gif](/assets/images/2017/core_jwt_8.gif)

## Testler

Testleri yapmak için bir istemci uygulama yazabileceğimiz gibi Chrome'da Postman veya Firefox'ta HttpRequester gibi araçları da kullanabiliriz. Ben Firefox'a kurduğum HttpRequester'dan yaralanacağım. İlk olarak geçerli kullanıcı adı ve şifre ile bir bilet almamız gerekiyor. Bunu alırken body kısmında JSON formatında username ve password bilgisinin gönderilmesi önemli. HTTP POST tipinden bir talep gerçekleştireceğiz.

adres: [http://localhost:5000/token/new](http://localhost:5000/token/new)

method: HTTP POST

content type: application/json

content:

```json
{
   "username":"Heimdall",
   "password":"P@ssw0rd"
}
```

![core_jwt_2.gif](/assets/images/2017/core_jwt_2.gif)

Artık elimizde bir token bilgisi var. Bu token bilgisini kullanarak promosyon kodu için talepte bulunabiliriz. Burada da önemli olan Authorization isimli Header bilgisine Bearer {tokenbilgisi} şeklinde değer vermemiz. Geçerli ve henüz ölmemiş bir bilet vermemiz gerekiyor.

adres: [http://localhost:5000/promotion/new](http://localhost:5000/promotion/new)

method: HTTP Get

header için key: Authorization

header için value: Bearer {token içeriği}

İşte çalışma zamanı.

![core_jwt_3.gif](/assets/images/2017/core_jwt_3.gif)

Console'a gönderdiğimiz bilgilerin bir kısmına ait görüntüde aşağıdaki gibi.

![core_jwt_4.gif](/assets/images/2017/core_jwt_4.gif)

Şimdi verdiğimiz zaman aşımı süresinin dolması sonrasında neler olacağına bakalım. Bu durumda token ömrü sonlandığı için hata almamız gerekiyor. Token bilgisinin geçersiz olması kullanıcıya 401 Unauthorized hatasını döndürür.

![core_jwt_5.gif](/assets/images/2017/core_jwt_5.gif)

Halen daha kafamda soru işaretleri bulunmakta. Bunlardan birisi sizin de yapacağınız denelemelerde fark edeceğiniz üzere 3 dakikadan daha uzun sürede 401 almış olmamız. Ben denemelerimde bu süreyi tutturmayı bir türlü başaramadım. Yaptığım araştırmalarda Token doğrulaması için delegate edilen fonksiyonelliği ezebileceğimiz, AddJwtBearer metodundaki seçeneklerde ClockSkew özelliği için TimeSpan.Zero gibi değerler kullanabileceğimize dair ipuçları vardı. Belki de sorun Gondor'dadır. West-World üzerinden henüz kodları test edemedim ama şimdilik tek sorun geç dolan Token Timeout süresi gibi.

Esas itibariyle JSON Web Token, OAuth 2.0 alt yapısında kullanılan bir erişim standardı (AccessToken) Bu anlamda Bearer adı verilen Token türevinden de farklılaşıyor. JWT için Internet Engineering Task Force'un [şu adresteki](https://tools.ietf.org/html/rfc7519) tanımlamalarına bakmakta fayda var. Bearer token tanımlamaları da [bu adresten](https://tools.ietf.org/html/rfc6750) incelenebilir. Aralarında belirgin farklılıklar olduğu kesin. Doğruyu söylemek gerekirse araştırmaya devam ediyorum. Böylece geldik bir makalemizin daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
