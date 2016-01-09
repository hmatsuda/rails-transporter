json.array!(@blogs) do |blog|
  json.extract! blog, :id, :title
  json.url blog_url(blog, format: :json)
end
