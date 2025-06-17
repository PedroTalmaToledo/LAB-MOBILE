package br.pucminas.lab.microservicos.pedidos.exception;

public class PedidoException extends RuntimeException{
    private static final long serialVersionUID = 1L;

    public PedidoException(String message) {
        super(message);
    }

    public PedidoException(String message, Throwable cause) {
        super(message, cause);
    }

    public PedidoException(Throwable cause) {
        super(cause);
    }
}
