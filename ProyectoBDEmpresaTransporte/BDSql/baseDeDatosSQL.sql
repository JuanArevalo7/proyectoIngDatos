DROP DATABASE basedeDatosSQL;
CREATE DATABASE basedeDatosSQL;
USE basedeDatosSQL;
CREATE TABLE CONDUCTOR(
idConductor INT AUTO_INCREMENT PRIMARY KEY,
nombreConductor VARCHAR(20),
docConductor INT NOT NULL UNIQUE,
numViajes INT DEFAULT 0,
numMultas INT DEFAULT 0,
numeroContacto BIGINT NOT NULL,
EpsConductor varchar(20)
);
CREATE TABLE VEHICULO(
idVehiculo int AUTO_INCREMENT PRIMARY KEY,
placaVehiculo varchar(10) UNIQUE NOT NULL,
colorVehiculo VARCHAR(20) NOT NULL,
marcaVehiculo VARCHAR(20) NOT NULL,
cantidadReparaciones INT,
estadoVehiculo ENUM("activo","inactivo"),
valorImpuesto DOUBLE(12,3),
SoatVehiculo ENUM("pendiente","activo")
);
CREATE TABLE CLIENTE(
idCLiente int PRIMARY KEY AUTO_INCREMENT,
docCliente int,
contactoCliente bigint,
tipoCliente ENUM("natural","juridico"), /*juridico hace referencia a las empresas*/
nombreCliente VARCHAR(20)
);
CREATE TABLE VIAJE(
idViaje INT AUTO_INCREMENT PRIMARY KEY,
lugarDestino varchar(20) NOT NULL,
lugarOrigen varchar(20) NOT NULL,
duracionEstimada varchar(20),
numEscalas int);
CREATE TABLE GASTO(
idGasto INT PRIMARY KEY AUTO_INCREMENT,
descripcionGasto VARCHAR(20),
tipoGasto int
);
CREATE TABLE FACTURA(
idFactura INT AUTO_INCREMENT PRIMARY KEY,
valorViaje double(15,3) NOT NULL,
utilidadesViaje double (15,3) NOT NULL,
idCLienteFK int ,
idConductorFK int,
idViajeFK int ,
idVehiculoFK INT,
CONSTRAINT llaveCliente FOREIGN KEY(idCLienteFK) REFERENCES CLIENTE(idCliente) ON DELETE SET NULL,
CONSTRAINT llaveConductor FOREIGN KEY(idConductorFK) REFERENCES conductor(IdCOnductor) ON DELETE SET NULL,
CONSTRAINT llaveViaje FOREIGN KEY(idViajeFK) REFERENCES viaje(IdViaje) ON DELETE SET NULL,
CONSTRAINT llaveVehiculo FOREIGN KEY(idVehiculoFK) REFERENCES vehiculo(IdVehiculo) ON DELETE SET NULL
);
CREATE TABLE gastoFactura(
idRegistro INT PRIMARY KEY AUTO_INCREMENT,
valorGasto DOUBLE(11,3) NOT NULL,
idFacturaFK INT ,
idGastoFK INT ,
CONSTRAINT llaveFacturaFK FOREIGN KEY(idFacturaFK) REFERENCES factura(idFactura) ON DELETE SET NULL,
CONSTRAINT llaveGastoFK FOREIGN KEY(idGastoFK) REFERENCES gasto(idGasto) ON DELETE SET NULL
);
ALTER TABLE CONDUCTOR 
ADD COLUMN estadoConductor ENUM("activo","inactivo");
ALTER TABLE GASTO
ADD COLUMN nombreGasto varchar(20);
ALTER TABLE GASTO
MODIFY COLUMN descripcionGasto varchar(40);
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
/* MEJOR VISUALIZACION DE LAS FACTURAS*/
CREATE VIEW facturaCompleta as
SELECT f.valorViaje,f.utilidadesVIaje,v.lugarOrigen,v.lugarDestino,c.nombreConductor as "conductor" ,cl.nombreCliente ,ve.marcaVehiculo,
ve.placaVehiculo  FROM factura f 
INNER JOIN viaje v on v.idVIaje=f.idViajeFK
INNER JOIN conductor c on c.idConductor=f.idConductorFK
INNER JOIN vehiculo ve on ve.idVehiculo=f.idVehiculoFK
INNER JOIN cliente cl on cl.idCliente=f.idCLienteFK;
/* TRIGGER PARA AÑADIR REPARACIONES A UN VEHICULO AUTOMATICAMENTE*/ 
DELIMITER $$
CREATE TRIGGER añadirReparaciones AFTER INSERT ON gastoFactura FOR EACH ROW
BEGIN 
IF NEW.IDGASTOFK = 1 THEN
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
IF NEW.idgastoFK IN (2,3) THEN
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
/* trigger para calcular automaticamente las utilidades */
DELIMITER $$
CREATE TRIGGER actualizarUtilidades
AFTER INSERT ON gastoFactura
FOR EACH ROW
BEGIN
  DECLARE totalGastos DOUBLE;
  SELECT SUM(valorGasto)
  INTO totalGastos
  FROM gastoFactura
  WHERE idFacturaFK = NEW.idFacturaFK;

  UPDATE factura
  SET utilidadesViaje = valorViaje - totalGastos
  WHERE idFactura = NEW.idFacturaFK;
