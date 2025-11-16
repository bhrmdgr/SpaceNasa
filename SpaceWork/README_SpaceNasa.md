# SpaceNasa

iOS 13+ için, Launch Library 2 (The Space Devs) verilerini kullanarak uzay programlarını ve fırlatmaları listeleyen, detaylandıran bir UIKit/MVVM uygulaması. Ağ katmanı ayrı bir Swift Package olarak modellenmiştir: **SpaceNasaAPI**.


** XCode 16 da yapıldı. 


## Öne Çıkanlar

- **UIKit + MVVM**: Ekranlar ViewModel’lerle durum tabanlı yönetilir, mapping katmanı ile DTO → ViewData dönüşür.
- **Modüler ağ katmanı**: `SpaceNasaAPI` Swift Package’i içinde hizmetler (Program/Flight), DTO’lar, decoder ve response modelleri ayrı tutulur.
- **Sayfalama ve filtreleme**: Fırlatma listesi yaklaşan/önceki sekmeleriyle, limit/offset sayfalama ile yüklenir.
- **Launch detay zenginliği**: Roket, taşıyıcı, görev, yörünge, fırlatma yeri ve sağlayıcı gibi alanların normalize edilmiş görünümü.
- **Görsel optimizasyonu**: `ImageLoader` ile downsampling ve cache uygulanır.
- **Erişilebilirlik**: Bazı hücre/etiketlerde `accessibilityLabel/accessibilityValue` kullanımı mevcuttur.
- **Yerelleştirme duyarlı tarih**: Listede ve detayda tarih/saat gösterimleri `Locale` ve `TimeZone` bazlı formatlanır.



## Ekranlar

- **Onboarding**: Basit tanıtım ekranı ve grid’e yönlendirme.
- **Home (Program Listesi)**: Uzay programları kartlar halinde gösterilir. Seçim, ilgili programın **Dashboard**’ına yönlendirir.
- **Dashboard (Program Özeti)**: Program görseli, açıklaması, toplam uçuş sayısı ve başarı oranı.
- **Launch List (Fırlatma Listesi)**: Segment ile **Yaklaşan** / **Önceki** filtreleri, sayfalama ile yükleme.
- **Launch Detail**: Ayrıntılı fırlatma bilgileri (durum, tarih, roket, görev, pad, site, sağlayıcı).

---

## Proje Yapısı ve Mimari

SpaceNasa/
│
├ ViewModels/
│  ├ HomeViewModel.swift
│  ├ DashboardViewModel.swift
│  ├ LaunchListViewModel.swift
│  ├ LaunchDetailViewModel.swift
│  └ OnboardingViewModel.swift
│
├ Models/
│  ├ DashBoardModel.swift
│  ├ HomeModel.swift
│  ├ OnboardingModel.swift
│  ├ LaunchList/
│  │    └ Listeleme için gerekli modeller
│  ├ LaunchDetail/
│  │    ├ LaunchDetailModel.swift
│  └    └ LaunchDetailMapper.swift
│
├ Service/
│  └ ImageLoader.swift
│
├ Utils/
│  └ LoadingShowable.swift
│
├ Views/
│  ├ Cell/
│  │    ├ FlightProgramCell.swift / .xib → Program kartı
│  │    ├ LaunchCell.swift → Fırlatma listesi hücresi
│  │    └ OnboardingCell.swift → Açılış sayfası hücresi
│  └ ViewControllers/
│       ├ HomeViewController.swift
│       │    → Program listesi (grid görünümü)
│       ├ DashboardViewController.swift
│       │    → Seçilen programın özeti ve metrikleri
│       ├ LaunchListViewController.swift
│       │    → Fırlatma listesi (yaklaşan / önceki sekmeleri)
│       ├ LaunchDetailViewController.swift
│       │    → Tekil fırlatma detayları (tarih, roket, pad, sağlayıcı)
│       ├ OnboardingViewController.swift
│       │    → Uygulama açılışında kısa tanıtım ekranı


