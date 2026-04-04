---
layout: post
title: "Matematik ve Oyun Programlama - Missile Command - Final"
date: 2022-11-29 11:32:00
categories:
  - Programlama Dilleri
tags:
  - rust
  - rust-lang
  - oyun-matematiği
  - oyun-programlama
  - collasion
  - collision-detection
  - clamping
  - vektörler
---
Hiçbir ödül veya karşılık beklemeden kendinizi iyi hissetmek adına en son ne yaptığınızı hatırlıyor musunuz? Bu öyle değişik bir iç motivasyon ki kendinizi bir amaca adayarak hareket etmenizi sağlıyor. Karşılaşılan engeller engel olmaktan çıkıyor ve anlamak istediğiniz şeyler haline geliyor. En azından ben birkaç haftadır böyle hissediyorum. Cevval bir oyun programcısı olmak ya da akademide bu alana dair dersler vermek gibi bir amacım yok ama çok güçlü bir iç motivasyonum var; öğrenmek…

![matematik ve oyun programlama missile command final 01](/assets/images/2022/matematik-ve-oyun-programlama-missile-command-final-01.png)

İşte bu düşüncelerle çıktığım yolda çocukluğumdan hayal mayal hatırladığım popüler Atari oyunlardan birisi olan Missile Command arkasındaki matematiği keşfetmeye çalıştım. Kimi enstrüman (son bölümde de göreceğiniz üzere) son derece basit fonksiyonlardan ibaretti ama çözdüğü problem oyunun akıcılığı adına gerçekten büyüleyiciydi. Üstelik ciddi olarak ele aldığım bu ilk antrenmanda sadece birkaç matematik enstrümanı kullanarak etkileyici dinamikleri nasıl harekete geçirebileceğimi de görme şansım oldu. Pek tabii oyun geliştiricileri adına önem arz eden bir çok konu var. Ben bu alanda ahkam kesebilecek birisi değilim lakin birkaç anahtar noktayı rahatlıkla ifade edebilirim.

- İyi oyun geliştiricilerin iyi seviyede lineer cebir bildiğine inanıyorum.
- Oyun geliştiricisi olmak için kuvvetli bir iç motivasyona sahip olmak gerektiğini düşünüyorum.
- Bir şeyler öğrenirken geçilen her adımın, varılan her sonucun bir sonraki aşamayı kuvvetlendirecek donanımı sağlayacağını biliyorum.

Lafı fazla uzatmadan son bölümün anlatımını buraya bırakayım. Bu bölümde Clamping isimli çarpışma tekniğini kullanarak patlama noktasına temas eden füzelerin sahneden kaldırılmasını inceliyoruz.

[Youtube Link](https://www.youtube.com/watch?v=IsLHKyjYQf8)

Konu ile ilgili örneği Rust programlama dilini kullanarak geliştiriyorum. [Github hesabımdan ilgili kaynak kodlara ulaşabilirsiniz](https://github.com/buraksenyurt/game-dev-with-rust/tree/main/missile-commander). Oyun motoru olarak hafifsiklet olanlardan [Macroquad](https://macroquad.rs/examples/)'ı tercih ettim.

Bir sonraki hedefim Commodore 64 ile çokça oynadığım 1942 oyunu arkasındaki matematiği keşfetmek. Ama iş bununla bitmiyor. Takip ettiğim pek çok kaynak bazı efsane oyunların klonlarını yazmaya çalışmamızı öğütler nitelikte. Karakterinizi farklı yapay zeka dinamikleri ile takip eden hayaletlerin yer aldığı Pacman, zıplama ve yerçekimi gibi etkenleri hesaba kattığınız Super Mario, vektör ve açıları etkin şekilde kullandığınız Missile Command ve benzerleri. Yine de bunlardan hangisi olursa olsun yazmaya başlamadan önce belli başlı matematik konuları çalışmak/hatırlamak gerekiyor. Böylece geldik bir programın daha sonuna. Tekrardan görüşünceye dek hepinize mutlu günler dilerim.
