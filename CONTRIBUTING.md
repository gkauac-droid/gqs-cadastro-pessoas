# Como contribuir

## Preparar um fork

Faca um fork de `gkauac-droid/gqs-cadastro-pessoas` na sua conta. Substitua `SEU-USUARIO` pelo seu usuario do GitHub nos comandos abaixo.

```console
git clone https://github.com/SEU-USUARIO/gqs-cadastro-pessoas.git
cd gqs-cadastro-pessoas
git remote add upstream https://github.com/gkauac-droid/gqs-cadastro-pessoas.git
git fetch upstream
git switch -c docs/readme-contributing upstream/main
```

Escolha um nome de branch que descreva sua contribuicao. O exemplo acima cria uma branch de documentacao a partir da versao atual da `main` do projeto.

## Preparar e conferir a mudanca

Use dados ficticios nos exemplos. Mantenha a interacao com o terminal em `src/main.py`, as operacoes em `src/cadastro.py` e o armazenamento nas classes de repositorio. Siga os nomes usados no projeto e as convencoes da configuracao do Pylint. Deixe os arquivos gerados pelo Python, como `__pycache__/` e `*.pyc`, fora do commit.

Prepare o ambiente conforme o [README](README.md). Para alteracoes de codigo, execute na raiz:

```console
python -m pytest -v
python -m pylint src
python src/main.py
```

O projeto tambem configura hooks de pytest e Pylint. Para ativa-los no seu clone, execute `pre-commit install` com o ambiente virtual ativo. Para uma analise adicional de complexidade com Radon, instale-o com `python -m pip install radon` e execute `radon cc src -s`.

## Publicar e abrir o Pull Request

Confira os arquivos e faca um commit que descreva a alteracao. Para a contribuicao de documentacao deste exemplo:

```console
git status
git diff
git add README.md CONTRIBUTING.md
git diff --cached
git commit -m "docs: explica a execucao do cadastro e o fluxo de contribuicao"
git push -u origin HEAD
```

No GitHub, abra **Compare & pull request**. Selecione a `main` de `gkauac-droid/gqs-cadastro-pessoas` como destino e a branch do seu fork como origem. Descreva o que mudou e como voce conferiu o resultado. O responsavel pelo projeto revisa e integra o PR.

Para registrar a autoria na atividade da disciplina, consulte o historico da `main` atualizada apos o merge:

```console
git log --format="%h | %an <%ae> | %s"
```
