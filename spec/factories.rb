FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@example.com"
  end

  factory :recipe do
    association :user, strategy: :create
    name "Chocolate Chip Cookies"
    cook_time "30 minutes"
    prep_time "20 minutes"
    description "it's a recipe. deal with it."
    notes "this recipe is awesome."
    servings 18
    current_step 2
    ingredients [{"name"=>"butter", "measurement"=>"1/2", "unit"=>"cup"}, {"name"=>"vanilla extract", "measurement"=>"1/2", "unit"=>"teaspoon"}, {"name"=>"chocolate chips", "measurement"=>"1", "unit"=>"cup"}, {"name"=>"salt", "measurement"=>"1/4", "unit"=>"teaspoon"}, {"name"=>"peanut butter", "measurement"=>"1/2", "unit"=>"cup"}, {"name"=>"egg", "measurement"=>"1"}]
    steps ["Preheat oven to 350 degrees F", "In a medium bowl, cream together the butter, white sugar and brown sugar until smooth.", "Stir in the peanut butter, vanilla and egg until well blended.", "Combine the flour, baking soda and salt; stir into the batter just until moistened.", "Mix in the oats and chocolate chips until evenly distributed.", "Drop by tablespoonfuls on to lightly greased cookie sheets.", "Bake for 10 to 12 minutes in the preheated oven, until the edges start to brown.", "Cool on cookie sheets for about 5 minutes before transferring to wire racks to cool completely."]
  end

  factory :user do
    name "Test Subject"
    email { generate(:email) }
    password "password"
    amazon_id "amazon_blahhh"
  end

end
