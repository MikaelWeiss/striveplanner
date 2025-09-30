import type { Post } from './types';

const postModules = import.meta.glob('/src/lib/blog-posts/*.md', { eager: true });

// Map of normalized slugs to actual file paths
const slugToPathMap: Record<string, string> = {};

// Initialize the mapping
for (const path in postModules) {
	const filename = path.split('/').pop() || '';
	const slug = filename.replace('.md', '');
	// Normalize slug by replacing spaces and special characters
	const normalizedSlug = slug.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
	slugToPathMap[normalizedSlug] = path;
}

export async function getAllPosts(): Promise<Post[]> {
	const posts: Post[] = [];
	
	for (const path in postModules) {
		const module = postModules[path] as any;
		const filename = path.split('/').pop() || '';
		const slug = filename.replace('.md', '');
		
		if (slug && module.metadata) {
			posts.push({
				slug: slug.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, ''),
				...module.metadata
			});
		}
	}
	
	return posts.sort((a, b) => new Date(b.published).getTime() - new Date(a.published).getTime());
}

export async function getPost(slug: string): Promise<Post | null> {
	const normalizedSlug = slug.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
	const modulePath = slugToPathMap[normalizedSlug];
	
	if (modulePath && postModules[modulePath]) {
		const module = postModules[modulePath] as any;
		return {
			slug: normalizedSlug,
			...module.metadata
		};
	}
	
	return null;
}

export async function getPostComponent(slug: string): Promise<any | null> {
	const normalizedSlug = slug.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
	const modulePath = slugToPathMap[normalizedSlug];

	if (!modulePath) {
		return null;
	}

	try {
		// Import the markdown component using the full path
		const filename = modulePath.split('/').pop() || '';
		// @ts-ignore
		const module = await import(/* @vite-ignore */ `./blog-posts/${filename}`);
		return module.default;
	} catch {
		return null;
	}
}