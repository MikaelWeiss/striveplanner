defmodule StrivePlannerWeb.NewsletterComponent do
  use Phoenix.Component

  def newsletter_signup(assigns) do
    ~H"""
    <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8" id="newsletter-signup">
      <h2 class="text-2xl font-medium text-white mb-4">Stay Updated</h2>
      <p class="text-gray-300 mb-6">
        Get the latest posts delivered straight to your inbox. No spam, unsubscribe anytime.
      </p>

      <form id="newsletter-form" class="flex flex-col sm:flex-row gap-4" phx-submit="subscribe">
        <input
          type="email"
          name="email"
          id="newsletter-email"
          placeholder="Enter your email"
          required
          class="flex-1 px-4 py-3 bg-white/10 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent"
        />
        <button
          type="submit"
          id="newsletter-submit"
          class="px-6 py-3 bg-[#40e0d0] text-black font-medium rounded-lg hover:bg-[#40e0d0]/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Subscribe
        </button>
      </form>

      <div id="newsletter-message" class="hidden mt-4 p-4 rounded-lg"></div>
    </div>

    <script>
      document.getElementById('newsletter-form').addEventListener('submit', async function(e) {
        e.preventDefault();

        const form = e.target;
        const emailInput = form.querySelector('#newsletter-email');
        const submitButton = form.querySelector('#newsletter-submit');
        const messageDiv = document.getElementById('newsletter-message');

        const email = emailInput.value;

        // Disable form
        submitButton.disabled = true;
        submitButton.textContent = 'Subscribing...';
        messageDiv.classList.add('hidden');

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
            messageDiv.className = 'mt-4 p-4 rounded-lg bg-green-500/20 text-green-300';
            messageDiv.textContent = data.message || 'Successfully subscribed!';
            messageDiv.classList.remove('hidden');
            emailInput.value = '';
          } else {
            messageDiv.className = 'mt-4 p-4 rounded-lg bg-red-500/20 text-red-300';
            messageDiv.textContent = data.error || 'Failed to subscribe';
            messageDiv.classList.remove('hidden');
          }
        } catch (error) {
          messageDiv.className = 'mt-4 p-4 rounded-lg bg-red-500/20 text-red-300';
          messageDiv.textContent = 'An error occurred. Please try again.';
          messageDiv.classList.remove('hidden');
        } finally {
          submitButton.disabled = false;
          submitButton.textContent = 'Subscribe';
        }
      });
    </script>
    """
  end
end
