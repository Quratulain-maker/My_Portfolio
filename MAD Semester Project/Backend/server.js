const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Load static hall data
const halls = require('./data/halls.json');

// API route
app.get('/api/halls', (req, res) => {
  res.json(halls);
});

// Start server
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
});
