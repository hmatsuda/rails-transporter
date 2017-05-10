class BlogPostAnalytics
  def initialize(post)
    @post = post
  end

  def run
    AnalyticsService.register_pageview(@post.url)
  end
end
