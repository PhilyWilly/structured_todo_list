# structured_todo_list

Eine strukturierte Todo‑Listen‑Anwendung (Flutter desktop).

Dieses Repository enthält eine kleine Desktop‑App, die Aufgaben in einer
SQLite‑Datenbank verwaltet. Die App bietet eine baumartige Darstellung von
Todos, Unterstützung für Unteraufgaben sowie Import/Export der Datenbank.

## Features

- Baumstrukturierte Todos mit beliebiger Tiefe
- Markieren / Fertigstellen von Todos (Fortschrittsberechnung)
- Erstellen, Bearbeiten und Löschen von Todos
- Import/Export der Datenbank (`data/sqlite/todos.db`) über native Dateiauswahl
- Reaktive UI: Änderungen an der Datenbank lösen ein Neuladen aus

## Voraussetzungen

- Flutter SDK (empfohlen: stabile Version für Desktop)
- Dart
- Auf Desktop (Linux/macOS/Windows): entsprechende Desktop-Tooling von Flutter

## Schnellstart (Entwicklung)

1. Abhängigkeiten holen:

```bash
flutter pub get
```

2. App starten (Beispiel: Linux/Windows/macOS Desktop):

```bash
flutter run -d linux
```

Ersetze `linux` durch `windows` oder `macos` wenn du auf dem entsprechenden
Zielsystem ausführst.

## Datenbank (Import / Export)

- Die Anwendung verwendet `data/sqlite/todos.db` als Standarddatenbank.
- In der App findest du im CommandBar zwei Buttons: **Import** und **Export**.

- Export: Wähle einen Zielordner über den nativen Dateiauswahldialog. Die App
	kopiert dann `data/sqlite/todos.db` als `todos.db` in den gewählten Ordner.

- Import: Wähle eine SQLite‑Datei (`.db` / `.sqlite`) über den nativen
	Dateiauswahldialog. Die Datei ersetzt die interne `data/sqlite/todos.db` und
	die App öffnet die neue Datenbank automatisch.

Hinweis: Import/Export nutzt das `file_picker` Paket; stelle sicher, dass du
`flutter pub get` ausgeführt hast.

## Entwicklungshinweise

- Änderungen an der Datenbank sollten `dbVersion.value++` aufrufen oder die
	mitgelieferten Helper `importDatabaseFromPath` / `exportDatabaseToPath`
	verwenden, damit die UI automatisch neu lädt.
- Die Datenbankdatei wird beim Import ersetzt; sichere ggf. vorher eine Kopie.
- Für große Datenbanken empfiehlt sich, die Dateioperationen außerhalb des UI
	Threads auszuführen (Isolate) oder einen Fortschrittsbalken anzuzeigen.

## Projektstruktur (wichtig)

- `lib/db.dart` — DB‑Zugriff, `dbVersion` notifier, Import/Export‑Helper
- `lib/src/todo.dart` — `Todo` Modell und UI‑Konvertierung (TreeViewItem)
- `lib/pages/home_page.dart` — Hauptseite mit TreeView und Import/Export Buttons
- `data/sqlite/todos.db` — Standarddatenbank (nicht versioniert im Repo)

## Mitwirken

- Forke das Repository, erstelle einen Branch und öffne einen Pull Request.
- Beschreibe Änderungen in English oder German in deinem PR.

## Lizenz

Dieses Projekt ist lizenziert unter der MIT License — siehe die `LICENSE`‑Datei
im Projektstamm.

