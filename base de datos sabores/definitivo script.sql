DROP DATABASE IF EXISTS sabores_del_mundo;

-- Crear base de datos
CREATE DATABASE sabores_del_mundo;

-- Usar la base de datos
USE sabores_del_mundo;

-- Tabla Rol
CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla Permiso
CREATE TABLE permiso (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla RolPermiso (relación muchos a muchos)
CREATE TABLE rol_permiso (
    id_rol INT,
    id_permiso INT,
    PRIMARY KEY (id_rol, id_permiso),
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE,
    FOREIGN KEY (id_permiso) REFERENCES permiso(id_permiso) ON DELETE CASCADE
);

-- Tabla Usuario
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    fecha_registro DATETIME,
    id_rol INT NOT NULL,
    estado ENUM('activo', 'inactivo', 'suspendido') DEFAULT 'activo',
    foto_perfil VARCHAR(255),
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

-- Tabla Pais
CREATE TABLE pais (
    id_pais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo CHAR(2) NOT NULL UNIQUE,
    continente VARCHAR(50),
    bandera VARCHAR(255)
);

-- Tabla Categoria
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    imagen VARCHAR(255)
);

-- Tabla Receta
CREATE TABLE receta (
    id_receta INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tiempo_preparacion INT, -- en minutos
    tiempo_coccion INT, -- en minutos
    tiempo_total INT, -- en minutos
    porciones INT,
    dificultad ENUM('fácil', 'media', 'difícil') DEFAULT 'media',
    instrucciones TEXT,
    imagen VARCHAR(255),
    fecha_publicacion DATETIME,
    estado ENUM('publicada', 'borrador', 'archivada') DEFAULT 'publicada',
    id_usuario INT NOT NULL,
    id_categoria INT NOT NULL,
    id_pais INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

-- Tabla Etiqueta
CREATE TABLE etiqueta (
    id_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla RecetaEtiqueta (relación muchos a muchos)
CREATE TABLE receta_etiqueta (
    id_receta INT,
    id_etiqueta INT,
    PRIMARY KEY (id_receta, id_etiqueta),
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
    FOREIGN KEY (id_etiqueta) REFERENCES etiqueta(id_etiqueta) ON DELETE CASCADE
);

-- Tabla Ingrediente
CREATE TABLE ingrediente (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    imagen VARCHAR(255)
);

-- Tabla UnidadMedida
CREATE TABLE unidad_medida (
    id_unidad_medida INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    abreviatura VARCHAR(10) NOT NULL UNIQUE,
    tipo ENUM('volumen', 'peso', 'unidad') NOT NULL
);

-- Tabla RecetaIngrediente (relación muchos a muchos)
CREATE TABLE receta_ingrediente (
    id_receta INT,
    id_ingrediente INT,
    cantidad DECIMAL(10,2) NOT NULL,
    id_unidad_medida INT NOT NULL,
    notas VARCHAR(255),
    PRIMARY KEY (id_receta, id_ingrediente),
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente) ON DELETE RESTRICT,
    FOREIGN KEY (id_unidad_medida) REFERENCES unidad_medida(id_unidad_medida) ON DELETE RESTRICT
);

-- Tabla Paso
CREATE TABLE paso (
    id_paso INT AUTO_INCREMENT PRIMARY KEY,
    id_receta INT NOT NULL,
    numero_paso INT NOT NULL,
    descripcion TEXT NOT NULL,
    imagen VARCHAR(255),
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
    UNIQUE (id_receta, numero_paso)
);

-- Tabla Comentario
CREATE TABLE comentario (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_receta INT NOT NULL,
    id_usuario INT NOT NULL,
    texto TEXT NOT NULL,
    fecha DATETIME,
    estado ENUM('aprobado', 'pendiente', 'rechazado') DEFAULT 'aprobado',
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Valoracion
CREATE TABLE valoracion (
    id_valoracion INT AUTO_INCREMENT PRIMARY KEY,
    id_receta INT NOT NULL,
    id_usuario INT NOT NULL,
    puntuacion INT NOT NULL,
    fecha DATETIME,
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
    UNIQUE (id_receta, id_usuario)
);

-- Tabla Favorito (relación muchos a muchos)
CREATE TABLE favorito (
    id_usuario INT,
    id_receta INT,
    fecha_guardado DATETIME,
    PRIMARY KEY (id_usuario, id_receta),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE
);

INSERT INTO rol (nombre, descripcion) VALUES
('Administrador', 'Control total del sistema'),
('Editor', 'Puede crear y editar contenido'),
('Moderador', 'Puede moderar comentarios y valoraciones'),
('Usuario Premium', 'Usuario con beneficios adicionales'),
('Usuario Regular', 'Usuario con acceso básico'),
('Chef Verificado', 'Chef profesional verificado'),
('Nutricionista', 'Especialista en nutrición'),
('Bloguero Culinario', 'Creador de contenido gastronómico'),
('Estudiante Gastronomía', 'Estudiante de artes culinarias'),
('Invitado', 'Usuario no registrado con acceso limitado');

-- Insertar datos en la tabla permiso
INSERT INTO permiso (nombre, descripcion) VALUES
('crear_receta', 'Permiso para crear nuevas recetas'),
('editar_receta', 'Permiso para editar recetas existentes'),
('eliminar_receta', 'Permiso para eliminar recetas'),
('moderar_comentarios', 'Permiso para aprobar o rechazar comentarios'),
('gestionar_usuarios', 'Permiso para gestionar cuentas de usuario'),
('gestionar_categorias', 'Permiso para crear y editar categorías'),
('gestionar_etiquetas', 'Permiso para crear y editar etiquetas'),
('gestionar_ingredientes', 'Permiso para crear y editar ingredientes'),
('ver_estadisticas', 'Permiso para ver estadísticas del sistema'),
('exportar_datos', 'Permiso para exportar datos del sistema');

-- Insertar datos en la tabla rol_permiso
INSERT INTO rol_permiso (id_rol, id_permiso) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), -- Administrador tiene todos los permisos
(2, 1), (2, 2), (2, 6), (2, 7), (2, 8), -- Editor
(3, 4), (3, 9), -- Moderador
(4, 1), (4, 2), -- Usuario Premium
(5, 1), -- Usuario Regular
(6, 1), (6, 2), -- Chef Verificado
(7, 1), (7, 2), -- Nutricionista
(8, 1), (8, 2), -- Bloguero Culinario
(9, 1); -- Estudiante Gastronomía

-- Insertar datos en la tabla pais
INSERT INTO pais (nombre, codigo, continente, bandera) VALUES
('España', 'ES', 'Europa', 'espana.png'),
('México', 'MX', 'América', 'mexico.png'),
('Italia', 'IT', 'Europa', 'italia.png'),
('Japón', 'JP', 'Asia', 'japon.png'),
('India', 'IN', 'Asia', 'india.png'),
('Marruecos', 'MA', 'África', 'marruecos.png'),
('Perú', 'PE', 'América', 'peru.png'),
('Tailandia', 'TH', 'Asia', 'tailandia.png'),
('Francia', 'FR', 'Europa', 'francia.png'),
('Argentina', 'AR', 'América', 'argentina.png');

-- Insertar datos en la tabla categoria
INSERT INTO categoria (nombre, descripcion, imagen) VALUES
('Platos Principales', 'Platos que constituyen el centro de una comida', 'platos_principales.jpg'),
('Entrantes', 'Aperitivos y primeros platos', 'entrantes.jpg'),
('Postres', 'Dulces y postres de todo tipo', 'postres.jpg'),
('Sopas y Cremas', 'Caldos, sopas y cremas calientes o frías', 'sopas.jpg'),
('Ensaladas', 'Platos frescos a base de vegetales', 'ensaladas.jpg'),
('Panes y Masas', 'Recetas de panadería y masas', 'panes.jpg'),
('Bebidas', 'Bebidas con y sin alcohol', 'bebidas.jpg'),
('Salsas y Condimentos', 'Acompañamientos para realzar sabores', 'salsas.jpg'),
('Platos Veganos', 'Recetas sin ingredientes de origen animal', 'veganos.jpg'),
('Platos Vegetarianos', 'Recetas sin carne pero pueden incluir derivados animales', 'vegetarianos.jpg'),
('Cocina Festiva', 'Platos especiales para celebraciones', 'festiva.jpg');

-- Insertar datos en la tabla unidad_medida
INSERT INTO unidad_medida (nombre, abreviatura, tipo) VALUES
('Gramo', 'g', 'peso'),
('Kilogramo', 'kg', 'peso'),
('Mililitro', 'ml', 'volumen'),
('Litro', 'l', 'volumen'),
('Cucharadita', 'cdta', 'volumen'),
('Cucharada', 'cda', 'volumen'),
('Taza', 'tza', 'volumen'),
('Unidad', 'ud', 'unidad'),
('Pizca', 'pzc', 'peso'),
('Al gusto', 'ag', 'unidad');

-- Insertar datos en la tabla usuario
INSERT INTO usuario (nombre_usuario, email, contraseña, fecha_registro, id_rol, estado, foto_perfil) VALUES
('admin', 'admin@sabores.com', 'admin123', '2024-01-01 10:00:00', 1, 'activo', 'admin.jpg'),
('maria_chef', 'maria@ejemplo.com', 'maria123', '2024-01-15 14:30:00', 6, 'activo', 'maria.jpg'),
('carlos_editor', 'carlos@ejemplo.com', 'carlos123', '2024-01-20 09:45:00', 2, 'activo', 'carlos.jpg'),
('ana_nutricionista', 'ana@ejemplo.com', 'ana123', '2024-02-05 11:20:00', 7, 'activo', 'ana.jpg'),
('pedro_blogger', 'pedro@ejemplo.com', 'pedro123', '2024-02-10 16:15:00', 8, 'activo', 'pedro.jpg'),
('lucia_premium', 'lucia@ejemplo.com', 'lucia123', '2024-02-15 13:40:00', 4, 'activo', 'lucia.jpg'),
('juan_regular', 'juan@ejemplo.com', 'juan123', '2024-02-20 10:30:00', 5, 'activo', 'juan.jpg'),
('sofia_moderadora', 'sofia@ejemplo.com', 'sofia123', '2024-03-01 15:10:00', 3, 'activo', 'sofia.jpg'),
('diego_estudiante', 'diego@ejemplo.com', 'diego123', '2024-03-05 12:25:00', 9, 'activo', 'diego.jpg'),
('elena_chef', 'elena@ejemplo.com', 'elena123', '2024-03-10 09:50:00', 6, 'activo', 'elena.jpg'),
('carmen_regular', 'carmen@ejemplo.com', 'carmen123', '2024-03-20 11:35:00', 5, 'activo', 'carmen.jpg');

-- Insertar datos en la tabla ingrediente
INSERT INTO ingrediente (nombre, descripcion, imagen) VALUES
('Arroz', 'Grano básico para múltiples preparaciones', 'arroz.jpg'),
('Tomate', 'Fruto rojo versátil para salsas y ensaladas', 'tomate.jpg'),
('Cebolla', 'Bulbo aromático base de muchas recetas', 'cebolla.jpg'),
('Ajo', 'Bulbo aromático intenso', 'ajo.jpg'),
('Aceite de oliva', 'Aceite vegetal extraído de las olivas', 'aceite_oliva.jpg'),
('Pimentón', 'Condimento en polvo de color rojo intenso', 'pimenton.jpg'),
('Azafrán', 'Especia de color amarillo-anaranjado', 'azafran.jpg'),
('Pollo', 'Carne blanca de ave', 'pollo.jpg'),
('Gambas', 'Crustáceos marinos', 'gambas.jpg'),
('Mantequilla', 'Producto lácteo graso', 'mantequilla.jpg');

-- Insertar datos en la tabla etiqueta
INSERT INTO etiqueta (nombre, descripcion) VALUES
('Sin Gluten', 'Recetas que no contienen gluten'),
('Sin Lactosa', 'Recetas sin productos lácteos'),
('Bajo en Calorías', 'Recetas con menos de 300 calorías por porción'),
('Alto en Proteínas', 'Recetas con alto contenido proteico'),
('Apto para Niños', 'Recetas ideales para el público infantil'),
('Cocina Tradicional', 'Recetas de la gastronomía tradicional'),
('Cocina Fusión', 'Recetas que combinan diferentes tradiciones culinarias'),
('Cocina Rápida', 'Recetas que se preparan en menos de 30 minutos'),
('Cocina Gourmet', 'Recetas elaboradas de alta cocina'),
('Recetas Económicas', 'Recetas con ingredientes asequibles')
;
-- Insertar datos en la tabla receta
INSERT INTO receta (titulo, descripcion, tiempo_preparacion, tiempo_coccion, porciones, dificultad, instrucciones, imagen, id_usuario, id_categoria, id_pais) VALUES
('Paella Valenciana', 'Auténtica paella valenciana con pollo, conejo y verduras', 30, 45, 4, 'media', 'Instrucciones detalladas para preparar una auténtica paella valenciana...', 'paella.jpg', 2, 1, 1),
('Tacos al Pastor', 'Deliciosos tacos mexicanos con carne marinada', 40, 30, 6, 'media', 'Instrucciones para preparar tacos al pastor tradicionales...', 'tacos.jpg', 5, 1, 2),
('Risotto de Setas', 'Cremoso risotto italiano con variedad de setas', 15, 30, 4, 'media', 'Instrucciones para preparar un auténtico risotto italiano...', 'risotto.jpg', 10, 1, 3),
('Sushi Variado', 'Selección de diferentes tipos de sushi japonés', 60, 30, 4, 'difícil', 'Instrucciones detalladas para preparar diferentes tipos de sushi...', 'sushi.jpg', 4, 2, 4),
('Curry de Garbanzos', 'Curry vegetariano de garbanzos estilo indio', 15, 25, 4, 'fácil', 'Instrucciones para preparar un curry de garbanzos aromático...', 'curry.jpg', 6, 9, 5),
('Tajine de Cordero', 'Guiso marroquí de cordero con frutas secas', 30, 90, 6, 'media', 'Instrucciones para preparar un auténtico tajine marroquí...', 'tajine.jpg', 7, 1, 6),
('Ceviche Peruano', 'Pescado fresco marinado en limón al estilo peruano', 30, 0, 4, 'fácil', 'Instrucciones para preparar un ceviche peruano tradicional...', 'ceviche.jpg', 11, 2, 7),
('Pad Thai', 'Fideos de arroz salteados al estilo tailandés', 20, 15, 2, 'media', 'Instrucciones para preparar un auténtico pad thai...', 'padthai.jpg', 9, 1, 8),
('Croissants Caseros', 'Deliciosos croissants de mantequilla', 40, 20, 8, 'difícil', 'Instrucciones detalladas para preparar croissants caseros...', 'croissants.jpg', 3, 6, 9),
('Dumplings Chinos', 'Empanadillas al vapor rellenas de carne y verduras', 40, 25, 6, 'media', 'Instrucciones para preparar dumplings chinos tradicionales...', 'dumplings.jpg', 2, 2, 10);


-- Insertar datos en la tabla receta_etiqueta

INSERT INTO receta_etiqueta (id_receta, id_etiqueta) VALUES 
(1, 5),  -- Paella - Cocina Tradicional
(2, 4),  -- Paella - Recetas Festivas
(2, 5),  -- Tacos - Cocina Tradicional (mantenemos solo una instancia de 2,5)
(3, 5),  -- Risotto - Cocina Tradicional (mantenemos solo una instancia de 3,5)
(4, 5),  -- Sushi - Cocina Tradicional (mantenemos solo una instancia de 4,5)
(5, 1),  -- Curry - Sin Gluten
(5, 2);   -- Curry - Bajo en Calorías


-- Insertar datos en la tabla paso

INSERT INTO paso (id_receta, numero_paso, descripcion, imagen) VALUES 
(1, 1, 'Calentar el aceite en la paellera y dorar el pollo y el conejo.', 'paella_paso1.jpg'),
(1, 2, 'Añadir las verduras y sofreír hasta que estén tiernas.', 'paella_paso2.jpg'),
(1, 3, 'Incorporar el arroz y remover para que se impregne bien.', 'paella_paso3.jpg'),
(1, 4, 'Añadir el caldo caliente, el azafrán y el pimentón.', 'paella_paso4.jpg'),
(1, 5, 'Cocer a fuego medio-alto durante 10 minutos.', 'paella_paso5.jpg'),
(1, 6, 'Bajar el fuego y cocer 10 minutos más.', 'paella_paso6.jpg'),
(1, 7, 'Dejar reposar 5 minutos antes de servir.', 'paella_paso7.jpg'),
(2, 1, 'Marinar la carne con achiote, piña y especias durante al menos 2 horas.', 'tacos_paso1.jpg'),
(2, 2, 'Montar la carne en un trompo vertical o preparar en sartén.', 'tacos_paso2.jpg'),
(2, 3, 'Cocinar la carne hasta que esté dorada y tierna.', 'tacos_paso3.jpg'),
(2, 4, 'Cortar la carne en trozos pequeños.', 'tacos_paso4.jpg'),
(2, 5, 'Calentar las tortillas.', 'tacos_paso5.jpg'),
(2, 6, 'Servir la carne en las tortillas y añadir cebolla, cilantro y piña.', 'tacos_paso6.jpg'),
(3, 1, 'Limpiar y cortar las setas en trozos.', 'risotto_paso1.jpg'),
(3, 2, 'Sofreír la cebolla en aceite hasta que esté transparente.', 'risotto_paso2.jpg'),
(3, 3, 'Añadir las setas y cocinar hasta que suelten el agua.', 'risotto_paso3.jpg'),
(3, 4, 'Incorporar el arroz y remover para que se impregne bien.', 'risotto_paso4.jpg'),
(3, 5, 'Añadir el vino blanco y dejar que se evapore.', 'risotto_paso5.jpg'),
(3, 6, 'Ir añadiendo el caldo caliente poco a poco, removiendo constantemente.', 'risotto_paso6.jpg'),
(3, 7, 'Cuando el arroz esté al dente, añadir mantequilla y queso parmesano.', 'risotto_paso7.jpg'),
(3, 8, 'Servir inmediatamente.', 'risotto_paso8.jpg');


-- Insertar datos en la tabla receta_ingrediente


INSERT INTO receta_ingrediente (id_receta, id_ingrediente, cantidad, id_unidad_medida, notas) VALUES 
-- Ingredientes para Paella Valenciana 
(1, 1, 400, 1, 'Arroz bomba preferiblemente'), 
(1, 7, 0.5, 1, 'Unas hebras'), 
(1, 6, 1, 6, NULL), 
(1, 8, 300, 1, 'Troceado'), 
(1, 3, 1, 8, 'Grande'), 
(1, 1, 1, 8, 'Rojo'), 
(1, 5, 50, 3, 'Virgen extra'), 

-- Ingredientes para Tacos al Pastor 
(2, 17, 500, 1, 'Lomo de cerdo'), 
(2, 3, 1, 8, 'Morada'), 
(2, 21, 30, 1, 'Fresco'), 
(2, 15, 1, 8, 'Para exprimir'), 
(2, 19, 1, 8, 'Rojo'), 

-- Ingredientes para Risotto de Setas 
(3, 1, 300, 1, 'Arroz arborio o carnaroli'), 
(3, 3, 1, 8, 'Finamente picada'), 
(3, 4, 2, 8, 'Dientes'), 
(3, 5, 30, 3, 'Virgen extra'), 
(3, 14, 50, 1, 'Parmesano rallado');

;


-- Insertar datos en la tabla comentario
INSERT INTO comentario (id_receta, id_usuario, texto, fecha, estado) VALUES 
(1, 1, '¡Excelente receta! La paella quedó deliciosa y auténtica.', '2025-01-20 14:30:00', 'aprobado'), 
(1, 2, 'Muy buena, aunque le añadiría un poco más de azafrán.', '2025-01-25 10:15:00', 'aprobado'), 
(2, 3, 'Los tacos quedaron increíbles, el achiote le da un sabor especial.', '2025-02-05 19:45:00', 'aprobado'), 
(2, 4, 'Muy buenos, aunque prefiero añadir más cilantro.', '2025-02-10 13:20:00', 'aprobado'), 
(3, 1, 'El risotto quedó cremoso y con el punto perfecto.', '2025-02-15 20:30:00', 'aprobado'), 
(3, 2, 'Delicioso, pero requiere bastante tiempo de preparación.', '2025-02-20 11:45:00', 'aprobado'), 
(4, 3, 'El sushi quedó muy bien, aunque es complicado de hacer.', '2025-03-01 18:10:00', 'aprobado'), 
(4, 4, 'Excelente receta, muy detallada y fácil de seguir.', '2025-03-05 15:25:00', 'aprobado'), 
(5, 1, 'El curry quedó muy sabroso y es muy fácil de preparar.', '2025-03-10 12:40:00', 'aprobado'), 
(5, 2, 'Delicioso y muy aromático, lo repetiré seguro.', '2025-03-15 17:55:00', 'aprobado'), 
(5, 3, 'El tajine quedó muy sabroso, las frutas secas le dan un toque especial.', '2025-03-20 14:15:00', 'aprobado');

;

-- Insertar datos en la tabla valoracion
INSERT INTO valoracion (id_receta, id_usuario, puntuacion, fecha) VALUES
(1, 7, 5, '2025-01-20 14:35:00'),
(1, 9, 4, '2025-01-25 10:20:00'),
(1, 4, 5, '2025-01-30 16:45:00'),
(2, 6, 5, '2025-02-05 19:50:00'),
(2, 3, 4, '2025-02-10 13:25:00'),
(2, 2, 5, '2025-02-12 11:15:00'),
(3, 1, 5, '2025-02-15 20:35:00'),
(3, 5, 4, '2025-02-20 11:50:00'),
(3, 7, 4, '2025-02-22 15:40:00'),
(4, 7, 4, '2025-03-01 18:15:00')
;

-- Insertar datos en la tabla favorito
INSERT INTO favorito (id_usuario, id_receta, fecha_guardado) VALUES
(6, 1, '2025-01-22 10:15:00'),
(6, 3, '2025-02-18 14:30:00'),
(6, 5, '2025-03-12 16:45:00'),
(7, 2, '2025-02-08 11:20:00'),
(7, 4, '2025-03-03 15:35:00'),
(7, 6, '2025-03-22 17:50:00'),
(9, 1, '2025-01-27 12:25:00'),
(9, 3, '2025-02-24 16:40:00'),
(9, 5, '2025-03-14 18:55:00'),
(10, 2, '2025-02-14 13:30:00')
;


-- 1. Listar todas las recetas ordenadas por título
SELECT id_receta, titulo, dificultad, tiempo_total
FROM receta
ORDER BY titulo ASC;

-- 2. Mostrar todas las recetas de un país específico (España)
SELECT r.titulo, r.dificultad, r.porciones, p.nombre AS pais
FROM receta r
JOIN pais p ON r.id_pais = p.id_pais
WHERE p.nombre = 'España';

-- 3. Listar los usuarios con rol de Chef Verificado
SELECT u.id_usuario, u.nombre_usuario, u.email, r.nombre AS rol
FROM usuario u
JOIN rol r ON u.id_rol = r.id_rol
WHERE r.nombre = 'Chef Verificado';

-- 4. Mostrar las recetas con dificultad fácil
SELECT titulo, tiempo_preparacion, tiempo_coccion, porciones
FROM receta
WHERE dificultad = 'fácil';

-- 5. Contar el número de recetas por categoría
SELECT c.nombre AS categoria, COUNT(r.id_receta) AS total_recetas
FROM categoria c
LEFT JOIN receta r ON c.id_categoria = r.id_categoria
GROUP BY c.nombre
ORDER BY total_recetas DESC;

-- 6. Listar los ingredientes de una receta específica (Paella Valenciana)
SELECT r.titulo, i.nombre AS ingrediente, ri.cantidad, um.nombre AS unidad_medida
FROM receta r
JOIN receta_ingrediente ri ON r.id_receta = ri.id_receta
JOIN ingrediente i ON ri.id_ingrediente = i.id_ingrediente
JOIN unidad_medida um ON ri.id_unidad_medida = um.id_unidad_medida
WHERE r.titulo = 'Paella Valenciana';

-- 7. Mostrar las recetas que contienen un ingrediente específico (Arroz)
SELECT r.titulo, r.dificultad, r.tiempo_total
FROM receta r
JOIN receta_ingrediente ri ON r.id_receta = ri.id_receta
JOIN ingrediente i ON ri.id_ingrediente = i.id_ingrediente
WHERE i.nombre = 'Arroz';

-- 8. Listar los pasos de preparación de una receta específica (Risotto de Setas)
SELECT p.numero_paso, p.descripcion
FROM paso p
JOIN receta r ON p.id_receta = r.id_receta
WHERE r.titulo = 'Risotto de Setas'
ORDER BY p.numero_paso;

-- 9. Mostrar las recetas con etiqueta específica (Sin Gluten)
SELECT r.titulo, r.dificultad, e.nombre AS etiqueta
FROM receta r
JOIN receta_etiqueta re ON r.id_receta = re.id_receta
JOIN etiqueta e ON re.id_etiqueta = e.id_etiqueta
WHERE e.nombre = 'Sin Gluten';

-- 10. Listar las recetas con tiempo de preparación menor a 30 minutos
SELECT titulo, tiempo_preparacion, tiempo_coccion, tiempo_total, dificultad
FROM receta
WHERE tiempo_preparacion < 30
ORDER BY tiempo_preparacion;




