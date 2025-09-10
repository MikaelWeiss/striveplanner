<script lang="ts">
	import { getAllPosts } from '$lib/blog/static-posts';
	import type { Post } from '$lib/blog/types';
	import { onMount } from 'svelte';

	let posts: Post[] = [];
	let loading = true;
let email = '';
let formLoading = false;
let message: { type: 'success' | 'error'; text: string } | null = null;

	onMount(async () => {
		posts = await getAllPosts();
		loading = false;
	});

	function formatDate(dateString: string): string {
		return new Date(dateString).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'long',
			'day': 'numeric'
		});
	}

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

<svelte:head>
  <title>Blog - Strive Planner</title>
  <meta name="description" content="Insights and tips on productivity, goal setting, and living with intention." />
</svelte:head>

<div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
  <!-- Header -->
  <div class="text-center mb-16">
    <h1 class="text-4xl font-normal text-white mb-4">Blog</h1>
    <p class="text-lg text-gray-300 max-w-2xl mx-auto">
      Insights and tips on productivity, goal setting, and living with intention.
    </p>
  </div>
  
  <!-- Newsletter Signup -->
  <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8 mb-16">
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
  
  <!-- Loading State -->
  {#if loading}
    <div class="text-center py-16">
      <div class="text-gray-400 mb-4">
        <svg class="mx-auto h-12 w-12 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
      </div>
      <h3 class="text-lg font-medium text-white mb-2">Loading posts...</h3>
    </div>
  <!-- Blog Posts Grid -->
  {:else if posts.length > 0}
    <div class="space-y-12">
      {#each posts as post (post.slug)}
        <a href="/blog/{post.slug}" class="block group">
          <article class="bg-white/5 backdrop-blur-lg rounded-lg p-8 hover:bg-white/10 transition-all duration-200 cursor-pointer group-hover:shadow-lg">
            <div class="flex flex-col md:flex-row md:items-start md:justify-between mb-4">
              <h2 class="text-2xl font-medium text-white mb-2 md:mb-0">
                {post.title}
              </h2>
              <time class="text-sm text-gray-400 md:ml-4 md:flex-shrink-0">
                {formatDate(post.published)}
              </time>
            </div>

            {#if post.excerpt}
              <p class="text-gray-300 mb-4 leading-relaxed">
                {post.excerpt}
              </p>
            {/if}

            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
              <div class="flex flex-wrap gap-2 mb-4 sm:mb-0">
                {#each post.tags as tag}
                  <span class="px-3 py-1 text-xs bg-[#40e0d0]/20 text-[#40e0d0] rounded-full">
                    {tag}
                  </span>
                {/each}
              </div>

              <div class="inline-flex items-center text-[#40e0d0] transition-colors font-medium">
                Read More
                <svg
                  class="ml-2 w-4 h-4 transition-transform group-hover:translate-x-1"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </div>
            </div>
          </article>
        </a>
      {/each}
    </div>
  <!-- Empty State (if no posts) -->
  {:else}
    <div class="text-center py-16">
      <div class="text-gray-400 mb-4">
        <svg class="mx-auto h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
          />
        </svg>
      </div>
      <h3 class="text-lg font-medium text-white mb-2">No blog posts yet</h3>
      <p class="text-gray-400">Check back soon for new content!</p>
    </div>
  {/if}
</div>