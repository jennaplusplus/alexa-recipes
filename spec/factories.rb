FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@example.com"
  end

  factory :recipe do
    association :user, strategy: :create
    name "Chocolate Chip Cookies"
    cook_time "30 minutes"
    current_step 2
    ingredients [{"name"=>"butter", "measurement"=>"1/2", "unit"=>"cup"}, {"name"=>"vanilla extract", "measurement"=>"1/2", "unit"=>"teaspoon"}, {"name"=>"chocolate chips", "measurement"=>"1", "unit"=>"cup"}, {"name"=>"salt", "measurement"=>"1/4", "unit"=>"teaspoon"}, {"name"=>"peanut butter", "measurement"=>"1/2", "unit"=>"cup"}, {"name"=>"egg", "measurement"=>"1"}]
  end

  factory :user do
    name "Test Subject"
    email { generate(:email) }
    password "password"
  end

end
