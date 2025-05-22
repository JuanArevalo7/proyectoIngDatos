const express = require('express');
const router = express.Router();
const Vehiculo = require('../models/Vehiculo'); 

// Registrar un vehículo
router.post('/', async (req, res) => {
    try {
        const vehiculo = new Vehiculo(req.body); 
        await vehiculo.save();
        res.status(201).json(vehiculo);
    } catch (error) {
        res.status(400).json({ error: error.message }); 
    }
});
router.get('/', async (req, res) => {
  try {
    const { precio } = req.query;

    let filtro = {};
    if (precio) {
      filtro.Precio = { $gte: Number(precio) };
    }

    const productos = await Producto.find(filtro).sort({ Precio: -1 }); 
    res.json(productos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const { precio } = req.query;
    let filtro = {};

    if (precio) {
      filtro.Precio = { $gte: Number(precio) }; 
    }

    const productos = await Producto.find(filtro);
    res.json(productos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
//consultar todos los productos
router.get('/',async(req,res)=>{
    try{
        const items=await Item.find();
        res.json(items);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})

//consultar prodcuto por id
router.get('/:id',async(req,res)=>{
    try{
        const items=await Item.findById(req.params.id);
        if (!item)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(item);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
router.put('/actualizar-stock-false', async (req, res) => {
  try {
    const resultado = await Producto.updateMany(
      { Precio: { $gt: 500 } },  // filtro: Precio mayor a 500
      { $set: { stock: false } }  // actualiza stock a false
    );
    res.json({ mensaje: 'Stock actualizado a false para productos > 500', resultado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put('/actualizar-stock', async (req, res) => {
  try {
    const resultado = await Producto.updateMany({}, { $set: { stock: true } });
    res.json({ mensaje: 'Stock actualizado para todos los productos', resultado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const item=await Item.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!item)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(item);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
//eliminar un producto 
router.delete('/eliminar-precio-menor-50', async (req, res) => {
  try {
    const resultado = await Producto.deleteMany({ Precio: { $lt: 50 } });
    res.json({ mensaje: 'Productos eliminados con precio menor a 50', resultado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete('/:id',async(req,res)=>{
    try{
        const items=await Item.findByIdAndUpdate(req.params.id);
        if (!item)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(items);
    
    }catch(error){
        res.status(500).json({ error: error.menssage})
    }
});

module.exports=router;
