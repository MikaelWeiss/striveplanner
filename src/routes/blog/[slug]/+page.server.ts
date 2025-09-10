import { error } from '@sveltejs/kit';

// Map of slugs to markdown files
const slugToPost = {
	'where-there-is-no-vision-the-people-perish': {
		title: 'Where there is no vision, the people perish',
		published: '2025-09-02',
		tags: ['vision', 'intention'],
		excerpt: 'Understanding the power of vision in achieving your goals and why it matters more than just setting tasks.',
		file: 'where-there-is-no-vision-the-people-perish.md'
	},
	'why-did-i-build-strive': {
		title: 'Why did I build Strive?',
		published: '2025-09-09',
		tags: ['vision', 'intention'],
		excerpt: 'Have you ever felt like you\'re just going through the motions? This is why I built Strive Planner.',
		file: 'why-did-i-build-strive.md'
	}
};

export async function load({ params }) {
	const { slug } = params;
	
	const post = slugToPost[slug as keyof typeof slugToPost];
	
	if (!post) {
		error(404, 'Post not found');
	}
	
	return {
		post: {
			slug,
			...post
		}
	};
}