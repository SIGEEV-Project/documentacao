--
-- Inserção de dados de exemplo nas tabelas
--

-- Insere 10 usuários com perfis e dados variados
INSERT INTO "Usuarios" (
  "usuarioId",
  "primeiroNome",
  "ultimoNome",
  "email",
  "cpf",
  "telefone",
  "dataNascimento",
  "perfil",
  "status",
  "dataCadastro"
) VALUES
('b301f286-90c7-4348-876b-9c766e4871e9', 'Carlos', 'Admin Souza', 'carlos.admin@email.com', '11122233344', '81988887777', '1980-05-15', 'administrador', 'ativo', '2024-01-10 10:00:00'),
('d529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'Mariana', 'Promotora Lima', 'mariana.promotora@email.com', '22233344455', '81999996666', '1992-07-22', 'promotor', 'ativo', '2024-01-15 11:30:00'),
('b08d4b31-4a1d-444f-8368-80f48866175e', 'Fernando', 'Promotor Guedes', 'fernando.guedes@email.com', '33344455566', '81977775555', '1988-11-01', 'promotor', 'ativo', '2024-01-20 09:15:00'),
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'Ana', 'Participante Pereira', 'ana.pereira@email.com', '44455566677', '81966664444', '1995-03-10', 'participante', 'ativo', '2024-02-01 14:00:00'),
('a9c8e7b6-d5a4-4c3d-b2e1-a0f9e8d7c6b5', 'Rafael', 'Participante Costa', 'rafael.costa@email.com', '55566677788', '81955553333', '2000-08-25', 'participante', 'ativo', '2024-02-05 16:20:00'),
('f8e7d6c5-b4a3-4b2e-a1d0-c9b8a7f6e5d4', 'Julia', 'Participante Ferreira', 'julia.ferreira@email.com', '66677788899', '81944442222', '1998-02-18', 'participante', 'ativo', '2024-02-10 08:00:00'),
('c1a0b9c8-d7e6-4f5a-8b9c-7d6e5f4a3b2c', 'Pedro', 'Participante Silveira', 'pedro.silveira@email.com', '77788899900', '81933331111', '1993-06-05', 'participante', 'ativo', '2024-02-12 17:45:00'),
('d4e3f2g1-h5i4-j6k5-l7m6-n8o7p6q5r4s3', 'Isabela', 'Participante Gomes', 'isabela.gomes@email.com', '88899900011', '81922220000', '1997-09-30', 'participante', 'ativo', '2024-02-15 10:30:00'),
('a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'João', 'Participante Mendes', 'joao.mendes@email.com', '99900011122', '81911119999', '1990-12-12', 'participante', 'ativo', '2024-02-20 12:00:00'),
('c6d5e4f3-a2b1-4d3c-e5f6-7a8b9c0d1e2f', 'Lucia', 'Participante Almeida', 'lucia.almeida@email.com', '00011122233', '81900008888', '1985-04-05', 'participante', 'ativo', '2024-02-25 15:50:00');

-- Insere senhas para todos os usuários
INSERT INTO "Senhas" ("usuarioId", "senhaHash") VALUES
('b301f286-90c7-4348-876b-9c766e4871e9', 'hash_senha_carlos'),
('d529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'hash_senha_mariana'),
('b08d4b31-4a1d-444f-8368-80f48866175e', 'hash_senha_fernando'),
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'hash_senha_ana'),
('a9c8e7b6-d5a4-4c3d-b2e1-a0f9e8d7c6b5', 'hash_senha_rafael'),
('f8e7d6c5-b4a3-4b2e-a1d0-c9b8a7f6e5d4', 'hash_senha_julia'),
('c1a0b9c8-d7e6-4f5a-8b9c-7d6e5f4a3b2c', 'hash_senha_pedro'),
('d4e3f2g1-h5i4-j6k5-l7m6-n8o7p6q5r4s3', 'hash_senha_isabela'),
('a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'hash_senha_joao'),
('c6d5e4f3-a2b1-4d3c-e5f6-7a8b9c0d1e2f', 'hash_senha_lucia');


-- Insere histórico de promoções
INSERT INTO "HistoricoDePromocoes" (
  "usuarioId",
  "adminId",
  "tipoAcao",
  "perfilAntigo",
  "perfilNovo",
  "dataAcao"
) VALUES
('d529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'b301f286-90c7-4348-876b-9c766e4871e9', 'promocao', 'participante', 'promotor', '2024-01-15 11:30:00'),
('b08d4b31-4a1d-444f-8368-80f48866175e', 'b301f286-90c7-4348-876b-9c766e4871e9', 'promocao', 'participante', 'promotor', '2024-01-20 09:15:00'),
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'b301f286-90c7-4348-876b-9c766e4871e9', 'promocao', 'participante', 'promotor', '2024-03-01 15:00:00'),
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'b301f286-90c7-4348-876b-9c766e4871e9', 'rebaixamento', 'promotor', 'participante', '2024-03-05 10:00:00');


-- Insere 10 eventos
INSERT INTO "Eventos" (
  "eventoId",
  "promotorId",
  "titulo",
  "descricao",
  "dataInicio",
  "dataFim",
  "local",
  "capacidade",
  "vagasRestantes",
  "bannerUrl",
  "status"
) VALUES
('e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'd529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'Workshop de Fotografia', 'Aprenda técnicas de fotografia profissional com especialistas.', '2025-09-10 09:00:00', '2025-09-10 17:00:00', 'Centro de Convenções', 50, 48, 'https://seusistema.com/banners/workshop-foto.jpg', 'ativo'),
('a2b3c4d5-e6f7-4a8b-9c0d-1e2f3a4b5c6d', 'b08d4b31-4a1d-444f-8368-80f48866175e', 'Feira de Artesanato Local', 'Exposição e venda de produtos artesanais da região.', '2025-09-20 10:00:00', '2025-09-22 18:00:00', 'Praça do Marco Zero', 1000, 1000, 'https://seusistema.com/banners/feira-artesanato.jpg', 'ativo'),
('f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f', 'd529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'Show de Jazz no Parque', 'Noite de jazz com bandas locais.', '2025-10-05 19:00:00', '2025-10-05 23:00:00', 'Parque da Cidade', 200, 198, 'https://seusistema.com/banners/show-jazz.jpg', 'ativo'),
('c9d8e7f6-a5b4-4c3d-b2e1-a0f9e8d7c6b5', 'b08d4b31-4a1d-444f-8368-80f48866175e', 'Congresso de Tecnologia', 'Discussões sobre as últimas tendências em tecnologia.', '2025-10-15 08:00:00', '2025-10-17 18:00:00', 'Universidade Federal', 500, 500, 'https://seusistema.com/banners/congresso-tec.jpg', 'ativo'),
('b1a0c2d3-e4f5-4g6h-7i8j-9k0l1m2n3o4p', 'd529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'Maratona de Programação', 'Compita com os melhores programadores da região.', '2025-11-01 08:00:00', '2025-11-02 18:00:00', 'Centro de Inovação', 80, 80, 'https://seusistema.com/banners/maratona-prog.jpg', 'ativo'),
('e3e2c1a0-b9d8-4f7a-8e9c-7d6f5a4c3b21', 'b08d4b31-4a1d-444f-8368-80f48866175e', 'Curso de Culinária Italiana', 'Aprenda a fazer massas frescas e molhos tradicionais.', '2025-11-10 14:00:00', '2025-11-10 18:00:00', 'Escola de Gastronomia', 20, 20, 'https://seusistema.com/banners/curso-culinaria.jpg', 'ativo'),
('d5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g', 'd529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'Palestra sobre Empreendedorismo', 'Estratégias e desafios para empreendedores iniciantes.', '2025-11-25 19:30:00', '2025-11-25 21:30:00', 'Auditório Central', 120, 118, 'https://seusistema.com/banners/palestra-empreendedorismo.jpg', 'ativo'),
('a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'b08d4b31-4a1d-444f-8368-80f48866175e', 'Festival de Cervejas Artesanais', 'Degustação e food trucks no festival de cervejas.', '2025-12-05 18:00:00', '2025-12-07 23:00:00', 'Recife Antigo', 300, 299, 'https://seusistema.com/banners/festival-cerveja.jpg', 'ativo'),
('f6e5d4c3-b2a1-4a9d-8c7e-6f5d4a3b2c1d', 'd529f7b1-21c8-4b71-b8f9-4c919d30c58e', 'Exposição de Arte Moderna', 'Mostra de obras de artistas contemporâneos.', '2025-12-15 10:00:00', '2026-01-15 18:00:00', 'Museu de Arte', 500, 499, 'https://seusistema.com/banners/exposicao-arte.jpg', 'ativo'),
('d9c8b7a6-e5f4-4d3c-b2a1-0f9e8d7c6b5a', 'b08d4b31-4a1d-444f-8368-80f48866175e', 'Peça de Teatro Infantil', 'Peça para toda a família.', '2025-12-20 16:00:00', '2025-12-20 17:30:00', 'Teatro Santa Isabel', 150, 150, 'https://seusistema.com/banners/peca-teatro.jpg', 'ativo');

-- Insere preços para os eventos
INSERT INTO "PrecosEventos" (
  "precoId",
  "eventoId",
  "tipoIngresso",
  "valor"
) VALUES
('p1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'Ingresso Normal', 50.00),
('p2a2b3c4-e6f7-4a8b-9c0d-1e2f3a4b5c6d', 'e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'Meia Entrada', 25.00),
('p3f5e4d3-c2b1-4c9d-8e7f-6a5b4c3d2e1f', 'f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f', 'Ingresso Normal', 35.00),
('p4c9d8e7-f6a5-4c3d-b2e1-a0f9e8d7c6b5', 'f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f', 'VIP', 100.00),
('p5b1a0c2-d3e4-4g6h-7i8j-9k0l1m2n3o4p', 'd5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g', 'Ingresso Normal', 20.00),
('p6e3e2c1-a0b9-4f7a-8e9c-7d6f5a4c3b21', 'd5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g', 'Estudante', 10.00),
('p7d5d4c3-b2a1-4f8e-9a7c-6b5d4a3e2f1g', 'a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'Ingresso Normal', 60.00),
('p8a1b2c3-d4e5-4a7b-8c9d-1e2f3a4b5c6d', 'a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'Ingresso Antecipado', 45.00),
('p9f6e5d4-c3b2-4a9d-8c7e-6f5d4a3b2c1d', 'f6e5d4c3-b2a1-4a9d-8c7e-6f5d4a3b2c1d', 'Entrada Gratuita', 0.00),
('p0d9c8b7-a6e5-4d3c-b2a1-0f9e8d7c6b5a', 'd9c8b7a6-e5f4-4d3c-b2a1-0f9e8d7c6b5a', 'Ingresso Normal', 25.00);


-- Insere 10 inscrições em eventos, conectando usuários e preços
INSERT INTO "Inscricoes" (
  "usuarioId",
  "eventoId",
  "precoId",
  "status",
  "dataInscricao"
) VALUES
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'p1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'confirmada', '2025-09-05 10:00:00'),
('a9c8e7b6-d5a4-4c3d-b2e1-a0f9e8d7c6b5', 'e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b', 'p2a2b3c4-e6f7-4a8b-9c0d-1e2f3a4b5c6d', 'confirmada', '2025-09-06 11:30:00'),
('c1a0b9c8-d7e6-4f5a-8b9c-7d6e5f4a3b2c', 'f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f', 'p3f5e4d3-c2b1-4c9d-8e7f-6a5b4c3d2e1f', 'confirmada', '2025-09-20 15:00:00'),
('f8e7d6c5-b4a3-4b2e-a1d0-c9b8a7f6e5d4', 'f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f', 'p4c9d8e7-f6a5-4c3d-b2e1-a0f9e8d7c6b5', 'confirmada', '2025-09-22 17:00:00'),
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'd5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g', 'p5b1a0c2-d3e4-4g6h-7i8j-9k0l1m2n3o4p', 'confirmada', '2025-11-10 10:00:00'),
('a9c8e7b6-d5a4-4c3d-b2e1-a0f9e8d7c6b5', 'd5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g', 'p6e3e2c1-a0b9-4f7a-8e9c-7d6f5a4c3b21', 'confirmada', '2025-11-11 09:30:00'),
('c1a0b9c8-d7e6-4f5a-8b9c-7d6e5f4a3b2c', 'a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'p7d5d4c3-b2a1-4f8e-9a7c-6b5d4a3e2f1g', 'confirmada', '2025-11-25 14:00:00'),
('f8e7d6c5-b4a3-4b2e-a1d0-c9b8a7f6e5d4', 'a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d', 'p8a1b2c3-d4e5-4a7b-8c9d-1e2f3a4b5c6d', 'confirmada', '2025-11-26 18:00:00'),
('e3b2b1a0-e9c8-4b5a-9d8f-6c7e5d4a3b2c', 'f6e5d4c3-b2a1-4a9d-8c7e-6f5d4a3b2c1d', 'p9f6e5d4-c3b2-4a9d-8c7e-6f5d4a3b2c1d', 'confirmada', '2025-12-01 11:00:00'),
('a9c8e7b6-d5a4-4c3d-b2e1-a0f9e8d7c6b5', 'f6e5d4c3-b2a1-4a9d-8c7e-6f5d4a3b2c1d', 'p9f6e5d4-c3b2-4a9d-8c7e-6f5d4a3b2c1d', 'confirmada', '2025-12-02 12:00:00');

-- Atualiza as vagas restantes dos eventos
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'e1d3f4a5-b6c7-4d8e-a9b0-1c2d3e4f5a6b';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'f5e4d3c2-b1a0-4c9d-8e7f-6a5b4c3d2e1f';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'd5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'd5d4c3b2-a1e0-4f8e-9a7c-6b5d4a3e2f1g';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'a1b2c3d4-e5f6-4a7b-8c9d-1e2f3a4b5c6d';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'f6e5d4c3-b2a1-4a9d-8c7e-6f5d4a3b2c1d';
UPDATE "Eventos" SET "vagasRestantes" = "vagasRestantes" - 1 WHERE "eventoId" = 'f6e5d4c3-b2a1-4a9d-8c7e-6f5d4a3b2c1d';