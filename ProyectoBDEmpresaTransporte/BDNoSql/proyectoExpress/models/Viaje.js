const mongoose=require('mongoose');


const ViajeSchema=new mongoose.Schema({
    lugarDestino:{type:String,require:true},
    lugarOrigen:String,
    duracionEstimada:Number,
    numEscalas:Number,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('viaje',ViajeSchema)
