# Imagem base com Node.js 18
FROM node:18

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia apenas os arquivos de dependência primeiro (otimiza o cache)
COPY package*.json ./

# Instala dependências
RUN npm install

# Copia o restante do código da aplicação
COPY . .

# Expõe a porta esperada pelo Cloud Run
EXPOSE 8080

# Comando para iniciar o serviço
CMD ["node", "index.js"]
