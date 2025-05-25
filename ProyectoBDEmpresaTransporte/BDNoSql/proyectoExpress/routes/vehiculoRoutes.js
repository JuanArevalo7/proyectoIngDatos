const express = require('express');
const router = express.Router();
const Vehiculo = require('../models/Vehiculo'); 

// Registrar un vehículo
router.post('/', async (req, res) => {
    try {
        if (Array.isArray(req.body)) {
            const vehiculos = await Vehiculo.insertMany(req.body);
            res.status(201).json(vehiculos);
        } else {
            const vehiculo = new Vehiculo(req.body);
            await vehiculo.save();
            res.status(201).json(vehiculo);
        }
    } catch (error) {
        res.status(400).json({ error: error.message }); 
    }
});
router.get('/soat/:idVehiculo', async (req, res) => {
  try {
    const vehiculo = await Vehiculo.findOne(
      { idVehiculo: Number(req.params.idVehiculo) },
      { placaVehiculo: 1, SoatVehiculo: 1, _id: 0 }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.get('/vehiculo/:idVehiculo', async (req, res) => {
  try {
    const vehiculo = await Vehiculo.findOne({ idVehiculo: Number(req.params.idVehiculo) });

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

//consultar todos los productos
router.get('/',async(req,res)=>{
    try{
        const vehiculos=await Vehiculo.find();
        res.json(vehiculos);

    }catch(error){
        res.status(500).json({ error: error.menssage});
}
})
router.get('/impuesto/:idVehiculo', async (req, res) => {
  try {
    const vehiculo = await Vehiculo.findOne(
      { idVehiculo: Number(req.params.idVehiculo) },  
      { placaVehiculo: 1, valorImpuesto: 1, _id: 0 }  
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/masReparaciones', async (req, res) => {
  try {
    const vehiculos = await Vehiculo.find({}, {
      _id: 0,
      idVehiculo: 1,
      placaVehiculo: 1,
      cantidadReparaciones: 1
    })
    .sort({ cantidadReparaciones: -1 }) // Orden descendente
    .limit(5); // Solo los 5 primeros

    if (vehiculos.length === 0) {
      return res.status(404).json({ mensaje: 'No hay vehículos registrados con reparaciones' });
    }

    res.json(vehiculos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/estado/:idVehiculo', async (req, res) => {
  try {
    const vehiculo = await Vehiculo.findOne(
      { idVehiculo: Number(req.params.idVehiculo) },
      { _id: 0, placaVehiculo: 1, estadoVehiculo: 1 }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/:idVehiculo', async (req, res) => {
  try {
    const vehiculo = await Vehiculo.findOne({ idVehiculo: req.params.idVehiculo });
    if (!vehiculo) return res.status(404).json({ error: 'Vehículo no encontrado' });
    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message }); 
  }
});

router.get('/reparaciones/:idVehiculo', async (req, res) => {
  try {
    const vehiculo = await Vehiculo.findOne(
      { idVehiculo: Number(req.params.idVehiculo) },
      { placaVehiculo: 1, cantidadReparaciones: 1, _id: 0 }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.put('/reparaciones/:idVehiculo', async (req, res) => {
  try {
    const { cantidadReparaciones } = req.body;

    if (cantidadReparaciones === undefined) {
      return res.status(400).json({ error: 'El campo cantidadReparaciones es requerido' });
    }

    const vehiculo = await Vehiculo.findOneAndUpdate(
      { idVehiculo: Number(req.params.idVehiculo) },
      { cantidadReparaciones },
      { new: true }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put('/soat/:idVehiculo', async (req, res) => {
  try {
    const { placaVehiculo, SoatVehiculo } = req.body;

    if (!placaVehiculo && !SoatVehiculo) {
      return res.status(400).json({ error: 'Debe enviar al menos placaVehiculo o SoatVehiculo para actualizar' });
    }

    const updateData = {};
    if (placaVehiculo) updateData.placaVehiculo = placaVehiculo;
    if (SoatVehiculo) updateData.SoatVehiculo = SoatVehiculo;

    const vehiculo = await Vehiculo.findOneAndUpdate(
      { idVehiculo: Number(req.params.idVehiculo) },
      updateData,
      { new: true }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.put('/impuesto/:idVehiculo', async (req, res) => {
  try {
    const { valorImpuesto } = req.body;

    if (valorImpuesto === undefined) {
      return res.status(400).json({ error: 'El valorImpuesto es requerido' });
    }

    const vehiculo = await Vehiculo.findOneAndUpdate(
      { idVehiculo: Number(req.params.idVehiculo) },
      { valorImpuesto },
      { new: true }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



// Actualizar solo el estado del vehículo por idVehiculo
router.put('/estado/:idVehiculo', async (req, res) => {
  try {
    const { estadoVehiculo } = req.body;

    if (!estadoVehiculo) {
      return res.status(400).json({ error: 'El nuevo estadoVehiculo es requerido' });
    }

    const vehiculo = await Vehiculo.findOneAndUpdate(
      { idVehiculo: req.params.idVehiculo },
      { estadoVehiculo },
      { new: true }
    );

    if (!vehiculo) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json(vehiculo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.delete('/:idVehiculo', async (req, res) => {
  try {
    const id = Number(req.params.idVehiculo);
    const vehiculoEliminado = await Vehiculo.findOneAndDelete({ idVehiculo: id });

    if (!vehiculoEliminado) {
      return res.status(404).json({ error: 'Vehículo no encontrado' });
    }

    res.json({ mensaje: 'Vehículo eliminado correctamente', vehiculo: vehiculoEliminado });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports=router;

