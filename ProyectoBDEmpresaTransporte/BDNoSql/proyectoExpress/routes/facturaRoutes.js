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