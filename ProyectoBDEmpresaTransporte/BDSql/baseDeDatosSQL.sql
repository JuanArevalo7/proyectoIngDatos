CREATE DATABASE CONSTRUCTORA;
USE CONSTRUCTORA;
CREATE TABLE CONDUCTOR(
idConductor INT AUTO_INCREMENT PRIMARY KEY,
nombreConductor VARCHAR(20) not null,
docConductor BIGINT NOT NULL UNIQUE,
numViajes BIGINT DEFAULT 0,
numMultas BIGINT DEFAULT 0,
numeroContacto BIGINT NOT NULL,
EpsConductor varchar(20) null
);

CREATE TABLE VEHICULO(
idVehiculo int AUTO_INCREMENT PRIMARY KEY,
placaVehiculo varchar(10) UNIQUE NOT NULL,
colorVehiculo VARCHAR(20) NOT NULL,
marcaVehiculo VARCHAR(20) NOT NULL,
cantidadReparaciones INT DEFAULT 0,
estadoVehiculo ENUM("activo","inactivo") NOT NULL,
valorImpuesto DOUBLE(12,3) NOT NULL,
SoatVehiculo ENUM("pendiente","activo") NOT NULL
);

CREATE TABLE CLIENTE(
idCLiente int PRIMARY KEY AUTO_INCREMENT,
docCliente BIGINT NULL,
contactoCliente bigint NULL,
tipoCliente ENUM("natural","juridico"), /*juridico hace referencia a las empresas*/
nombreCliente VARCHAR(20) NOT NULL
);

CREATE TABLE VIAJE(
idViaje INT AUTO_INCREMENT PRIMARY KEY,
lugarDestino varchar(20) NOT NULL,
lugarOrigen varchar(20) NOT NULL,
duracionEstimada varchar(20) NOT NULL,
numEscalas BIGINT DEFAULT 0);

CREATE TABLE GASTO(
idGasto INT PRIMARY KEY AUTO_INCREMENT,
descripcionGasto VARCHAR(20) NOT NULL,
tipoGasto int NOT NULL
);


CREATE TABLE FACTURA(
idFactura INT AUTO_INCREMENT PRIMARY KEY,
valorViaje double(15,3) NOT NULL,
utilidadesViaje double (15,3) NOT NULL,
idCLienteFK int ,
idConductorFK int,
idViajeFK int  ,
idVehiculoFK INT ,
CONSTRAINT llaveCliente FOREIGN KEY(idCLienteFK) REFERENCES CLIENTE(idCliente) ON DELETE SET NULL,
CONSTRAINT llaveConductor FOREIGN KEY(idConductorFK) REFERENCES conductor(IdCOnductor) ON DELETE SET NULL,
CONSTRAINT llaveViaje FOREIGN KEY(idViajeFK) REFERENCES viaje(IdViaje) ON DELETE SET NULL,
CONSTRAINT llaveVehiculo FOREIGN KEY(idVehiculoFK) REFERENCES vehiculo(IdVehiculo) ON DELETE SET NULL
);

CREATE TABLE gastoFactura(
idRegistro INT PRIMARY KEY AUTO_INCREMENT,
valorGasto DOUBLE(11,3) NOT NULL,
idFacturaFK INT,
idGastoFK INT ,
CONSTRAINT llaveFacturaFK FOREIGN KEY(idFacturaFK) REFERENCES factura(idFactura) ON DELETE SET NULL,
CONSTRAINT llaveGastoFK FOREIGN KEY(idGastoFK) REFERENCES gasto(idGasto) ON DELETE SET NULL
);

ALTER TABLE CONDUCTOR 
ADD COLUMN estadoConductor ENUM("activo","inactivo") not null;
ALTER TABLE GASTO
ADD COLUMN nombreGasto varchar(20) not null;
ALTER TABLE GASTO
MODIFY COLUMN descripcionGasto varchar(40) not null;
/* CREACION DE VISTA PARA VEHICULOS ACTIVOS E INACTIVOS*/
CREATE VIEW vehiculosInactivos as 
SELECT * FROM vehiculo where estadoVehiculo = 'inactivo';

