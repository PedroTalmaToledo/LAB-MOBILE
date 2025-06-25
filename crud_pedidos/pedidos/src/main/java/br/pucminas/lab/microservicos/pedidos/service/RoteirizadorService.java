package br.pucminas.lab.microservicos.pedidos.service;

import br.pucminas.lab.microservicos.pedidos.model.Coordenada;
import br.pucminas.lab.microservicos.response.NominatimResponse;
import br.pucminas.lab.microservicos.response.RotaResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Locale;

@Service
public class RoteirizadorService {

    private static final String OSRM_BASE_URL = "http://router.project-osrm.org/route/v1/driving";
    private static final String NOMINATIM_URL = "https://nominatim.openstreetmap.org/search?q=%s&format=json&limit=1";

    private final RestTemplate restTemplate;
    private final ObjectMapper mapper = new ObjectMapper();

    public RoteirizadorService() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * Converte um endereço ou cidade em coordenadas [lat, lon].
     */
    public double[] geocodificarEndereco(String endereco) {
        String enderecoCompleto = endereco + ", Brasil";
        String url = String.format(NOMINATIM_URL, enderecoCompleto.replace(" ", "+"));

        HttpHeaders headers = new HttpHeaders();
        headers.set("User-Agent", "pedidos-app/1.0 (contato@exemplo.com)");
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));
        HttpEntity<Void> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<NominatimResponse[]> response = restTemplate.exchange(
                    url, HttpMethod.GET, entity, NominatimResponse[].class
            );
            NominatimResponse[] body = response.getBody();
            if (body != null && body.length > 0) {
                double lat = Double.valueOf(body[0].getLat().replace(",", "."));
                double lon = Double.valueOf(body[0].getLon().replace(",", "."));

                System.out.printf("Geocodificado %s -> lat: %f, lon: %f%n", endereco, lat, lon);
                return new double[]{lat, lon};
            } else {
                throw new RuntimeException("Endereço não encontrado: " + endereco);
            }
        } catch (Exception e) {
            throw new RuntimeException("Erro ao consultar Nominatim: " + endereco, e);
        }
    }

    /**
     * Calcula rota entre duas coordenadas usando OSRM.
     */
    public RotaResponse calcularRota(double origemLat, double origemLon, double destinoLat, double destinoLon) {
        String coords = String.format(Locale.US, "%f,%f;%f,%f", origemLon, origemLat, destinoLon, destinoLat);
        String url = String.format("%s/%s?overview=full&geometries=geojson", OSRM_BASE_URL, coords);
        System.out.println("Requisição OSRM: " + url);

        try {
            String resp = restTemplate.getForObject(url, String.class);
            JsonNode root = mapper.readTree(resp);
            JsonNode route = root.path("routes").get(0);

            double distanciaKm = Math.round((route.path("distance").asDouble() / 1000.0) * 10.0) / 10.0;
            double segundos = route.path("duration").asDouble();
            double horas = segundos / 3600.0;
            int horasInt = (int) horas;
            int minutos = (int) Math.round((horas - horasInt) * 60);
            String duracaoFormatada = horasInt + "h " + minutos + "min";

            List<Coordenada> rota = new java.util.ArrayList<>();
            JsonNode coordsArray = route.path("geometry").path("coordinates");
            for (JsonNode coord : coordsArray) {
                double lon = coord.get(0).asDouble();
                double lat = coord.get(1).asDouble();
                rota.add(new Coordenada(lat, lon));
            }

            return new RotaResponse(distanciaKm, duracaoFormatada, rota);

        } catch (Exception e) {
            throw new RuntimeException("Erro ao consultar rota OSRM", e);
        }
    }


}
