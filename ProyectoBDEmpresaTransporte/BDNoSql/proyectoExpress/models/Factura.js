const mongoose=require('mongoose');


const facturaSchema=new mongoose.Schema({
    valorViaje:Number,
    utilidadesViaje:Number,
    fechaViaje:String,
    creadoEn:{type:Date,default:Date.now}
});

module.exports=mongoose.model('factura',facturaSchema)