CREATE VIEW vehiculosActivos as 
SELECT * FROM vehiculo where estadoVehiculo='activo';
/* CREACION DE VISTA PARA CONDUCTORES ACTIVOS E INACTIVOS */
CREATE VIEW conductoresActivos as
SELECT * from conductor where estadoConductor='activo';
CREATE VIEW conductoresInactivos as
SELECT * FROM conductor where estadoConductor='inactivo';
/* consultar el mayor gasto de una factura*/
DELIMITER $$
CREATE PROCEDURE consultarMayorGasto(in idFactura int)
BEGIN 
SELECT idFacturaFK  as "numero de factura",valorGasto,g.nombreGasto,g.descripcionGasto FROM gastofactura
INNER JOIN gasto g on idGastoFK=idGasto
where idFacturaFK=idFactura
order by valorGasto desc LIMIT 1;
END $$
DELIMITER ;
CALL consultarMayorGasto(1);
/* PROCEDURE PARA CONSULTAR CONDUCTOR POR ID*/
DELIMITER $$
CREATE PROCEDURE consultarConductor(in idCon int)
BEGIN 
SELECT * FROM CONDUCTOR
WHERE idConductor=idCon;
END $$
DELIMITER ;
/*CONSULTAR EPS CONDUCTOR POR ID*/
DELIMITER $$
CREATE PROCEDURE consultarEPS(in idCon int)
BEGIN 
SELECT nombreConductor,docConductor,EpsConductor FROM CONDUCTOR
WHERE idConductor=idCon;
END $$
DELIMITER ;
DELIMITER $$
CALL consultarEPS(1);
CREATE PROCEDURE actualizarEPS (IN idModif int, nuevaEPs varchar(20))
BEGIN 
UPDATE conductor
SET EpsConductor=nuevaEps WHERE idConductor=idModif;
END $$
DELIMITER ;
/*CREATE PROCEDURE ACTUALIZAR CONTACTO*/
DELIMITER $$
CREATE PROCEDURE actualizarCont(in idConduct INT,nuevoCont BIGINT)
BEGIN
UPDATE conductor
SET numeroContacto=nuevoCont
WHERE idConduct=idConductor;
END $$
DELIMTIER ;
DELIMITER $$
CREATE PROCEDURE actualizarDur(IN idCambio INT,durNueva varchar(20))
BEGIN
UPDATE viaje
SET duracionEstimada=durNueva
WHERE idCambio=idViaje;
END $$
DELIMITER ;
DELIMITER $$
CREATE PROCEDURE actualizarEsc(IN idCambio INT,escalas bigint)
BEGIN
UPDATE viaje
SET numEscalas=escalas
WHERE idCambio=idViaje;
END $$
DELIMITER ;
DELIMITER $$
CREATE PROCEDURE cambiarEstado(IN idCambio INT,estado varchar(20))
BEGIN
UPDATE vehiculo
SET estadoVehiculo=estado
WHERE idVehiculo=idCambio;
END $$
DELIMITER ;
DELIMITER $$
CREATE PROCEDURE cambiarSoat(IN idCambio INT,estado varchar(20))
BEGIN
UPDATE vehiculo
SET SoatVehiculo=estado
WHERE idVehiculo=idCambio;
END $$
DELIMITER ;
/*view de viajes */
CREATE VIEW viajesLargos as 
SELECT lugarDestino,lugarOrigen,duracionEstimada FROM VIAJE WHERE
duracionEstimada like "%dia%";
SELECT * FROM viajesLargos;
/* MEJOR VISUALIZACION DE LAS FACTURAS*/
CREATE VIEW facturaCompleta as
SELECT f.valorViaje,f.utilidadesVIaje,v.lugarOrigen,v.lugarDestino,c.nombreConductor as "conductor" ,cl.nombreCliente ,ve.marcaVehiculo,
ve.placaVehiculo  FROM factura f 
INNER JOIN viaje v on v.idVIaje=f.idViajeFK
INNER JOIN conductor c on c.idConductor=f.idConductorFK
INNER JOIN vehiculo ve on ve.idVehiculo=f.idVehiculoFK
INNER JOIN cliente cl on cl.idCliente=f.idCLienteFK;
CREATE VIEW mejorClientes as
SELECT idClienteFK as "id cliente",sum(valorviaje) as "total que ha pagado a la empresa"  FROM FACTURA
GROUP BY idClienteFK ORDER BY  sum(valorviaje)  DESC LIMIT 5;
/* TRIGGER PARA AÑADIR REPARACIONES A UN VEHICULO AUTOMATICAMENTE*/ 
DELIMITER $$
CREATE TRIGGER añadirReparaciones AFTER INSERT ON gastoFactura FOR EACH ROW
BEGIN 
IF (SELECT tipoGasto FROM gasto WHERE idGasto = NEW.idGastoFK)=1 THEN 
UPDATE VEHICULO 
SET cantidadReparaciones=cantidadReparaciones+1 WHERE idVehiculo=(select idVehiculoFK from factura
where idFactura=new.idFacturaFK);
END IF;
END $$
DELIMITER ;
/* TRIGGER PARA AÑADIR MULTAS A UN CONDCTOR */
DELIMITER $$
CREATE TRIGGER añadirMultas AFTER INSERT ON gastoFactura FOR EACH ROW
BEGIN 
 IF (SELECT tipoGasto FROM gasto WHERE idGasto = NEW.idGastoFK) = 2 THEN
