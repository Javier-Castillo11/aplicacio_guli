const express = require('express');
const multer = require('multer');
const cors = require('cors');
const { execFile } = require('child_process');
const path = require('path');
const fs = require('fs');
const jwt = require('jsonwebtoken');
const ffmpeg = require('fluent-ffmpeg');
const { Writable } = require('stream');


//seccion de conexion Bd
const mysql = require('mysql2');
const bcrypt = require('bcrypt');

// Conexión MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'huevos1',
  database: 'bd_guli'
});

db.connect((err) => {
  if (err) {
    console.error('Error al conectar a la base de datos:', err);
    return;
  }
  console.log('Conectado a la base de datos MySQL');
});
////

const app = express();
const port = 3000;

// Middleware
app.use(cors({
  origin: '*', // O especifica los dominios permitidos: ['http://tudominio.com', 'http://localhost:port']
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

///seccion de perfiles
app.post('/guardarRol', async (req, res) => {
  const { id_usuario, tipo_perfil } = req.body;

  if (!id_usuario || !tipo_perfil) {
    return res.status(400).json({ error: 'Faltan datos requeridos.' });
  }

  try {
    // Insertar el rol/perfil en la tabla "perfiles"
    const sql = `
      INSERT INTO perfiles (id_usuario, tipo_perfil)
      VALUES (?, ?)
    `;
    await db.promise().query(sql, [id_usuario, tipo_perfil]);

    res.status(200).json({ mensaje: 'Perfil guardado correctamente.' });
  } catch (error) {
    console.error('Error al guardar el perfil:', error);
    res.status(500).json({ error: 'Error interno al guardar el perfil.' });
  }
});
////

app.use(express.json()); // Para parsear JSON
app.use(express.urlencoded({ extended: true })); 

// Configurar Multer con nombre personalizado que mantenga la extensión original
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1E9)}${ext}`;
    cb(null, uniqueName);
  }
});

const upload = multer({ storage });

// Ruta para recibir y clasificar la señal
app.post('/clasificar', upload.single('audio'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No se recibió ningún archivo.' });
  }

  const audioPath = path.resolve(req.file.path);
  const scriptPath = 'C:\\Users\\Javie\\Documents\\clasif\\clasif.py';

  console.log("Entrando a ejecutar el clasificador...");

  execFile('python', [scriptPath, audioPath], (error, stdout, stderr) => {
    // Borrar archivo después de procesar
    fs.unlink(audioPath, (unlinkErr) => {
      if (unlinkErr) {
        console.warn('Advertencia: no se pudo borrar el archivo temporal:', unlinkErr);
      }
    });

    if (error) {
      console.error('Error al ejecutar el script:', error);
      return res.status(500).json({ error: 'Error al ejecutar el clasificador.' });
    }

    if (stderr) {
      console.error('Error del clasificador:', stderr);
    }

    const diagnostico = stdout.trim();
    res.json({ diagnostico });
  });
});

//////////////
app.post('/registro', async (req, res) => {
  const { nombre_completo, correo_electronico, contrasena } = req.body;

  if (!nombre_completo || !correo_electronico || !contrasena) {
    return res.status(400).json({ error: 'Todos los campos son obligatorios.' });
  }

  try {
    // Verificar si el usuario ya existe
    const [rows] = await db.promise().query('SELECT * FROM usuarios WHERE correo_electronico = ?', [correo_electronico]);
    if (rows.length > 0) {
      return res.status(409).json({ error: 'El correo electrónico ya está registrado.' });
    }

    // Hashear la contraseña
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(contrasena, saltRounds);

    // Insertar nuevo usuario
    const sql = `
      INSERT INTO usuarios (nombre_completo, correo_electronico, contrasena, fecha_registro)
      VALUES (?, ?, ?, NOW())
    `;
    const [result] = await db.promise().query(sql, [nombre_completo, correo_electronico, hashedPassword]);

const userId = result.insertId; // <-- Aquí obtienes el ID del nuevo usuario


    const token = jwt.sign(
      {
        userId: result.insertId,
        email: correo_electronico
      },
      'tu_secreto_jwt',
      { expiresIn: '1h' }
    );


 res.status(201).json({
      mensaje: 'Usuario registrado exitosamente.',
      userId: result.insertId,
      token: token // <- Añadir esta línea
    });

  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).json({ error: 'Error interno del servidor.' });
  }
});
///////////////////////

// Ruta para login
app.post('/login', async (req, res) => {
  console.log('Petición POST a /login recibida');
  console.log('Body recibido:', req.body);

  const { correo_electronico, contrasena } = req.body;

  if (!correo_electronico || !contrasena) {
    return res.status(400).json({ error: 'Faltan datos requeridos.' });
  }

  try {
    const [rows] = await db.promise().query(
      `SELECT u.id_usuario, u.nombre_completo, u.correo_electronico, u.contrasena, p.tipo_perfil
       FROM usuarios u
       LEFT JOIN perfiles p ON u.id_usuario = p.id_usuario
       WHERE u.correo_electronico = ?`,
      [correo_electronico]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Correo electrónico o contraseña incorrectos.' });
    }

    const usuario = rows[0];
    const passwordMatch = await bcrypt.compare(contrasena, usuario.contrasena);

    if (!passwordMatch) {
      return res.status(401).json({ error: 'Correo electrónico o contraseña incorrectos.' });
    }

    // Generar token JWT
    const token = jwt.sign(
      {
        userId: usuario.id_usuario,
        email: usuario.correo_electronico
      },
      'tu_secreto_jwt', // Cambia esto por una clave secreta segura
      { expiresIn: '1h' }
    );

    res.status(200).json({
      token: token, // Asegúrate de enviar el token
      userId: usuario.id_usuario,
      nombre_completo: usuario.nombre_completo,
      correo_electronico: usuario.correo_electronico,
      tipo_perfil: usuario.tipo_perfil || 'sin_definir'
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ error: 'Error interno del servidor.' });
  }
});
///

app.post('/obtenerCorreo', async (req, res) => {
  const { id_usuario } = req.body;
console.log('ID recibido en /obtenerCorreo:', id_usuario); // <-- Agrega esto
  try {
    const [rows] = await db.promise().execute('SELECT correo_electronico FROM usuarios WHERE id_usuario = ?', [id_usuario]);

    if (rows.length > 0) {
      res.json({ correo: rows[0].correo_electronico });
    } else {
      res.status(404).json({ error: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error del servidor' });
  }
});

///ruta para codigo de verificacion
const nodemailer = require('nodemailer');

// Almacén temporal de códigos (en producción usa Redis o una tabla en la base de datos)
const verificationCodes = {};

app.post('/enviar-codigo-verificacion', async (req, res) => {
  const { correo_electronico } = req.body;

  if (!correo_electronico) {
    return res.status(400).json({ error: 'Correo electrónico requerido' });
  }

  // Generar código aleatorio de 4 dígitos
  const codigo = Math.floor(1000 + Math.random() * 9000).toString();

  // Guardar en memoria con tiempo de expiración (en producción mejor con Redis o DB)
  verificationCodes[correo_electronico] = {
    code: codigo,
    expiresAt: Date.now() + 60000, // 1 minuto
  };

  // Configurar el transporter con un correo real
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'l20212495@tectijuana.edu.mx',
      pass: 'iecd zqll yznu bqej', // Usa contraseña de aplicación
    },
  });

  const mailOptions = {
    from: 'Guli App <tucorreo@gmail.com>',
    to: correo_electronico,
    subject: 'Tu código de verificación',
    text: `Tu código de verificación es: ${codigo}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    res.status(200).json({ mensaje: 'Código enviado con éxito' });
  } catch (error) {
    console.error('Error al enviar correo:', error);
    res.status(500).json({ error: 'No se pudo enviar el código' });
  }
});
/////

