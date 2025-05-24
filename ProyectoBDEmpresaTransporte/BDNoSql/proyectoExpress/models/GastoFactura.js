const mongoose=require('mongoose');


const GastoFacturaSchema=new mongoose.Schema({
    idRegistro:Number,
    valorGasto:Number,
    idFacturaFK:Number,
    idGastoFK:Number
});

module.exports=mongoose.model('gastoFactura',GastoFacturaSchema)
