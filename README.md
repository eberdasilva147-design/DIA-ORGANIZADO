# 📱 Dia Organizado — Flutter App

Aplicativo mobile de organização pessoal com voz, tarefas, agenda, notas e versículo do dia.

---

## ✅ Funcionalidades

- Tela Home com saudação, versículo, tarefas do dia e próximos compromissos
- Tarefas com prioridade (Alta/Média/Baixa), abas Pendentes/Concluídas, destaque para atrasadas
- Agenda com visualização semanal e mensal
- Notas rápidas com busca em tempo real
- Comando de voz nativo (speech_to_text)
- Versículo do dia + favoritos
- Configurações com modo escuro/claro
- Firebase Auth (e-mail e senha)
- Firebase Firestore (dados na nuvem)
- Notificações locais com som

---

## 🛠️ Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0.0
- Android Studio ou VS Code com extensão Flutter
- Conta no [Firebase Console](https://console.firebase.google.com)
- Node.js (para Firebase CLI)

---

## 🚀 Configuração passo a passo

### 1. Instalar Flutter

Siga o guia oficial: https://docs.flutter.dev/get-started/install/windows

Após instalar, verifique com:
```
flutter doctor
```

### 2. Clonar/abrir o projeto

```
cd "C:\Users\user\Desktop\CURSO DE IA\APP DIA ORGANIZADO\dia_organizado"
```

### 3. Instalar dependências

```
flutter pub get
```

### 4. Configurar Firebase

#### 4.1 Criar projeto no Firebase Console
1. Acesse https://console.firebase.google.com
2. Clique em "Adicionar projeto"
3. Nome: `dia-organizado`
4. Habilite o Google Analytics (opcional)

#### 4.2 Ativar Authentication
- No Firebase Console → Authentication → Começar
- Ativar provedor: **E-mail/senha**

#### 4.3 Criar banco Firestore
- No Firebase Console → Firestore Database → Criar banco de dados
- Escolha modo de teste (pode ajustar regras depois)
- Região: `southamerica-east1`

#### 4.4 Instalar FlutterFire CLI e configurar
```
dart pub global activate flutterfire_cli

# Na raiz do projeto:
flutterfire configure
```
Isso substitui automaticamente o arquivo `lib/firebase_options.dart` com as chaves reais.

#### 4.5 Adicionar google-services.json (Android)
- No Firebase Console → Configurações do projeto → Android
- Adicionar app: `com.seudominio.dia_organizado`
- Baixar `google-services.json`
- Colocar em: `android/app/google-services.json`

#### 4.6 Regras do Firestore
No Firebase Console → Firestore → Regras:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Rodar o app

Conecte um dispositivo Android ou inicie um emulador, então:

```
flutter run
```

Para gerar APK de debug:
```
flutter build apk --debug
```

Para APK de release (Play Store):
```
flutter build apk --release
```

---

## 📂 Estrutura do Projeto

```
lib/
  main.dart                    # Ponto de entrada
  firebase_options.dart        # Config Firebase (gerado pelo flutterfire)
  models/                      # Modelos de dados
    task_model.dart
    appointment_model.dart
    note_model.dart
    verse_model.dart
  providers/                   # Gerenciamento de estado (Provider)
    auth_provider.dart
    task_provider.dart
    appointment_provider.dart
    note_provider.dart
    settings_provider.dart
    verse_provider.dart
  services/                    # Serviços
    firebase_service.dart      # CRUD Firestore + Auth
    notification_service.dart  # Notificações locais
    verse_service.dart         # Versículos embutidos
  screens/                     # Telas
    splash_screen.dart
    main_scaffold.dart         # Scaffold com barra inferior
    auth/
      login_screen.dart
      register_screen.dart
    home/
      home_screen.dart
    tasks/
      tasks_screen.dart
      task_create_modal.dart
    agenda/
      agenda_screen.dart
      appointment_create_modal.dart
    notes/
      notes_screen.dart
    voice/
      voice_screen.dart
    verse/
      verse_screen.dart
    settings/
      settings_screen.dart
  widgets/                     # Widgets reutilizáveis
    task_card.dart
    appointment_card.dart
    priority_badge.dart
    app_modal.dart
  utils/
    app_colors.dart
    app_theme.dart
```

---

## 🎤 Comandos de Voz

| Fale | Ação |
|------|------|
| "Criar tarefa pagar conta amanhã às 9h" | Cria tarefa |
| "Lembrar de ligar para João às 15h" | Cria tarefa com lembrete |
| "Adicionar nota comprar material" | Cria nota |
| "Marcar como concluída pagar conta" | Conclui tarefa pelo nome |

---

## 🎨 Paleta de Cores

| Elemento | Cor |
|----------|-----|
| Fundo | `#060f1c` |
| Cards | `#0d1f3a` |
| Azul principal | `#1a5aa8` |
| Azul destaque | `#4a9fd4` |
| Prioridade Alta | `#e05c5c` |
| Prioridade Média | `#e0a83a` |
| Prioridade Baixa | `#3aad6e` |

---

## 📋 Próximos passos (Versão 2)

- [ ] Notificações locais agendadas por horário da tarefa
- [ ] Integração com Google Calendar
- [ ] Widget na tela inicial do Android
- [ ] Backup/exportação de dados
- [ ] Autenticação com Google
- [ ] Publicar na Play Store / App Store
