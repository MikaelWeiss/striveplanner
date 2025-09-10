import { json } from '@sveltejs/kit';
import { Resend } from 'resend';

async function verifyRecaptcha(token: string): Promise<boolean> {
  const secretKey = import.meta.env.VITE_RECAPTCHA_SECRET_KEY;
  
  if (!secretKey) {
    console.error('reCAPTCHA secret key not configured');
    return false;
  }
  
  const response = await fetch('https://www.google.com/recaptcha/api/siteverify', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: `secret=${secretKey}&response=${token}`,
  });
  
  const result = await response.json();
  return result.success && result.score > 0.5;
}

export async function POST({ request }) {
  try {
    const data = await request.formData();
    
    // Extract form data
    const name = data.get('name');
    const email = data.get('email');
    const subject = data.get('subject');
    const message = data.get('message');
    const recaptchaToken = data.get('g-recaptcha-response');
    
    // Basic validation
    if (!name || !email || !subject || !message) {
      return json(
        { error: 'All fields are required' },
        { status: 400 }
      );
    }
    
    // reCAPTCHA validation
    if (!recaptchaToken) {
      return json(
        { error: 'reCAPTCHA verification failed' },
        { status: 400 }
      );
    }
    
    const isHuman = await verifyRecaptcha(recaptchaToken as string);
    if (!isHuman) {
      return json(
        { error: 'reCAPTCHA verification failed' },
        { status: 400 }
      );
    }
    
    // Send email using Resend
    const resend = new Resend(import.meta.env.VITE_RESEND_API_KEY);
    const { data: emailData, error } = await resend.emails.send({
      from: 'Strive Planner Contact <onboarding@resend.dev>',
      to: 'support@striveplanner.org',
      reply_to: email as string,
      subject: `Contact Form: ${subject}`,
      html: `
        <h2>New Contact Form Submission</h2>
        <p><strong>Name:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Subject:</strong> ${subject}</p>
        <h3>Message:</h3>
        <p>${message}</p>
      `
    });
    
    if (error) {
      console.error('Resend error:', error);
      return json(
        { error: 'Failed to send message' },
        { status: 500 }
      );
    }
    
    console.log('Email sent successfully:', emailData);
    
    return json(
      { success: true, message: 'Message received successfully' },
      { status: 200 }
    );
    
  } catch (error) {
    console.error('Contact form error:', error);
    return json(
      { error: 'Failed to process contact form' },
      { status: 500 }
    );
  }
}