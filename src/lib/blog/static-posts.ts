import type { Post } from '$lib/blog/types';

// This file contains static post data for now
// In production, this would be replaced with dynamic imports

export const posts: Post[] = [
	{
		slug: 'where-there-is-no-vision-the-people-perish',
		title: 'Where there is no vision, the people perish',
		published: '2025-09-02',
		tags: ['vision', 'intention'],
		excerpt: 'Understanding the power of vision in achieving your goals and why it matters more than just setting tasks.'
	},
	{
		slug: 'why-did-i-build-strive',
		title: 'Why did I build Strive?',
		published: '2025-09-09',
		tags: ['vision', 'intention'],
		excerpt: 'Have you ever felt like you\'re just going through the motions? This is why I built Strive Planner.'
	}
];

export async function getAllPosts(): Promise<Post[]> {
	return posts;
}

export async function getPost(slug: string): Promise<Post | null> {
	return posts.find(post => post.slug === slug) || null;
}