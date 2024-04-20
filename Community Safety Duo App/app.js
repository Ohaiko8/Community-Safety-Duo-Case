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
app.get('/users', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, name, phone, trusted_ids, profile_picture FROM users;');
        const users = result.rows.map(user => ({
            id: user.id,
            name: user.name,
            phone: user.phone,
            trustedIds: user.trusted_ids,
            profilePicture: user.profile_picture  // Ensure this matches your database column name
        }));
        res.status(200).json(users);
    } catch (err) {
        console.error('Error retrieving users:', err);
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

// Route to get a user by name and phone number
app.get('/users/find', async (req, res) => {
    const { name, phone } = req.query;
    try {
        const result = await pool.query(
            'SELECT * FROM users WHERE name = $1 AND phone = $2;',
            [name, phone]
        );
        if (result.rows.length > 0) {
            res.json(result.rows[0]);
        } else {
            res.status(404).send('User not found');
        }
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});

/// Assuming your server has methods to check for user existence and retrieve users
app.post('/users/updateTrustedContacts', async (req, res) => {
    const { targetUserId, newContactId } = req.body;

    try {
        // Fetch the target user
        const targetUser = await pool.query('SELECT * FROM users WHERE id = $1', [targetUserId]);

        if (targetUser.rows.length === 0) {
            return res.status(404).json({ message: "Target user not found." });
        }

        // Check if the newContactId is already in the trusted_ids
        if (targetUser.rows[0].trusted_ids.includes(newContactId)) {
            return res.status(400).json({ message: "Contact already in trusted list." });
        }

        // Update the trusted_ids
        const updatedTrustedIds = [...targetUser.rows[0].trusted_ids, newContactId];
        const updateResult = await pool.query(
            'UPDATE users SET trusted_ids = $1 WHERE id = $2 RETURNING *;',
            [updatedTrustedIds, targetUserId]
        );

        res.json(updateResult.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});

// Route to fetch the first user
app.get('/users/first', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM users ORDER BY id ASC LIMIT 1;');
        if (result.rows.length > 0) {
            res.json(result.rows[0]);
        } else {
            res.status(404).send('No users found');
        }
    } catch (err) {
        console.error('Error fetching first user:', err);
        res.status(500).send('Server error');
    }
});

// Server-side: Fetching trusted contacts for a user
app.get('/users/trusted', async (req, res) => {
    const { userId } = req.query;
    try {
        const result = await pool.query(
            'SELECT * FROM users WHERE $1 = ANY(trusted_ids);',
            [userId]
        );
        res.json(result.rows);
    } catch (err) {
        console.error('Error retrieving trusted contacts:', err);
        res.status(500).send('Server error');
    }
});



// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
