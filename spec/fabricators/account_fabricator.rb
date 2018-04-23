Fabricator(:account) do
  type 'ActivityMon::Trainer'
  username { sequence(:username) { |i| "#{Faker::Internet.user_name(nil, %w(_))}#{i}" } }
  last_webfingered_at { Time.now.utc }
end
