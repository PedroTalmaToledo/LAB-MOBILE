# 📦 API de Pedidos - Microserviço

Este projeto é um microserviço em Spring Boot para o gerenciamento do ciclo de vida de pedidos, com persistência em PostgreSQL e documentação via Swagger.

[Vídeo Explicando Sobre o Projeto](https://github.com/PedroTalmaToledo/LAB-MOBILE/blob/main/crud_pedidos/Video_CRUD_Pedidos.mkv)

---
## 🚀 Funcionalidades

- Criar novos pedidos
- Listar todos os pedidos
- Buscar pedido por ID
- Filtrar por cliente ou status
- Atualizar status do pedido
- Deletar pedidos

---

## 🧰 Tecnologias Utilizadas

- Java 17
- Spring Boot 3.2.x
- Spring Data JPA
- PostgreSQL 16
- Flyway
- Swagger (Springdoc OpenAPI)
- Maven

---

## 🛠️ Requisitos

- Java 17+
- PostgreSQL 16 instalado e rodando na porta padrão `5432`
- Maven 3.8+
- Git

---

## ⚙️ Configuração do Banco de Dados

Criar um banco de dados PostgreSQL, certificar que está rodando localmente e configurar o arquivo `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/pedidos
spring.datasource.username={seu_usuario}
spring.datasource.password={sua_senha}
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

> O Flyway será executado automaticamente ao iniciar a aplicação.

---

## ▶️ Como Rodar

### 1. Clone o projeto

```bash
git clone {opção de clonagem, recomendo SSH}
```

### 2. Execute com Maven

```bash
./mvnw spring-boot:run
```

ou

```bash
mvn spring-boot:run
```

---

## 📑 Documentação Swagger

Acesse:

```
http://localhost:8080/swagger-ui.html
```

Ou:

```
http://localhost:8080/swagger-ui/index.html
```

---

## 🧪 Exemplo de JSON para criação de pedido

```json
{
  "origem": "Belo Horizonte",
  "destino": "São Paulo",
  "cliente": "TESTE",
  "tipoMercadoria": "ROUPAS",
  "status": "EM_PROCESSAMENTO"
}
```

---

## 🗃️ Scripts Flyway

Os scripts de criação de tabelas estão na pasta:

```
src/main/resources/db/migration/
```

E seguem o padrão:

```
V{sequencia}__{descrição separado por '_'}.sql
```

---

## 📂 Estrutura de Pacotes

```
├── controller
├── model
│   └── type (StatusPedido, TipoMercadoria)
├── repository
├── service
├── resources
│   ├── application.properties
│   └── db/migration
```

---
