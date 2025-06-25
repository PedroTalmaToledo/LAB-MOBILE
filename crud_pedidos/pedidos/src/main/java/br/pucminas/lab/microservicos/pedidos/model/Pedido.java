package br.pucminas.lab.microservicos.pedidos.model;

import br.pucminas.lab.microservicos.pedidos.model.type.StatusPedido;
import br.pucminas.lab.microservicos.pedidos.model.type.TipoMercadoria;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;

import java.time.LocalDateTime;
import java.util.Date;

@Entity
@Table(name = "pedidos")
public class Pedido {
    private Long id;

    private String origem;
    private String destino;
    private String cliente;
    private TipoMercadoria tipoMercadoria;
    private StatusPedido status;
    private Date dataHoraCriacao;

    public Pedido() {
        this.dataHoraCriacao = Date.from(LocalDateTime.now().atZone(java.time.ZoneId.systemDefault()).toInstant());
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    @Column(name = "ori_ped", nullable = false)
    public String getOrigem() {
        return origem;
    }

    public void setOrigem(String origem) {
        this.origem = origem;
    }

    @Column(name = "des_ped", nullable = false)
    public String getDestino() {
        return destino;
    }

    public void setDestino(String destino) {
        this.destino = destino;
    }

    @Column(name = "cli_ped", nullable = false)
    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "tip_mer_ped", columnDefinition = "varchar(20)", nullable = false)
    public TipoMercadoria getTipoMercadoria() {
        return tipoMercadoria;
    }

    public void setTipoMercadoria(TipoMercadoria tipoMercadoria) {
        this.tipoMercadoria = tipoMercadoria;
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "sta_ped", columnDefinition = "varchar(20)", nullable = false)
    public StatusPedido getStatus() {
        return status;
    }

    public void setStatus(StatusPedido status) {
        this.status = status;
    }

    @Column(name = "dat_cri_ped", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    public Date getDataHoraCriacao() {
        return dataHoraCriacao;
    }
    public void setDataHoraCriacao(Date dataHoraCriacao) {
        this.dataHoraCriacao = dataHoraCriacao;
    }
}
