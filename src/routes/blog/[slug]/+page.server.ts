import { error } from '@sveltejs/kit';
import { getPost } from '$lib/blog/utils';

export async function load({ params }) {
	const { slug } = params;
	
	const post = await getPost(slug);
	
	if (!post) {
		error(404, 'Post not found');
	}
	
	return {
		post
	};
}