///ruta para verificacion
app.post('/verificar-codigo', (req, res) => {
  const { correo_electronico, codigo_ingresado } = req.body;

  const registro = verificationCodes[correo_electronico];

  if (!registro || Date.now() > registro.expiresAt) {
    return res.status(400).json({ error: 'Código expirado o inválido' });
  }

  if (registro.code !== codigo_ingresado) {
    return res.status(401).json({ error: 'Código incorrecto' });
  }

  // Eliminar el código usado
  delete verificationCodes[correo_electronico];

  res.status(200).json({ mensaje: 'Código verificado correctamente' });
});
/////

///ruta para subir señales desde flutter
app.post('/subirsenales', upload.single('archivo'), async (req, res) => {
  const { id_paciente, tipo_senal, datos_senal } = req.body;

  if (!req.file || !id_paciente || !tipo_senal || !datos_senal) {
    return res.status(400).json({ error: 'Faltan datos o archivo.' });
  }

  const ruta_archivo = req.file.filename; // nombre del archivo guardado
  const fecha_subida = new Date();

  try {
    const sql = `
      INSERT INTO senales (id_paciente, tipo_senal, ruta_archivo, datos_senal, fecha_subida, estado)
      VALUES (?, ?, ?, ?, ?, 'pendiente')
    `;
    await db.promise().query(sql, [id_paciente, tipo_senal, ruta_archivo, datos_senal, fecha_subida]);

    res.status(201).json({ mensaje: 'Señal subida correctamente.' });
  } catch (error) {
    console.error('Error al guardar la señal:', error);
    res.status(500).json({ error: 'Error interno al guardar la señal.' });
  }
});
/////