SpaceNasaAPI/ (Swift Package)
├ DTOs/
│   ├ Program.swift
│   └ Flight.swift
│      → Ağ yanıtı veri modelleri
│
├ Service/
│   ├ ProgramService.swift
│   └ FlightService.swift
│      → Alamofire tabanlı API servisleri
│
├ Decoder/
│   └ Decoders.swift → JSON çözümleyici
│
└ Response/
    ├ ProgramResponse.swift
    └ FlightResponse.swift
       → Sayfalama yapısına sahip API cevapları

---

## Ekran Fotoğrafları

<img width="300" alt="Simulator Screenshot - iPhone Air - 2025-11-16 at 20 53 05" src="https://github.com/user-attachments/assets/e8b2267f-58db-46f7-871d-a87345445ea8" />
<img width="300" alt="Simulator Screenshot - iPhone Air - 2025-11-16 at 20 53 09" src="https://github.com/user-attachments/assets/52636c63-a4ca-4233-9344-d5e3b2b88494" />
<img width="300" alt="Simulator Screenshot - iPhone Air - 2025-11-16 at 20 53 20" src="https://github.com/user-attachments/assets/6e5920ee-8389-43ff-ae08-159d5aeb8c4c" />
<img width="300" alt="Simulator Screenshot - iPhone Air - 2025-11-16 at 20 53 33" src="https://github.com/user-attachments/assets/df05df43-fc98-4fc9-aa8f-8ff0f57b5f74" />
<img width="300" alt="Simulator Screenshot - iPhone Air - 2025-11-16 at 20 53 40" src="https://github.com/user-attachments/assets/0e543108-6cb5-4187-81fe-25dc00a1cb7f" />
<img width="300" alt="Simulator Screenshot - iPhone Air - 2025-11-16 at 20 53 45" src="https://github.com/user-attachments/assets/81f108d3-81e8-4522-b34b-736fe9f950ec" />
       
---
## Bağımlılıklar

- **Alamofire** – HTTP istekleri
- **iOS 13+**, **Swift 6.2 (Xcode 16)** hedefleniyor.
- Harici API anahtarı gerekmiyor; Launch Library 2’nin açık uç noktaları kullanılıyor.

---

## Derleme ve Çalıştırma

1. Xcode 16+ kurulu olduğundan emin olun.
2. `SpaceNasa.xcworkspace` açın.
3. Hedef olarak **SpaceNasa** uygulamasını seçin.
4. iOS 13+ simülatör veya cihazda derleyip çalıştırın.

---
## Veri Kaynağı ve Ağ

- **Temel URL**: `https://lldev.thespacedevs.com/2.2.0/`
- **Servisler**:
  - `ProgramService`: Program listesi ve detayları.
  - `FlightService`: Fırlatma listesi (yaklaşan/önceki) ve tekil fırlatma detayları.
- **Sayfalama**: `limit` ve `offset` parametreleriyle.
- **Decoder**: Ortak JSON çözümleyici (`Decoders.swift`).
- **DTO ve Response**: `Program`, `Flight`, `ProgramResults`, `FlightResults`.

---

## Kullanılan API Uç Noktaları

### Alan Adı
`lldev.thespacedevs.com` (Launch Library 2 geliştirici ortamı)

### Programlar
- `https://lldev.thespacedevs.com/2.2.0/program/`
  - Amaç: Program listesi
  - Parametreler: `limit`, `offset`
- `https://lldev.thespacedevs.com/2.2.0/program/{id}/`
  - Amaç: Tekil program detayı

### Fırlatmalar (Launches)
- `https://lldev.thespacedevs.com/2.2.0/launch/upcoming/`
  - Amaç: Yaklaşan fırlatmalar listesi
  - Parametreler: `limit`, `offset`, `ordering=net`
- `https://lldev.thespacedevs.com/2.2.0/launch/previous/`
  - Amaç: Geçmiş fırlatmalar listesi
  - Parametreler: `limit`, `offset`, `ordering=-net`
- `https://lldev.thespacedevs.com/2.2.0/launch/{id}/`
  - Amaç: Tekil fırlatma detayı


