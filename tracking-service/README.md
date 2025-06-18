# Serviço de Rastreamento

Este microsserviço gerencia o rastreamento em tempo real das entregas:

## Configuração

1. Copie `.env.example` para `.env` e ajuste os valores.
2. Instale as dependências:
   ```bash
   npm install
   ```
3. Inicie o serviço:
   ```bash
   npm run dev
   ```

## Endpoints

- **POST** `/tracking/:deliveryId/locations`
  Corpo: `{ driverId, latitude, longitude, [timestamp] }`

- **GET** `/tracking/:deliveryId/locations/latest`
  Retorna a localização mais recente.

- **GET** `/tracking/nearby?lat=...&lng=...&radius=...`
  Retorna entregas dentro de um raio de `radius` metros do ponto informado.

## Integração

- Aponte seu API Gateway ou cliente para este serviço em `/tracking`.
- Garanta que a autenticação via JWT seja tratada a montante ou adicione um middleware aqui.
