const express=require('express');
const router=express.Router();
const GastoFactura=require('../models/GastoFactura');


//Registrar un usuario
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const gastos = await GastoFactura.insertMany(req.body);
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
router.get('/valor/:idRegistro', async (req, res) => {
  try {
    const gasto = await GastoFactura.findOne(
      { idRegistro: Number(req.params.idRegistro) },
      { idGastoFK: 1, valorGasto: 1, _id: 0 }
    );

    if (!gasto) {
      return res.status(404).json({ error: 'Registro no encontrado' });
    }

    res.json(gasto);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/tipo/:idRegistro', async (req, res) => {
  try {
    const id = Number(req.params.idRegistro);

    const resultado = await GastoFactura.aggregate([
      {
        $match: { idRegistro: id }
      },
      {
        $lookup: {
          from: 'gastos',
          localField: 'idGastoFK',
          foreignField: 'idGasto',
          as: 'detalleGasto'
        }
      },
      { $unwind: '$detalleGasto' },
      {
        $project: {
          _id: 0,
          idRegistro: 1,
          tipoGasto: {
            $switch: {
              branches: [
                { case: { $eq: ['$detalleGasto.tipoGasto', 1] }, then: 'Reparaciones' },
                { case: { $eq: ['$detalleGasto.tipoGasto', 2] }, then: 'Multas' },
                { case: { $eq: ['$detalleGasto.tipoGasto', 3] }, then: 'Otros' }
              ],
              default: 'Desconocido'
            }
          }
        }
      }
    ]);

    if (resultado.length === 0) {
      return res.status(404).json({ error: 'Registro no encontrado' });
    }

    res.json(resultado[0]);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/descripcion/:idRegistro', async (req, res) => {
  try {
    const id = Number(req.params.idRegistro);

    const resultado = await GastoFactura.aggregate([
      {
        $match: { idRegistro: id }
      },
      {
        $lookup: {
          from: 'gastos',  // nombre real de la colección en Mongo
          localField: 'idGastoFK',
          foreignField: 'idGasto',
          as: 'detalleGasto'
        }
      },
      {
        $unwind: '$detalleGasto'
      },
      {
        $project: {
          _id: 0,
          idRegistro: 1,
          descripcionGasto: '$detalleGasto.descripcionGasto'
        }
      }
    ]);

    if (resultado.length === 0) {
      return res.status(404).json({ error: 'Registro no encontrado' });
    }

    res.json(resultado[0]);

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
    const gasto = await GastoFactura.find(filtro);
    res.json(gasto);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id
router.get('/:idRegistro', async (req, res) => {
  try {
    const gasto = await GastoFactura.findOne({ idRegistro: req.params.idRegistro });
    if (!gasto) return res.status(404).json({ error: 'Gasto no encontrado' });
    res.json(gasto);
  } catch (error) {
    res.status(500).json({ error: error.message }); 
  }
});

//modificar datos del producto 
router.put('/:id',async(req,res)=>{
    try{
        const gasto=await GastoFactura.findByIdAndUpdate(req.params.id, req.body,{new:true});
        if (!gasto)return res.status(404).json({error: 'Producto no encontrado'});
        res.json(gasto);

    }catch(error){
        res.status(500).json({ error: error.message});
}
})
//eliminar un producto 

router.delete('/:idRegistro', async (req, res) => {
  try {
    const id = Number(req.params.idRegistro);
    const registroEliminado = await GastoFactura.findOneAndDelete({ idRegistro: id });

    if (!registroEliminado) {
      return res.status(404).json({ error: 'Registro no encontrado' });
    }

    res.json({ mensaje: 'GastoFactura eliminado correctamente', registro: registroEliminado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports=router;