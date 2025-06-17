package br.pucminas.lab.microservicos.pedidos.controller;

import br.pucminas.lab.microservicos.pedidos.model.Pedido;
import br.pucminas.lab.microservicos.pedidos.model.type.StatusPedido;
import br.pucminas.lab.microservicos.pedidos.service.PedidoService;
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

    public PedidoController(PedidoService service) {
        this.service = service;
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
            summary = "Listar todos os pedidos",
            description = "Retorna todos os pedidos cadastrados"
    )
    public List<Pedido> listarTodos() {
        return service.buscarTodos();
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Buscar pedido por ID",
            description = "Retorna os dados de um pedido específico"
    )
    public Pedido buscarPorId(
            @Parameter(description = "ID do pedido") @PathVariable Long id) {
        return service.buscarPorId(id);
    }

    @GetMapping("/cliente/{cliente}")
    @Operation(
            summary = "Buscar pedidos por cliente",
            description = "Retorna os pedidos associados a um cliente específico"
    )
    public List<Pedido> buscarPorCliente(
            @Parameter(description = "Nome do cliente") @PathVariable String cliente) {
        return service.buscarPorCliente(cliente);
    }

    @GetMapping("/status/{status}")
    @Operation(
            summary = "Buscar pedidos por status",
            description = "Retorna os pedidos de acordo com o status atual"
    )
    public List<Pedido> buscarPorStatus(
            @Parameter(description = "Status do pedido") @PathVariable StatusPedido status) {
        return service.buscarPorStatus(status);
    }

    @PutMapping("/{id}/status")
    @Operation(
            summary = "Atualizar status do pedido",
            description = "Atualiza o status de um pedido específico"
    )
    public Pedido atualizarStatus(
            @Parameter(description = "ID do pedido") @PathVariable Long id,
            @Parameter(description = "Novo status") @RequestParam StatusPedido status) {
        return service.atualizarStatus(id, status);
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Deletar pedido",
            description = "Remove um pedido com base no ID"
    )
    public void deletar(
            @Parameter(description = "ID do pedido a ser removido") @PathVariable Long id) {
        service.deletarPedido(id);
    }
}
