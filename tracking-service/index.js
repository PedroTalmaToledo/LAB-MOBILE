require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const morgan = require("morgan");
const cors = require("cors");
const trackingRoutes = require("./routes/trackingRoutes");

const app = express();

// Middleware para habilitar CORS (resolve erro de conexão com Flutter/Front)
app.use(cors());

// Middleware para logar requisições HTTP
app.use(morgan("dev"));

// Log personalizado para debug (exibe método e rota)
app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.originalUrl}`);
  next();
});

// Middleware para ler JSON do body
app.use(express.json());

app.use("/rastreamento", trackingRoutes);

// Conexão com MongoDB e inicialização do servidor
const PORT = process.env.PORT || 5002;
mongoose
  .connect(
    "mongodb+srv://pedrotoledo1717:123@cluster0.ut2fptr.mongodb.net/tracking?retryWrites=true&w=majority",
    {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    }
  )
  .then(() =>
    app.listen(PORT, () =>
      console.log(`Tracking Service running on port ${PORT}`)
    )
  )
  .catch((err) => console.error("MongoDB connection error:", err));
