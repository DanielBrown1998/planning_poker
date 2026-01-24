# Configuração do Firebase para Planning Poker

## Passo a Passo

### 1. Criar Projeto no Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Dê um nome ao projeto (ex: "planning-poker")
4. Siga as instruções para criar o projeto

### 2. Configurar Realtime Database
1. No console do Firebase, vá em "Build" > "Realtime Database"
2. Clique em "Create Database"
3. Escolha a região mais próxima
4. Inicie em "modo de teste" para desenvolvimento

### 3. Regras do Realtime Database
Configure as regras do seu banco de dados (Database > Rules):

```json
{
  "rules": {
    "sessions": {
      "$sessionId": {
        ".read": true,
        ".write": true
      }
    },
    "sessionKeys": {
      ".read": true,
      ".write": true
    }
  }
}
```

**Nota:** Para produção, você deve implementar regras mais restritivas.

### 4. Instalar Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 5. Configurar Flutter com Firebase
Execute no terminal do projeto:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=SEU_PROJETO_ID
```

Isso criará automaticamente os arquivos de configuração para cada plataforma.

### 6. Arquivo firebase_options.dart
O comando `flutterfire configure` criará o arquivo `lib/firebase_options.dart`.
Após isso, atualize o `main.dart` para usar as opções:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ...
}
```

## Estrutura do Banco de Dados

```
planning-poker-db
├── sessions
│   └── {sessionId}
│       ├── id: string
│       ├── sessionKey: string
│       ├── hostId: string
│       ├── name: string
│       ├── state: "waiting" | "voting" | "revealed"
│       ├── createdAt: string (ISO 8601)
│       ├── players
│       │   └── {playerId}
│       │       ├── id: string
│       │       ├── name: string
│       │       └── isHost: boolean
│       └── playedCards
│           └── {playerId}
│               ├── playerId: string
│               ├── playerName: string
│               ├── cardValue: string | null
│               └── playedAt: string (ISO 8601)
└── sessionKeys
    └── {sessionKey}: sessionId
```

## Troubleshooting

### Erro de conexão
- Verifique se o Firebase está inicializado corretamente
- Confira as regras do Realtime Database
- Verifique a conectividade com a internet

### Dados não sincronizando
- Verifique se os Streams estão ativos
- Confira se o sessionId está correto
- Verifique os logs do Firebase
