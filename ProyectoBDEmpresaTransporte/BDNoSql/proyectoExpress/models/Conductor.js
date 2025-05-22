const mongoose=require('mongoose');


const conductorSchema=new mongoose.Schema({
    nombreConductor:{type:String,require:true},
    docConductor:Number,
    numViajes:Number,
    numMultas:Number,
    numContacto:Number,
    epsConductor:String,
    estadoConductor:Number,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('conductor',conductorSchema)