// ruta para obtener lista de señales con nombre del paciente y fecha
app.get('/obtener-pacientes-con-senales', async (req, res) => {
  try {
    const sql = `
      SELECT u.id_usuario, u.nombre_completo, MAX(s.fecha_subida) AS fecha_ultima_senal
      FROM usuarios u
      JOIN senales s ON u.id_usuario = s.id_paciente
      GROUP BY u.id_usuario, u.nombre_completo
      ORDER BY fecha_ultima_senal DESC
    `;
    const [rows] = await db.promise().query(sql);
    console.log(rows); // Añade esto antes de res.json
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error al obtener pacientes:', error);
    res.status(500).json({ error: 'Error al obtener la lista de pacientes.' });
  }
});
///////

app.post('/obtener-senales-de-paciente', async (req, res) => {
  const { id_paciente } = req.body;

  try {
    const sql = `
      SELECT id_senal, tipo_senal, ruta_archivo, datos_senal, fecha_subida, estado
      FROM senales
      WHERE id_paciente = ?
      ORDER BY fecha_subida DESC
    `;
    const [rows] = await db.promise().query(sql, [id_paciente]);

    res.status(200).json({ senales: rows });
  } catch (error) {
    console.error('Error al obtener señales del paciente:', error);
    res.status(500).json({ error: 'Error interno al obtener señales.' });
  }
});
/////

app.get('/fcg/:id', async (req, res) => {
  const { id } = req.params;
  let ffmpegProcess; // Mover la declaración aquí arriba

  try {
    // Obtener info de la señal
    const [rows] = await db.promise().query(
      `SELECT s.ruta_archivo, s.datos_senal, s.fecha_subida, u.nombre_completo
       FROM senales s
       JOIN usuarios u ON s.id_paciente = u.id_usuario
       WHERE s.id_senal = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Señal no encontrada' });
    }

    const señal = rows[0];
    const filePath = path.join(__dirname, 'uploads', señal.ruta_archivo);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Archivo de audio no encontrado' });
    }

    // Configuración para extraer muestras de audio
    const samples = [];
    let duration = 0;
    let sampleRate = 44100;

    // Usar un sistema de buffer más robusto
    const { Writable } = require('stream');
    const audioProcessor = new Writable({
      write(chunk, encoding, callback) {
        try {
          for (let i = 0; i < chunk.length; i += 2) {
            if (i + 2 <= chunk.length) {
              samples.push(chunk.readInt16LE(i));
            }
          }
          callback();
        } catch (err) {
          callback(err);
        }
      }
    });

    // Procesamiento con FFmpeg
    await new Promise((resolve, reject) => {
      ffmpegProcess = ffmpeg(filePath)
        .audioChannels(1)
        .audioFrequency(sampleRate)
        .format('s16le')
        .on('start', (cmd) => console.log('Iniciando procesamiento:', cmd))
        .on('codecData', (data) => {
          duration = parseFloat(data.duration);
          console.log('Duración del audio:', duration);
        })
        .on('error', (err) => {
          console.error('Error en FFmpeg:', err);
          reject(err);
        })
        .on('end', () => {
          console.log('Procesamiento completado. Muestras:', samples.length);
          resolve();
        })
        .pipe(audioProcessor, { end: true });

      // Timeout para evitar procesos colgados
      setTimeout(() => {
        if (samples.length === 0) {
          ffmpegProcess?.kill('SIGKILL');
          reject(new Error('Timeout: No se recibieron datos'));
        }
      }, 30000);
    });

    // Reducción de muestras optimizada
    const targetSamples = Math.min(10000, samples.length); // Máximo 10,000 muestras
    const stride = Math.max(1, Math.floor(samples.length / targetSamples));
    const reducedSamples = [];
    
    for (let i = 0; i < samples.length; i += stride) {
      if (reducedSamples.length >= targetSamples) break;
      reducedSamples.push(samples[i] / 32768.0); // Normalización aquí
    }

    res.json({
      audio_url: `http://192.168.1.69:3000/uploads/${señal.ruta_archivo}`,
      audio_samples: reducedSamples,
      sample_rate: sampleRate,
      duration: duration,
      patient_name: señal.nombre_completo,
      record_date: señal.fecha_subida
    });

  } catch (error) {
    console.error('Error al procesar señal FCG:', error);
    
    if (ffmpegProcess) {
      ffmpegProcess.kill('SIGKILL');
    }

    res.status(500).json({ 
      error: 'Error al procesar audio',
      details: error.message.includes('timeout') 
        ? 'El procesamiento tardó demasiado' 
        : 'Error interno del servidor'
    });
  }
});
/////

