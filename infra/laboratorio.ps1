# Executar no PowerShell com o Docker Desktop em modo Linux.
$ErrorActionPreference = 'Stop'
$compose = Join-Path $PSScriptRoot 'compose.yaml'
$projeto = 'gqs-aula11-' + [guid]::NewGuid().ToString('N').Substring(0, 10)

function Compose {
    & docker compose -p $projeto -f $compose @args
    if ($LASTEXITCODE -ne 0) { throw "Falha no Docker Compose: $($args -join ' ')" }
}

function Sql($servico, $consulta) {
    $resultado = $consulta | docker compose -p $projeto -f $compose exec -T $servico sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot --batch --skip-column-names'
    if ($LASTEXITCODE -ne 0) { throw "Falha na consulta ao serviço $servico." }
    return $resultado
}

function Conferir($servico, $consulta, $esperado) {
    for ($i = 0; $i -lt 60; $i++) {
        $valor = Sql $servico $consulta
        if ("$valor" -eq "$esperado") { return }
        Start-Sleep -Seconds 1
    }
    throw "Resultado inesperado em ${servico}: esperado '$esperado', obtido '$valor'."
}

function ConferirCanal {
    $status = Sql replica 'SHOW REPLICA STATUS\G'
    foreach ($campo in 'Replica_IO_Running', 'Replica_SQL_Running') {
        if (-not ($status -match "^\s*${campo}: Yes\s*$")) {
            throw "Canal de replicação: $campo não está ativo."
        }
    }
    Write-Host 'Replica_IO_Running: Yes; Replica_SQL_Running: Yes'
}

Write-Host "Projeto isolado: $projeto"
Write-Host "Para retomar este projeto, na pasta infra: docker compose -p $projeto start"
$senhaRepl = [guid]::NewGuid().ToString('N')
$idadeAna = "SELECT idade FROM cadastro.pessoa WHERE email='ana.teste@example.invalid';"
$idadeBruno = "SELECT idade FROM cadastro.pessoa WHERE email='bruno.teste@example.invalid';"

try {
    Compose config --quiet
    Compose up -d --wait --wait-timeout 180
    Compose ps
    Sql principal "CREATE USER 'repl'@'%' IDENTIFIED BY '$senhaRepl'; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';"
    Sql replica @"
CHANGE REPLICATION SOURCE TO SOURCE_HOST='principal', SOURCE_PORT=3306,
SOURCE_USER='repl', SOURCE_PASSWORD='$senhaRepl', SOURCE_AUTO_POSITION=1, GET_SOURCE_PUBLIC_KEY=1;
START REPLICA;
SET PERSIST read_only=ON;
SET PERSIST super_read_only=ON;
"@
    Sql principal @"
CREATE DATABASE cadastro CHARACTER SET utf8mb4;
CREATE TABLE cadastro.pessoa (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  idade INT NOT NULL,
  email VARCHAR(200) NOT NULL UNIQUE
);
INSERT INTO cadastro.pessoa (nome, idade, email)
VALUES ('Ana Teste', 30, 'ana.teste@example.invalid');
"@
    # Aguarda o DDL ser aplicado antes de consultar a tabela na réplica.
    Conferir replica "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='cadastro' AND table_name='pessoa';" 1
    Conferir replica $idadeAna 30
    ConferirCanal
    Sql principal "UPDATE cadastro.pessoa SET idade=31 WHERE email='ana.teste@example.invalid';"
    Conferir replica $idadeAna 31
    Write-Host 'Ana chegou à réplica com 30 anos e foi atualizada para 31.'

    Compose up -d --no-deps --force-recreate --wait --wait-timeout 180 principal
    Conferir principal $idadeAna 31
    Write-Host 'O principal recuperou Ana do volume após a recriação.'

    Compose stop replica
    Sql principal "INSERT INTO cadastro.pessoa (nome,idade,email) VALUES ('Bruno Teste',28,'bruno.teste@example.invalid');"
    Compose up -d --wait --wait-timeout 180
    Conferir replica $idadeBruno 28
    Write-Host 'Bruno foi gravado durante a parada e chegou à réplica na retomada.'

    Compose stop
    Compose up -d --wait --wait-timeout 180
    Conferir principal $idadeAna 31
    Conferir replica $idadeBruno 28
    # Após um reinício a reconexão pode ocorrer depois do healthcheck.
    for ($i = 0; $i -lt 90; $i++) {
        $status = Sql replica 'SHOW REPLICA STATUS\G'
        if (($status -match 'Replica_IO_Running: Yes') -and ($status -match 'Replica_SQL_Running: Yes')) { break }
        Start-Sleep -Seconds 1
    }
    ConferirCanal
    Sql replica 'SELECT id,nome,idade,email FROM cadastro.pessoa ORDER BY id;'
    Write-Host 'Verificações concluídas.'
} finally {
    Compose stop
}
