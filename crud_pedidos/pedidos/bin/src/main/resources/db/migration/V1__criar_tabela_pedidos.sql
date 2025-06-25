CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    ori_ped VARCHAR NOT NULL,
    des_ped VARCHAR NOT NULL,
    cli_ped VARCHAR NOT NULL,
    tip_mer_ped VARCHAR(20) NOT NULL,
    sta_ped VARCHAR(20) NOT NULL,
    dat_cri_ped TIMESTAMP NOT NULL
);