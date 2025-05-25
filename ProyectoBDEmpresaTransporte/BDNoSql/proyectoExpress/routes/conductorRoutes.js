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

router.get('/info/:idConductor', async (req, res) => {
  try {
    const conductor = await Conductor.findOne(
      { idConductor: req.params.idConductor },
      'nombreConductor EpsConductor' 
    );
    if (!conductor) return res.status(404).json({ error: 'Conductor no encontrado' });
    res.json(conductor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/mejoresConductores', async (req, res) => {
  try {
    const conductores = await Conductor.find()
      .sort({ numViajes: -1 })
      .limit(5)
      .select({ _id: 0, idConductor: 1, nombreConductor: 1, numViajes: 1 });

    res.json(conductores);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/multados', async (req, res) => {
  try {
    const conductores = await Conductor.find({ numMultas: { $gt: 1 } }, {
      _id: 0,
      idConductor: 1,
      nombreConductor: 1,
      numMultas: 1
    });

    if (conductores.length === 0) {
      return res.status(404).json({ mensaje: 'No hay conductores con más de una multa' });
    }

    res.json(conductores);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

//consultar todos los productos
router.get('/', async (req, res) => {
  try {
    const { idConductor, nombre, edad } = req.query;

    let filtro = {};
    if (idConductor) filtro.idConductor = { $eq: idConductor };
    if (nombre) filtro.nombre = { $eq: nombre };
    if (edad) filtro.edad = { $gte: edad }; // Si edad es numérica, asegúrate de convertirla

    const conductores = await Conductor.find(filtro);
    res.json(conductores);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/:idConductor', async (req, res) => {
  try {
    const conductor = await Conductor.findOne({ idConductor: req.params.idConductor });
    if (!conductor) return res.status(404).json({ error: 'Conductor no encontrado' });
    res.json(conductor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/estado/:idConductor', async (req, res) => {
  try {
    const conductor = await Conductor.findOne(
      { idConductor: Number(req.params.idConductor) },
      { _id: 0, nombreConductor: 1, estadoConductor: 1 }
    );

    if (!conductor) return res.status(404).json({ error: 'Conductor no encontrado' });

    res.json(conductor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/numViajes/:idConductor', async (req, res) => {
  try {
    const conductor = await Conductor.findOne(
      { idConductor: Number(req.params.idConductor) },
      'nombreConductor numViajes'
    );

    if (!conductor) return res.status(404).json({ error: 'Conductor no encontrado' });

    res.json(conductor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/numMultas/:idConductor', async (req, res) => {
  try {
    const conductor = await Conductor.findOne(
      { idConductor: Number(req.params.idConductor) },
      'nombreConductor numMultas'
    );

    if (!conductor) return res.status(404).json({ error: 'Conductor no encontrado' });

    res.json(conductor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put('/cambiarEps/:idConductor', async (req, res) => {
  try {
    const { EpsConductor } = req.body;
    if (!EpsConductor) {
      return res.status(400).json({ error: 'Falta el campo epsConductor' });
    }

    const actualizado = await Conductor.findOneAndUpdate(
      { idConductor: Number(req.params.idConductor) },  
      { EpsConductor: EpsConductor },                   
      { new: true }                                     
    );

    if (!actualizado) {
      return res.status(404).json({ error: 'Conductor no encontrado' });
    }

    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.put('/numeroContacto/:idConductor', async (req, res) => {
  try {
    const { numeroContacto } = req.body;
    if (numeroContacto === undefined) {
      return res.status(400).json({ error: 'Falta el campo numeroContacto' });
    }

    const actualizado = await Conductor.findOneAndUpdate(
      { idConductor: Number(req.params.idConductor) },
      { numeroContacto: numeroContacto },
      { new: true }
    );

    if (!actualizado) {
      return res.status(404).json({ error: 'Conductor no encontrado' });
    }

    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

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
router.put('/numMultas/:idConductor', async (req, res) => {
  try {
    const { numMultas } = req.body;
    if (numMultas === undefined) {
      return res.status(400).json({ error: 'Falta el campo numMultas' });
    }

    const actualizado = await Conductor.findOneAndUpdate(
      { idConductor: Number(req.params.idConductor) },
      { numMultas: numMultas },
      { new: true }
    );

    if (!actualizado) {
      return res.status(404).json({ error: 'Conductor no encontrado' });
    }

    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


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