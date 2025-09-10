import { json } from '@sveltejs/kit';
import { Resend } from 'resend';

const resend = new Resend(import.meta.env.VITE_RESEND_API_KEY);

export async function POST({ request }) {
  try {
    const data = await request.formData();
    
    // Extract form data
    const name = data.get('name');
    const email = data.get('email');
    const subject = data.get('subject');
    const message = data.get('message');
    
    // Basic validation
    if (!name || !email || !subject || !message) {
      return json(
        { error: 'All fields are required' },
        { status: 400 }
      );
    }
    
    // Send email using Resend
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