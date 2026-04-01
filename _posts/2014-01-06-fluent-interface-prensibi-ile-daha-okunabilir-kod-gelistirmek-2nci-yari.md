---
layout: post
title: "Fluent Interface Prensibi ile Daha Okunabilir Kod Geliştirmek -2nci Yarı"
date: 2014-01-06 05:37:00 +0300
categories:
  - Programlama Dilleri
tags:
  - fluent-interface
  - generics
  - expression
  - k>
  - reflection
  - fluent-api
  - martin-fowler
  - ruby-lang
  - scala
  - mocking
  - unit-test
  - domain-driven-design
  - domain-specific-language
  - dsl
---
[Bir önceki görsel dersimizde](/2013/12/23/fluent-interface-prensibi-ile-daha-okunabilir-kod-gelistirmek-1nci-yari/) Fluent Interface prensibini nasıl kullanabileceğimizi görmüştük. Bu sefer Generic tip kullanan bir versiyonunu geliştireceğiz. İşin içerisine Generic mimari Reflection kavramı ile Expression<> ve Func gibi tipleri de katacağız. Amacımız sadece belirli bir tip için değil bazı kıstaslara uyan her hangibir T tipi için Fluent Interface prensiplerini uygulatabilmek. Buyrun izleyelim.

[Youtube Link](https://www.youtube.com/watch?v=m63k7UOMweA)