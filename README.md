# Cadastro de Pessoas

Aplicacao de console em Python desenvolvida na disciplina Gestao da Qualidade de Software. O menu permite cadastrar, consultar por nome, alterar e listar pessoas. A opcao de analise mostra a faixa etaria, avalia o e-mail e informa a condicao de contato.

## Executar

Na raiz do projeto, execute:

```console
python src/main.py
```

Para experimentar, escolha **1**, informe um nome ficticio, a idade e um e-mail. Escolha **2** e digite o mesmo nome para consultar o registro. A opcao **6** encerra a sessao. O repositorio padrao guarda os dados em memoria durante essa execucao.

## Ambiente de desenvolvimento no Windows

No PowerShell, a partir da raiz do projeto:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m pytest -v
```

## Organizacao

| Caminho | Responsabilidade |
| --- | --- |
| `src/main.py` | Menu e interacao pelo terminal |
| `src/cadastro.py` | Operacoes do cadastro |
| `src/pessoa.py` | Dados de uma pessoa |
| `src/repositorio_pessoas.py` | Contrato de armazenamento |
| `src/repositorio_pessoas_memoria.py` | Armazenamento em memoria |
| `tests/` | Testes automatizados de cadastro e busca |

## Laboratorio MySQL

O arquivo `infra/compose.yaml` define dois servicos de MySQL para as praticas de banco de dados. Para inicia-los e consultar o estado dos conteineres, use:

```console
docker compose -f infra/compose.yaml up -d
docker compose -f infra/compose.yaml ps
```

O servico `principal` usa a porta local 3307 e o servico `replica` usa a 3308. A aplicacao de console continua usando o repositorio em memoria quando esses servicos estao ativos.

Para configurar o canal de replicacao e testar a persistencia e a retomada apos uma parada, siga o [laboratorio da Aula 11](infra/LABORATORIO.md).

Para enviar melhorias, consulte o [guia de contribuicao](CONTRIBUTING.md).
