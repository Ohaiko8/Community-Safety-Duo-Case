const express = require('express');
const { Pool } = require('pg');
const app = express();

// Set up PostgreSQL connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false
    }
});

// Define the port
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON bodies with increased limit
app.use(express.json({ limit: '50mb' })); // Increase the payload size limit here

// Home route for testing
app.get('/', (req, res) => {
    res.send('Hello World!');
});

// Route to add a new user
app.post('/users', async (req, res) => {
    console.log('Received request:', req.body);
    const { name, phone, trustedIds, profilePicture } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO users (name, phone, trusted_ids, profile_picture) VALUES ($1, $2, $3, $4) RETURNING *;',
            [name, phone, trustedIds, profilePicture]
        );
        console.log('Insert result:', result.rows[0]);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error on insert:', err);
        res.status(500).send('Server error');
    }
});

app.get('/users', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM users;');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error retrieving users:', err);
        res.status(500).send('Server error');
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