////ruta para ecg exclusiva
app.get('/ecg/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // 1. Obtener la ruta del archivo desde la BD
    const [rows] = await db.promise().query(
      `SELECT ruta_archivo, fecha_subida, u.nombre_completo
       FROM senales s
       JOIN usuarios u ON s.id_paciente = u.id_usuario
       WHERE s.id_senal = ? AND s.tipo_senal = 'ECG'`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Registro ECG no encontrado' });
    }

    const señal = rows[0];
    const fileName = señal.ruta_archivo.trim();

    // 2. Construir ruta absoluta (¡corrige esto!)
    const uploadsDir = path.join(__dirname, 'uploads'); // __dirname es la carpeta del script
    const filePath = path.join(uploadsDir, fileName);

    console.log('Buscando archivo en:', filePath); // Debug clave

    // 3. Validar que el archivo exista
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        error: 'Archivo .dat no encontrado',
        details: `Servidor buscó en: ${filePath}`,
        fileName: fileName,
        uploadsDir: uploadsDir
      });
    }

    // 4. Leer y procesar el archivo binario
    const fileData = fs.readFileSync(filePath);
    const signalData = [];
    
    for (let i = 0; i < fileData.length; i += 2) {
      signalData.push(fileData.readInt16LE(i)); // Little-endian 16-bit
    }

    // 5. Responder con los datos
    res.json({
      signal_data: signalData,
      patient_name: señal.nombre_completo,
      record_date: señal.fecha_subida,
      sampling_rate: 250.0
    });

  } catch (error) {
    console.error('Error en /ecg:', error);
    res.status(500).json({ 
      error: 'Error al procesar el archivo',
      details: process.env.NODE_ENV === 'development' ? error.message : null
    });
  }
});
//////

///ruta para guardar los comentarios de los profesionales 
app.post('/guardar-diagnostico', async (req, res) => {
  console.log('Datos recibidos:', req.body); // <-- Agrega esto al inicio
  try {
    const { id_senal, id_profesional, diagnostico_resumen, comentario, es_urgente } = req.body;

    // Validación de campos requeridos
    if (!id_senal || !id_profesional || !diagnostico_resumen || !comentario || es_urgente === undefined) {
      return res.status(400).json({ 
        error: 'Faltan datos requeridos.',
        detalle: 'Todos los campos son obligatorios' 
      });
    }

    const fecha_diagnostico = new Date();

    // 1. Insertar diagnóstico
    const [result] = await db.promise().query(
      `INSERT INTO diagnosticos (
        id_senal, id_profesional, diagnostico_resumen, comentario, 
        fecha_diagnostico, es_urgente
      ) VALUES (?, ?, ?, ?, ?, ?)`,
      [id_senal, id_profesional, diagnostico_resumen, comentario, 
       fecha_diagnostico, es_urgente || 0]
    );

    // 2. Actualizar estado de la señal
    await db.promise().query(
      `UPDATE senales SET estado = 'diagnosticado' WHERE id_senal = ?`,
      [id_senal]
    );

    res.status(201).json({ 
      mensaje: 'Diagnóstico guardado correctamente.',
      diagnosticoId: result.insertId 
    });

  } catch (error) {
    console.error('Error al guardar diagnóstico:', error);
    res.status(500).json({ 
      error: 'Error interno al guardar el diagnóstico',
      detalle: error.message
    });
  }
});
/////

