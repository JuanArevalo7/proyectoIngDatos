const express=require('express');
const router=express.Router();
const Conductor=require('../models/Conductor');


//Registrar un usuario
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const conductores = await Conductor.insertMany(req.body);
            res.status(201).json(conductores);
        } else {
            const conductor = new Conductor(req.body);
            await conductor.save();
            res.status(201).json(conductor);
        }
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});



//consultar todos los productos
router.get('/', async (req, res) => {
  try {
    const { nombre, edad } = req.query;

    let filtro = {};
    if (nombre) filtro.nombre = { $eq: nombre };
    if (edad) filtro.edad = { $gte: edad };
    const conductor = await Conductor.find(filtro);
    res.json(conductor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id
router.get('/:id',async(req,res)=>{
    try{
        const conductor=await Conductor.findById(req.params.id);
        if (!conductor)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(conductor);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const conductor=await Conductor.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!conductor)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(conductor);

    }catch(error){
        res.status(500).json({ error: error.message});
}
})


//eliminar un producto 

router.delete('/:id',async(req,res)=>{
    try{
        const conductor=await Conductor.findByIdAndDelete(req.params.id);
        if (!conductor)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(conductor);
    
    }catch(error){
        res.status(500).json({ error: error.message})
    }
});

module.exports=router;