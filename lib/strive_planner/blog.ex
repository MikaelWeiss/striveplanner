defmodule StrivePlanner.Blog do
  @moduledoc """
  Blog functionality for Strive Planner.
  Provides static blog post data and retrieval functions.
  """

  defmodule Post do
    @moduledoc """
    Blog post structure.
    """
    defstruct [:id, :title, :slug, :excerpt, :content, :published_at, :author, :tags]
  end

  @doc """
  Returns all blog posts as a list.
  """
  def posts do
    [
      %Post{
        id: 1,
        title: "How to Build Better Habits with Strive",
        slug: "how-to-build-better-habits-with-strive",
        excerpt:
          "Discover how Strive's intelligent planning helps you create lasting habits that stick.",
        content: """
        <p>Building better habits is one of the most powerful ways to transform your life. With Strive's intelligent planning system, you can create habits that actually stick.</p>

        <h2>Why Most Habits Fail</h2>
        <p>Traditional habit formation often fails because it doesn't account for your actual schedule and priorities. Strive changes this by integrating habit formation into your daily planning.</p>

        <h2>Strive's Approach to Habit Building</h2>
        <p>Our app uses intelligent scheduling to place your habits at optimal times in your day, ensuring they're more likely to become automatic behaviors.</p>

        <h2>Getting Started</h2>
        <p>Start small with one or two habits, and let Strive help you build momentum over time.</p>
        """,
        published_at: ~D[2024-09-01],
        author: "Strive Team",
        tags: ["habits", "productivity", "planning"]
      },
      %Post{
        id: 2,
        title: "The Science of Goal Achievement",
        slug: "the-science-of-goal-achievement",
        excerpt:
          "Learn about the psychological principles behind successful goal setting and how Strive incorporates them.",
        content: """
        <p>Goal achievement isn't just about hard work—it's about understanding the science behind motivation and behavior change.</p>

        <h2>The Psychology of Goals</h2>
        <p>Research shows that specific, measurable goals are more likely to be achieved than vague aspirations.</p>

        <h2>Breaking Down Big Goals</h2>
        <p>Strive helps you break large goals into manageable daily actions, making success more achievable.</p>

        <h2>Staying Motivated</h2>
        <p>Regular progress tracking and reflection keep you motivated and on track toward your goals.</p>
        """,
        published_at: ~D[2024-08-15],
        author: "Strive Team",
        tags: ["goals", "psychology", "motivation"]
      },
      %Post{
        id: 3,
        title: "Time Management in the Digital Age",
        slug: "time-management-in-the-digital-age",
        excerpt:
          "Navigate the challenges of digital distractions and learn to manage your time more effectively.",
        content: """
        <p>In our hyper-connected world, effective time management has never been more challenging—or more important.</p>

        <h2>The Digital Distraction Problem</h2>
        <p>Constant notifications and endless scrolling can derail even the best intentions.</p>

        <h2>Strive's Solution</h2>
        <p>Our app helps you create focused time blocks and minimize distractions during important work periods.</p>

        <h2>Practical Strategies</h2>
        <p>Learn techniques for batching similar tasks, setting boundaries, and maintaining focus in a distracted world.</p>
        """,
        published_at: ~D[2024-07-30],
        author: "Strive Team",
        tags: ["time-management", "focus", "productivity"]
      }
    ]
  end

  @doc """
  Returns all published blog posts, sorted by publication date (newest first).
  """
  def list_posts do
    posts()
    |> Enum.sort_by(& &1.published_at, {:desc, Date})
  end

  @doc """
  Returns a blog post by its slug, or nil if not found.
  """
  def get_post_by_slug(slug) do
    Enum.find(posts(), &(&1.slug == slug))
  end

  @doc """
  Returns recent blog posts (limited by count).
  """
  def recent_posts(limit \\ 5) do
    posts()
    |> Enum.sort_by(& &1.published_at, {:desc, Date})
    |> Enum.take(limit)
  end
end