// ruta para obtener diagnósticos por paciente
app.get('/diagnosticos-por-paciente', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Token no proporcionado' });

    const payload = jwt.verify(token, 'tu_secreto_jwt');
    const pacienteId = payload.userId || payload.id; // Compatible con ambos formatos

    console.log(`Consultando diagnósticos para paciente ID: ${pacienteId}`);

    // Consulta definitiva con estructura de respuesta mejorada
    const [resultados] = await db.promise().query(`
      SELECT 
        d.id_diagnostico,
        d.diagnostico_resumen,
        d.comentario,
        DATE_FORMAT(d.fecha_diagnostico, '%Y-%m-%d %H:%i:%s') as fecha_diagnostico,
        d.es_urgente,
        u_prof.nombre_completo as profesional_nombre,
        s.tipo_senal,
        s.ruta_archivo,
        DATE_FORMAT(s.fecha_subida, '%Y-%m-%d %H:%i:%s') as fecha_subida,
        s.id_senal,
        s.id_paciente,
        u_pac.nombre_completo as paciente_nombre
      FROM 
        diagnosticos d
        JOIN senales s ON d.id_senal = s.id_senal
        JOIN usuarios u_prof ON d.id_profesional = u_prof.id_usuario
        JOIN usuarios u_pac ON s.id_paciente = u_pac.id_usuario
      WHERE 
        s.id_paciente = ? AND u_pac.id_usuario = ?
      ORDER BY 
        d.fecha_diagnostico DESC
    `, [pacienteId, pacienteId]);

    console.log(`Número de diagnósticos encontrados: ${resultados.length}`);
    
    // Respuesta estructurada según la solución propuesta
    res.setHeader('Content-Type', 'application/json');
    res.status(200).json({
      success: true,
      count: resultados.length,
      diagnosticos: resultados
    });
    
  } catch (error) {
    console.error('Error en /diagnosticos-por-paciente:', {
      error: error.message,
      stack: error.stack
    });
    
    res.status(500).json({ 
      success: false,
      error: 'Error interno del servidor',
      detalle: error.message
    });
  }
});
/////

app.get('/todos-diagnosticos-debug', async (req, res) => {
  try {
    const [diagnosticos] = await db.promise().query(`
      SELECT 
        d.*, 
        s.id_paciente,
        u_pac.nombre_completo as paciente_nombre,
        u_prof.nombre_completo as profesional_nombre
      FROM 
        diagnosticos d
        JOIN senales s ON d.id_senal = s.id_senal
        JOIN usuarios u_pac ON s.id_paciente = u_pac.id_usuario
        JOIN usuarios u_prof ON d.id_profesional = u_prof.id_usuario
      ORDER BY d.fecha_diagnostico DESC
    `);
    
    res.status(200).json(diagnosticos);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Error al obtener diagnósticos' });
  }
});

// Ruta para actualizar contraseña
app.post('/actualizar-contrasena', async (req, res) => {

  console.log('Body recibido:', req.body); // Debug crucial
  
  if (!req.body || !req.body.correo_electronico) {
    return res.status(400).json({ 
      error: 'Formato incorrecto. Se requiere {correo_electronico: string}' 
    });
  }

  const { correo_electronico, nueva_contrasena } = req.body;

  if (!correo_electronico || !nueva_contrasena) {
    return res.status(400).json({ error: 'Faltan datos requeridos.' });
  }

  try {
    // Hashear la nueva contraseña
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(nueva_contrasena, saltRounds);

    // Actualizar contraseña en la base de datos
    await db.promise().query(
      'UPDATE usuarios SET contrasena = ? WHERE correo_electronico = ?',
      [hashedPassword, correo_electronico]
    );

    res.status(200).json({ mensaje: 'Contraseña actualizada correctamente.' });
  } catch (error) {
    console.error('Error al actualizar contraseña:', error);
    res.status(500).json({ error: 'Error interno al actualizar la contraseña.' });
  }
});
////

