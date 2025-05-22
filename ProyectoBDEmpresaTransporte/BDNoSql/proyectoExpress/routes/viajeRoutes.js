const express=require('express');
const router=express.Router();
const Viaje=require('../models/Viaje');


//Registrar un usuario
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const viajes = await Viaje.insertMany(req.body);
            res.status(201).json(viajes);
        } else {
            const viaje = new Viaje(req.body);
            await viaje.save();
            res.status(201).json(viaje);
        }
    } catch (error) {
        res.status(400).json({ error: error.message });  // Corrección en message
    }
});

//consultar todos los productos
router.get('/', async (req, res) => {
  try {
    const { nombre, edad } = req.query;

    let filtro = {};
    if (nombre) filtro.nombre = { $eq: nombre };
    if (edad) filtro.edad = { $gte: edad };
    const viajes = await Viaje.find(filtro);
    res.json(viajes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id
router.get('/:id',async(req,res)=>{
    try{
        const viaje=await Viaje.findById(req.params.id);
        if (!viaje)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(viaje);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const viaje=await Viaje.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!viaje)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(viaje);

    }catch(error){
        res.status(500).json({ error: error.message});
}
})

//eliminar un producto 

router.delete('/:id',async(req,res)=>{
    try{
        const viaje=await Viaje.findByIdAndDelete(req.params.id);
        if (!viaje)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(viaje);
    
    }catch(error){
        res.status(500).json({ error: error.message})
    }
});

module.exports=router;
