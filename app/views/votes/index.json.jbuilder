json.array!(@votes) do |vote|
  json.extract! vote, :id, :grand_parent_id, :parent_id, :prabowo_count, :jokowi_count
  json.url vote_url(vote, format: :json)
end
