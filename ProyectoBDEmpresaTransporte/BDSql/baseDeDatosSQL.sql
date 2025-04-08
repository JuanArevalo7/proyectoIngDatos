CREATE DATABASE TRANSPORTADORA;
USE TRANSPORTADORA;
CREATE TABLE CONDUCTOR(
idConductor INT AUTO_INCREMENT PRIMARY KEY,
nombreCOnductor VARCHAR(20),
docConductor INT NOT NULL UNIQUE,
numViajes INT DEFAULT 0,
numMultas INT DEFAULT 0,
numeroContacto INT NOT NULL,
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
contactoCliente int,
tipoCliente ENUM("natural","juridico") /*juridico hace referencia a las empresas*/
);
CREATE TABLE VIAJE(
idViaje INT AUTO_INCREMENT PRIMARY KEY,
lugarDestino varchar(20) NOT NULL,
lugarOrigen varchar(20) NOT NULL,
duracionEstimada varchar(20),
numEscalas int);
CREATE TABLE GASTO(
idGasto INT PRIMARY KEY AUTO_INCREMENT,
descripcionGasto VARCHAR(20)
);
CREATE TABLE FACTURA(
idFactura INT AUTO_INCREMENT PRIMARY KEY,
valorViaje double(11,8) NOT NULL,
utilidadesViaje double (11,8) NOT NULL,
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
ADD COLUMN estadoConductor ENUM('t','f');
/* CREACION DE VISTA PARA VEHICULOS ACTIVOS E INACTIVOS*/
CREATE VIEW vehiculosInactivos as 
SELECT * FROM vehiculo where estadoVehiculo = 'f';
CREATE VIEW vehiculosActivos as 
SELECT * FROM vehiculo where estadoVehiculo='t';
/* CREACION DE VISTA PARA CONDUCTORES ACTIVOS E INACTIVOS */
CREATE VIEW conductoresActivos as
SELECT * from conductor where estadoConductor='t';
CREATE VIEW conductoresInactivos as
SELECT * FROM conductor where estadoConductor='f';
/* consultar el mayor gasto de una factura*/
DELIMITER $$
CREATE PROCEDURE consultarMayorGasto(in idFactura int)
BEGIN 
SELECT idFacturaFK  as "numero de factura",valorGasto FROM gastofactura
INNER JOIN gasto  on idGastoFK=idGasto
where idFacturaFK=idFactura
order by valorGasto desc limit 1;
END $$
DELIMITER ;
/* MEJOR VISUALIZACION DE LAS FACTURAS*/
CREATE VIEW facturaCompleta as
SELECT f.valorViaje,f.utilidadesVIaje,v.lugarOrigen,v.lugarDestino,c.nombreConductor as "conductor",ve.marcaVehiculo,
ve.placaVehiculo  FROM factura f 
INNER JOIN viaje v on v.idVIaje=f.idViajeFK
INNER JOIN conductor c on c.idConductor=f.idConductorFK
INNER JOIN vehiculo ve on ve.idVehiculo=f.idVehiculoFK
INNER JOIN cliente cl on cl.idCliente=f.idCLienteFK;
/* TRIGGER PARA AÑADIR REPARACIONES A UN VEHICULO AUTOMATICAMENTE*/ 
DELIMITER $$
CREATE TRIGGER añadirReparaciones AFTER INSERT ON gastoFactura FOR EACH ROW
BEGIN 
IF NEW.IDGASTOFK IN (1,2,3) THEN
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
SELECT * FROM facturaCompleta