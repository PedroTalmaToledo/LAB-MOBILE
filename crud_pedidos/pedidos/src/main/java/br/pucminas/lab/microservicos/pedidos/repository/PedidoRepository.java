package br.pucminas.lab.microservicos.pedidos.repository;

import br.pucminas.lab.microservicos.pedidos.model.Pedido;
import br.pucminas.lab.microservicos.pedidos.model.type.StatusPedido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    List<Pedido> findPedidoByCliente(String cliente);
    List<Pedido> findPedidoByStatus(StatusPedido status);
}
