# Verificação da replicação MySQL

Com Docker Desktop em modo Linux e as portas locais 3307 e 3308 livres, execute na raiz do repositório:

```powershell
.\infra\laboratorio.ps1
```

O script usa o Compose da disciplina e cria um projeto com nome exclusivo para manter os volumes do exercício separados de cadastros existentes. Cada execução cria dois volumes. A primeira execução pode demorar para baixar a imagem MySQL. O usuário de replicação recebe uma senha aleatória exclusiva do laboratório.

Registre a saída de `compose ps`, as linhas `Replica_IO_Running: Yes` e `Replica_SQL_Running: Yes` e a consulta final. O roteiro verifica a inserção de Ana, a atualização de 30 para 31 anos, a preservação do registro após recriar o principal e a chegada de Bruno depois de reiniciar a réplica. Uma divergência encerra o roteiro com erro.

Ao final, os serviços ficam parados e os volumes preservados. Para rever os registros, entre na pasta `infra`, use o nome de projeto impresso no início e execute:

```powershell
docker compose -p NOME_DO_PROJETO start
docker compose -p NOME_DO_PROJETO ps
docker compose -p NOME_DO_PROJETO exec replica mysql -uroot -p
```

No console SQL, use `SHOW REPLICA STATUS\G` e `SELECT * FROM cadastro.pessoa ORDER BY id;`. A senha administrativa local está no Compose do laboratório. Saia com `exit` e pare os serviços com `docker compose -p NOME_DO_PROJETO stop`.

Os dois serviços rodam no mesmo computador. A replicação é assíncrona e o laboratório usa a réplica para leitura. O programa Python continua usando o repositório em memória conforme o escopo das Aulas 10 e 11.
