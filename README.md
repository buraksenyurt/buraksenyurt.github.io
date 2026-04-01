# buraksenyurt.github.io

Bu depo, Burak Selim Şenyurt'un kişisel blogunun kaynak kodlarını ve içeriklerini barındırmaktadır. Blog, **Jekyll** tabanlı bir statik site üreticisi *(Static Site Generator)* olarak çalışmakta ve GitHub Pages üzerinden yayınlanmaktadır.

Eğer bu blogu kendi bilgisayarınıza indirip çalıştırmak, arşivleri okumak veya üzerinde denemeler yapmak isterseniz, aşağıdaki adımları izleyebilirsiniz.

## Ön Koşullar (Prerequisites)

Bilgisayarınızda projeyi ve ilgili betikleri ayağa kaldırmadan önce aşağıdaki temel araçların kurulu olması gerekir:

1. **Ruby:** Sitenin çalışmasını sağlayan Jekyll'in altyapısı Ruby'ye dayanır. Nasıl kurulacağını [Ruby resmi sitesinden](https://www.ruby-lang.org/tr/downloads/) inceleyebilirsiniz. Windows için [RubyInstaller](https://rubyinstaller.org/) kullanımı pratiktir.
2. **Bundler:** Ruby için paket yöneticisidir. Terminalinizde şu komutu çalıştırarak kurabilirsiniz: gem install bundler

## Local Ortamda Çalıştırma

Gerekli yardımcı araçları kurduktan sonra aşağıdaki adımları izleyerek siteyi kendi makinenizde ayağa kaldırabilirsiniz:

- **Depoyu Klonlayın:**
  
```bash
git clone https://github.com/buraksenyurt/buraksenyurt.github.io.git
cd buraksenyurt.github.io
```

- **Bağımlılıkları Yükleyin:**
   Kök dizindeki `Gemfile` dosyasında yer alan paketlerin (Jekyll ve GitHub Pages eklentileri vb.) sisteme yüklenmesi için proje dizininde şu komutu çalıştırın:
  
```bash
bundle install
```

Windows üzerinde çalışıyorsanız, zaman dilimi verisi için `tzinfo-data` gem'i de bu kurulumla birlikte alınır. Bu, tarih bazlı permalink'lerin GitHub Pages ile yerel ortamda aynı üretilmesini sağlar.

- **Lokal Sunucuyu Başlatın:** Jekyll'in geliştirme sunucusunu başlatmak için şu komutu çalıştırın:

```bash
bundle exec jekyll serve
```

*(Eğer canlı izleme, anında derleme gibi detaylı kolaylıklar isterseniz `bundle exec jekyll serve --livereload` parametresini de kullanabilirsiniz).*

- **Sitenizi Tarayıcıda Görüntüleyin:**

Tarayıcınızı açın ve **[http://localhost:4000](http://localhost:4000)** adresine gidin. Blog altyapısı karşınızda olacaktır.

## Projenin Yapısı ve Çalışma Prensibi

Proje, hem standart bir Jekyll dizin yapısına sahip olup hem de yılların birikimini organize etmek için ekstra özel betiklerle (script) zenginleştirilmiştir:

- **`_posts/`:** Sitenin kalbidir. Tüm blog yazıları *(2003 yılından günümüze dek)* Markdown (`.md`) formatında burada bulunur. Yeni eklenecek bir yazının dosya adı muhakkak `YYYY-MM-DD-yazi-basligi.md` formatında olmalıdır. Slug kısmında sadece küçük harf, rakam ve `-` kullanılmalıdır; Türkçe karakterler ve boşluklar başlıkta kalabilir ama dosya adında yer almamalıdır.
- **`_layouts/` ve `_includes/`:** Sayfaların dış görünümünü *(iskeletini)* tanımlayan HTML dosyalarıdır. `post.html`, `home.html` gibi kalıplar burada tasarlanır ve verileri harmanlamak için Liquid template dili *(ör: `{% if %}`) kullanılır.*
- **`assets/`:** CSS/SCSS (stil dosyaları) `main.scss` başta olmak üzere görsel assets *(`images/`)* ve sayfa için gereken diğer statik dosyaların olduğu ana klastördür.
- **Taxonomy *(Kategori ve Etiketler)* Sistemi:** Orijinal kurguya ek olarak; blog yazılarının kategori ve etiketleri, `scripts/build_taxonomy.rb` adındaki Ruby betiği üzerinden bir ağaç yapısında derlenerek `_data/inferred_taxonomy.json` dosyasına yazılır. GitHub Actions akışı ([.github/workflows/refresh-taxonomy.yml](.github/workflows/refresh-taxonomy.yml)) her push sonrasında bu ruby kodunu çalıştırır, taxonomy verisini üretir, ardından Jekyll sitesini derleyip GitHub Pages'e yayınlar.
- **`_config.yml`:** Jekyll sitesinin ana konfigürasyon dosyasıdır. URL, site verileri, klasör istisnaları *(excludes)* ve aktif Ruby Gem *(eklenti)* ayarlamaları yer almaktadır.

## Yeni Yazı Ekleme

Yeni bir makale eklemek için, `_posts/` klasörü içerisinde `2026-03-31-ornek-makale-basligi.md` adında bir dosya oluşturmanız yeterlidir. Dosya adındaki slug bölümünü ASCII/lowercase kebab-case olarak tutun. Örneğin `pi-sayisini-hesaplama-yolunda` doğru, `pİ-sayisini-hesaplama-yolunda` veya `Pi Sayisini Hesaplama` yanlış olur. Dosyanın en başında **Front Matter** dediğimiz verilerin olduğu bir **YAML** bloğu bulunmalıdır. Aşağıdaki gibi bir şablon kullanabilirsiniz:

```yaml
---
layout: post
title: "Örnek Makale Başlığı"
date: 2026-03-31 10:00:00 +0300
categories: [Programlama Dilleri]
tags: [csharp, python, ipucu]
---
```

Bu bloğu kapatan `---` çizgisinden sonrasında ise bildiğiniz standart Markdown işaret diliyle makalenizi yazmaya koyulabilirsiniz. Dosyayı kaydettiğinizde `jekyll serve` aracı sayfanızı saniyeler içinde anında HTML formatına çevirecektir. Ayrıca `ruby scripts/build_taxonomy.rb` betiği dosya adını doğrular; standart dışı slug kullanılırsa hata vererek sizi durdurur.
