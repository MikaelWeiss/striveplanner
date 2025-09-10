import { json, type RequestHandler } from '@sveltejs/kit';
import { addSubscriber, isEmailSubscribed } from '$lib/db';

// Simple in-memory rate limiting
const rateLimit = new Map<string, { count: number; lastRequest: number }>();

function isValidEmail(email: string): boolean {
	const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	return emailRegex.test(email);
}

function isRateLimited(clientIP: string): boolean {
	const now = Date.now();
	const windowMs = 60 * 1000; // 1 minute
	const maxRequests = 5; // 5 requests per minute

	const record = rateLimit.get(clientIP);
	
	if (!record) {
		rateLimit.set(clientIP, { count: 1, lastRequest: now });
		return false;
	}

	if (now - record.lastRequest > windowMs) {
		// Reset window
		rateLimit.set(clientIP, { count: 1, lastRequest: now });
		return false;
	}

	if (record.count >= maxRequests) {
		return true;
	}

	record.count++;
	record.lastRequest = now;
	return false;
}

export const POST: RequestHandler = async ({ request }) => {
	try {
		// Check if database is available
		if (!process.env.DATABASE_URL) {
			return json(
				{ error: 'Newsletter service is currently unavailable.' },
				{ status: 503 }
			);
		}
		
		const clientIP = request.headers.get('x-forwarded-for') || 'unknown';
		
		// Rate limiting
		if (isRateLimited(clientIP)) {
			return json(
				{ error: 'Too many requests. Please try again later.' },
				{ status: 429 }
			);
		}

		const body = await request.json();
		const { email } = body;

		// Validate email
		if (!email || !isValidEmail(email)) {
			return json(
				{ error: 'Please provide a valid email address.' },
				{ status: 400 }
			);
		}

		// Check if already subscribed
		const alreadySubscribed = await isEmailSubscribed(email);
		if (alreadySubscribed) {
			return json(
				{ message: 'You are already subscribed to the newsletter.' },
				{ status: 200 }
			);
		}

		// Add subscriber to database
		const subscriber = await addSubscriber(email);
		
		if (subscriber) {
			return json(
				{ message: 'Successfully subscribed to the newsletter!' },
				{ status: 200 }
			);
		} else {
			return json(
				{ error: 'Failed to subscribe. Please try again.' },
				{ status: 500 }
			);
		}
	} catch (error) {
		console.error('Newsletter subscription error:', error);
		return json(
			{ error: 'An unexpected error occurred. Please try again.' },
			{ status: 500 }
		);
	}
};