UPDATE conductor
SET numMultas=numMultas+1 WHERE idConductor=(select idConductorFK from factura
where idFactura=new.idFacturaFK);
END IF;
END $$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER añadirViaje AFTER INSERT ON Factura FOR EACH ROW
BEGIN 
UPDATE conductor
SET numViajes=numViajes+1 WHERE idConductor=new.idConductorFK;
END $$
DELIMITER ;
INSERT INTO CLIENTE (docCliente, contactoCliente, tipoCliente, nombreCliente) VALUES
(1023456789, 3124567890, 'juridico', 'TransRisaralda'),(2234567890, 3135678901, 'juridico', 'CCM Ingenieros'),
(3345678901, 3146789012, 'juridico', 'INVERTRANS'),(4456789012, 3157890123, 'juridico', 'OLT'),
(5567890123, 3168901234, 'juridico', 'ALITRANS'),(6678901234, 3179012345, 'juridico', 'TRANSPCOL'),
(7789012345, 3180123456, 'juridico', 'LOGYSTEL'),(8890123456, 3191234567, 'juridico', 'SERVIENTREGA'),
(9901234567, 3202345678, 'juridico', 'DEPRISA'),(1012345678, 3213456789, 'juridico', 'JYM'),
(1345678901, 3246789012, 'natural', 'Sergio Peña'),(1456789012, 3257890123, 'juridico', 'MENSAJEROS URBANOS'),
(1567890123, 3268901234, 'natural', 'Paola Rios'),(1678901234, 3279012345, 'juridico', 'INVERCORP'),
(1789012345, 3280123456, 'natural', 'Luis Moreno'),(1890123456, 3291234567, 'juridico', 'TRANSPORTES DEL SUR'),(1901234567, 3302345678, 'natural', 'Andrea Silva'),
(2012345678, 3313456789, 'juridico', 'COLOMBIAEXPRESS'),(2123456789, 3324567890, 'natural', 'Camilo Torres'),
(2234567891, 3335678901, 'juridico', 'ENVIA EXPRESS'),(2345678902, 3346789012, 'natural', 'Lorena Mejía'),
(2456789013, 3357890123, 'juridico', 'RAPPI'),(2567890124, 3368901234, 'natural', 'Diego Vargas'),
(2678901235, 3379012345, 'juridico', 'ENTREGAS RAPIDAS'),(2789012346, 3380123456, 'natural', 'Marcela Quintero'),
(2890123457, 3391234567, 'juridico', 'MOVILCARGA'),(2901234568, 3402345678, 'natural', 'Ricardo Castaño'),
(3012345679, 3413456789, 'juridico', 'FASTCOURIER'),(3123456780, 3424567890, 'natural', 'Sara Medina'),
(3234567891, 3435678901, 'juridico', 'NOVA CARGA'),(3345678902, 3446789012, 'natural', 'Jorge Acosta'),
(3456789013, 3457890123, 'juridico', 'MENSAJEROS SIGLO XXI'),(3567890124, 3468901234, 'natural', 'Tatiana Mora'),
(3678901235, 3479012345, 'juridico', 'ENVIEXPRESS'),(3789012346, 3480123456, 'natural', 'Esteban Prada'),
(3890123457, 3491234567, 'juridico', 'EXPRESOS DEL VALLE'),(3901234568, 3502345678, 'natural', 'Daniela Niño'),
(4012345679, 3513456789, 'juridico', 'ENTREGA TOTAL'),(4123456780, 3524567890, 'natural', 'Nicolás Rueda'),
(4234567891, 3535678901, 'juridico', 'TRANSANDINA'),(4345678902, 3546789012, 'natural', 'Manuela Cely'),
(4456789013, 3557890123, 'juridico', 'CARGO LINE'),(4567890124, 3568901234, 'natural', 'Felipe Gil'),
(4678901235, 3579012345, 'juridico', 'FLYTRANS'),(4789012346, 3580123456, 'natural', 'Valentina Pardo'),
(4890123457, 3591234567, 'juridico', 'LOGICARGO'),(4901234568, 3602345678, 'natural', 'Juanita Ramírez'),
(5012345679, 3613456789, 'juridico', 'REDEX COURIER');


select * from cliente;
INSERT INTO gasto (descripcionGasto, tipoGasto, nombreGasto) VALUES
-- Reparaciones (tipoGasto = 1)
('Cambio de aceite y filtro', 1, 'Aceite'),('Reparacion de frenos delanteros', 1, 'Frenos Delante'),
('Cambio de correa de distribucion', 1, 'Correa'),('Alineacion y balanceo completo', 1, 'Alineacion'),
('Reparacion de suspension trasera', 1, 'Suspension'),('Reparacion del sistema de escape', 1, 'Escape'),
('Cambio de bujias desgastadas', 1, 'Bujias'),('Mantenimiento general del motor', 1, 'Mantenimiento'),
('Reparacion del sistema electrico', 1, 'Electrico'),('Reemplazo de amortiguadores', 1, 'Amortiguad'),
('Reparacion de caja de cambios', 1, 'CajaCambios'),('Sustitucion de parabrisas agrietado', 1, 'Parabrisas'),
('Reparacion de ventanilla electrica', 1, 'Ventanilla'),('Arreglo de maletero y cierres', 1, 'Maletero'),
('Cambio de discos de freno', 1, 'DiscosFreno'),('Sustitucion de pastillas de freno', 1, 'Pastillas'),
('Reparacion de sistema de refrigeracion', 1, 'Refrigeracion'),('Ajuste de direccion asistida', 1, 'Direccion'),
('Ajuste en sistema de inyeccion', 1, 'Inyeccion'),('Servicio mecanico completo', 1, 'ServicioMeca'),

