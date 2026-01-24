# Planning Poker 🃏

Um aplicativo de Planning Poker multiplayer em tempo real, construído com Flutter e Firebase Realtime Database.

## Funcionalidades

- ✅ Criar sessões de Planning Poker com código único
- ✅ Entrar em sessões existentes usando código
- ✅ Cartas de Planning Poker (sequência Fibonacci: 0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ?, ☕)
- ✅ Votação em tempo real com sincronização via Firebase
- ✅ Revelar cartas quando todos votarem
- ✅ Iniciar nova rodada
- ✅ Lista de jogadores com status de voto

## Arquitetura

O projeto segue **Clean Architecture** com **MVVM** e **Command Pattern**:

```
lib/
├── core/                      # Utilitários e constantes
│   ├── constants/
│   ├── di/                    # Injeção de dependências
│   ├── result/                # Result type para tratamento de erros
│   └── utils/
├── data/                      # Camada de dados
│   ├── datasources/           # Firebase data sources
│   └── repositories/          # Implementações dos repositories
├── domain/                    # Regras de negócio
│   ├── entities/              # Entidades (Player, Session, PlayedCard)
│   ├── repositories/          # Interfaces dos repositories
│   └── usecases/              # Casos de uso
└── presentation/              # Camada de apresentação
    ├── commands/              # Command Pattern
    ├── viewmodels/            # ViewModels (MVVM)
    ├── views/                 # Telas
    └── widgets/               # Widgets reutilizáveis
```

## Configuração

### Pré-requisitos

- Flutter SDK 3.9+
- Projeto Firebase configurado
- Firebase Realtime Database habilitado

### Instalação

1. Clone o repositório
2. Configure o Firebase seguindo as instruções em [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
3. Execute:

```bash
flutter pub get
flutter run
```

## Uso

### Criar uma Sessão

1. Abra o app
2. Digite seu nome
3. Selecione "Criar Sessão"
4. Digite o nome da sessão
5. Compartilhe o código gerado com sua equipe

### Entrar em uma Sessão

1. Abra o app
2. Digite seu nome
3. Selecione "Entrar"
4. Digite o código da sessão
5. Comece a votar!

## Tecnologias

- **Flutter** - Framework UI
- **Firebase Realtime Database** - Sincronização em tempo real
- **Provider** - Gerenciamento de estado
- **Clean Architecture** - Separação de responsabilidades
- **MVVM** - Padrão de apresentação
- **Command Pattern** - Encapsulamento de ações

## Licença

MIT
