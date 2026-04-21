# Car Registration Information System

This project is an information system for car registration (Evidencia Automobilov).

## Structure

- `client/` - Frontend React application
- `server/` - Backend Node.js API server
- `database/` - Database files (EvidenciaAut.sql for MSSQL)

## Features

- Register vehicles with details
- Register owners
- Add new vehicle
- Remove vehicle
- Transfer vehicle between owners
- Display registered vehicles
- Search vehicle by owner and by VIN
- Add and delete vehicle in evidence
- Register and delete owner

## Setup

1. Add your MSSQL database file to `database/EvidenciaAut.sql`
2. Update `server/.env` with your database credentials
3. Run the server: `cd server && npm start`
4. Run the client: `cd client && npm run dev`

## API Endpoints

- GET /api/vehicles - List all vehicles
- GET /api/vehicles/search?owner=...&vin=... - Search vehicles
- POST /api/vehicles - Add vehicle
- DELETE /api/vehicles/:id - Delete vehicle
- PUT /api/vehicles/:id/transfer - Transfer vehicle
- GET /api/owners - List owners
- POST /api/owners - Add owner
- DELETE /api/owners/:id - Delete owner