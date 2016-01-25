json.array!(@bells) do |bell|
  json.extract! bell, :id, :user_id, :name, :description
  json.url bell_url(bell, format: :json)
end
