import type { Handle } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';

export const handle: Handle = async ({ event, resolve }) => {
	// Make environment variables available to the client
	event.locals.recaptchaSiteKey = env.VITE_RECAPTCHA_SITE_KEY;
	
	const response = await resolve(event);
	
	// Add Content Security Policy headers to allow reCAPTCHA
	response.headers.set(
		'Content-Security-Policy',
		[
			"default-src 'self'",
			"script-src 'self' 'unsafe-inline' https://www.google.com https://www.gstatic.com",
			"frame-src 'self' https://www.google.com https://recaptcha.google.com",
			"connect-src 'self' https://www.google.com https://www.gstatic.com",
			"img-src 'self' data: https:",
			"style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
			"font-src 'self' https://fonts.gstatic.com"
		].join('; ')
	);
	
	return response;
};