# VTEX Sync

Sincroniza base de dados MySQL com informações da API de vendas da VTEX.

## Instalação

O projeto utiliza a versão 2.6.6 do Ruby. Utilizamos o [rbenv](https://github.com/rbenv/rbenv) para instalação dessa versão:

```sh
rbenv install 2.6.6
```

Para compilação dessa versão do Ruby no Mac com arquitetura M1, foi necessário utilizar o parâmetro `RUBY_CFLAGS="-w"`:

```sh
RUBY_CFLAGS="-w" rbenv install 2.6.6
```

Referência: https://github.com/rbenv/ruby-build/issues/1691#issuecomment-752802171

Após a instalação do Ruby, instalamos a versão 2.1.4 da *gem* Bundler:

```sh
gem install bundler -v 2.1.4
```

E, finalmente, instalamos as demais *gems* necessárias ao projeto:

```sh
bundle install
```

## Sincronização

Inicialmente vamos criar a base de dados que será utilizada para a sincronização das informações das vendas. O nome da base pode ser alterado na seção `development` do arquivo `config/database.yml`. O nome padrão é `vtexsync_development`. Para criar a base de dados e as tabelas, usamos o comando:

```sh
bundle exec rake db:create db:migrate
```

Em seguida, precisamos alterar algumas configurações para que o sistema consiga acessar a API da VTEX. Em `application.yml`, alterar as propriedades `account_name` e `environment` na seção `shared/vtex`. Exemplo:

```yaml
shared:
  vtex:
    account_name: "bioextratusvirtual"
    environment: "vtexcommercestable"
```

Também precisamos alterar as propriedades `app_token` e `app_key` da seção `vtex` do arquivo `config/credentials.yml.enc` (arquivo não versionado). Por serem informações sensíveis, elas são salvas de forma criptografada e não podem ser editadas diretamente. Para editar o arquivo com as credenciais, é necessário utilizar o comando `rails credentials:edit`. Exemplo:

```yaml
vtex:
  app_token: xxx
  app_key: yyy
```

Mais informações sobre o mecanismo de credenciais do Rails podem ser encontradas no [Ruby on Rails Guides](https://guides.rubyonrails.org/security.html#custom-credentials).

Depois que as configurações para conexão com a API da VTEX tiverem sido definidas, para iniciar a sincronização das vendas, basta executar:

```sh
bundle exec rake info vtex:sync
```

Por padrão, a rotina irá sincronizar com a base de dados MySQL todos os pedidos das últimas 24 horas. É possível personalizar esse período através dos parâmetros `from` e `to`, conforme exemplo abaixo:

```sh
bundle exec rake info vtex:sync from="2022-06-15" to="2022-06-20 23:59:59"
```

Há também outras `rakes` disponíveis para sincronização de alguns períodos pré-definidos:

```sh
bundle exec rake info vtex:sync_1_day_ago
bundle exec rake info vtex:sync_2_days_ago
bundle exec rake info vtex:sync_1_week_ago
bundle exec rake info vtex:sync_1_month_ago
```

## Estrutura de dados

Os dados das vendas são sincronizados em tabelas do MySQL conforme a estrutura abaixo:

![Modelo de Dados](files/VTEX_Sync_Modelo_de_Dados.png?raw=true "Modelo de Dados")
