const mongoose=require('mongoose');


const GastoSchema=new mongoose.Schema({
    descripcionGasto:{type:String,require:true},
    tipoGasto:Number,
    nombreGasto:String,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('gasto',GastoSchema)
