const express=require('express');
const router=express.Router();
const Factura=require('../models/Factura');
const GastoFactura = require('../models/GastoFactura');

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

router.get('/viajesFrecuentes', async (req, res) => {
  try {
    const resultado = await Factura.aggregate([
      {
        $group: {
          _id: "$idViajeFK",
          frecuencia: { $sum: 1 }
        }
      },
      {
        $sort: { frecuencia: -1 }
      },
      {
        $limit: 5
      },
      {
        $lookup: {
          from: 'viajes', // nombre real de la colección
          localField: '_id',
          foreignField: 'idViaje',
          as: 'infoViaje'
        }
      },
      {
        $unwind: "$infoViaje"
      },
      {
        $project: {
          _id: 0,
          idViaje: "$_id",
          frecuencia: 1,
          lugarOrigen: "$infoViaje.lugarOrigen",
          lugarDestino: "$infoViaje.lugarDestino",
          duracionEstimada: "$infoViaje.duracionEstimada"
        }
      }
    ]);

    res.json(resultado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/viajesConductor/:idConductor', async (req, res) => {
  try {
    const idConductor = Number(req.params.idConductor);

    const resultado = await Factura.aggregate([
      { $match: { idConductorFK: idConductor } },
      {
        $lookup: {
          from: 'viajes',  // nombre exacto de la colección de viajes en MongoDB
          localField: 'idViajeFK',
          foreignField: 'idViaje',
          as: 'viaje'
        }
      },
      { $unwind: '$viaje' },
      {
        $project: {
          _id: 0,
          idViaje: '$viaje.idViaje',
          lugarOrigen: '$viaje.lugarOrigen',
          lugarDestino: '$viaje.lugarDestino',
          duracionEstimada: '$viaje.duracionEstimada',
          numEscalas: '$viaje.numEscalas',
          valorViaje: 1,
          utilidadesViaje: 1
        }
      }
    ]);

    if (resultado.length === 0) {
      return res.status(404).json({ error: 'No se encontraron viajes para ese conductor' });
    }

    res.json(resultado);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/origenComun', async (req, res) => {
  try {
    const resultado = await Factura.aggregate([
      {
        $lookup: {
          from: 'viajes', 
          localField: 'idViajeFK',
          foreignField: 'idViaje',
          as: 'viaje'
        }
      },
      { $unwind: "$viaje" },
      {
        $group: {
          _id: "$viaje.lugarOrigen",
          total: { $sum: 1 }
        }
      },
      { $sort: { total: -1 } },
      { $limit: 1 },
      {
        $project: {
          _id: 0,
          lugarOrigen: "$_id",
          total: 1
        }
      }
    ]);

    if (resultado.length === 0) {
      return res.status(404).json({ error: 'No hay registros de facturas o viajes' });
    }

    res.json(resultado[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/:idFactura/gastos', async (req, res) => {
  try {
    const idFactura = Number(req.params.idFactura);

    const gastos = await GastoFactura.aggregate([
      { $match: { idFacturaFK: idFactura } },
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
          valorGasto: 1,
          descripcionGasto: '$detalleGasto.descripcionGasto',
          nombreGasto: '$detalleGasto.nombreGasto',
          tipoGasto: '$detalleGasto.tipoGasto'
        }
      }
    ]);

    if (gastos.length === 0) {
      return res.status(404).json({ error: 'No se encontraron gastos para esta factura' });
    }

    res.json(gastos);
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
    const factura = await Factura.find(filtro);
    res.json(factura);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
router.get('/mejoresClientes', async (req, res) => {
  try {
    const resultado = await Factura.aggregate([
      {
        $group: {
          _id: '$idClienteFK',
          totalPagado: { $sum: '$valorViaje' }
        }
      },
      {
        $sort: { totalPagado: -1 }
      },
      {
        $limit: 5
      },
      {
        $lookup: {
          from: 'clientes', // nombre de la colección en Mongo (no el modelo)
          localField: '_id',
          foreignField: 'idCliente',
          as: 'cliente'
        }
      },
      {
        $unwind: '$cliente'
      },
      {
        $project: {
          _id: 0,
          idCliente: '$_id',
          nombreCliente: '$cliente.nombreCliente',
          totalQueHaPagadoALaEmpresa: '$totalPagado'
        }
      }
    ]);

    res.json(resultado);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/completa/:idFactura', async (req, res) => {
  try {
    const id = Number(req.params.idFactura);

    const resultado = await Factura.aggregate([
      {
        $match: { idFactura: id }
      },
      // Cliente
      {
        $lookup: {
          from: 'clientes',
          localField: 'idClienteFK',
          foreignField: 'idCliente',
          as: 'cliente'
        }
      },
      { $unwind: '$cliente' },

      // Conductor
      {
        $lookup: {
          from: 'conductores',
          localField: 'idConductorFK',
          foreignField: 'idConductor',
          as: 'conductor'
        }
      },
      { $unwind: '$conductor' },

      // Viaje
      {
        $lookup: {
          from: 'viajes',
          localField: 'idViajeFK',
          foreignField: 'idViaje',
          as: 'viaje'
        }
      },
      { $unwind: '$viaje' },

      // Vehículo
      {
        $lookup: {
          from: 'vehiculos',
          localField: 'idVehiculoFK',
          foreignField: 'idVehiculo',
          as: 'vehiculo'
        }
      },
      { $unwind: '$vehiculo' },

      // Solo los campos necesarios
      {
        $project: {
          _id: 0,
          idFactura: 1,
          FechaFacturacion: 1,
          valorViaje: 1,
          utilidadesViaje: 1,
          nombreCliente: '$cliente.nombreCliente',
          nombreConductor: '$conductor.nombreConductor',
          origen: '$viaje.origen',
          destino: '$viaje.destino',
          placaVehiculo: '$vehiculo.placaVehiculo'
        }
      }
    ]);

    if (resultado.length === 0) {
      return res.status(404).json({ error: 'Factura no encontrada' });
    }

    res.json(resultado[0]);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


//consultar prodcuto por id
router.get('/:idFactura', async (req, res) => {
  try {
    const factura = await Factura.findOne({ idFactura: req.params.idFactura });
    if (!factura) return res.status(404).json({ error: 'Factura no encontrada' });
    res.json(factura);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

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

router.delete('/:idFactura', async (req, res) => {
  try {
    const id = Number(req.params.idFactura);
    const facturaEliminada = await Factura.findOneAndDelete({ idFactura: id });

    if (!facturaEliminada) {
      return res.status(404).json({ error: 'Factura no encontrada' });
    }

    res.json({ mensaje: 'Factura eliminada correctamente', factura: facturaEliminada });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports=router;