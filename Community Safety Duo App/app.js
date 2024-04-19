const express = require('express');
const { Pool } = require('pg');
const app = express();

app.use(express.json()); // Middleware to parse JSON bodies

// Set up PostgreSQL connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false
    }
});

// Define the port
const PORT = process.env.PORT || 3000;

// Home route for testing
app.get('/', (req, res) => {
    res.send('Hello World!');
});

// Route to add a new user
app.post('/users', async (req, res) => {
    const { name, phone, trustedIds, profilePicture } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO users (name, phone, trusted_ids, profile_picture) VALUES ($1, $2, $3, $4) RETURNING *;',
            [name, phone, trustedIds, profilePicture]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

