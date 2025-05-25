const mongoose=require('mongoose');


const conductorSchema=new mongoose.Schema({
    idConductor:Number,
    nombreConductor:{type:String,require:true},
    docConductor:Number,
    numViajes:Number,
    numMultas:Number,
    numeroContacto:Number,
    EpsConductor:String,
    estadoConductor:String,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('conductores',conductorSchema)
