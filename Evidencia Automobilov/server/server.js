const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

const config = {
  server: process.env.DB_SERVER || 'localhost',
  port: parseInt(process.env.DB_PORT || '1433', 10),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

let poolPromise = null;

async function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect(config);
    await poolPromise;
    console.log('Pripojené k MSSQL');
  }
  return poolPromise;
}

function safeText(value) {
  return value === undefined || value === null ? null : String(value).trim();
}

app.get('/', (req, res) => {
  res.send('API evidencie automobilov beží');
});

app.get('/debug-db', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        DB_NAME() AS databaza,
        SUSER_SNAME() AS prihlaseny_uzivatel,
        @@SERVERNAME AS server_name
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// MAJITELIA
// =========================

app.get(['/api/majitelia', '/api/owners'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, meno, priezvisko, rodne_cislo, telefon, email
      FROM Majitel
      ORDER BY priezvisko, meno
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/majitelia/:id', '/api/owners/:id'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, parseInt(req.params.id, 10))
      .query(`
        SELECT id, meno, priezvisko, rodne_cislo, telefon, email
        FROM Majitel
        WHERE id = @id
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Majiteľ sa nenašiel' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post(['/api/majitelia', '/api/owners'], async (req, res) => {
  try {
    const meno = safeText(req.body.meno);
    const priezvisko = safeText(req.body.priezvisko);
    const rodneCislo = safeText(req.body.rodneCislo || req.body.rodne_cislo);
    const telefon = safeText(req.body.telefon);
    const email = safeText(req.body.email);

    if (!meno || !priezvisko || !rodneCislo) {
      return res.status(400).json({ error: 'Meno, priezvisko a rodné číslo sú povinné' });
    }

    const pool = await getPool();
    await pool.request()
      .input('meno', sql.VarChar(50), meno)
      .input('priezvisko', sql.VarChar(50), priezvisko)
      .input('rodne_cislo', sql.VarChar(20), rodneCislo)
      .input('telefon', sql.VarChar(20), telefon)
      .input('email', sql.VarChar(100), email)
      .query(`
        INSERT INTO Majitel (meno, priezvisko, rodne_cislo, telefon, email)
        VALUES (@meno, @priezvisko, @rodne_cislo, @telefon, @email)
      `);

    res.json({ sprava: 'Majiteľ bol pridaný' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete(['/api/majitelia/:id', '/api/owners/:id'], async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const pool = await getPool();

    await pool.request()
      .input('id', sql.Int, id)
      .query(`DELETE FROM Majitel WHERE id = @id`);

    res.json({ sprava: 'Majiteľ bol zmazaný' });
  } catch (err) {
    res.status(500).json({
      error: 'Majiteľa sa nepodarilo zmazať. Pravdepodobne je naviazaný na vozidlo alebo históriu.',
      detail: err.message
    });
  }
});

// =========================
// ZNAČKY A ČÍSELNÍKY
// =========================

app.get('/api/znacky', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM Znacka
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/modely', async (req, res) => {
  try {
    const pool = await getPool();
    const znackaId = req.query.znackaId ? parseInt(req.query.znackaId, 10) : null;

    const request = pool.request();
    let query = `
      SELECT m.id, m.nazov, m.znacka_id, z.nazov AS znacka
      FROM Model m
      JOIN Znacka z ON m.znacka_id = z.id
    `;

    if (znackaId) {
      query += ` WHERE m.znacka_id = @znackaId`;
      request.input('znackaId', sql.Int, znackaId);
    }

    query += ` ORDER BY z.nazov, m.nazov`;

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/palivo', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM Palivo
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/farby', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM Farba
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/prevodovky', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM Prevodovka
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/karoserie', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM Karoseria
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/poistovne', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM Poistovna
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/druhy-servisu', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov
      FROM DruhServisu
      ORDER BY nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/stk-stanice', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT id, nazov, mesto, ulica
      FROM STKStanica
      ORDER BY mesto, nazov
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// VOZIDLÁ
// =========================

app.get(['/api/vozidla', '/api/vehicles'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        a.id,
        a.VIN,
        a.rok,
        a.stav,
        a.model_id,
        a.palivo_id,
        a.farba_id,
        a.prevodovka_id,
        a.karoseria_id,
        a.majitel_id,
        m.nazov AS model,
        z.nazov AS znacka,
        p.nazov AS palivo,
        f.nazov AS farba,
        pr.nazov AS prevodovka,
        k.nazov AS karoseria,
        maj.meno,
        maj.priezvisko,
        maj.rodne_cislo,
        maj.telefon,
        maj.email
      FROM Automobil a
      JOIN Model m ON a.model_id = m.id
      JOIN Znacka z ON m.znacka_id = z.id
      LEFT JOIN Palivo p ON a.palivo_id = p.id
      LEFT JOIN Farba f ON a.farba_id = f.id
      LEFT JOIN Prevodovka pr ON a.prevodovka_id = pr.id
      LEFT JOIN Karoseria k ON a.karoseria_id = k.id
      JOIN Majitel maj ON a.majitel_id = maj.id
      ORDER BY a.id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/vozidla/:id', '/api/vehicles/:id'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, parseInt(req.params.id, 10))
      .query(`
        SELECT
          a.id,
          a.VIN,
          a.rok,
          a.stav,
          a.model_id,
          a.palivo_id,
          a.farba_id,
          a.prevodovka_id,
          a.karoseria_id,
          a.majitel_id,
          m.nazov AS model,
          z.nazov AS znacka,
          p.nazov AS palivo,
          f.nazov AS farba,
          pr.nazov AS prevodovka,
          k.nazov AS karoseria,
          maj.meno,
          maj.priezvisko,
          maj.rodne_cislo,
          maj.telefon,
          maj.email
        FROM Automobil a
        JOIN Model m ON a.model_id = m.id
        JOIN Znacka z ON m.znacka_id = z.id
        LEFT JOIN Palivo p ON a.palivo_id = p.id
        LEFT JOIN Farba f ON a.farba_id = f.id
        LEFT JOIN Prevodovka pr ON a.prevodovka_id = pr.id
        LEFT JOIN Karoseria k ON a.karoseria_id = k.id
        JOIN Majitel maj ON a.majitel_id = maj.id
        WHERE a.id = @id
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Vozidlo sa nenašlo' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/vozidla/search', '/api/vehicles/search'], async (req, res) => {
  try {
    const pool = await getPool();
    const { vin, owner, majitel, majitelId } = req.query;

    const request = pool.request();
    let query = `
      SELECT
        a.id,
        a.VIN,
        a.rok,
        a.stav,
        m.nazov AS model,
        z.nazov AS znacka,
        maj.meno,
        maj.priezvisko,
        maj.id AS majitel_id
      FROM Automobil a
      JOIN Model m ON a.model_id = m.id
      JOIN Znacka z ON m.znacka_id = z.id
      JOIN Majitel maj ON a.majitel_id = maj.id
      WHERE 1 = 1
    `;

    const searchOwner = owner || majitel;

    if (vin) {
      query += ` AND a.VIN LIKE @vin`;
      request.input('vin', sql.VarChar(17), `%${String(vin).trim()}%`);
    }

    if (majitelId) {
      query += ` AND a.majitel_id = @majitelId`;
      request.input('majitelId', sql.Int, parseInt(majitelId, 10));
    } else if (searchOwner) {
      query += ` AND (
        maj.meno LIKE @ownerText OR
        maj.priezvisko LIKE @ownerText OR
        (maj.meno + ' ' + maj.priezvisko) LIKE @ownerText
      )`;
      request.input('ownerText', sql.VarChar(150), `%${String(searchOwner).trim()}%`);
    }

    query += ` ORDER BY a.id DESC`;

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/majitelia/:id/vozidla', '/api/owners/:id/vehicles'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, parseInt(req.params.id, 10))
      .query(`
        SELECT
          a.id,
          a.VIN,
          a.rok,
          a.stav,
          m.nazov AS model,
          z.nazov AS znacka
        FROM Automobil a
        JOIN Model m ON a.model_id = m.id
        JOIN Znacka z ON m.znacka_id = z.id
        WHERE a.majitel_id = @id
        ORDER BY a.id DESC
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post(['/api/vozidla', '/api/vehicles'], async (req, res) => {
  try {
    const {
      vin,
      modelId,
      palivoId,
      farbaId,
      prevodovkaId,
      karoseriaId,
      rok,
      majitelId,
      stav
    } = req.body;

    if (!vin || !modelId || !majitelId) {
      return res.status(400).json({ error: 'VIN, modelId a majitelId sú povinné' });
    }

    const pool = await getPool();
    await pool.request()
      .input('VIN', sql.VarChar(17), String(vin).trim())
      .input('model_id', sql.Int, parseInt(modelId, 10))
      .input('palivo_id', sql.Int, palivoId ? parseInt(palivoId, 10) : null)
      .input('farba_id', sql.Int, farbaId ? parseInt(farbaId, 10) : null)
      .input('prevodovka_id', sql.Int, prevodovkaId ? parseInt(prevodovkaId, 10) : null)
      .input('karoseria_id', sql.Int, karoseriaId ? parseInt(karoseriaId, 10) : null)
      .input('rok', sql.Int, rok ? parseInt(rok, 10) : null)
      .input('majitel_id', sql.Int, parseInt(majitelId, 10))
      .input('stav', sql.VarChar(20), stav || 'AKTIVNE')
      .query(`
        INSERT INTO Automobil
          (VIN, model_id, palivo_id, farba_id, prevodovka_id, karoseria_id, rok, majitel_id, stav)
        VALUES
          (@VIN, @model_id, @palivo_id, @farba_id, @prevodovka_id, @karoseria_id, @rok, @majitel_id, @stav)
      `);

    res.json({ sprava: 'Vozidlo bolo pridané' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put(['/api/vozidla/:id', '/api/vehicles/:id'], async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const {
      vin,
      modelId,
      palivoId,
      farbaId,
      prevodovkaId,
      karoseriaId,
      rok,
      majitelId,
      stav
    } = req.body;

    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, id)
      .input('VIN', sql.VarChar(17), vin ? String(vin).trim() : null)
      .input('model_id', sql.Int, modelId ? parseInt(modelId, 10) : null)
      .input('palivo_id', sql.Int, palivoId ? parseInt(palivoId, 10) : null)
      .input('farba_id', sql.Int, farbaId ? parseInt(farbaId, 10) : null)
      .input('prevodovka_id', sql.Int, prevodovkaId ? parseInt(prevodovkaId, 10) : null)
      .input('karoseria_id', sql.Int, karoseriaId ? parseInt(karoseriaId, 10) : null)
      .input('rok', sql.Int, rok ? parseInt(rok, 10) : null)
      .input('majitel_id', sql.Int, majitelId ? parseInt(majitelId, 10) : null)
      .input('stav', sql.VarChar(20), stav || null)
      .query(`
        UPDATE Automobil
        SET
          VIN = COALESCE(@VIN, VIN),
          model_id = COALESCE(@model_id, model_id),
          palivo_id = COALESCE(@palivo_id, palivo_id),
          farba_id = COALESCE(@farba_id, farba_id),
          prevodovka_id = COALESCE(@prevodovka_id, prevodovka_id),
          karoseria_id = COALESCE(@karoseria_id, karoseria_id),
          rok = COALESCE(@rok, rok),
          majitel_id = COALESCE(@majitel_id, majitel_id),
          stav = COALESCE(@stav, stav)
        WHERE id = @id
      `);

    res.json({ sprava: 'Vozidlo bolo upravené' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch(['/api/vozidla/:id/vyradit', '/api/vehicles/:id/deactivate'], async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const pool = await getPool();

    await pool.request()
      .input('id', sql.Int, id)
      .query(`
        UPDATE Automobil
        SET stav = 'VYRADENE'
        WHERE id = @id
      `);

    res.json({ sprava: 'Vozidlo bolo vyradené' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete(['/api/vozidla/:id', '/api/vehicles/:id'], async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const pool = await getPool();

    await pool.request()
      .input('id', sql.Int, id)
      .query(`DELETE FROM Automobil WHERE id = @id`);

    res.json({ sprava: 'Vozidlo bolo zmazané' });
  } catch (err) {
    res.status(500).json({
      error: 'Vozidlo sa nepodarilo zmazať. Pravdepodobne naň viažu ďalšie tabuľky.',
      detail: err.message
    });
  }
});

// =========================
// PREPIS VOZIDLA
// =========================

app.patch(['/api/vozidla/:id/prepis', '/api/vehicles/:id/transfer'], async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const novyMajitelId = parseInt(req.body.novyMajitelId || req.body.newMajitelId || req.body.newOwnerId, 10);
  const cena = req.body.cena !== undefined && req.body.cena !== null && req.body.cena !== ''
    ? parseFloat(req.body.cena)
    : null;

  if (!novyMajitelId) {
    return res.status(400).json({ error: 'novyMajitelId je povinný' });
  }

  const pool = await getPool();
  const transaction = new sql.Transaction(pool);

  try {
    await transaction.begin();

    const current = await new sql.Request(transaction)
      .input('id', sql.Int, id)
      .query(`
        SELECT id, majitel_id, stav
        FROM Automobil
        WHERE id = @id
      `);

    if (current.recordset.length === 0) {
      throw new Error('Vozidlo sa nenašlo');
    }

    const staryMajitelId = current.recordset[0].majitel_id;
    const aktualnyStav = current.recordset[0].stav;

    await new sql.Request(transaction)
      .input('id', sql.Int, id)
      .input('novyMajitelId', sql.Int, novyMajitelId)
      .query(`
        UPDATE Automobil
        SET majitel_id = @novyMajitelId
        WHERE id = @id
      `);

    await new sql.Request(transaction)
      .input('automobil_id', sql.Int, id)
      .input('stary_majitel_id', sql.Int, staryMajitelId)
      .input('novy_majitel_id', sql.Int, novyMajitelId)
      .query(`
        INSERT INTO HistoriaVlastnictva (automobil_id, stary_majitel_id, novy_majitel_id)
        VALUES (@automobil_id, @stary_majitel_id, @novy_majitel_id)
      `);

    if (cena !== null && !Number.isNaN(cena)) {
      await new sql.Request(transaction)
        .input('automobil_id', sql.Int, id)
        .input('stary_majitel_id', sql.Int, staryMajitelId)
        .input('novy_majitel_id', sql.Int, novyMajitelId)
        .input('cena', sql.Decimal(12, 2), cena)
        .query(`
          INSERT INTO Predaj (automobil_id, stary_majitel_id, novy_majitel_id, cena)
          VALUES (@automobil_id, @stary_majitel_id, @novy_majitel_id, @cena)
        `);

      await new sql.Request(transaction)
        .input('id', sql.Int, id)
        .query(`
          UPDATE Automobil
          SET stav = 'PREDANE'
          WHERE id = @id
        `);
    } else if (aktualnyStav === 'PREDANE') {
      await new sql.Request(transaction)
        .input('id', sql.Int, id)
        .query(`
          UPDATE Automobil
          SET stav = 'AKTIVNE'
          WHERE id = @id
        `);
    }

    await transaction.commit();

    res.json({ sprava: 'Prepis vozidla prebehol úspešne' });
  } catch (err) {
    try {
      await transaction.rollback();
    } catch (_) {}

    res.status(500).json({ error: err.message });
  }
});

// =========================
// HISTÓRIA A PREDAJ
// =========================

app.get(['/api/historia-vlastnictva', '/api/history'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        hv.id,
        hv.automobil_id,
        a.VIN,
        hv.stary_majitel_id,
        sm.meno AS stary_meno,
        sm.priezvisko AS stary_priezvisko,
        hv.novy_majitel_id,
        nm.meno AS novy_meno,
        nm.priezvisko AS novy_priezvisko,
        hv.datum_zmeny
      FROM HistoriaVlastnictva hv
      JOIN Automobil a ON hv.automobil_id = a.id
      LEFT JOIN Majitel sm ON hv.stary_majitel_id = sm.id
      LEFT JOIN Majitel nm ON hv.novy_majitel_id = nm.id
      ORDER BY hv.datum_zmeny DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/historia-vlastnictva/:autoId', '/api/history/:autoId'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('autoId', sql.Int, parseInt(req.params.autoId, 10))
      .query(`
        SELECT
          hv.id,
          hv.automobil_id,
          a.VIN,
          hv.stary_majitel_id,
          sm.meno AS stary_meno,
          sm.priezvisko AS stary_priezvisko,
          hv.novy_majitel_id,
          nm.meno AS novy_meno,
          nm.priezvisko AS novy_priezvisko,
          hv.datum_zmeny
        FROM HistoriaVlastnictva hv
        JOIN Automobil a ON hv.automobil_id = a.id
        LEFT JOIN Majitel sm ON hv.stary_majitel_id = sm.id
        LEFT JOIN Majitel nm ON hv.novy_majitel_id = nm.id
        WHERE hv.automobil_id = @autoId
        ORDER BY hv.datum_zmeny DESC
      `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/predaj', '/api/sales'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        p.id,
        p.automobil_id,
        a.VIN,
        p.stary_majitel_id,
        sm.meno AS stary_meno,
        sm.priezvisko AS stary_priezvisko,
        p.novy_majitel_id,
        nm.meno AS novy_meno,
        nm.priezvisko AS novy_priezvisko,
        p.datum_predaja,
        p.cena
      FROM Predaj p
      JOIN Automobil a ON p.automobil_id = a.id
      LEFT JOIN Majitel sm ON p.stary_majitel_id = sm.id
      LEFT JOIN Majitel nm ON p.novy_majitel_id = nm.id
      ORDER BY p.datum_predaja DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// ĎALŠIE TABUĽKY - len výpisy
// =========================

app.get(['/api/poistenie', '/api/insurances'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT *
      FROM Poistenie
      ORDER BY id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/servis', '/api/services'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT *
      FROM Servis
      ORDER BY datum DESC, id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/kontroly', '/api/inspections'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT *
      FROM Kontrola
      ORDER BY datum DESC, id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/uver', '/api/loans'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT *
      FROM Uver
      ORDER BY id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get(['/api/splatky', '/api/installments'], async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT *
      FROM Splatka
      ORDER BY datum_splatky DESC, id DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// =========================
// SPUSTENIE
// =========================

app.listen(PORT, () => {
  console.log(`Server beží na http://localhost:${PORT}`);
});