-- Multas (tipoGasto = 2)
('Multa por exceso de velocidad', 2, 'Velocidad'),('Multa por estacionamiento indebido', 2, 'Estacionamien'),
('Multa por no respetar semaforos', 2, 'Semaforos'),('Multa por uso de celular al conducir', 2, 'Celular'),
('Multa por circular en carril prohibido', 2, 'Carril'),('Multa por no usar cinturón de seguridad', 2, 'Cinturon'),
('Multa por fallo en registro vehicular', 2, 'Registro'),('Multa por infraccion de transito', 2, 'Infraccion'),
('Multa por incumplimiento en señalizacion', 2, 'Senalizacion'),('Multa por obstaculos en via', 2, 'Obstaculos'),
('Multa por obstruccion de paso peatonal', 2, 'Obstruccion'),('Multa por exceso de carga vehicular', 2, 'ExcesoCarga'),
('Multa por no detenerse en stop', 2, 'Stop'),('Multa por circulacion en via restringida', 2, 'Restringida'),
('Multa por maniobra peligrosa', 2, 'Maniobra'),

-- Otros gastos (tipoGasto = 3)
('Pago de peaje en autopista', 3, 'Peaje'),('Gastos administrativos del vehiculo', 3, 'Administ'),
('Compra de accesorios varios', 3, 'Accesorios'),('Pago por estacionamiento prolongado', 3, 'Estaciona'),
('Actualizacion de senal y espejos', 3, 'SenalEspej'),('Pago de matricula anual', 3, 'Matricula'),
('Gastos de limpieza y lavado', 3, 'Limpieza'),('Pago de peaje urbano', 3, 'PeajeUrb'),('Coste de gestorias legales', 3, 'Gestoria'),
('Costo de afianzamiento vehicular', 3, 'Afianza'),('Compra de herramientas de taller', 3, 'Herramientas'),
('Pago de licencias y permisos', 3, 'Licencias'),('Gastos en publicidad y marketing', 3, 'Publicidad'),
('Pago de servicios de rastreo GPS', 3, 'Rastreo'),('Otros gastos imprevistos operativos', 3, 'Imprevistos');
INSERT INTO viaje (lugarDestino, lugarOrigen, duracionEstimada, numEscalas) VALUES
('Bogotá', 'Pasto', '4 horas y 30 min', 3),('Medellín', 'Barranquilla', '2 días', 1),
('Cali', 'Armenia', '6 horas', 0),('Tunja', 'Villavicencio', '1 día y 2 horas', 2),
('Cartagena', 'Montería', '5 horas y 15 min', 0),('Manizales', 'Ibagué', '3 horas', 1),
('Bucaramanga', 'Neiva', '2 días y 6 horas', 2),('Pereira', 'Santa Marta', '1 día', 1),
('Cúcuta', 'Bogotá', '16 horas', 3),('Quibdó', 'Turbo', '10 horas y 20 min', 1),
('Barrancabermeja', 'Cali', '18 horas', 2),('Popayán', 'Florencia', '9 horas', 0),
('Leticia', 'Puerto Nariño', '3 horas en lancha', 0),('Yopal', 'Arauca', '12 horas', 1),
('Riohacha', 'Valledupar', '7 horas', 0),('Sincelejo', 'Cartagena', '4 horas', 1),
('Palmira', 'Jamundí', '1 hora', 0),('Zipaquirá', 'Bogotá', '1 hora y 15 min', 0),
('Fusagasugá', 'Melgar', '2 horas', 0),('Sogamoso', 'Tunja', '3 horas y 10 min', 0),
('Pamplona', 'Cúcuta', '5 horas', 1),('Ipiales', 'Pasto', '1 hora y 30 min', 0),
('Tuluá', 'Buga', '1 hora', 0),('Chía', 'Girardot', '3 horas y 30 min', 1),
('Floridablanca', 'Bucaramanga', '40 min', 0),('La Dorada', 'Honda', '1 hora', 0),
('Aguachica', 'Ocaña', '2 horas', 0),('Montelíbano', 'Sincelejo', '6 horas', 1),
('San Gil', 'Barrancabermeja', '4 horas', 0),('Mocoa', 'Florencia', '7 horas y 45 min', 1),
('Guaduas', 'Bogotá', '2 horas', 0),('Sahagún', 'Montería', '2 horas', 0),
('Villanueva', 'San Juan del Cesar', '1 hora', 0),('Socorro', 'San Gil', '1 hora y 30 min', 0),
('El Banco', 'Valledupar', '5 horas', 1),('Turbo', 'Apartadó', '1 hora', 0),
('Cereté', 'Montería', '30 min', 0),('Chigorodó', 'Turbo', '45 min', 0),
('Pitalito', 'Neiva', '7 horas y 30 min', 1),('Riosucio', 'Pereira', '8 horas', 1),
('Ciénaga', 'Santa Marta', '1 hora', 0),('Sibaté', 'Bogotá', '1 hora y 20 min', 0),
('Madrid', 'Funza', '30 min', 0),('La Calera', 'Bogotá', '1 hora', 0),
('Puerto Asís', 'Mocoa', '6 horas', 1),('San José Guaviare', 'Villavicencio', '10 horas', 2),
('Tierralta', 'Montería', '2 horas', 0),('Arauquita', 'Arauca', '3 horas', 0),
('Puerto López', 'Villavicencio', '2 horas', 0),('La Vega', 'Facatativá', '1 hora', 0);

