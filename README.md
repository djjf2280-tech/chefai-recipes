# 🍳 ChefAI — Инструкция по сборке APK

## ⚡ Быстрый старт (5 шагов)

### 1. Установи Flutter SDK
```bash
# Скачай Flutter с официального сайта:
# https://docs.flutter.dev/get-started/install/windows/mobile

# Или через командную строку (Linux/macOS):
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Проверь установку
```bash
flutter doctor
# Всё должно быть зелёным для Android
```

### 3. Скопируй проект
```bash
# Скачай папку recipe_ai_app на свой компьютер
cd recipe_ai_app
```

### 4. Установи зависимости
```bash
flutter pub get
```

### 5. Собери APK
```bash
# Отладочная версия (для тестирования)
flutter build apk --debug

# Релизная версия (для установки)
flutter build apk --release --no-shrink

# APK будет здесь:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Альтернатива: Онлайн-сборка без установки Flutter

### Вариант A: GitHub Actions (БЕСПЛАТНО)
1. Зарегистрируйся на [github.com](https://github.com)
2. Создай новый репозиторий
3. Загрузи всю папку `recipe_ai_app`
4. Создай файл `.github/workflows/build.yml`:

```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

5. APK автоматически скачается из раздела "Actions" → "Artifacts"

### Вариант B: Codemagic (онлайн CI/CD)
1. Зайди на [codemagic.io](https://codemagic.io)
2. Подключи репозиторий
3. Выбери Flutter → Build APK
4. Скачай готовый APK

---

## 📱 Установка APK на телефон

1. Включи **«Установку из неизвестных источников»** в настройках Android:
   - Настройки → Безопасность → Неизвестные источники ✅
   - (или Настройки → Приложения → Специальный доступ → Установка неизвестных приложений)

2. Перенеси APK на телефон (USB / Telegram себе / Google Drive)

3. Открой файл менеджер → найди APK → нажми «Установить»

---

## 🛠️ Требования для сборки

| Компонент | Минимум |
|-----------|---------|
| Flutter | 3.19+ |
| Dart SDK | 3.0+ |
| Android SDK | API 21+ (Android 5.0) |
| Java | JDK 17 |
| RAM | 8 GB рекомендуется |
| Диск | 5 GB свободно |

---

## ❓ Частые проблемы

**`flutter doctor` показывает ошибки:**
```bash
flutter doctor --android-licenses  # Принять лицензии Android
```

**Ошибка Gradle:**
```bash
cd android && ./gradlew clean
cd .. && flutter clean && flutter pub get
flutter build apk --release
```

**Нет Android SDK:**
- Установи [Android Studio](https://developer.android.com/studio)
- Или только [Command Line Tools](https://developer.android.com/studio#command-tools)

---

## 🎨 Возможности приложения

- ✅ 15 рецептов (завтрак, обед, ужин, супы, десерты, напитки)
- ✅ Поиск по названию, ингредиентам, тегам
- ✅ Фильтрация по категориям
- ✅ Избранные рецепты (сохраняются)
- ✅ Пересчёт порций
- ✅ ИИ-чат ШефАИ (полностью офлайн!)
- ✅ Быстрые подсказки в чате
- ✅ Красивые анимации
- ✅ Material Design 3
