<script lang="ts">
	import { error } from '@sveltejs/kit';
	import type { Post } from '$lib/blog/types';
	import NewsletterSignup from '$lib/NewsletterSignup.svelte';

	export let data: {
		post: Post;
	};

	// Import the markdown component dynamically
	let component: any;
	
	$: {
		if (data.post) {
			import(`$lib/blog-posts/${data.post.slug}.md`).then(mod => {
				component = mod.default;
			}).catch(() => {
				// Fallback: try to find the component using utils
				import('$lib/blog/utils').then(utils => {
					utils.getPostComponent(data.post.slug).then(comp => {
						component = comp;
					});
				});
			});
		}
	}

	function formatDate(dateString: string): string {
		return new Date(dateString).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'long',
			'day': 'numeric'
		});
	}
</script>

<svelte:head>
	<title>{data.post.title} - Strive Planner</title>
	<meta name="description" content={data.post.excerpt || 'Blog post from Strive Planner'} />
</svelte:head>

<article class="mx-auto max-w-4xl px-4 py-24 sm:px-6 lg:px-8">
	<!-- Back to Blog -->
	<div class="mb-8">
		<a
			href="/blog"
			class="inline-flex items-center text-[#40e0d0] transition-colors hover:text-[#3bd89d]"
		>
			<svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
			</svg>
			Back to Blog
		</a>
	</div>

	<!-- Header -->
	<header class="mb-12">
		<h1 class="mb-4 text-4xl font-normal text-white">{data.post.title}</h1>
		<div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
			<time class="text-gray-400">{formatDate(data.post.published)}</time>
			<div class="flex flex-wrap gap-2">
				{#each data.post.tags as tag}
					<span class="rounded-full bg-[#40e0d0]/20 px-3 py-1 text-xs text-[#40e0d0]">
						{tag}
					</span>
				{/each}
			</div>
		</div>
	</header>

	<!-- Content -->
	<div class="prose prose-lg max-w-none prose-invert">
		{#if component}
			<svelte:component this={component} />
		{:else}
			<div class="text-center py-8">
				<div class="text-gray-400 mb-4">
					<svg class="mx-auto h-12 w-12 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
					</svg>
				</div>
				<p class="text-gray-400">Loading post...</p>
			</div>
		{/if}
	</div>

	<!-- Newsletter Signup -->
	<div class="mt-16">
		<NewsletterSignup />
	</div>

	<!-- Back to Blog -->
	<div class="mt-16 border-t border-gray-800 pt-8">
		<a
			href="/blog"
			class="inline-flex items-center text-[#40e0d0] transition-colors hover:text-[#3bd89d]"
		>
			<svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
			</svg>
			Back to Blog
		</a>
	</div>

	</article>
