const express=require('express');
const mongoose=require('mongoose');
const bodyParser=require('body-parser');
const cors=require('cors');
const vehiculoRoutes=require('./routes/vehiculoRoutes')
const conductorRoutes=require('./routes/conductorRoutes')
const gastoRoutes=require('./routes/gastoRoutes')
const viajeRoutes=require('./routes/viajeRoutes')
const app=express();
const PORT=3000;

//Midleware
app.use(bodyParser.json());
app.use(cors());

//conexion a mongo

mongoose.connect('mongodb://localhost:27017/bdNosqltransportadora',{
    useNewUrlParser:true,
    useUnifiedTopology:true,
})
.then(()=>console.log("MongoDB conectado"))
.catch(err=>console.err(err))

//Rutas
app.use('/api/Conductor',conductorRoutes);
app.use('/api/Vehiculo',vehiculoRoutes);
app.use('/api/Gasto',gastoRoutes);
app.use('/api/Gasto',viajeRoutes);
app.listen(PORT,()=>{
    console.log(`Servidor conectado en http://localhost:${PORT}`);
});


