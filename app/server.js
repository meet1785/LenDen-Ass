/**
 * LenDen DevSecOps Demo Application
 * A simple Node.js/Express web server for demonstrating
 * containerization, CI/CD pipelines, and cloud deployment
 */

const express = require('express');
const os = require('os');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Main route - serves the landing page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Health check endpoint for load balancers and monitoring
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        hostname: os.hostname(),
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// API endpoint returning server information
app.get('/api/info', (req, res) => {
    res.json({
        application: 'LenDen DevSecOps Demo',
        version: '1.0.0',
        environment: ENVIRONMENT,
        hostname: os.hostname(),
        platform: os.platform(),
        nodeVersion: process.version,
        memory: {
            total: Math.round(os.totalmem() / 1024 / 1024) + ' MB',
            free: Math.round(os.freemem() / 1024 / 1024) + ' MB'
        }
    });
});

// API endpoint for deployment verification
app.get('/api/deployment', (req, res) => {
    res.json({
        deployed: true,
        deployedAt: new Date().toISOString(),
        infrastructure: 'AWS EC2',
        pipeline: 'Jenkins CI/CD',
        securityScan: 'Trivy'
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║   🚀 LenDen DevSecOps Application                    ║
    ║                                                       ║
    ║   Server running on: http://0.0.0.0:${PORT}             ║
    ║   Environment: ${ENVIRONMENT.padEnd(16)}                    ║
    ║   Hostname: ${os.hostname().substring(0, 20).padEnd(20)}               ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝
    `);
});

module.exports = app;
