import express from 'express';
import sql from 'mssql';
import config from "./config/ConfigDB";

const app = express();
app.use(express.json());


// Este es el endpoint para obtener los clientes (select)
app.get("/Clientes", async (req, res) => {
    try {
        let pool = await sql.connect(config);

        let result = await pool.request().query('exec selectClientes');
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).send("Hubo un error en la base de datos");
    
    }
});

// Este es el post para insertar un cliente (insert)
app.post("/ClientesR", async (req, res) => {
    try {
        const { TipoPersona, Nombre, SegundoNombre, Apellido } = req.body;

        const tiposValidos = ["EM", "SC", "VC"]; 
        if (!tiposValidos.includes(TipoPersona)) {
            return res.status(400).json({ error: "tipoPersona inválido. Debe ser EM, SC o VC." });
        }
        const segundoNombreN = SegundoNombre || null;

        let pool = await sql.connect(config);
        let result = await pool.request()
            .input("tipoPersona", sql.VarChar, TipoPersona)
            .input("Nombre", sql.VarChar, Nombre)
            .input("SegundoNombre", sql.VarChar, segundoNombreN)
            .input("Apellido", sql.VarChar, Apellido)
            .execute("insertClientes"); // tu SP en SQL Server

        res.json({ message: "Cliente insertado correctamente", result: result.recordset });
    } catch (err) {
        console.error(err);
        res.status(500).send("Hubo un error en la base de datos");
    }
});


// Este es el post para insertar una tienda (insert)
app.post("/TiendasI", async (req, res) => {
    try {
        const { NombreTienda, IdVendedor } = req.body;

        let pool = await sql.connect(config);
        let result = await pool.request()
            .input("NombreTienda", sql.VarChar, NombreTienda)
            .input("IdVendedor", sql.Int , IdVendedor)
            .execute("insertTiendas")
        res.json({ message: "Tienda insertada correctamente", result: result.recordset });
    
    } catch(err) {
        console.error(err);
        res.status(500).send("Hay un error en la base de datos");
    }
})

app.delete("/NoCelularCorreoP", async (req, res) => {
    try {
        const { tipoTrabajo, nombre, segundoNombreP, apellidoP} = req.body;
        const segundoNombrePN = segundoNombreP || null;
        let pool = await sql.connect(config);
        let result = await pool.request()
            .input("PersonType", sql.VarChar,tipoTrabajo)
            .input("FirstName", sql.VarChar, nombre)
            .input("MiddleName", sql.VarChar, segundoNombrePN)
            .input("LastName", sql.VarChar, apellidoP)
            .execute("eliminarCelularCorreoP")
            res.json({ 
            message: "Se eliminaron correctamente los datos.", 
            result: result.recordset 
            });
    } catch(err) {
        console.error(err);
        res.status(500).send("Hay un error en la base de datos");
    }
})

app.patch("/TiendasI/Actualizacion", async (req, res) => {
    try {
        const { NombreTienda, NuevoNombre } = req.body;

        let pool = await sql.connect(config);
        let result = await pool.request()
            .input("NombreTienda", sql.VarChar, NombreTienda)
            .input("NuevoNombre", sql.VarChar, NuevoNombre)
            .execute("actualizarNombreTienda")
        res.json({ message: "Tienda insertada correctamente", result: result.recordset });
    
    } catch(err) {
        console.error(err);
        res.status(500).send("Hay un error en la base de datos");
    } 
})

// Este es el endpoint para obtener las tiendas (select)
app.get("/Tiendas", async (req, res) => {
    try {
        let pool = await sql.connect(config);

        let result = await pool.request().query('exec verTiendas');
        res.json(result.recordset);
    } catch(err) {
        console.error(err);
        res.status(500).send("Hay un error en la base de datos");
    }
});


// Este es el endpoint para obtener los trabajadores (select)
app.get("/Trabajadores", async (req, res) => {
    try {
        let pool = await sql.connect(config);
        let result = await pool.request().query('exec verTrabajadores');
        res.json(result.recordset);
    } catch(err) {
        console.error(err);
        res.status(500).send("Hay un error en la base de datos");
    }
});



//Aquí hago un endopoint en el cual mando el requisito de la llamada y la respuesta
app.get("/", (req, res) => {
    res.send("Hello motherfuckers");
})

app.listen(3000, () => {
    console.log('Server listening on port 3000');
});




