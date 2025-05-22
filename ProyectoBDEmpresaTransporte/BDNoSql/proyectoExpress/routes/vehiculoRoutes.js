const express = require('express');
const router = express.Router();
const Vehiculo = require('../models/Vehiculo'); 

// Registrar un vehículo
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const vehiculos = await Vehiculo.insertMany(req.body);
            res.status(201).json(vehiculos);
        } else {
            const vehiculo = new Vehiculo(req.body);
            await vehiculo.save();
            res.status(201).json(vehiculo);
        }
    } catch (error) {
        res.status(400).json({ error: error.message }); 
    }
});
//consultar todos los productos
router.get('/',async(req,res)=>{
    try{
        const vehiculos=await Vehiculo.find();
        res.json(vehiculos);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})

//consultar prodcuto por id
router.get('/:id',async(req,res)=>{
    try{
        const vehiculo=await Vehiculo.findById(req.params.id);
        if (!vehiculo)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(vehiculo);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const vehiculo=await Vehiculo.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!vehiculo)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(vehiculo);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})

router.delete('/:id',async(req,res)=>{
    try{
        const vehiculo=await Vehiculo.findByIdAndDelete(req.params.id);
        if (!vehiculo)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(vehiculo);
    
    }catch(error){
        res.status(500).json({ error: error.menssage})
    }
});

module.exports=router;

