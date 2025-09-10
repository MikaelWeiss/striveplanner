<script lang="ts">
  // Sample blog posts data - in a real app this would come from a CMS or markdown files
  const blogPosts = [
    {
      slug: 'getting-started-with-intentional-living',
      title: 'Getting Started with Intentional Living',
      excerpt: 'Learn how to live with more purpose and intention in your daily life.',
      publishedAt: new Date('2024-01-15'),
      tags: ['productivity', 'intentionality', 'lifestyle']
    },
    {
      slug: 'the-power-of-daily-reflection',
      title: 'The Power of Daily Reflection',
      excerpt: 'Discover how daily reflection can transform your productivity and well-being.',
      publishedAt: new Date('2024-01-10'),
      tags: ['reflection', 'productivity', 'mindfulness']
    },
    {
      slug: 'setting-goals-that-actually-matter',
      title: 'Setting Goals That Actually Matter',
      excerpt: 'A guide to setting meaningful goals that align with your values and vision.',
      publishedAt: new Date('2024-01-05'),
      tags: ['goals', 'planning', 'productivity']
    }
  ];

  function formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
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
  
  <!-- Blog Posts Grid -->
  <div class="space-y-12">
    {#each blogPosts as post (post.slug)}
      <a href="/blog/{post.slug}" class="block group">
        <article class="bg-white/5 backdrop-blur-lg rounded-lg p-8 hover:bg-white/10 transition-all duration-200 cursor-pointer group-hover:shadow-lg">
          <div class="flex flex-col md:flex-row md:items-start md:justify-between mb-4">
            <h2 class="text-2xl font-medium text-white mb-2 md:mb-0">
              {post.title}
            </h2>
            <time class="text-sm text-gray-400 md:ml-4 md:flex-shrink-0">
              {formatDate(post.publishedAt)}
            </time>
          </div>

          <p class="text-gray-300 mb-4 leading-relaxed">
            {post.excerpt}
          </p>

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
  {#if blogPosts.length === 0}
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