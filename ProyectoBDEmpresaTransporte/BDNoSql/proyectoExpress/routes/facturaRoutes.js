const express=require('express');
const router=express.Router();
const Factura=require('../models/Factura');


//Registrar un usuario
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const facturas = await Factura.insertMany(req.body);
            res.status(201).json(facturas);
        } else {
            const factura = new Factura(req.body);
            await factura.save();
            res.status(201).json(factura);
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
    const factura = await Factura.find(filtro);
    res.json(factura);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id
router.get('/:id',async(req,res)=>{
    try{
        const factura=await Factura.findById(req.params.id);
        if (!factura)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(factura);

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
        const factura=await Factura.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!factura)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(factura);

    }catch(error){
        res.status(500).json({ error: error.message});
}
})

//eliminar un producto 

router.delete('/:id',async(req,res)=>{
    try{
        const factura=await Factura.findByIdAndDelete(req.params.id);
        if (!factura)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(factura);
    
    }catch(error){
        res.status(500).json({ error: error.message})
    }
});

module.exports=router;