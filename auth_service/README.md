# Serviço de Autenticação

Este microsserviço gerencia registro, login e validação de tokens JWT para clientes e motoristas.

## Configuração

1. Copie `.env.example` para `.env` e ajuste:
   - `MONGODB_URI`
   - `JWT_SECRET`
   - `JWT_EXPIRES_IN`
2. Instale dependências: `npm install`
3. Inicie o serviço: `npm run dev`

## Endpoints

- **POST** `/auth/register`
  Body: `{ name, email, password, role }`
  - `role`: `client` ou `driver`
  - Retorna: `{ token }`

- **POST** `/auth/login`
  Body: `{ email, password }`
  - Retorna: `{ token }`

- **GET** `/auth/verify`
  Headers: `Authorization: Bearer <token>`
  - Retorna: `{ valid: true, user: { userId, role, iat, exp } }`

## Integração

- Use o token retornado em `Authorization: Bearer <token>` para acessar outros microsserviços.
