# DX UI Creator

MTA:SA icin oyun ici calisan basit bir `dx` arayuz olusturucusudur.

## Kullanim

- Resource'u baslat.
- `F7` veya `/dxui` ile editoru ac.
- Soldan `window`, `button`, `label` ve `rectangle` ekle.
- Canvas uzerinde elemani sec, surukle, koselerinden boyutlandir.
- Sag panelden degerleri duzenle.
- `rectangle` ve `button` icin `radius` vererek SVG rounded gorunum olustur.
- `font`, `align`, `clip`, `wordBreak`, `colorCoded`, `shadow` gibi text ayarlarini kullan.
- `Copy Code` ile uretilen Lua kodunu panoya kopyala.

## Kisayollar

- `Delete`: secili elemani sil
- `Ctrl + D`: secili elemani kopyala
- `Ctrl + C`: export kodunu panoya kopyala
- `Yon tuslari`: elemani hareket ettir
- `Shift + Yon tuslari`: 10 px hareket ettir
- `Mouse Wheel`: inspector alaninda ozellikleri kaydir

## Notlar

- Export ciktisi, `1280x720` tasarim tabanina gore `scaleX/scaleY` ile uretilir.
- Export icinde SVG tabanli `dxDrawRoundedRectangle` helper'i otomatik uretilir.
- Font alaninda `default`, `default-bold`, `clear`, `arial`, `sans`, `pricedown`, `bankgothic`, `diploma`, `beckett` secenekleri kullanilabilir.
- Bu ilk surum; elemanlar client tarafinda bellekte tutulur ve otomatik dosyaya kaydetmez.
