package br.pucminas.lab.microservicos.response;

import br.pucminas.lab.microservicos.pedidos.model.Coordenada;

import java.util.List;

public class RotaResponse {
    private double distanciaKm;
    private String duracaoHoras;
    private List<Coordenada> rota;

    public RotaResponse(double distanciaKm, String duracaoHoras, List<Coordenada> rota) {
        this.distanciaKm = distanciaKm;
        this.duracaoHoras = duracaoHoras;
        this.rota = rota;
    }

    public double getDistanciaKm() {
        return distanciaKm;
    }

    public void setDistanciaKm(double distanciaKm) {
        this.distanciaKm = distanciaKm;
    }

    public String getDuracaoHoras() {
        return duracaoHoras;
    }

    public void setDuracaoHoras(String duracaoHoras) {
        this.duracaoHoras = duracaoHoras;
    }

    public List<Coordenada> getRota() {
        return rota;
    }

    public void setRota(List<Coordenada> rota) {
        this.rota = rota;
    }
}