// Nueva ruta para obtener datos del usuario
app.get('/obtener-datos-usuario', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Token no proporcionado' });

    const payload = jwt.verify(token, 'tu_secreto_jwt');
    const userId = payload.userId;

    const [rows] = await db.promise().query(
      `SELECT u.correo_electronico, p.tipo_perfil 
       FROM usuarios u
       LEFT JOIN perfiles p ON u.id_usuario = p.id_usuario
       WHERE u.id_usuario = ?`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({
      correo_electronico: rows[0].correo_electronico,
      tipo_perfil: rows[0].tipo_perfil || 'sin_definir'
    });

  } catch (error) {
    console.error('Error en /obtener-datos-usuario:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});
//

// Ruta alternativa específica para cambio de contraseña desde la app
app.post('/cambio-contrasena-app', async (req, res) => {
  const { correo, codigo_verificacion, nueva_contrasena } = req.body;

  if (!correo || !codigo_verificacion || !nueva_contrasena) {
    return res.status(400).json({ error: 'Faltan campos requeridos' });
  }

  try {
    // 1. Verificar el código (puedes reutilizar tu lógica actual)
    const codigoValido = verificationCodes[correo]?.code === codigo_verificacion;
    const codigoExpirado = verificationCodes[correo]?.expiresAt < Date.now();

    if (!codigoValido || codigoExpirado) {
      return res.status(401).json({ error: 'Código inválido o expirado' });
    }

    // 2. Cambiar la contraseña
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(nueva_contrasena, saltRounds);

    await db.promise().query(
      'UPDATE usuarios SET contrasena = ? WHERE correo_electronico = ?',
      [hashedPassword, correo]
    );

    // Eliminar el código usado
    delete verificationCodes[correo];

    res.status(200).json({ mensaje: 'Contraseña actualizada exitosamente' });
  } catch (error) {
    console.error('Error en cambio-contrasena-app:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});
//

///
app.get('/obtener-perfil-completo', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, error: 'Token no proporcionado' });

    const payload = jwt.verify(token, 'tu_secreto_jwt');
    const userId = payload.userId;

    const [userData] = await db.promise().query(
      `SELECT 
        u.id_usuario,
        u.nombre_completo,
        u.correo_electronico,
        DATE_FORMAT(u.fecha_registro, '%Y-%m-%d %H:%i:%s') as fecha_registro,
        DATE_FORMAT(u.ultimo_login, '%Y-%m-%d %H:%i:%s') as ultimo_login,
        p.tipo_perfil
       FROM usuarios u
       LEFT JOIN perfiles p ON u.id_usuario = p.id_usuario
       WHERE u.id_usuario = ?`,
      [userId]
    );

    if (userData.length === 0) {
      return res.status(404).json({ success: false, error: 'Usuario no encontrado' });
    }

    // DEBUG: Verificar dato antes de enviar
    console.log('Datos crudos de DB:', userData[0]);

    // Mantener el valor original sin transformar
    const tipoPerfil = userData[0].tipo_perfil || 'paciente';

    res.json({
      success: true,
      datos: {
        ...userData[0],
        tipo_perfil: tipoPerfil // Envía el valor exacto de la BD
      }
    });

  } catch (error) {
    console.error('Error en /obtener-perfil-completo:', error);
    res.status(500).json({ success: false, error: 'Error interno del servidor' });
  }
});
///

///
app.post('/obtener-rol-usuario', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, error: 'Token no proporcionado' });

    const payload = jwt.verify(token, 'tu_secreto_jwt');
    const userId = payload.userId;

    console.log(`Solicitud de rol para usuario ID: ${userId}`);

    const [rows] = await db.promise().query(
      'SELECT tipo_perfil FROM perfiles WHERE id_usuario = ?',
      [userId]
    );

    if (rows.length > 0) {
      res.json({
        success: true,
        tipo_perfil: rows[0].tipo_perfil
      });
    } else {
      // Si no encuentra perfil, devolvemos 'patient' como valor por defecto
      res.json({
        success: true,
        tipo_perfil: 'patient'
      });
    }
  } catch (error) {
    console.error('Error en /obtener-rol-usuario:', error);
    
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(401).json({ 
        success: false,
        error: 'Token inválido o expirado' 
      });
    }
    
    res.status(500).json({
      success: false,
      error: 'Error al obtener el rol del usuario'
    });
  }
});
///

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
