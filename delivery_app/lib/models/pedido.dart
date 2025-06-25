class Pedido {
  final int? id;
  final String origem;
  final String destino;
  final String cliente;
  final String tipoMercadoria;
  final String status;
  final DateTime? dataHoraCriacao;

  Pedido({
    this.id,
    required this.origem,
    required this.destino,
    required this.cliente,
    required this.tipoMercadoria,
    required this.status,
    this.dataHoraCriacao,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        id: json['id'],
        origem: json['origem'],
        destino: json['destino'],
        cliente: json['cliente'],
        tipoMercadoria: json['tipoMercadoria'],
        status: json['status'],
        dataHoraCriacao: json['dataHoraCriacao'] != null
            ? DateTime.parse(json['dataHoraCriacao'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'origem': origem,
        'destino': destino,
        'cliente': cliente,
        'tipoMercadoria': tipoMercadoria,
        'status': status,
      };
}
