<script lang="ts">
	let email = '';
	let formLoading = false;
	let message: { type: 'success' | 'error'; text: string } | null = null;

	async function subscribe() {
		if (!email || formLoading) return;
		
		formLoading = true;
		message = null;
		
		try {
			const response = await fetch('/api/newsletter/subscribe', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ email }),
			});
			
			const data = await response.json();
			
			if (response.ok) {
				message = { type: 'success', text: data.message || 'Successfully subscribed!' };
				email = '';
			} else {
				message = { type: 'error', text: data.error || 'Failed to subscribe' };
			}
		} catch (error) {
			message = { type: 'error', text: 'An error occurred. Please try again.' };
		} finally {
			formLoading = false;
		}
	}
</script>

<div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
  <h2 class="text-2xl font-medium text-white mb-4">Stay Updated</h2>
  <p class="text-gray-300 mb-6">
    Get the latest posts delivered straight to your inbox. No spam, unsubscribe anytime.
  </p>
  
  <form on:submit|preventDefault={subscribe} class="flex flex-col sm:flex-row gap-4">
    <input
      type="email"
      bind:value={email}
      placeholder="Enter your email"
      required
      class="flex-1 px-4 py-3 bg-white/10 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent"
    />
    <button
      type="submit"
      disabled={formLoading || !email}
      class="px-6 py-3 bg-[#40e0d0] text-black font-medium rounded-lg hover:bg-[#40e0d0]/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
    >
      {formLoading ? 'Subscribing...' : 'Subscribe'}
    </button>
  </form>
  
  {#if message}
    <div class="mt-4 p-4 rounded-lg {message.type === 'success' ? 'bg-green-500/20 text-green-300' : 'bg-red-500/20 text-red-300'}">
      {message.text}
    </div>
  {/if}
</div>