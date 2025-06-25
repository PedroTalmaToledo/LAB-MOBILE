package br.pucminas.lab.microservicos.pedidos.model.type;

public enum TipoMercadoria {
    ELETRONICOS(0),
    ALIMENTOS(1),
    ROUPAS(2),
    MOVEIS(3),
    LIVROS(4),
    OUTROS(5);

    private final int key;

    private TipoMercadoria(int key) {
        this.key = key;
    }

    public int getKey() {
        return key;
    }

    public String getLabel() {
        switch (key) {
            case 0:
                return "Eletrônicos";
            case 1:
                return "Alimentos";
            case 2:
                return "Roupas";
            case 3:
                return "Móveis";
            case 4:
                return "Livros";
            case 5:
                return "Outros";
            default:
                return "Desconhecido";
        }
    }

    @Override
    public String toString() {
        return getLabel();
    }
}