END $$
DELIMITER ;
INSERT INTO gasto (descripcionGasto, tipoGasto, nombreGasto)
VALUES 
('Cambio de frenos', 1, 'Reparación'),
('Multa por exceso de velocidad', 2, 'Multa'),
('Multa por mal parqueo', 2, 'Multa'),
('Peaje Bogotá', 3, 'Peaje'),
('Hotel en Cali', 3, 'Hospedaje'),
('Parqueadero Medellín', 3, 'Parqueadero');
INSERT INTO conductor (nombreConductor, docConductor, numeroContacto, EpsConductor, estadoConductor)
VALUES ('Pedro Torres', 123456789, 3101234567, 'Sura', 'activo');

INSERT INTO vehiculo (placaVehiculo, colorVehiculo, marcaVehiculo, cantidadReparaciones, estadoVehiculo, valorImpuesto, SoatVehiculo)
VALUES ('ABC123', 'Rojo', 'Chevrolet', 0, 'activo', 100000.000, 'activo');

INSERT INTO cliente (docCliente, contactoCliente, tipoCliente, nombreCliente)
VALUES (987654321, 3198765432, 'natural', 'Laura Gómez');

INSERT INTO viaje (lugarDestino, lugarOrigen, duracionEstimada, numEscalas)
VALUES ('Medellín', 'Bogotá', '10 horas', 1);
INSERT INTO factura (valorViaje, utilidadesViaje, idClienteFK, idConductorFK, idViajeFK, idVehiculoFK)
VALUES (1000000.000, 0.000, 1, 1, 1, 1);
INSERT INTO gastoFactura (valorGasto, idFacturaFK, idGastoFK)
VALUES (150000.000, 1, 1);
INSERT INTO gastoFactura (valorGasto, idFacturaFK, idGastoFK)
VALUES (80000.000, 1, 2);
INSERT INTO gastoFactura (valorGasto, idFacturaFK, idGastoFK)
VALUES (120000.000, 1, 4);
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
SELECT idClienteFK,count(*) FROM factura
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
/* CONSULTAS MULTITABLA */
SELECT * FROM ---- ;
/* prueba de las vistas */
SELECT * FROM conductoresActivos;
SELECT * FROM conductoresInactivos;
SELECT * FROM facturaCompleta;
SELECT * FROM VEHICULOSACTIVOS;
SELECT * FROM VEHICULOSINACTIVOS;
SELECT * FROM gastoFactura;
/* prueba del procedimiento almacendado*/
CALL consultarMayorGasto(1);
CALL consultarMayorGasto(2);
/*	*/