INSERT INTO vehiculo (placaVehiculo, colorVehiculo, marcaVehiculo, cantidadReparaciones, estadoVehiculo, valorImpuesto, SoatVehiculo) VALUES
('SLF799', 'Rojo', 'KIA', 1, 'Activo', 95000, 'Pendiente'),('SLF044', 'Negro', 'Mazda', 0, 'Activo', 87000, 'Activo'),
('SJP614', 'Blanco', 'Chevrolet', 3, 'Inactivo', 120000, 'Pendiente'),('SDN758', 'Gris', 'Hyundai', 2, 'Activo', 110000, 'Activo'),
('BRL123', 'Rojo', 'Renault', 0, 'Activo', 83000, 'Activo'),('FGH456', 'Azul', 'Toyota', 0, 'Inactivo', 105000, 'Pendiente'),
('MNB789', 'Negro', 'Nissan', 4, 'Activo', 99000, 'Activo'),('QWE234', 'Verde', 'Ford', 1, 'Activo', 98000, 'Pendiente'),
('ASD567', 'Blanco', 'Volkswagen', 0, 'Inactivo', 89000, 'Activo'),('ZXC890', 'Gris', 'KIA', 2, 'Activo', 102000, 'Pendiente'),
('JKL321', 'Rojo', 'Hyundai', 5, 'Activo', 150000, 'Activo'),('UIO654', 'Amarillo', 'Mazda', 0, 'Activo', 92000, 'Pendiente'),
('BNM987', 'Azul', 'Chevrolet', 0, 'Inactivo', 91000, 'Activo'),('TGB159', 'Negro', 'Renault', 3, 'Activo', 132000, 'Pendiente'),
('YHN753', 'Gris', 'Toyota', 1, 'Activo', 97000, 'Activo'),('EDC852', 'Blanco', 'Nissan', 0, 'Activo', 85000, 'Activo'),
('WSX951', 'Verde', 'KIA', 2, 'Inactivo', 115000, 'Pendiente'),('RFV357', 'Rojo', 'Ford', 0, 'Activo', 94000, 'Activo'),
('TGB258', 'Azul', 'Mazda', 4, 'Activo', 140000, 'Pendiente'),('YHN456', 'Gris', 'Hyundai', 1, 'Inactivo', 118000, 'Pendiente'),
('UJM654', 'Blanco', 'Chevrolet', 0, 'Activo', 96000, 'Activo'),('IKM741', 'Negro', 'Volkswagen', 3, 'Activo', 125000, 'Pendiente'),
('OLP369', 'Rojo', 'Renault', 0, 'Inactivo', 87000, 'Activo'),('AQW147', 'Amarillo', 'Toyota', 1, 'Activo', 102000, 'Pendiente'),
('SWD258', 'Gris', 'Nissan', 2, 'Activo', 112000, 'Activo'),('XED369', 'Verde', 'Ford', 0, 'Activo', 89000, 'Pendiente'),
('CVF741', 'Azul', 'KIA', 3, 'Inactivo', 135000, 'Activo'),('BGY852', 'Rojo', 'Mazda', 0, 'Activo', 93000, 'Activo'),
('NHU963', 'Negro', 'Hyundai', 4, 'Activo', 145000, 'Pendiente'),('MKO159', 'Blanco', 'Chevrolet', 1, 'Inactivo', 120000, 'Activo'),
('PLM357', 'Gris', 'Volkswagen', 0, 'Activo', 91000, 'Pendiente'),('QAZ456', 'Verde', 'Renault', 0, 'Activo', 86000, 'Activo'),
('WSX789', 'Azul', 'Toyota', 5, 'Inactivo', 175000, 'Pendiente'),('EDC123', 'Negro', 'Nissan', 1, 'Activo', 98000, 'Activo'),
('RFV456', 'Rojo', 'KIA', 2, 'Activo', 99000, 'Pendiente'),('TGB789', 'Amarillo', 'Mazda', 0, 'Inactivo', 87000, 'Activo'),
('YHN951', 'Gris', 'Hyundai', 3, 'Activo', 130000, 'Pendiente'),('UJM123', 'Blanco', 'Chevrolet', 1, 'Activo', 97000, 'Activo'),
('IKM456', 'Negro', 'Volkswagen', 2, 'Inactivo', 108000, 'Pendiente'),('OLP789', 'Rojo', 'Ford', 0, 'Activo', 92000, 'Activo'),
('AQW963', 'Verde', 'Renault', 3, 'Activo', 134000, 'Pendiente'),('SWD147', 'Azul', 'Toyota', 0, 'Activo', 88000, 'Activo'),
('XED258', 'Gris', 'Nissan', 1, 'Inactivo', 101000, 'Pendiente'),('CVF369', 'Amarillo', 'KIA', 2, 'Activo', 95000, 'Activo'),
('BGY147', 'Rojo', 'Mazda', 4, 'Activo', 160000, 'Pendiente');
INSERT INTO conductor (nombreConductor, docConductor, numViajes, numMultas, numeroContacto, EpsConductor, estadoConductor) VALUES
('Mario Mendoza', 1031650258, 0, 0, 3227830878, 'Sura', 'activo'),
('Carlos Pérez', 1029876543, 5, 1, 3204567890, 'Sanitas', 'activo'),
('Jorge Ramírez', 1013456789, 10, 3, 3109876543, 'Compensar', 'activo'),
('Luis Torres', 1002345678, 2, 0, 3182345678, 'Nueva EPS', 'inactivo'),
('Andrés Martínez', 1009871234, 12, 2, 3012345678, 'Sura', 'activo'),
('Pedro Herrera', 1034567891, 0, 0, 3119876543, 'Coomeva', 'activo'),
('Juan Ríos', 1011122233, 8, 1, 3198765432, 'Sanitas', 'inactivo'),
('David López', 1056789012, 7, 3, 3145678901, 'Compensar', 'activo'),
('Óscar Díaz', 1001234567, 4, 0, 3151234567, 'Sura', 'activo'),
('Héctor Castro', 1034567001, 1, 0, 3176543210, 'Nueva EPS', 'inactivo'),
('Esteban Castaño', 1023344556, 11, 2, 3134567890, 'Sanitas', 'activo'),
('Sergio Guzmán', 1019988776, 3, 0, 3123456789, 'Coomeva', 'activo'),
('Kevin Vargas', 1025478963, 0, 0, 3101234567, 'Compensar', 'activo'),
('Wilson Mora', 1032147859, 6, 1, 3224567890, 'Sura', 'inactivo'),
('Fernando Salazar', 1018529637, 14, 2, 3009876543, 'Nueva EPS', 'activo'),
('Daniel Blanco', 1047852369, 0, 0, 3111234567, 'Sura', 'activo'),
('Jaime León', 1058963214, 9, 3, 3013456789, 'Sanitas', 'activo'),
('Eduardo Peña', 1023456987, 5, 0, 3212345678, 'Compensar', 'activo'),
('Miguel Pardo', 1011597536, 2, 1, 3157890123, 'Coomeva', 'inactivo'),
('Camilo Ruiz', 1047893215, 7, 2, 3173214567, 'Sura', 'activo'),
('Leonardo Gómez', 1032587412, 10, 1, 3002345678, 'Nueva EPS', 'activo'),
('Cristian Rueda', 1041597536, 0, 0, 3137896541, 'Sanitas', 'activo'),
('Rubén Villalba', 1023689741, 8, 0, 3161234567, 'Compensar', 'inactivo'),
('Mauricio Ovalle', 1053698521, 0, 0, 3016549873, 'Coomeva', 'activo'),
('Hernán Duarte', 1017534869, 6, 2, 3127890123, 'Sura', 'activo'),
('Iván Herrera', 1036987451, 4, 0, 3194567890, 'Sanitas', 'activo'),
('Julio Ríos', 1027896541, 0, 0, 3156547891, 'Nueva EPS', 'activo'),
('Álvaro Guzmán', 1047896325, 13, 3, 3143214567, 'Compensar', 'inactivo'),
('Nicolás Barrios', 1013579512, 1, 0, 3184567890, 'Coomeva', 'activo'),
('Samuel Cárdenas', 1009875412, 3, 1, 3106543210, 'Sura', 'activo'),
('Tomás Carvajal', 1025412369, 2, 0, 3003214567, 'Sanitas', 'activo'),
('Fabián Zapata', 1059874563, 0, 0, 3126549870, 'Nueva EPS', 'activo'),
('Raúl Calderón', 1006543217, 11, 2, 3193216547, 'Sura', 'inactivo'),
('Jonathan Niño', 1037412589, 7, 0, 3177894561, 'Compensar', 'activo'),
('Henry Espinosa', 1023587412, 0, 0, 3213216540, 'Sanitas', 'activo'),
('Ramiro Córdoba', 1054123789, 6, 1, 3114569871, 'Coomeva', 'activo'),
('Alexander Salas', 1049632587, 9, 1, 3094567890, 'Sura', 'inactivo'),
('Darío Fajardo', 1036982547, 0, 0, 3107896543, 'Nueva EPS', 'activo'),
('Néstor Vargas', 1013256987, 2, 1, 3086543217, 'Sanitas', 'activo'),
('Carlos Ayala', 1047852365, 3, 0, 3207896541, 'Sura', 'activo'),
('Francisco Valdés', 1024785214, 5, 2, 3129632145, 'Compensar', 'activo'),
('Andrés Olaya', 1036987456, 0, 0, 3109632147, 'Sanitas', 'activo'),
('Manuel Castillo', 1007896321, 4, 1, 3217412369, 'Coomeva', 'inactivo'),
('Gustavo Reyes', 1013698524, 8, 2, 3017896542, 'Nueva EPS', 'activo'),
('Santiago Prieto', 1024569871, 12, 3, 3179632145, 'Sura', 'activo'),
('Ángel Mejía', 1053217896, 1, 0, 3164567893, 'Compensar', 'activo'),
('Julián Cano', 1036547895, 0, 0, 3119632584, 'Sanitas', 'activo'),
('Elías Suárez', 1021478596, 6, 1, 3203214567, 'Nueva EPS', 'activo'),
('Rafael Mora', 1007891234, 0, 0, 3087894561, 'Coomeva', 'inactivo'),
('Ricardo Medina', 1014563210, 3, 0, 3093216547, 'Sura', 'activo');
INSERT INTO factura (valorViaje, utilidadesViaje, idClienteFK, idConductorFK, idViajeFK, idVehiculoFK) VALUES
(180000, 15000, 1, 3, 6, 9),(250000, 20000, 2, 4, 6, 10),(320000, 28000, 3, 5, 8, 9),
(150000, 12000, 4, 3, 9, 12),(400000, 35000, 5, 3, 10, 13),(220000, 18000, 6, 6, 11, 9),
(270000, 22000, 6, 6, 12, 15),(310000, 29000, 3, 4, 13, 16),(190000, 13000, 9, 7, 14, 17),
(230000, 17000, 10, 4, 14, 18),(500000, 45000, 11, 5, 15, 19),(210000, 16000, 12, 5, 15, 20),
(280000, 23000, 13, 8, 16, 19),(330000, 25000, 14, 9, 16, 22),(290000, 19000, 15, 3, 17, 23),
(240000, 21000, 5, 4, 18, 23),(150000, 8000, 17, 6, 19, 25),(170000, 7000, 18, 7, 19, 25),
(310000, 15000, 3, 3, 20, 27),(450000, 40000, 20, 3, 20, 28),(160000, 6000, 1, 4, 20, 28),
(380000, 33000, 2, 5, 21, 28),(300000, 27000, 1, 6, 22, 29),(275000, 25000, 3, 6, 22, 29),
(265000, 22000, 3, 6, 23, 30),(185000, 17000, 3, 6, 23, 30),(370000, 30000, 4, 6, 24, 30),
(215000, 18000, 4, 6, 24, 30),(345000, 31000, 4, 6, 25, 30),(160000, 9000, 5, 3, 25, 30),
(400000, 37000, 5, 3, 25, 30),(195000, 14000, 5, 3, 26, 31),(180000, 12000, 6, 4, 26, 31),
(410000, 35000, 7, 5, 26, 31),(210000, 19000, 8, 5, 26, 31),(250000, 23000, 9, 5, 27, 32),
(290000, 28000, 10, 5, 27, 32),(190000, 16000, 11, 5, 28, 32),(275000, 26000, 12, 5, 28, 32),
(360000, 30000, 13, 5, 28, 32),(300000, 24000, 13, 6, 29, 32),(320000, 27000, 14, 6, 30, 32),
(150000, 10000, 15, 6, 30, 32),(370000, 32000, 16, 7, 30, 32),(200000, 18000, 17, 7, 30, 32),
(220000, 20000, 18, 7, 30, 32),(260000, 23000, 19, 7, 30, 32),(310000, 29000, 20, 7, 30, 32),
(190000, 15000, 1, 3, 1, 1),(430000, 40000, 1, 3, 1, 1);
insert into gastoFactura(valorGasto,idFacturaFK,idGastoFK) values (165000,1,2),(248000,2,17),
(29200,3,32),(138000,4,10),(365000,5,22);
SELECT * FROM facturaCompleta;
SELECT * FROM gastofactura;
SELECT * FROM CONDUCTOR;
SELECT * FROM vehiculo;
/*consulta basica tabla cliente*/
SELECT idCLiente,nombreCliente FROM cliente;
/* consulta basica tabla conducotr */
select nombreConductor,numViajes,numMultas from conductor;
/* consulta basica tabla viaje*/
SELECT * FROM VIAJE;
/*consulta basica tabla vehiculo*/
select marcaVehiculo,estadoVehiculo,colorVehiculo,soatVehiculo from VEHICULO;
/* consulta basica taba gasto*/
SELECT nombreGasto,descripcionGasto,tipoGasto from gasto;

