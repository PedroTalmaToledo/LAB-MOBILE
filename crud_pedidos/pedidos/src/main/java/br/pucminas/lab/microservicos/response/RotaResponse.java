package br.pucminas.lab.microservicos.response;

public class RotaResponse {
    private double distanciaKm;
    private String duracaoHoras;

    public RotaResponse(double distanciaKm, String duracaoHoras) {
        this.distanciaKm = distanciaKm;
        this.duracaoHoras = duracaoHoras;
    }

    public double getDistanciaKm() { return distanciaKm; }
    public String getDuracaoHoras() { return duracaoHoras; }
}
