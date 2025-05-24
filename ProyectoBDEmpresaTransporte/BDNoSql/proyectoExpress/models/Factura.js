const mongoose=require('mongoose');


const facturaSchema=new mongoose.Schema({
    idFactura:Number,
    valorViaje:Number,
    utilidadesViaje:Number,
    idClienteFK:Number,
    idConductorFK:Number,
    idViajeFK:Number,
    idVehiculoFK:Number,
    FechaFacturacion:String,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('factura',facturaSchema)