/* consulta basica factura*/
select idFactura,valorViaje,utilidadesViaje from factura;
select valorGasto,idFacturaFK,idGastoFK from gastofactura;
/* consultas especificas tabla cliente */
SELECT * FROM CLIENTE 
WHERE tipoCLiente='natural';
SELECT * FROM CLIENTE 
WHERE tipoCLiente='juridico';
SELECT * FROM CLIENTE WHERE contactoCliente is not null;
/* consulta especifica tabla conductor */
SELECT nombreConductor,numMultas,numeroContacto FROM conductor
WHERE numMultas>0;
SELECT nombreConductor,numMultas,numeroContacto FROM conductor
WHERE numViajes>50;
SELECT nombreConductor,numMultas,numeroContacto FROM conductor
WHERE EpsConductor IS NULL;
SELECT nombreConductor,numeroContacto,numMultas FROM conductor
WHERE numViajes<>0
ORDER BY numMultas asc;
SELECT nombreConductor,numViajes FROM conductor 
ORDER BY numViajes DESC LIMIT 5;
/* CONSULTAS ESPECIFICAS VEHICULO*/
SELECT idVehiculo, placaVehiculo from Vehiculo 
WHERE soatVehiculo='pendiente';
SELECT * FROM VEHICULO;
SELECT placaVehiculo,marcaVehiculo from Vehiculo
where valorImpuesto>=100000.000;
SELECT * FROM VEHICULO
WHERE marcaVehiculo LIKE "%chevrolet%";
SELECT * FROM VEHICULO 
ORDER BY cantidadReparaciones desc limit 5;
/* CONSULTA ESPECIFICA TABLA VIAJE*/
SELECT LugarOrigen,lugarDestino,duracionEstimada FROM viaje
WHERE numEscalas=(select max(numEscalas) from viaje limit 1);
/* CONSULTA ESPECIFICA TABLA FACTURA*/
SELECT * from factura
where utilidadesviaje<=0;
SELECT idClienteFK,count(*) as "numero de viajes " FROM factura
GROUP BY idClienteFK;
SELECT * FROM GASTO 
where tipoGasto=2;
SELECT * FROM GASTO 
where tipoGasto=1;
SELECT * FROM GASTO 
where tipoGasto=3;
/*CONSULTA ESPECIFICA TABLA GASTOFACTURA*/
SELECT idGastoFK,count(*) from gastoFactura
group by idGastoFK;
SELECT idFacturaFK,ROUND(avg(valorGasto),2) as "valor promedio de cada gasto" from 
gastoFactura group by idFacturaFK;
/* updates tabla conductor*/
UPDATE 	CONDUCTOR  
SET estadoConductor="inactivo" 
WHERE idConductor=1;
SELECT * FROM conductor;
/* consultar conductor por id */
CALL consultarConductor(2);
/* consultar eps por conductor*/
CALL consultarEPS(1);
/*ACTUALIZAR EPS POR ID CONDUCTOR*/
CALL actualizarEps(1,"compensar");
/*ACTUALIZAR CONTACTO CONDUCTOR POR ID*/
call actualizarCont(1,3053524931);
/* CONSULTAR LOS VIAJES DE UN CONDUCTOR*/
 SELECT nombreConductor,lugarOrigen,lugarDestino FROM FACTURA
 INNER JOIN CONDUCTOR ON idConductorFK=idConductor
 INNER JOIN VIAJE ON idVIaje=idViajeFK;
 /* INFORMACION MULTAS DE UN CONDUCTOR*/
 SELECT valorGasto,nombreConductor,descripcionGasto FROM GASTOFACTURA 
 INNER JOIN GASTO on idGasto=idGastoFK
 INNER JOIN FACTURA ON idFacturaFK=idFactura
 INNER JOIN CONDUCTOR ON idConductorFK=idConductor
 WHERE idConductorFK=1 and idGasto=2;
