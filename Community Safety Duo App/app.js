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
    const { name, phone, trusted_ids, profile_picture } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO users (name, phone, trusted_ids, profile_picture) VALUES ($1, $2, $3, $4) RETURNING *;',
            [name, phone, trusted_ids, profile_picture]
        );
        console.log('Insert result:', result.rows[0]);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error on insert:', err);
        res.status(500).send('Server error');
    }
});

// Route to add a new user
app.get('/users', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, name, phone, trusted_ids, profile_picture FROM users;');
        const users = result.rows.map(user => ({
            id: user.id,
            name: user.name,
            phone: user.phone,
            trusted_ids: user.trusted_ids,
            profile_picture: user.profile_picture  // Ensure this matches your database column name
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

// Fetch User by Name and Phone
app.get('/users/find', (req, res) => {
    // Log raw query to see how it's received
    console.log(req.originalUrl);  // This will show you the raw URL called.
    console.log(`Received name: ${req.query.name}, phone: ${req.query.phone}`);

    const name = req.query.name;
    const phone = req.query.phone.replace(' ', '+');  // Replace space with + if necessary

    pool.query('SELECT * FROM users WHERE name = $1 AND phone = $2', [name, phone], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send('Server error');
        }
        if (result.rows.length > 0) {
            res.json(result.rows[0]);
        } else {
            res.status(404).send('User not found');
        }
    });
});


// Update Trusted Contacts
app.post('/users/update-trusted', async (req, res) => {
    const { userId, newContactId } = req.body;
    
    try {
        // Transaction to ensure both updates succeed
        await pool.query('BEGIN');

        const addContact = async (userId, contactId) => {
            const user = await pool.query('SELECT trusted_ids FROM users WHERE id = $1', [userId]);
            let trustedIds = user.rows[0].trusted_ids || [];
            if (trustedIds.includes(contactId)) {
                throw new Error('Contact already in trusted list');
            }
            trustedIds.push(contactId);
            await pool.query('UPDATE users SET trusted_ids = $1 WHERE id = $2', [trustedIds, userId]);
        };

        await addContact(userId, newContactId);
        await addContact(newContactId, userId); // Ensure bidirectional trust
        
        await pool.query('COMMIT');
        res.send('Trusted contacts updated successfully');
    } catch (err) {
        await pool.query('ROLLBACK');
        console.error('Error on updating trusted contacts:', err);
        res.status(500).send(err.message);
    }
});

// Route to add a trusted contact
app.patch('/users/:userId/add-trusted', async (req, res) => {
    const { userId } = req.params;
    const { newContactId } = req.body;

    try {
        const user = await pool.query('SELECT trusted_ids FROM users WHERE id = $1', [userId]);
        if (user.rows.length === 0) {
            return res.status(404).json({ message: "User not found." });
        }

        if (user.rows[0].trusted_ids && user.rows[0].trusted_ids.includes(newContactId)) {
            return res.status(400).json({ message: "This contact is already in your trusted list." });
        }

        const updatedTrustedIds = user.rows[0].trusted_ids ? [...user.rows[0].trusted_ids, newContactId] : [newContactId];
        await pool.query('UPDATE users SET trusted_ids = $1 WHERE id = $2', [updatedTrustedIds, userId]);

        // Also add reciprocal trust
        const contact = await pool.query('SELECT trusted_ids FROM users WHERE id = $1', [newContactId]);
        const updatedContactTrustedIds = contact.rows[0].trusted_ids ? [...contact.rows[0].trusted_ids, parseInt(userId)] : [parseInt(userId)];
        await pool.query('UPDATE users SET trusted_ids = $1 WHERE id = $2', [updatedContactTrustedIds, newContactId]);

        res.json({ message: "Trusted contact added successfully." });
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

// Route to update the trusted contacts of a user
app.post('/users/updateTrustedContacts', async (req, res) => {
    const { userId, newContactId } = req.body;

    try {
        // Ensure the new contact is not the user themselves
        if (userId === newContactId) {
            return res.status(400).send('Cannot add oneself as a trusted contact.');
        }

        const userResult = await pool.query('SELECT trusted_ids FROM users WHERE id = $1', [userId]);
        if (userResult.rows.length === 0) {
            return res.status(404).send('User not found.');
        }

        let trustedIds = userResult.rows[0].trusted_ids || [];
        if (trustedIds.includes(newContactId)) {
            return res.status(400).send('This user is already in your trusted list.');
        }

        trustedIds.push(newContactId);
        await pool.query('UPDATE users SET trusted_ids = $1 WHERE id = $2', [trustedIds, userId]);

        // Optional: Update the new contact's trustedIds to include userId
        const contactResult = await pool.query('SELECT trusted_ids FROM users WHERE id = $1', [newContactId]);
        let contactTrustedIds = contactResult.rows[0].trusted_ids || [];
        if (!contactTrustedIds.includes(userId)) {
            contactTrustedIds.push(userId);
            await pool.query('UPDATE users SET trusted_ids = $1 WHERE id = $2', [contactTrustedIds, newContactId]);
        }

        res.send('Trusted contacts updated successfully.');
    } catch (err) {
        console.error('Error updating trusted contacts:', err);
        res.status(500).send('Server error');
    }
});

// Route to remove a trusted contact
app.patch('/users/:userId/remove-trusted', async (req, res) => {
    const { userId } = req.params;
    const { contactId } = req.body;

    try {
        const user = await pool.query(
            'SELECT trusted_ids FROM users WHERE id = $1', [userId]
        );
        const user2 = await pool.query(
            'SELECT trusted_ids FROM users WHERE id = $1', [contactId]
        );
        if (user.rows.length === 0) {
            return res.status(404).send('User not found');
        }

        let trustedIds = user.rows[0].trusted_ids.filter(id => id !== contactId);
        let trustedIds2 = user2.rows[0].trusted_ids.filter(id => id !== contactId);
        const update = await pool.query(
            'UPDATE users SET trusted_ids = $1 WHERE id = $2 RETURNING *',
            [trustedIds, userId]
        );
        const update2 = await pool.query(
            'UPDATE users SET trusted_ids = $1 WHERE id = $2 RETURNING *',
            [trustedIds2, contactId]
        );

        res.json(update.rows[0]);
        res.json(update2.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});


// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
