package br.pucminas.lab.microservicos.pedidos.service;

import br.pucminas.lab.microservicos.pedidos.exception.PedidoException;
import br.pucminas.lab.microservicos.pedidos.model.Pedido;
import br.pucminas.lab.microservicos.pedidos.model.type.StatusPedido;
import br.pucminas.lab.microservicos.pedidos.repository.PedidoRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PedidoService {

    private final PedidoRepository repository;

    public PedidoService(PedidoRepository repository) {
        this.repository = repository;
    }

    public Pedido criarPedido(Pedido pedido) {
        pedido.setStatus(StatusPedido.ENVIADO);
        return repository.save(pedido);
    }

    public List<Pedido> buscarTodos() {
        return repository.findAll();
    }

    public Pedido buscarPorId(Long id) {
        return repository.findById(id).orElseThrow(() -> new PedidoException("Pedido não encontrado"));
    }

    public List<Pedido> buscarPorCliente(String cliente) {
        return repository.findPedidoByCliente(cliente);
    }

    public List<Pedido> buscarPorStatus(StatusPedido status) {
        return repository.findPedidoByStatus(status);
    }

    public Pedido atualizarStatus(Long id, StatusPedido status) {
        Pedido pedido = buscarPorId(id);
        if (pedido == null) {
            throw new PedidoException("Pedido não encontrado");
        }
        pedido.setStatus(status);
        return repository.save(pedido);
    }

    public void deletarPedido(Long id) {
        repository.deleteById(id);
    }
}
