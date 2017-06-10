class BlogPostAnalyticsWorker
  def initialize(post)
    @post = post
  end

  def run
    BlogPostAnalytics.new(@post).run
  end
end
