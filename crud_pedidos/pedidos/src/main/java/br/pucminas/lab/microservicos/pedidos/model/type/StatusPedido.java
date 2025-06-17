package br.pucminas.lab.microservicos.pedidos.model.type;

public enum StatusPedido {
    EM_PROCESSAMENTO(0),
    ENVIADO(1),
    ENTREGUE(2),
    CANCELADO(3);

    private int key;

    private StatusPedido(int key) {
        this.key = key;
    }

    public String getLabel() {
        switch (key) {
            case 0:
                return "Em Processamento";
            case 1:
                return "Enviado";
            case 2:
                return "Entregue";
            case 3:
                return "Cancelado";
        }
        return null;
    }

    public int getKey() {
        return key;
    }

    @Override
    public String toString() {
        return getLabel();
    }
}