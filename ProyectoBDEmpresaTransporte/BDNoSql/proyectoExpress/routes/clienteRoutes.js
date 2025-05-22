const express=require('express');
const router=express.Router();
const Cliente=require('../models/Cliente');


//Registrar un usuario
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            // Insertar varios clientes
            const clientes = await Cliente.insertMany(req.body);
            res.status(201).json(clientes);
        } else {
            // Insertar un solo cliente
            const cliente = new Cliente(req.body);
            await cliente.save();
            res.status(201).json(cliente);
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
    const clientes = await Cliente.find(filtro);
    res.json(clientes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id
router.get('/:id',async(req,res)=>{
    try{
        const cliente=await Cliente.findById(req.params.id);
        if (!cliente)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(cliente);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const cliente=await Cliente.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!cliente)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(cliente);

    }catch(error){
        res.status(500).json({ error: error.message});
}
})

//eliminar un producto 

router.delete('/:id',async(req,res)=>{
    try{
        const cliente=await Cliente.findByIdAndDelete(req.params.id);
        if (!cliente)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(cliente);
    
    }catch(error){
        res.status(500).json({ error: error.message})
    }
});

module.exports=router;
