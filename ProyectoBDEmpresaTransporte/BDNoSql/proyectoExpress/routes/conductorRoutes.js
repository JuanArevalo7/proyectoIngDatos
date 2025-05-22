const express=require('express');
const router=express.Router();
const Cliente=require('../models/Conductor');


//Registrar un usuario
router.post('/',async(req,res)=>{
    try{
        const cliente=new Cliente(req.body);
        await cliente.save();
        res.status(201).json(cliente);

    }catch(error){
        res.status(400).json({ error: error.menssage});
}
})

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