/*RQFS VIAJE*/
SELECT lugarOrigen,LugarDestino, duracionEstimada FROM viaje;
CALL ActualizarDur(1,"12 horas");
CALL actualizarEsc(1,2);
SELECT * FROM VIAJE;
/*RQFS VEIHCULO*/
SELECT * FROM VEHICULO WHERE idVehiculo=1;
CALL cambiarEstado(1,"inactivo");
SELECT SoatVehiculo,placaVehiculo from VEHICULO;
SELECT * FROM vehiculo ;
SELECT placaVehiculo,marcaVehiculo,colorVehiculo FROM vehiculo;
SELECT placaVehiculo,valorImpuesto FROM vehiculo;
CALL cambiarSoat(1,"pendiente");
SELECT * FROM VEHICULOSACTIVOS;
SELECT * FROM VEHICULOSINACTIVOS;
SELECT placaVehiculo,cantidadReparaciones FROM vehiculo;
/*rqfs gasto*/
SELECT idFacturaFK as "facatura",valorgasto,descripcionGasto from gastoFactura Ç
INNER JOIN GASTO ON idGastofK=idGasto;
/* prueba de las vistas */
SELECT * FROM conductoresActivos;
SELECT * FROM conductoresInactivos;
SELECT * FROM facturaCompleta;
SELECT * FROM VEHICULOSACTIVOS;
SELECT * FROM VEHICULOSINACTIVOS;
SELECT * FROM gastoFactura;
SELECT * FROM mejorClientes;
SELECT * FROM viajesLargos;
SELECT * FROM mejorClientes;
/* prueba del procedimiento almacendado*/
CALL consultarMayorGasto(1);
CALL consultarMayorGasto(2);
SELECT * FROM CONDUCTOR;
SELECT * FROM VEHICULO;