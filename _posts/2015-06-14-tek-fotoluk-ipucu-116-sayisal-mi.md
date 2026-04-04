---
layout: post
title: "Tek Fotoluk İpucu 116 - Sayısal mı?"
date: 2015-06-14 15:32:00
categories:
  - Genel
tags:
  - regex
  - extension-methods
  - csharp
---
Oldu ya geliştirdiğiniz projenin bir yerinde, koda düşen metinsel bazı değişkenlerin sayısal olup olmadığını tespit etme ihtiyacı duydunuz. Söz gelimi bir Excel dokümanı içerisinden aldığınız hücre değerlerinin sayısallığını kontrol etmek ve buna göre program akışını yönlendirmek gerekiyor.

Gelen içeriğin sayısal olup olmadığını anlamanın bir kaç yolu olduğu kesin. Pek tabi Regex sınıfının static Match metodu çözüm alternatifleri içerisinde en kuvvetli olanlarından. Bunu bir de Extension metod haline getirsek ve public bir sınıf kütüphanesi (Class Library) içerisine koysak daha şık olmaz mı? Peki ama nasıl? Yoksa aşağıdaki fotoğrafta görüldüğü gibi olabilir mi?

![f5MrrnqzRjzuAAAAAElFTkSuQmCC](/assets/images/2015/tek-fotoluk-ipucu-116-sayisal-mi-01.png)

(Tabii ben sınıf kütüphanesini içerisine koymadım ama biliyorum ki sizin bu tip Extension metodları biriktirdiğiniz ve pek çok projede kullandığınız ortak bir kütüphaneniz vardır. Siz oraya koyuverirsiniz olma mı?)

Bir başka ipucunda görüşmek dileğiyle.