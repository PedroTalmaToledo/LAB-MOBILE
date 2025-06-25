package br.pucminas.lab.microservicos.pedidos.controller;

import br.pucminas.lab.microservicos.pedidos.model.Pedido;
import br.pucminas.lab.microservicos.pedidos.model.type.StatusPedido;
import br.pucminas.lab.microservicos.pedidos.service.PedidoService;
import br.pucminas.lab.microservicos.pedidos.service.RoteirizadorService;
import br.pucminas.lab.microservicos.response.RotaResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/pedidos")
@Tag(name = "Pedidos", description = "Endpoints para gerenciamento de pedidos")
public class PedidoController {

    private final PedidoService service;
    private final RoteirizadorService roteirizadorService;

    public PedidoController(PedidoService service, RoteirizadorService roteirizadorService) {
        this.service = service;
        this.roteirizadorService = roteirizadorService;
    }

    @PostMapping
    @Operation(
            summary = "Criar novo pedido",
            description = "Cria um novo pedido com dados de cliente, origem, destino, tipo de mercadoria e status.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Pedido criado com sucesso",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public Pedido criar(@RequestBody Pedido pedido) {
        return service.criarPedido(pedido);
    }

    @GetMapping
    @Operation(
            summary = "Listar Todos os Pedidos",
            description = "Listar Todos os Pedidos.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Pedidos filtrados com sucesso",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public List<Pedido> listarTodos() {
        return service.buscarTodos();
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Buscar Pedidos por ID",
            description = "Buscar Pedidos por ID.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Pedido encontrado",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public Pedido buscarPorId(@Parameter(description = "ID do pedido") @PathVariable Long id) {
        return service.buscarPorId(id);
    }

    @GetMapping("/cliente/{cliente}")
    @Operation(
            summary = "Buscar Pedidos por Cliente",
            description = "Buscar Pedidos por Cliente.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public List<Pedido> buscarPorCliente(@PathVariable String cliente) {
        return service.buscarPorCliente(cliente);
    }

    @GetMapping("/status/{status}")
    @Operation(
            summary = "Buscar Pedidos por Status",
            description = "Buscar Pedidos por Status.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Pedidos encontrados",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public List<Pedido> buscarPorStatus(@PathVariable StatusPedido status) {
        return service.buscarPorStatus(status);
    }

    @PutMapping("/{id}/status")
    @Operation(
            summary = "Atualizar Status do Pedido",
            description = "Atualizar Status do Pedido.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Status do Pedido atualizado com sucesso",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public Pedido atualizarStatus(@PathVariable Long id, @RequestParam StatusPedido status) {
        return service.atualizarStatus(id, status);
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Deletar Pedido",
            description = "Deletar Pedido.",
            responses = {
                    @ApiResponse(responseCode = "200", description = "Pedido deletado com sucesso",
                            content = @Content(schema = @Schema(implementation = Pedido.class))),
                    @ApiResponse(responseCode = "400", description = "Dados inválidos")
            }
    )
    public void deletar(@PathVariable Long id) {
        service.deletarPedido(id);
    }

    @GetMapping("/{id}/rota")
    @Operation(summary = "Calcular rota do pedido",
            description = "Usa geocodificação Nominatim e calcula rota com OSRM")
    public RotaResponse calcularRotaPedido(@PathVariable Long id) {
        Pedido pedido = service.buscarPorId(id);
        double[] origem = roteirizadorService.geocodificarEndereco(pedido.getOrigem());
        double[] destino = roteirizadorService.geocodificarEndereco(pedido.getDestino());
        return roteirizadorService.calcularRota(origem[0], origem[1], destino[0], destino[1]);
    }

    @GetMapping("/teste")
    @Operation(summary = "Teste simples via API Gateway",
            description = "Retorna uma string para validar se o serviço de pedidos está acessível via API Gateway")
    public String testeGateway() {
        System.out.println("✅ Requisição recebida no pedido-service via gateway");
        return "Requisição recebida no pedido-service via gateway!";
    }
}
