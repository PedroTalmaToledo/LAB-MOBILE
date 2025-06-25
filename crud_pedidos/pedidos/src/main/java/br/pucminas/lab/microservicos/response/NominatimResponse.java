package br.pucminas.lab.microservicos.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class NominatimResponse {
    private String lat;
    private String lon;

    public String getLat() { return lat; }
    public String getLon() { return lon; }
}