# 📄 Guia de Geração do PDF

Este guia explica como converter a documentação Markdown para PDF.

## Opção 1: Usando Pandoc (Recomendado)

### Instalação do Pandoc

```powershell
# Via Chocolatey
choco install pandoc miktex

# Ou via Scoop
scoop install pandoc
```

### Gerar PDF

```powershell
# Navegue até a pasta docs
cd docs

# Gerar PDF com template básico
pandoc DOCUMENTACAO_COMPLETA.md -o PlanningPoker_Documentacao.pdf --pdf-engine=xelatex --toc --toc-depth=3 -V geometry:margin=2.5cm

# Gerar PDF com metadata (capa bonita)
pandoc metadata.yaml DOCUMENTACAO_COMPLETA.md -o PlanningPoker_Documentacao.pdf --pdf-engine=xelatex --toc --toc-depth=3

# Gerar PDF incluindo imagens dos diagramas
pandoc metadata.yaml DOCUMENTACAO_COMPLETA.md -o PlanningPoker_Documentacao.pdf --pdf-engine=xelatex --toc --toc-depth=3 --resource-path=diagrams/images
```

## Opção 2: Usando VS Code

### Extensões Necessárias
1. **Markdown PDF** (`yzane.markdown-pdf`)
2. **Markdown Preview Enhanced** (`shd101wyy.markdown-preview-enhanced`)

### Passos
1. Abra `DOCUMENTACAO_COMPLETA.md` no VS Code
2. Pressione `Ctrl+Shift+P`
3. Digite "Markdown PDF: Export (pdf)"
4. O PDF será gerado na mesma pasta

## Opção 3: Usando mdpdf (Node.js)

```powershell
# Instalar mdpdf
npm install -g mdpdf

# Gerar PDF
mdpdf DOCUMENTACAO_COMPLETA.md --format=A4
```

## Opção 4: Via GitHub

1. Faça push do arquivo para o GitHub
2. Acesse o arquivo no repositório
3. O GitHub renderiza Markdown automaticamente
4. Use `Ctrl+P` para imprimir como PDF

## Opção 5: Usando Python (md2pdf)

```powershell
# Instalar
pip install md2pdf

# Gerar
md2pdf DOCUMENTACAO_COMPLETA.md PlanningPoker_Documentacao.pdf
```

---

## 📁 Arquivos Gerados

- `DOCUMENTACAO_COMPLETA.md` - Documentação em Markdown
- `metadata.yaml` - Metadados para capa bonita (Pandoc)
- `PlanningPoker_Documentacao.pdf` - PDF gerado (após conversão)

## 📊 Referência de Diagramas

Os diagramas PNG estão em `diagrams/images/`:

| Diagrama | Arquivo |
|----------|---------|
| Arquitetura | `architecture_overview.png` |
| Entidades | `domain_entities.png` |
| Apresentação | `presentation_layer.png` |
| Dados | `data_layer.png` |
| Casos de Uso | `use_cases.png` |
| Criar Sessão | `flow_create_session.png` |
| Jogar Carta | `flow_play_card.png` |
| Sincronização | `flow_realtime_sync.png` |
| Estado Home | `state_home.png` |
| Estado Game | `state_game.png` |
| Injeção DI | `dependency_injection.png` |
| Estrutura | `folder_structure.png` |

## 🔧 Dicas

### Para incluir imagens no PDF (Pandoc)
Certifique-se de que os caminhos das imagens estão corretos. Use caminhos relativos:
```markdown
![Diagrama](diagrams/images/architecture_overview.png)
```

### Para melhor qualidade
Use `--dpi=300` no Pandoc para maior resolução das imagens.

### Para versão impressa
Adicione `-V documentclass=report` para formatação de relatório.
