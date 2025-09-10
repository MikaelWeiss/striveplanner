<script lang="ts">
  let name = $state('');
  let email = $state('');
  let subject = $state('');
  let message = $state('');
  let isSubmitting = $state(false);
  let formMessage = $state<{ type: 'success' | 'error'; text: string } | null>(null);

  async function submitForm() {
    isSubmitting = true;
    formMessage = null;

    try {
      // Here you would implement reCAPTCHA and form submission
      // For now, just show a success message
      await new Promise(resolve => setTimeout(resolve, 1000));
      formMessage = { type: 'success', text: 'Thank you for your message! We\'ll get back to you soon.' };
      
      // Reset form
      name = '';
      email = '';
      subject = '';
      message = '';
    } catch (error) {
      formMessage = { type: 'error', text: 'Sorry, there was an error sending your message. Please try again.' };
    } finally {
      isSubmitting = false;
    }
  }
</script>

<svelte:head>
  <title>Contact Us - Strive Planner</title>
  <meta name="description" content="Get in touch with the Strive Planner team. We'd love to hear from you!" />
</svelte:head>

<div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
  <div class="text-center mb-16">
    <h1 class="text-4xl font-normal text-white mb-4">Contact Us</h1>
    <p class="text-lg text-gray-300">We'd love to hear from you. Send us a message and we'll respond as soon as possible.</p>
  </div>

  {#if formMessage}
    <div class="mb-8 p-4 rounded-lg {formMessage.type === 'success' ? 'bg-green-500/20 text-green-300' : 'bg-red-500/20 text-red-300'}">
      {formMessage.text}
    </div>
  {/if}

  <div class="grid md:grid-cols-2 gap-12">
    <!-- Contact Form -->
    <div class="bg-white backdrop-blur-lg rounded-lg p-8">
      <form on:submit|preventDefault={submitForm} class="text-gray-300" id="contact-form">
        <div class="mb-4">
          <label for="name" class="block text-sm font-medium text-white mb-2">Name *</label>
          <input 
            type="text" 
            id="name" 
            name="name" 
            bind:value={name}
            required 
            class="w-full px-3 py-2 bg-white/5 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-[#40e0d0]"
          />
        </div>
        
        <div class="mb-4">
          <label for="email" class="block text-sm font-medium text-white mb-2">Email *</label>
          <input 
            type="email" 
            id="email" 
            name="email" 
            bind:value={email}
            required 
            class="w-full px-3 py-2 bg-white/5 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-[#40e0d0]"
          />
        </div>
        
        <div class="mb-4">
          <label for="subject" class="block text-sm font-medium text-white mb-2">Subject *</label>
          <input 
            type="text" 
            id="subject" 
            name="subject" 
            bind:value={subject}
            required 
            class="w-full px-3 py-2 bg-white/5 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-[#40e0d0]"
          />
        </div>
        
        <div class="mb-6">
          <label for="message" class="block text-sm font-medium text-white mb-2">Message *</label>
          <textarea 
            id="message" 
            name="message" 
            bind:value={message}
            required 
            rows="5"
            class="w-full px-3 py-2 bg-white/5 text-white border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-[#40e0d0]"
          ></textarea>
        </div>
        
        <input type="hidden" name="g-recaptcha-response" id="g-recaptcha-response" />
        
        <button 
          type="submit" 
          disabled={isSubmitting}
          class="w-full bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 hover:opacity-90 disabled:opacity-50 disabled:cursor-not-allowed font-medium py-2 px-4 rounded-md transition-colors"
        >
          {isSubmitting ? 'Sending...' : 'Send Message'}
        </button>
      </form>
    </div>
    
    <!-- Contact Information -->
    <div class="space-y-8">
      <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
        <h3 class="text-lg font-medium mb-4 text-[#40e0d0]">Get in Touch</h3>
        <div class="space-y-4 text-gray-300">
          <p>
            <strong class="block text-white">Email:</strong>
            <a href="mailto:support@striveplanner.org" class="hover:text-[#40e0d0]">support@striveplanner.org</a>
          </p>
          <p>
            <strong class="block text-white">Response Time:</strong>
            Typically within 24 hours
          </p>
        </div>
      </div>

      <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
        <h3 class="text-lg font-medium mb-4 text-[#40e0d0]">Follow Us</h3>
        <div class="flex space-x-4">
          <a href="#" class="text-gray-300 hover:text-[#40e0d0]">X</a>
          <a href="#" class="text-gray-300 hover:text-[#40e0d0]">Facebook</a>
          <a href="#" class="text-gray-300 hover:text-[#40e0d0]">GitHub</a>
          <a href="#" class="text-gray-300 hover:text-[#40e0d0]">YouTube</a>
        </div>
      </div>
    </div>
  </div>
</div>