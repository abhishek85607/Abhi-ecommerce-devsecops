const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Bhai Abhishek, Ecommerce App is Running!'));
app.listen(3000, () => console.log('Listening on port 3000'));
