# VTEX Sync

Sincroniza base de dados MySQL com informações da API de vendas da VTEX.

## Instalação

A versão do Ruby utilizada pelo projeto está fixada no arquivo `.ruby-version`. Utilizamos o [mise](https://mise.jdx.dev) para instalação dessa versão. Basta mudar para o diretório do projeto e executar o comando:

```sh
mise install
```

Após a instalação do Ruby, instalamos a *gem* Bundler:

```sh
gem install bundler
```

E, finalmente, instalamos as demais *gems* necessárias ao projeto:

```sh
bundle install
```

## Sincronização

Inicialmente vamos criar a base de dados que será utilizada para a sincronização das informações das vendas. O nome da base pode ser alterado na seção `development` do arquivo `config/database.yml`. O nome padrão é `vtexsync_development`. Para criar a base de dados e as tabelas, usamos o comando:

```sh
bin/rails db:create db:migrate
```

Em seguida, precisamos alterar algumas configurações para que o sistema consiga acessar a API da VTEX. Em `application.yml`, alterar as propriedades `account_name` e `environment` na seção `shared/vtex`. Exemplo:

```yaml
shared:
  vtex:
    account_name: "bioextratusvirtual"
    environment: "vtexcommercestable"
```

Também precisamos alterar as propriedades `app_token` e `app_key` da seção `vtex` do arquivo `config/credentials.yml.enc` (arquivo não versionado). Por serem informações sensíveis, elas são salvas de forma criptografada e não podem ser editadas diretamente. Para editar o arquivo com as credenciais, é necessário utilizar o comando `bin/rails credentials:edit`. Exemplo:

```yaml
vtex:
  app_token: xxx
  app_key: yyy
```

Mais informações sobre o mecanismo de credenciais do Rails podem ser encontradas no [Ruby on Rails Guides](https://guides.rubyonrails.org/security.html#custom-credentials).

Depois que as configurações para conexão com a API da VTEX tiverem sido definidas, para iniciar a sincronização das vendas, basta executar:

```sh
bin/rails info vtex:sync_orders
```

> A task `info` (definida em `lib/tasks/debug.rake`) redireciona o log do Rails para o `stdout` no nível `info`. Ela é opcional e pode ser combinada com qualquer uma das rotinas abaixo para acompanhar o progresso da sincronização no terminal.

Por padrão, a rotina irá sincronizar com a base de dados MySQL todos os pedidos das últimas 24 horas. É possível personalizar esse período através dos parâmetros `from` e `to`, conforme exemplo abaixo:

```sh
bin/rails info vtex:sync_orders from="2022-06-15" to="2022-06-20 23:59:59"
```

Há também outras rotinas disponíveis para sincronização de alguns períodos pré-definidos:

```sh
bin/rails info vtex:sync_1_day_ago
bin/rails info vtex:sync_2_days_ago
bin/rails info vtex:sync_1_week_ago
bin/rails info vtex:sync_1_month_ago
```

Para sincronizar todos os pedidos desde o último pedido já sincronizado (ou desde o início, caso a base esteja vazia):

```sh
bin/rails info vtex:full_sync
```

Também é possível sincronizar um único pedido. Basta executar:

```sh
bin/rails info vtex:sync_order order_id="1379680932086-01"
```

## Re-sincronização

A re-sincronização de pedidos segue um protocolo produtor/consumidor através da tabela `vtex_order_resync_requests`: primeiro os pedidos são marcados (abrindo uma requisição pendente por pedido) e, em seguida, enfileirados em lotes para processamento. A requisição só é concluída quando a sincronização do pedido tem sucesso.

Para marcar pedidos para re-sincronização:

```sh
bin/rails vtex:mark_for_resync order_ids="1379680932086-01,456-01" reason="ajuste"
```

Para drenar as requisições pendentes para a fila de processamento, em lotes:

```sh
bin/rails vtex:enqueue_resync limit=500
```

## Enriquecimento de produtos

Os produtos podem ser enriquecidos com atributos do catálogo da VTEX por SKU. Para enfileirar o enriquecimento:

```sh
bin/rails vtex:enrich_products limit=500   # ou all=true para todos os produtos
```

## Estrutura de dados

Os dados das vendas são sincronizados em tabelas do MySQL conforme a estrutura abaixo:

![Modelo de Dados](files/VTEX_Sync_Modelo_de_Dados.png?raw=true "Modelo de Dados")
