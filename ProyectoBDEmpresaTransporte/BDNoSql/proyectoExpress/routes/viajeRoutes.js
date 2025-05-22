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
router.put('/activar-mayores-30', async (req, res) => {
  try {
    const resultado = await Cliente.updateMany(
      { edad: { $gte: 30 } },    // filtro: edad >= 30
      { $set: { activo: true } } // actualización: agrega campo activo:true
    );

    res.json({
      mensaje: 'Usuarios actualizados',
      modificados: resultado.modifiedCount
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
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

router.delete('/menores-30', async (req, res) => {
  try {
    const resultado = await Cliente.deleteMany({ edad: { $lt: 30 } });
    res.json({ mensaje: `Se eliminaron ${resultado.deletedCount} usuarios menores de 30 años.` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

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
