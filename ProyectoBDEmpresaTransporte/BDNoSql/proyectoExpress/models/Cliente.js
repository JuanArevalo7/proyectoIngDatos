const mongoose=require('mongoose');


const ClienteSchema=new mongoose.Schema({
    docCliente:{type:Number,require:true},
    contactoCliente:String,
    tipoCliente:String,
    nombreCliente:String,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('cliente',ClienteSchema)
