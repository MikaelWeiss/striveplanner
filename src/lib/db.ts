import { Pool } from 'pg';

// Only create pool if DATABASE_URL is available
const pool = process.env.DATABASE_URL ? new Pool({
	connectionString: process.env.DATABASE_URL,
	ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
}) : null;

export async function query(text: string, params?: any[]) {
	if (!pool) {
		throw new Error('Database not available. Set DATABASE_URL environment variable.');
	}
	
	const start = Date.now();
	try {
		const result = await pool.query(text, params);
		const duration = Date.now() - start;
		console.log('executed query', { text, duration, rows: result.rowCount });
		return result;
	} catch (error) {
		console.error('query error', { text, error });
		throw error;
	}
}

export async function createSubscribersTable() {
	const createTableQuery = `
		CREATE TABLE IF NOT EXISTS subscribers (
			id SERIAL PRIMARY KEY,
			email VARCHAR(255) UNIQUE NOT NULL,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
		);
	`;
	
	await query(createTableQuery);
}

export async function addSubscriber(email: string) {
	const insertQuery = `
		INSERT INTO subscribers (email)
		VALUES ($1)
		ON CONFLICT (email) DO NOTHING
		RETURNING id, email, created_at;
	`;
	
	const result = await query(insertQuery, [email]);
	return result.rows[0];
}

export async function isEmailSubscribed(email: string) {
	const selectQuery = `
		SELECT id FROM subscribers WHERE email = $1;
	`;
	
	const result = await query(selectQuery, [email]);
	return result.rows.length > 0;
}