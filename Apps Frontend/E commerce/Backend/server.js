const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();
app.use(cors());
app.use(express.json());

const FAKESTORE_API = "https://fakestoreapi.com";

// ✅ Fetch all products
app.get("/api/products", async (req, res) => {
  try {
    const response = await axios.get(`${FAKESTORE_API}/products`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch products" });
  }
});

// ✅ Fetch product by ID
app.get("/api/products/:id", async (req, res) => {
  try {
    const response = await axios.get(`${FAKESTORE_API}/products/${req.params.id}`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch product details" });
  }
});

// ✅ Fetch categories
app.get("/api/categories", async (req, res) => {
  try {
    const response = await axios.get(`${FAKESTORE_API}/products/categories`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch categories" });
  }
});

// ✅ Fetch products by category
app.get("/api/category/:category", async (req, res) => {
  try {
    const response = await axios.get(`${FAKESTORE_API}/products/category/${req.params.category}`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch category products" });
  }
});

// ✅ User login using FakeStoreAPI
app.post("/api/login", async (req, res) => {
  try {
    const { username, password } = req.body;
    const response = await axios.post(`${FAKESTORE_API}/auth/login`, { username, password });
    res.json(response.data);
  } catch (error) {
    res.status(401).json({ error: "Invalid credentials" });
  }
});

// ✅ API Homepage
app.get("/", (req, res) => {
  res.send(`
    <h1>FakeStoreAPI Proxy</h1>
    <p>Use the following routes:</p>
    <ul>
      <li><a href="/api/products">/api/products</a> - Get all products</li>
      <li><a href="/api/products/1">/api/products/:id</a> - Get product by ID</li>
      <li><a href="/api/categories">/api/categories</a> - Get all categories</li>
      <li><a href="/api/category/electronics">/api/category/:category</a> - Get products by category</li>
      <li>POST <b>/api/login</b> - Authenticate user</li>
    </ul>
  `);
});

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
