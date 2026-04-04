---
layout: post
title: "Tek Fotoluk İpucu 123 - LDAP Üzerinden Kullanıcı Doğrulama"
date: 2015-12-10 11:00:00
categories:
  - Genel
tags:
  - ldap
  - active-directory
  - directory-services
  - DirectoryEntry
  - DirectoryServices
  - DirectorySearcher
---
Bu aralar iş yerindeki projeler beni yeni bir şeyler araştırmaya ve öğrenmeye itiyor. Yeni bir şeyler olmasa bile daha önceden kullandığım ama unuttuğum konulara tekrardan bakmama vesile oluyor. Dün buna benzer bir durum gelişti. Bir projemizde kullanıcıların Active Directory üzerinden kod yoluyla doğrulanmasına ve belirli bir gruba dahil olup olmadıklarının öğrenilmesine ihtiyacımız oldu. (Pek tabi bu konuda yazılmış bazı NuGet paketleri bulunuyor ancak iş öğrenmeye gelince biraz kurcalamanın da yararı var elbette) Çok uzun zaman önce (tahminen 2006 yılı idi) eğitim verdiğim bir firmanın bu tip bir ihtiyacı olmuştu. Ama o günden bu yana hiç kullanmadığım için bilgiler de unutulmuştu. Tek hatırladığım System.DirectoryServices assembly'ında yer alan DirectoryEnrty ve DirectorySearcher sınıflarıydı. Biraz araştırma yapınca denemeler için basit bir kod parçası da ortaya çıkıverdi. Aynen aşağıdaki fotoğrafta olduğu gibi.

![tek fotoluk ipucu 123 ldap uzerinden kullanici dogrulama 01](/assets/images/2015/tek-fotoluk-ipucu-123-ldap-uzerinden-kullanici-dogrulama-01.gif)

Kodu gönül rahatlığı ile deneyebilirsiniz. Gerçek bir LDAP ortamında test edilmiştir. Dikkat edilmesi gereken notkalardan biris LDAP adresidir. Kodda yer alan DomainUser sınıfı, kimlik doğrulaması yapılacak kullanıcının adını, şifresini ve dahil olduğu domain bilgisini tutmaktadır. Ayrıca kod içerisinde yer alan ve LDAP'a özgü bazı kısaltmalar da vardır. CN, Common Name anlamına gelmektedir. sAMAccountName ise eski NT 4.0 stilindeki logon adıdır. Domain içerisinde Unique olmalıdır.

DirectoryEntry ve DirectorySearcher sınıfları için System.DirectoryServices.dll Assembly'ının eklenmesi gerektiğini unutmayalım. DirectoryEntry nesnesi var olan kullanıcı bilgileri ile örneklendikten sonra bir arama nesnesi oluşturulur. Bu arama nesnesine arama filtresi ve yüklenmek istenen özellik (CN) bildirildikten sonra FindOne metodunun döndürdüğü sonuca bakılır. Sonuç null değilse belirtilen kriterlere uygun kullanıcı bulunmuş demektir.

Size tavsiyem kullanıcının hangi grupta olduğunu nasıl bulabileceğinize ait kod parçasını geliştirmeye çalışmanızdır. Ayrıca bu ve benzer fonksiyonellikleri servisleştirmeyi de düşünebilirsiniz. Güzel bir antrenman olur. Böylece geldik bir tek fotoluk ipucunun daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
