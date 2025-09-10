<script lang="ts">
  import { error } from '@sveltejs/kit';
  
  // Sample blog posts data - in a real app this would come from a CMS or markdown files
  const blogPosts = {
    'getting-started-with-intentional-living': {
      title: 'Getting Started with Intentional Living',
      content: `
# Getting Started with Intentional Living

Living with intention is about making conscious choices that align with your values and goals. In a world full of distractions, it's more important than ever to be deliberate about how we spend our time and energy.

## What is Intentional Living?

Intentional living means:
- Making conscious decisions rather than reacting to circumstances
- Aligning your daily actions with your long-term vision
- Being mindful of how you spend your most valuable resources: time and attention
- Regularly reflecting on whether your activities serve your greater purpose

## Benefits of Living Intentionally

When you live with intention, you experience:
- Greater clarity and focus
- Reduced stress and anxiety
- Increased productivity and satisfaction
- Better decision-making
- Stronger sense of purpose

## Getting Started

1. **Define Your Values**: What matters most to you?
2. **Set Clear Goals**: What do you want to achieve?
3. **Create Daily Rituals**: How can you reinforce your intentions daily?
4. **Practice Mindfulness**: Stay present and aware
5. **Review and Adjust**: Regular reflection ensures you stay on track

Start small, be consistent, and remember that intentional living is a journey, not a destination.
      `,
      publishedAt: new Date('2024-01-15'),
      tags: ['productivity', 'intentionality', 'lifestyle']
    },
    'the-power-of-daily-reflection': {
      title: 'The Power of Daily Reflection',
      content: `
# The Power of Daily Reflection

Daily reflection is one of the most powerful habits you can develop for personal growth and productivity. Taking just a few minutes each day to review your experiences can transform your effectiveness and well-being.

## Why Daily Reflection Matters

Reflection helps you:
- Learn from your experiences
- Identify patterns in your behavior
- Make better decisions
- Stay aligned with your goals
- Practice gratitude and mindfulness

## How to Practice Daily Reflection

1. **Set a Regular Time**: Choose a consistent time each day
2. **Ask Key Questions**: What went well? What could be improved?
3. **Journal Your Thoughts**: Writing reinforces learning
4. **Plan for Tomorrow**: Apply insights to future actions
5. **Be Honest with Yourself**: Authenticity is crucial

## Questions to Guide Your Reflection

- What am I grateful for today?
- What did I accomplish?
- What challenges did I face?
- What did I learn?
- How can I improve tomorrow?

## Making It a Habit

Start with just 5 minutes a day. Use prompts if you get stuck, and don't worry about perfection. The goal is progress, not perfection.

Over time, you'll develop greater self-awareness and make more intentional choices in all areas of your life.
      `,
      publishedAt: new Date('2024-01-10'),
      tags: ['reflection', 'productivity', 'mindfulness']
    }
  };

  export let slug: string;

  // Find the blog post
  const post = blogPosts[slug as keyof typeof blogPosts];

  // If post not found, return 404
  if (!post) {
    error(404, 'Post not found');
  }

  function formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  }
</script>

<svelte:head>
  <title>{post.title} - Strive Planner</title>
  <meta name="description" content={post.content.substring(0, 160) + '...'} />
</svelte:head>

<article class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
  <!-- Header -->
  <header class="mb-12">
    <h1 class="text-4xl font-normal text-white mb-4">{post.title}</h1>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <time class="text-gray-400">{formatDate(post.publishedAt)}</time>
      <div class="flex flex-wrap gap-2">
        {#each post.tags as tag}
          <span class="px-3 py-1 text-xs bg-[#40e0d0]/20 text-[#40e0d0] rounded-full">
            {tag}
          </span>
        {/each}
      </div>
    </div>
  </header>

  <!-- Content -->
  <div class="prose prose-invert prose-lg max-w-none">
    {@html post.content}
  </div>

  <!-- Back to Blog -->
  <div class="mt-16 pt-8 border-t border-gray-800">
    <a href="/blog" class="inline-flex items-center text-[#40e0d0] hover:text-[#3bd89d] transition-colors">
      <svg class="mr-2 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
      </svg>
      Back to Blog
    </a>
  </div>
</article>