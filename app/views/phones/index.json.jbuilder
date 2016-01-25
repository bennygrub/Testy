json.array!(@phones) do |phone|
  json.extract! phone, :id, :digits
  json.url phone_url(phone, format: :json)
end
