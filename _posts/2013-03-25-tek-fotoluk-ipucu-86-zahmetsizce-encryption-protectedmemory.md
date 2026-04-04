---
layout: post
title: "Tek Fotoluk İpucu 86–Zahmetsizce Encryption (ProtectedMemory)"
date: 2013-03-25 20:50:00
tags:
  - tek-fotoluk-ipucu
  - cryptography
  - data-protection
  - dpapi
  - windows-protection
  - current-user
  - local-machine
  - security
  - encryption
  - decryption
  - şifreleme
  - çözümleme
  - memory-protection
categories:
  - Foto İpucu
---
[Bir önceki tek fotoluk ipucunda ProtectedData sınıfından yararlanmış](/2013/03/25/tek-fotoluk-ipucu-85-zahmetsizce-encryption-protecteddata/) ve basitçe bir byte dizisinin nasıl şifrelenebileceğini/çözümlenebileceğini görmüştük. Hatırlarsanız veriyi Current User ve Local Machine seviylerinde ele alabiliyorduk. DPAPI’ nin kullanıldığı veri odaklı bu tekniğin yanında, bellek üzerinde yer alan bir içeriğin Process bazında şifrelenmesi/çözümlenmesi de mümkündür. Aynı Process (SameProcess), farklı Process (CrossProcess) veya aynı giriş (SameLogon) bilgisi için…Üstelik son derece de kolay bir şekilde. Nasıl mı?

![tfi_86](/assets/images/2013/tfi_86.png)

Bir başka ipucunda görüşmek dileğiyle

