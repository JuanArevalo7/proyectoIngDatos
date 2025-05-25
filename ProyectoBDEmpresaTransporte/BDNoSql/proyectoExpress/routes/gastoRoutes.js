const express=require('express');
const router=express.Router();
const Gasto=require('../models/Gasto');


//Registrar un usuario
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const gastos = await Gasto.insertMany(req.body);
            res.status(201).json(gastos);
        } else {
            const gasto = new Gasto(req.body);
            await gasto.save();
            res.status(201).json(gasto);
        }
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});
router.get('/:idGasto', async (req, res) => {
  try {
    const gasto = await Gasto.findOne({ idGasto: Number(req.params.idGasto) });

    if (!gasto) {
      return res.status(404).json({ error: 'Gasto no encontrado' });
    }

    res.json(gasto);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

//consultar todos los productos
router.get('/', async (req, res) => {
  try {
    const { nombre, edad } = req.query;

    let filtro = {};
    if (nombre) filtro.nombre = { $eq: nombre };
    if (edad) filtro.edad = { $gte: edad };
    const gasto = await Gasto.find(filtro);
    res.json(gasto);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id

//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const gasto=await Gasto.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!gasto)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(gasto);

    }catch(error){
        res.status(500).json({ error: error.message});
}
})
//eliminar un producto 

router.delete('/:idGasto', async (req, res) => {
  try {
    const id = Number(req.params.idGasto);
    const gastoEliminado = await Gasto.findOneAndDelete({ idGasto: id });

    if (!gastoEliminado) {
      return res.status(404).json({ error: 'Gasto no encontrado' });
    }

    res.json({ mensaje: 'Gasto eliminado correctamente', gasto: gastoEliminado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports=router;