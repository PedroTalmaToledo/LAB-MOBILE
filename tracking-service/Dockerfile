FROM node:18

# Define diretório de trabalho
WORKDIR /app

# Copia apenas os arquivos de dependência para instalar primeiro (cache melhor)
COPY package*.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código
COPY . .

# Expõe a porta usada pela aplicação
EXPOSE 3000

# Comando de inicialização
CMD ["node", "index.js"]
