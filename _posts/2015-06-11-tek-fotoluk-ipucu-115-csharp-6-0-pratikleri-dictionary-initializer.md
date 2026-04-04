---
layout: post
title: "Tek Fotoluk İpucu 115 - C# 6.0 Pratikleri (Dictionary Initializer)"
date: 2015-06-11 12:09:00
categories:
  - Genel
tags:
  - csharp
  - generics
  - Dictionary,
  - initializer
  - ilasm
---
Bir [önceki tek fotoluk ipucunda](/2015/06/09/tek-fotoluk-ipucu-114-csharp-6-0-pratikleri-expression-bodied-function-ve-string-interpolation/) belirttiğimiz üzere C# 6.0 ile dile kazandırılan bazı kabiliyetler kodun kolay okunabilir olması açısında önem arz ediyorlar. Örneğin generic bir Dictionary koleksiyonunu örneklemek için aşağıdaki fotoğrafta görülen yeni yazım dizimini kullanabiliyoruz. Daha okunabilir ve anlaşılır olduğu şüphesiz.

![b2vmIxWKsqZVoql6VSocpgKDw1BQUFDGpMR5WF48YaSsHja1Ehmuh6XMYSYwOAwFBQVlTErPHEaFvNXDJOzZZ39FkxjU1Hihw0KBwWEoKCgoY1J66TArZrLQah0U05gJjAryMBQUFBQULbPiMD0UmkwrHRSyVygwKmUOowKHoaCgoIxV6b3DzFjWoaxnZ6XCYVTgMBQUFJTxKRmHkX7IN2HaVBhRLBKV0FjVPTsr1Q6jAoehoKCgjEmJ87DhLzM6DAUFBQVlTAochoKCgoLS1AKHoaCgoKA0tbDDGleix4CCgoKCMp7lS2eddS4KCgoKCkoTy5eOPXYeCgoKCgpKEwschoKCgoLSzHLsvP8fwgC34N+hcPAAAAAASUVORK5CYII=](/assets/images/2015/tek-fotoluk-ipucu-115-csharp-6-0-pratikleri-dictionary-initializer-01.png)

Tabi bu fotoğraftaki kod parçasını uygularken dikkat edilmesi gereken nokta sadece yazım dizimi değil. Hatta Console penceresine çıkacak olan sonuç da değil. Önemli olan bu yeni yazım diziminin IL (IntermediateLanguage) tarafındaki yansıması.

Olur ya üşenmez kodu yazarsınız, bu durumda ILDASM (ki umarım unutmamışsınızdır) aracı ile her iki Dictionary tipinin Main metodu içerisinde nasıl örneklendiğine bir bakın derim. Bakalım bir fark görebilecek misiniz?

Bir başka ipucunda görüşünceye dek hepinize mutlu günler dilerim.
