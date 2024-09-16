const express = require('express');
const promClient = require('prom-client');

const app = express();
const port = 3000;

// Create a default Registry and collect default metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

// Define a custom metric
const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'code']
});
register.registerMetric(httpRequestsTotal);

app.use((req, res, next) => {
  httpRequestsTotal.inc({ method: req.method, route: req.route ? req.route.path : '/', code: res.statusCode });
  next();
});

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.send(register.metrics());
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
