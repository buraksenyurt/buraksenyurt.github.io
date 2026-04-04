---
layout: post
title: "Tek Fotoluk İpucu–74–SequenceEqual<T>"
date: 2012-12-10 20:40:00
tags:
  - language-integrated-query
  - generics
  - sequenceequal
  - csharp
  - extension-methods
  - iequalitycomparer
  - comparer
categories:
  - Foto İpucu
---
Diyelim ki uygulamanızda zaman zaman da olsa farklı referanslar da duran ve aynı tipte elemanlardan oluşan koleksiyonlarınız oluşuyor ve bunları yeri geldiğinde birbirleri ile kıyaslamak istiyorsunuz. Ne yaparsınız?

Mantıksal olarak her iki koleksiyonu dolaşacak ortak bir döngü ile bire bir kıyaslama yolunu tercih edersiniz

Ama daha pratik yollar da var. Örneğin aşağıdaki gibi

![tfi_74](/assets/images/2012/tfi_74.png)

Bu kadar basit. Bir başka ip ucunda görüşmek dileğiyle.

Not: SequenceEqual metodu kaynak ve hedef koleksiyonların sıralı olduğunu varsayar. Yani yukarıdaki örnekte koleksiyonların içeriklerini farklı sırada tutarsak sonuç False dönecektir.