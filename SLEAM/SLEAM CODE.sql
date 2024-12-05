create database Sleam;

use	Sleam;


CREATE TABLE Usuarios (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    Nome VARCHAR(32) NOT NULL,
	Senha VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Data_nascimento DATE NOT NULL
);


CREATE TABLE Desenvolvedores (
    idDesenvolvedores INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Site_oficial INT
);


CREATE TABLE Jogos (
    idJogo INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Descricao TEXT,
    Preco DECIMAL(10, 2) NOT NULL,
    Data_lancamento DATE,
    Desenvolvedor_id INT,
    FOREIGN KEY (Desenvolvedor_id) REFERENCES Desenvolvedores(idDesenvolvedores)
);


CREATE TABLE Generos (
    idGeneros INT PRIMARY KEY NOT NULL,
    Nome VARCHAR(50) NOT NULL
);


CREATE TABLE Relacionamento_Jogos_e_Gêneros (
    Jogos_id INT NOT NULL,
    Generos_id INT NOT NULL,
    PRIMARY KEY (Jogos_id, Generos_id),
    FOREIGN KEY (Jogos_id) REFERENCES Jogos(idJogo),
    FOREIGN KEY (Generos_id) REFERENCES Generos(idGeneros)
);



CREATE TABLE Biblioteca_de_Jogos (
    usuario_id INT,
    jogo_id INT,
    PRIMARY KEY (usuario_id, jogo_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(idUsuario),
    FOREIGN KEY (jogo_id) REFERENCES Jogos(idJogo)
);

CREATE TABLE Amigos (
    usuario_id1 INT,
    usuario_id2 INT,
    PRIMARY KEY (usuario_id1, usuario_id2),
    FOREIGN KEY (usuario_id1) REFERENCES Usuarios(idUsuario),
    FOREIGN KEY (usuario_id2) REFERENCES Usuarios(idUsuario)
);


CREATE TABLE Compras (
    idCompras INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    usuario_id INT,
    jogo_id INT,
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(idUsuario),
    FOREIGN KEY (jogo_id) REFERENCES Jogos(idJogo)
);

-- mostra jogos dos usuraio--
SELECT 
    u.Nome AS Nome_Usuario,
    GROUP_CONCAT(j.Nome ORDER BY j.Nome ASC SEPARATOR ', ') AS Jogos
FROM 
    sleam.biblioteca_de_jogos bj
JOIN 
    sleam.usuarios u ON bj.usuario_id = u.idUsuario
JOIN 
    sleam.jogos j ON bj.jogo_id = j.idJogo
GROUP BY 
    u.Nome;


    
-- mostra genero dos jogos--

SELECT 
    j.Nome AS Nome_jogo,
    GROUP_CONCAT(g.Nome ORDER BY g.Nome ASC SEPARATOR ', ') AS Nome_genero
FROM 
    sleam.jogos_generos jg
JOIN 
    sleam.jogos j ON jg.jogo_id = j.idJogo
JOIN 
    sleam.generos g ON jg.genero_id = g.idGeneros
GROUP BY 
    j.Nome;


-- mostra as compras

SELECT 
    u.Nome AS Usuario,
    j.Nome AS Jogo,
    c.data_compra AS Data_Compra
FROM 
    sleam.compras C
JOIN 
    sleam.jogos j ON C.jogo_id = j.idJogo
JOIN 
    sleam.usuarios u ON C.usuario_id = u.idUsuario;


-- FAZER COMPRAS

INSERT INTO sleam.compras (usuario_id, jogo_id, data_compra)
VALUES (1, 9, NOW());	




-- DEFINIR O GENERO DE UM JOGO
INSERT INTO sleam.jogos_generos (jogo_id, genero_id)
VALUES 
(7, 4),  
(7, 1),  
(7, 5);  


-- CRIAR GENEROS
INSERT INTO sleam.generos(idGeneros, Nome)
values ( 9, "Crime");

-- CRIAR JOGOS 
INSERT INTO sleam.jogos(idJogo, Nome, Descricao, Preco, Data_lancamento, Desenvolvedor_id)
VALUES (10, 'Jogo de Aventura', 'Um emocionante jogo de aventura', '0', '2024-05-01', 123);

SELECT * FROM sleam.usuarios;


-- criar conta

-- usa uma func(nomeado por mim) para verificar se ja existe um email ou nome iguais e depois cria a conta caso nao tenha
CALL AddUserIfNotExists('Magodosgames', '154232', 'um.email@example.com', '2007-02-14');







SELECT * FROM sleam.biblioteca_de_jogos;

INSERT INTO sleam.biblioteca_de_jogos(usuario_id, jogo_id)
values ( 3 , 7);


DELETE FROM sleam.jogos
WHERE idJogo = 10;

    
SELECT * FROM sleam.jogos_generos;

INSERT INTO sleam.jogos_generos(jogo_id, genero_id)
values ( 7 , 1);

DELETE FROM sleam.jogos_generos
WHERE jogo_id = 7;

SELECT 
    j.Nome AS Nome_jogo,
    g.Nome Nome_genero
FROM 
    sleam.jogos_generos jg
JOIN 
    sleam.jogos j ON jg.jogo_id = j.idJogo
JOIN 
    sleam.generos g ON jg.genero_id = g.idGeneros;



SELECT * FROM sleam.generos;

SELECT * FROM sleam.jogos;

INSERT INTO sleam.jogos_generos (jogo_id, genero_id)
VALUES 
(7, 4),  
(7, 1),  
(7, 5);  

INSERT INTO sleam.jogos_generos (jogo_id, genero_id)
VALUES 
(8, 3),  
(8, 1),  
(8, 6), 
(8, 7);  

INSERT INTO sleam.jogos_generos (jogo_id, genero_id)
VALUES 
(9, 1),  
(9, 2),  
(9, 6),  
(9, 9);  


INSERT INTO sleam.generos(idGeneros, Nome)
values ( 9, "Crime");

UPDATE sleam.generos
SET Nome = 'Ficcao cientifica'
WHERE idGeneros = 5;

DELETE FROM sleam.generos
WHERE idJogo = 1;




SELECT * FROM sleam.compras;



INSERT INTO sleam.compras (usuario_id, jogo_id, data_compra)
VALUES (1, 9, NOW());	

    DELIMITER //
CREATE TRIGGER after_insert_compra
AFTER INSERT ON sleam.compras
FOR EACH ROW
BEGIN
    -- Verificar se o jogo já não está na biblioteca do usuário
    IF NOT EXISTS (
        SELECT 1
        FROM sleam.biblioteca_de_jogos bj
        WHERE bj.usuario_id = NEW.usuario_id
          AND bj.jogo_id = NEW.jogo_id
    ) THEN
        -- Inserir o jogo na biblioteca do usuário
        INSERT INTO sleam.biblioteca_de_jogos (usuario_id, jogo_id)
        VALUES (NEW.usuario_id, NEW.jogo_id);
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE AddUserIfNotExists(
    IN p_Nome VARCHAR(255),
    IN p_Senha VARCHAR(255),
    IN p_Email VARCHAR(255),
    IN p_Data_nascimento DATE
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM sleam.usuarios
        WHERE Nome = p_Nome
           OR Email = p_Email
    ) THEN
        INSERT INTO sleam.usuarios (Nome, Senha, Email, Data_nascimento)
        VALUES (p_Nome, p_Senha, p_Email, p_Data_nascimento);
    END IF;
END //

DELIMITER ;
