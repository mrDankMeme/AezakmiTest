# 📄 AezakmiTest

Тестовое задание: приложение для работы с **PDF**  
Автор: **Niiaz Khasanov**

---

## 🧭 Что делает приложение 


- **Welcome** экран с кратким описанием и переходом в:
  - **Editor** — создать PDF из фото/файла;
  - **Library** — список сохранённых документов.
- **Генерация PDF**:
  - выбор **нескольких фото** из галереи (PhotoPicker);
  - импорт **одного файла** через системный диалог Files (поддерживаются `.pdf` и изображения; для изображений из файла берётся первое).
  - конвертация в PDF, сохранение в песочницу `Documents/`, открытие в читалке.
- **Читалка (Reader)**:
  - просмотр PDF (`PDFKit`);
  - навигация по страницам;
  - **удаление** выбранной страницы;
  - **поворот** текущей страницы (±90°);
  - **добавление** новой страницы из текста вручную;
  - **надиктовать** текст (диктовка) и добавить как страницу;
  - **собрать новый PDF из выбранных страниц** текущего документа;
  - **поделиться** PDF (ShareSheet).
  - Все изменения сохраняются **в новый файл**; Core Data обновляется.
- **Библиотека (Library)**:
  - список всех документов из Core Data;
  - карточка: **название**, **дата**, **thumbnail**, **кол-во страниц**;
  - контекстное меню: **Поделиться / Удалить / Объединить**;
  - **Объединение документов**: выбираешь второй документ — создаётся **третий** (оригиналы не трогаем).

---

## 🧩 Архитектура и стек

- **Архитектура:** MVVM + Repository + Services, DI через Environment
- **UI:** SwiftUI (+ обёртки на UIKit для пикеров/шэринга)
- **Хранение:** Core Data (метаданные) + файлы в `Documents/`
- **PDF:** PDFKit
- **Реактивность:** Combine
- **Минимальная iOS:** 15.0

### Слои

- **Presentation**
  - Views: `WelcomeView`, `EditorView`, `LibraryView`, `ReaderView`, `DictationView`, `PDFKitView`, `PageSelectionView`, `ShareSheet`, `BusyOverlay`
  - ViewModels: `EditorViewModel`, `LibraryViewModel`, `ReaderViewModel`
- **Domain**
  - Models: `Document`
- **Infrastructure**
  - Protocols: `DocumentRepositoryProtocol`, `PDFServiceProtocol`, `FileStoreProtocol`, `SpeechServiceProtocol`
  - Utils/Services: `PDFService`, `FileStore`, `SpeechRecognizer` (реализация `SpeechServiceProtocol`)
  - Repositories: `DocumentRepositoryImpl`
- **Core/Persistence**
  - `CoreDataStack`, `DocumentEntity`, `DocumentEntity+CoreDataProperties`
- **App**
  - DI/Environment Keys: `DocumentRepositoryKey`, `PDFServiceKey`, `SpeechServiceKey`
  - Composition: `CompositionRoot`
  - Entry point: `AezakmiTestApp`



## 💾 Детали хранения

- Core Data хранит: `id`, `name`, `fileURL` (только имя файла), `createdAt`, `pageCount`, `thumbnail`.
- Файлы лежат в `Documents/`.  

---

## ▶️ Как запустить

1. Открыть проект в **Xcode 15+**.  
2. В **Deployment Target** выставить **iOS 15.0**.  
3. Запустить на симуляторе/устройстве (iOS 15+).

---

## 🧪 Сценарий проверки

1. **Editor** → выбрать несколько фото → **Сконвертировать**.  
2. В **Reader**: пролистать, удалить страницу, повернуть, добавить страницу с текстом → проверить, что файл перезаписан как **новый** и данные в списке обновились.  
3. В **Library**: шэринг/удаление из контекстного меню.  
4. **Объединение**: выбрать документ → «Объединить» → тапнуть по второму → в списке появится **третий** файл.

---

## ✅ Соответствие ТЗ (по текущей версии)

**Обязательные пункты (реализовано):**
- Welcome; Editor; Library; Reader.
- Конвертация фото/файла в PDF; просмотр; удаление листа; шаринг; сохранение.
- Core Data + SwiftUI + MVVM + NavigationView.
- Объединение документов (создаётся третий).

**Отличия/зоны роста:**
- Импорт через Files — **один файл за раз** (если это изображение, используется **первое** изображение).
- В списке библиотека показывает `pdf` как расширение по умолчанию; если потребуется — можно вывести реальный `pathExtension`.

Доп. задание :

✅ Поворот страниц.

✅ Добавление страницы с введённым текстом.

✅ Объединение документов целиком — требование тестового задания выполнено.

✅ Объединение отдельных страниц из одного или нескольких PDF — реализовано (страничный merge).

✅ Голосовой ввод («надиктованный» текст) - реализовано.

Как пользоваться «Собрать из страниц»:

Открой документ в читалке (Reader).

В тулбаре нажми «Собрать из страниц».

На экране выбора появится сетка с миниатюрами страниц. Отметь галочками нужные.

Нажми «Создать PDF» — новый документ появится в Library.


---

AezakmiTest/
├─ App/
│  ├─ AezakmiTestApp.swift
│  ├─ CompositionRoot.swift
│  ├─ EnvironmentKey/
│  │  ├─ DocumentRepositoryKey.swift
│  │  ├─ PDFServiceKey.swift
│  │  └─ SpeechServiceKey.swift
├─ Core/
│  └─ Persistence/
│     ├─ CoreDataStack.swift
│     ├─ DocumentEntity.swift
│     └─ DocumentEntity+CoreDataProperties.swift
├─ Domain/
│  └─ Document/
│     └─ Document.swift
├─ Infrastructure/
│  ├─ Protocols/
│  │  ├─ DocumentRepositoryProtocol.swift
│  │  ├─ PDFServiceProtocol.swift
│  │  ├─ FileStoreProtocol.swift
│  │  └─ SpeechServiceProtocol.swift
│  ├─ Repositories/
│  │  └─ DocumentRepositoryImpl.swift
│  ├─ Utils/
│  │  ├─ PDFService.swift
│  │  ├─ FileStore.swift
│  │  ├─ SpeechRecognizer.swift
│  │  └─ FileImageLoader.swift
├─ Presentation/
│  └─ Scenes/
│     ├─ Welcome/
│     │  └─ WelcomeView.swift
│     ├─ Editor/
│     │  ├─ EditorView.swift
│     │  ├─ EditorViewModel.swift
│     │  ├─ PhotoPicker.swift
│     │  └─ FilePicker.swift
│     ├─ Library/
│     │  ├─ LibraryView.swift
│     │  └─ LibraryViewModel.swift
│     └─ Reader/
│        ├─ ReaderView.swift
│        ├─ ReaderViewModel.swift
│        ├─ ReaderContainer.swift
│        ├─ PDFKitView.swift
│        ├─ DictationView.swift
│        └─ PageSelectionView.swift
│  └─ Common/
│     ├─ BusyOverlay.swift
│     └─ ShareSheet.swift



## 🧾 Автор

**Niiaz Khasanov**  
