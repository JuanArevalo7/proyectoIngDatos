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
router.get('/infoViaje/:idViaje', async (req, res) => {
  try {
    const viaje = await Viaje.findOne(
      { idViaje: Number(req.params.idViaje) },
      'lugarOrigen lugarDestino duracionEstimada'
    );

    if (!viaje) return res.status(404).json({ error: 'Viaje no encontrado' });

    res.json(viaje);
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
    const viajes = await Viaje.find(filtro);
    res.json(viajes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/viajesLargos', async (req, res) => {
  try {
    const viajes = await Viaje.find({
      duracionEstimada: { $regex: /d[ií]a/i
 }
    }, {
      _id: 0,
      lugarDestino: 1,
      lugarOrigen: 1,
      duracionEstimada: 1
    });

    res.json(viajes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

//consultar prodcuto por id
router.get('/:idViaje', async (req, res) => {
  try {
    const viaje = await Viaje.findOne({ idViaje: req.params.idViaje });
    if (!viaje) return res.status(404).json({ error: 'Viaje no encontrado' });
    res.json(viaje);
  } catch (error) {
    res.status(500).json({ error: error.message }); // corregido: error.message
  }
});
router.put('/escalas/:idViaje', async (req, res) => {
  try {
    const { numEscalas } = req.body;
    if (numEscalas === undefined) {
      return res.status(400).json({ error: 'Falta el campo numEscalas' });
    }

    const actualizado = await Viaje.findOneAndUpdate(
      { idViaje: Number(req.params.idViaje) },
      { numEscalas: numEscalas },
      { new: true }
    );

    if (!actualizado) {
      return res.status(404).json({ error: 'Viaje no encontrado' });
    }

    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put('/duracion/:idViaje', async (req, res) => {
  try {
    const { duracionEstimada } = req.body;
    if (!duracionEstimada) {
      return res.status(400).json({ error: 'Falta el campo duracionEstimada' });
    }

    const actualizado = await Viaje.findOneAndUpdate(
      { idViaje: Number(req.params.idViaje) },
      { duracionEstimada: duracionEstimada },
      { new: true }
    );

    if (!actualizado) {
      return res.status(404).json({ error: 'Viaje no encontrado' });
    }

    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

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
