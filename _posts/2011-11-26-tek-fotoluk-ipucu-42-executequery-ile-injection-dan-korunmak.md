---
layout: post
title: "Tek Fotoluk İpucu-42(ExecuteQuery ile Injection' dan Korunmak)"
date: 2011-11-26 03:15:00
tags:
  - csharp
  - language-integrated-query
  - execute-query
  - sql
categories:
  - Foto İpucu
---
LINQ to SQL kullandığımız durumlarda bildiğiniz gibi dışarıdan SQL sorgularını da icra ettirebilmekteyiz. Bu amaçla DataContext tipinin ExecuteQuery metodu kullanılmakta. Ancak özellikle SQL Injection saldırılarına karşı dikkatli olmamız gerekiyor. Bu nedenle söz konusu metodun placeholder kullanımına izin veren versiyonunu ele almamızda yarar olduğu kanısındayım. Nasıl mı?

![PhotoTrick42](/assets/images/2011/PhotoTrick42.png)

[ExecuteQueryAndInjection.rar (52,04 kb)](/assets/files/2011/ExecuteQueryAndInjection.rar)

