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
valorGasto DOUBLE(11,3) NOT NULL,
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
idFacturaFK INT ,
idGastoFK INT ,
CONSTRAINT llaveFacturaFK FOREIGN KEY(idFacturaFK) REFERENCES factura(idFactura) ON DELETE SET NULL,
CONSTRAINT llaveGastoFK FOREIGN KEY(idGastoFK) REFERENCES gasto(idGasto) ON DELETE SET NULL
);