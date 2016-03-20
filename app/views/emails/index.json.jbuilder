json.array!(@emails) do |email|
  json.extract! email, :id, :from, :body, :to
  json.url email_url(email, format: :json)
end
