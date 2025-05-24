const mongoose=require('mongoose');


const ViajeSchema=new mongoose.Schema({
    idViaje:Number,
    lugarDestino:{type:String,require:true},
    lugarOrigen:String,
    duracionEstimada:String,
    numEscalas:Number,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('viaje',ViajeSchema)
