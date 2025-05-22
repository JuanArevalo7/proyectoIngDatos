const mongoose=require('mongoose');


const vehiculoSchema=new mongoose.Schema({
    placaVehiculo:{type:String,require:true},
    colorVehiculo:String,
    marcaVehiculo:String,
    cantidadReparaciones:Number,
    estadoVehiculo:String,
    valorImpuesto:Number,
    SoatVehiculo:String,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('Vehiculo',vehiculoSchema)
