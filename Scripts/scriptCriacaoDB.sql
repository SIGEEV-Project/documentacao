
--
-- Exclusão de tabelas se existirem para permitir a reexecução do script
--
DROP TABLE IF EXISTS "Inscricoes" CASCADE;
DROP TABLE IF EXISTS "PrecosEventos" CASCADE;
DROP TABLE IF EXISTS "Eventos" CASCADE;
DROP TABLE IF EXISTS "HistoricoDePromocoes" CASCADE;
DROP TABLE IF EXISTS "Senhas" CASCADE;
DROP TABLE IF EXISTS "Usuarios" CASCADE;
DROP TYPE IF EXISTS "perfil_usuario" CASCADE;
DROP TYPE IF EXISTS "status_inscricao" CASCADE;
DROP TYPE IF EXISTS "status_evento" CASCADE;
DROP TYPE IF EXISTS "tipo_log_promocao" CASCADE;
DROP EXTENSION IF EXISTS "uuid-ossp";

--
-- Extensão para gerar UUIDs
--
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Tipos enumerados para perfis, status de eventos e inscrições
--
CREATE TYPE "perfil_usuario" AS ENUM ('participante', 'promotor', 'administrador');
CREATE TYPE "status_inscricao" AS ENUM ('pendente', 'confirmada', 'cancelada');
CREATE TYPE "status_evento" AS ENUM ('ativo', 'esgotado', 'inativo');
CREATE TYPE "tipo_log_promocao" AS ENUM ('promocao', 'rebaixamento');

--
-- Tabela de Usuários
--
CREATE TABLE "Usuarios" (
  "usuarioId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "primeiroNome" VARCHAR(50) NOT NULL,
  "ultimoNome" VARCHAR(100) NOT NULL,
  "email" VARCHAR(100) UNIQUE NOT NULL,
  "cpf" VARCHAR(11) UNIQUE NOT NULL,
  "telefone" VARCHAR(15),
  "dataNascimento" DATE,
  "logradouro" VARCHAR(100),
  "numeroEndereco" VARCHAR(10),
  "cidade" VARCHAR(50),
  "estado" CHAR(2),
  "cep" VARCHAR(9),
  "perfil" perfil_usuario NOT NULL DEFAULT 'participante',
  "status" VARCHAR(20) NOT NULL DEFAULT 'ativo',
  "dataCadastro" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "dataUltimoLogin" TIMESTAMP WITH TIME ZONE,
  "dataAlteracao" TIMESTAMP WITH TIME ZONE,
  "dataExclusao" TIMESTAMP WITH TIME ZONE,
  "dataReativacao" TIMESTAMP WITH TIME ZONE,
  "tokenRecuperacao" TEXT,
  "tokenRecuperacaoExpiraEm" TIMESTAMP WITH TIME ZONE
);

-- Índices para melhor desempenho em consultas
CREATE INDEX idx_usuarios_email ON "Usuarios" ("email");
CREATE INDEX idx_usuarios_cpf ON "Usuarios" ("cpf");

--
-- Tabela de Senhas (separada por segurança)
--
CREATE TABLE "Senhas" (
  "senhaId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "usuarioId" UUID NOT NULL,
  "senhaHash" TEXT NOT NULL,
  "dataCriacao" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY ("usuarioId") REFERENCES "Usuarios" ("usuarioId") ON DELETE CASCADE
);

--
-- Tabela de Histórico de Promoções/Rebaixamentos (para auditoria)
--
CREATE TABLE "HistoricoDePromocoes" (
  "historicoId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "usuarioId" UUID NOT NULL,
  "adminId" UUID NOT NULL,
  "tipoAcao" tipo_log_promocao NOT NULL,
  "perfilAntigo" perfil_usuario,
  "perfilNovo" perfil_usuario NOT NULL,
  "dataAcao" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY ("usuarioId") REFERENCES "Usuarios" ("usuarioId") ON DELETE CASCADE,
  FOREIGN KEY ("adminId") REFERENCES "Usuarios" ("usuarioId") ON DELETE CASCADE
);

--
-- Tabela de Eventos
--
CREATE TABLE "Eventos" (
  "eventoId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "promotorId" UUID NOT NULL,
  "titulo" VARCHAR(100) NOT NULL,
  "descricao" TEXT,
  "dataInicio" TIMESTAMP WITH TIME ZONE NOT NULL,
  "dataFim" TIMESTAMP WITH TIME ZONE NOT NULL,
  "local" VARCHAR(100),
  "capacidade" INTEGER NOT NULL,
  "vagasRestantes" INTEGER NOT NULL,
  "bannerUrl" TEXT,
  "status" status_evento NOT NULL DEFAULT 'ativo',
  "dataCriacao" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "dataAtualizacao" TIMESTAMP WITH TIME ZONE,
  "dataExclusao" TIMESTAMP WITH TIME ZONE,
  FOREIGN KEY ("promotorId") REFERENCES "Usuarios" ("usuarioId") ON DELETE CASCADE
);

-- Índices para melhor desempenho em consultas
CREATE INDEX idx_eventos_promotorId ON "Eventos" ("promotorId");
CREATE INDEX idx_eventos_dataInicio ON "Eventos" ("dataInicio");
CREATE INDEX idx_eventos_local ON "Eventos" ("local");

--
-- Tabela de Preços de Eventos (para flexibilidade de tipos de ingresso)
--
CREATE TABLE "PrecosEventos" (
  "precoId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "eventoId" UUID NOT NULL,
  "tipoIngresso" VARCHAR(50) NOT NULL, -- Ex: 'Meia Entrada', 'Área VIP'
  "valor" DECIMAL(10, 2) NOT NULL,
  "disponivel" BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY ("eventoId") REFERENCES "Eventos" ("eventoId") ON DELETE CASCADE
);

--
-- Tabela de Inscrições
--
CREATE TABLE "Inscricoes" (
  "inscricaoId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "usuarioId" UUID NOT NULL,
  "eventoId" UUID NOT NULL,
  "precoId" UUID, -- Ligação com o tipo de preço escolhido
  "dataInscricao" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "dataCancelamento" TIMESTAMP WITH TIME ZONE,
  "status" status_inscricao NOT NULL DEFAULT 'pendente',
  FOREIGN KEY ("usuarioId") REFERENCES "Usuarios" ("usuarioId") ON DELETE CASCADE,
  FOREIGN KEY ("eventoId") REFERENCES "Eventos" ("eventoId") ON DELETE CASCADE,
  FOREIGN KEY ("precoId") REFERENCES "PrecosEventos" ("precoId") ON DELETE SET NULL,
  UNIQUE ("usuarioId", "eventoId")
);

-- Índices para melhor desempenho em consultas
CREATE INDEX idx_inscricoes_usuarioId ON "Inscricoes" ("usuarioId");
CREATE INDEX idx_inscricoes_eventoId ON "Inscricoes" ("eventoId");
CREATE INDEX idx_inscricoes_dataInscricao ON "Inscricoes" ("dataInscricao");
CREATE INDEX idx_inscricoes_status ON "Inscricoes" ("status");